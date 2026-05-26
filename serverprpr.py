from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from datetime import datetime, timedelta
import math
import requests
from fastapi.middleware.cors import CORSMiddleware
import os

# ==========================================
# 1. 데이터베이스 연결 설정
# ==========================================
DB_URL = os.environ.get("DB_URL", "mysql+pymysql://nsl02:nsl02@codingmaker.net:33068/nsl02")
engine = create_engine(DB_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

SERVICE_KEY = os.environ.get("SERVICE_KEY", "915af7fc2df351dc8affe3e7ac89d734e0aba754d1e161d2685ddad45267f5fc")

app = FastAPI(title="Now App - 지능형 활동 추천 시스템")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ==========================================
# 2. Pydantic 모델 검증
# ==========================================
class UserSetup(BaseModel):
    user_id: str
    password: str
    name: str
    email: str
    preferred_type: str     # mbti 대신 추가: "온라인", "오프라인", "BOTH" 중 하나
    current_goal: str       # 초기 가입 목적 (예: "자기계발", "번아웃")

class RecommendRequest(BaseModel):
    user_id: str
    condition: str      # "좋음", "보통", "나쁨"
    latitude: float
    longitude: float

class FeedbackRequest(BaseModel):
    user_id: str
    recommendation_id: int
    activity_id: int
    is_liked: bool          # True(수락), False(거절)
    satisfaction_score: int # 1~5점 (거절 시 0점 전송 가능)

class ManualSelectRequest(BaseModel):
    user_id: str
    activity_id: int
    weather: str
    condition: str

# 메모리 거절 횟수 카운터
user_dislike_count = {}

# ==========================================
# 3. 유틸리티 함수 (좌표 및 기상청)
# ==========================================
def grid(v1, v2):
    RE, GRID, SLAT1, SLAT2, OLON, OLAT, XO, YO = 6371.00877, 5.0, 30.0, 60.0, 126.0, 38.0, 43, 136
    DEGRAD = math.pi / 180.0
    re, slat1, slat2, olon, olat = RE / GRID, SLAT1 * DEGRAD, SLAT2 * DEGRAD, OLON * DEGRAD, OLAT * DEGRAD
    sn = math.log(math.cos(slat1) / math.cos(slat2)) / math.log(math.tan(math.pi * 0.25 + slat2 * 0.5) / math.tan(math.pi * 0.25 + slat1 * 0.5))
    sf = math.pow(math.tan(math.pi * 0.25 + slat1 * 0.5), sn) * math.cos(slat1) / sn
    ro = re * sf / math.pow(math.tan(math.pi * 0.25 + olat * 0.5), sn)
    ra = re * sf / math.pow(math.tan(math.pi * 0.25 + v1 * DEGRAD * 0.5), sn)
    theta = v2 * DEGRAD - olon
    if theta > math.pi: theta -= 2.0 * math.pi
    if theta < -math.pi: theta += 2.0 * math.pi
    theta *= sn
    return int(math.floor(ra * math.sin(theta) + XO + 0.5)), int(math.floor(ro - ra * math.cos(theta) + YO + 0.5))

def get_weather(nx, ny):
    url = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
    now = datetime.now()
    if now.minute < 45: now -= timedelta(hours=1)
    params = {'serviceKey': SERVICE_KEY, 'numOfRows': '50', 'dataType': 'JSON', 'base_date': now.strftime('%Y%m%d'), 'base_time': now.strftime('%H30'), 'nx': str(nx), 'ny': str(ny)}
    try:
        data = requests.get(url, params=params).json()
        items = data['response']['body']['items']['item']
        sky = next(i['fcstValue'] for i in items if i['category'] == 'SKY')
        pty = next(i['fcstValue'] for i in items if i['category'] == 'PTY')
        if pty != "0": return "비/눈"
        return "맑음" if sky == "1" else "흐림"
    except: return "맑음"

# ==========================================
# 4. API 엔드포인트
# ==========================================

@app.post("/users/setup")
def setup_user(user: UserSetup, db: Session = Depends(get_db)):
    """1. 초기설정: 기본 정보 및 목적(Goal) 저장"""
    # 1. user 테이블 (mbti 컬럼 대신 preferred_type 컬럼으로 쿼리 변경)
    db.execute(text("INSERT INTO user (user_id, password, name, email, preferred_type) VALUES (:id, :pw, :name, :email, :pref)"),
               {"id": user.user_id, "pw": user.password, "name": user.name, "email": user.email, "pref": user.preferred_type})
    
    # 2. usergoal 테이블 (변경 없음)
    db.execute(text("INSERT INTO usergoal (user_id, current_goal) VALUES (:id, :goal)"),
               {"id": user.user_id, "goal": user.current_goal})
    db.commit()
    return {"message": "가입 및 초기 설정 완료"}

@app.post("/recommend/")
def get_recommendation(req: RecommendRequest, db: Session = Depends(get_db)):
    """2. 맞춤 활동 추천 핵심 로직"""
    
    # [1] 거절 횟수 체크 (3회 이상 시 프론트엔드로 플래그 전달)
    if user_dislike_count.get(req.user_id, 0) >= 3:
        user_dislike_count[req.user_id] = 0 # 카운트 리셋
        return {"action": "manual_selection", "message": "거절 3회 누적! 활동을 직접 선택해주세요."}

    # [2] 유저 정보(MBTI, 최신 목적) 조회
    pref_type = db.execute(text("SELECT preferred_type FROM user WHERE user_id = :id"), {"id": req.user_id}).scalar() or "BOTH"
    goal = db.execute(text("SELECT current_goal FROM usergoal WHERE user_id = :id ORDER BY created_at DESC LIMIT 1"), {"id": req.user_id}).scalar() or "일반"

    # [3] 날씨 및 좌표 처리
    nx, ny = grid(req.latitude, req.longitude)
    weather = get_weather(nx, ny)

    goal = db.execute(text("SELECT current_goal FROM usergoal WHERE user_id = :id ORDER BY created_at DESC LIMIT 1"), {"id": req.user_id}).scalar() or "일반"

    # [5] 알고리즘 필터링 (MBTI 대신 preferred_type 적용)
    cat_pool = {1, 2, 3, 4, 5, 6} # 기본 풀
    
    # 선호 타입에 따른 필터링 (기존 I, E 로직을 온라인/오프라인 성향으로 변경)
    if pref_type == "온라인": 
        cat_pool = cat_pool.intersection({1, 3, 4, 5}) # 온라인 활동 위주 카테고리
    elif pref_type == "오프라인": 
        cat_pool = cat_pool.intersection({2, 4, 6}) # 오프라인 활동 위주 카테고리

    # [4] 콜드 스타트 (첫 추천) 체크
    rec_count = db.execute(text("SELECT COUNT(*) FROM recommendation WHERE user_id = :uid"), {"uid": req.user_id}).scalar()
    
    if rec_count == 0:
        # 첫 번째 추천: 사람들이 가장 많이 한 인기 활동 추천
        query = text("""
            SELECT a.activity_id, a.activity_name, o.platform, f.location
            FROM activity a
            LEFT JOIN onlineactivity o ON a.activity_id = o.activity_id
            LEFT JOIN offlineactivity f ON a.activity_id = f.activity_id
            LEFT JOIN recommendation r ON a.activity_id = r.activity_id
            LEFT JOIN exec_log e ON r.recommendation_id = e.recommendation_id
            GROUP BY a.activity_id, a.activity_name, o.platform, f.location
            ORDER BY COUNT(e.log_id) DESC
            LIMIT 1
        """)
    else:
        # [5] 알고리즘 필터링 (MBTI, 날씨, 컨디션, 목적)
        cat_pool = {1, 2, 3, 4, 5, 6} # 기본 풀
        
        # MBTI 성향
        if mbti.upper() == "I": cat_pool = cat_pool.intersection({1, 3, 4, 5})
        elif mbti.upper() == "E": cat_pool = cat_pool.intersection({2, 4, 6})
        # H(Half)는 전체 허용 (교집합 패스)

        # 날씨 성향 (비/눈 시 실외 활동 제한)
        if weather == "비/눈":
            cat_pool = cat_pool.intersection({1, 3, 4, 5})

        if not cat_pool: cat_pool = {1, 3} # 엣지 케이스 안전장치

        # 컨디션 및 강도 필터
        intensity_pool = ["'하'", "'중'", "'상'"]
        if req.condition == "나쁨" or goal == "번아웃":
            intensity_pool = ["'하'"]
        elif req.condition == "보통":
            intensity_pool = ["'하'", "'중'"]

        int_sql = ", ".join(intensity_pool)
        cat_sql = ", ".join(map(str, list(cat_pool)))

        # 페널티 및 중복 회피 쿼리 (거절 횟수 > 추천 횟수 > 랜덤)
        query = text(f"""
            SELECT a.activity_id, a.activity_name, o.platform, f.location
            FROM activity a
            LEFT JOIN onlineactivity o ON a.activity_id = o.activity_id
            LEFT JOIN offlineactivity f ON a.activity_id = f.activity_id
            LEFT JOIN (SELECT activity_id, COUNT(*) as rec_cnt FROM recommendation WHERE user_id = :uid GROUP BY activity_id) r_log ON a.activity_id = r_log.activity_id
            LEFT JOIN (
                SELECT r.activity_id, COUNT(*) as rej_cnt FROM rejection_log rej
                JOIN recommendation r ON rej.recommendation_id = r.recommendation_id
                WHERE r.user_id = :uid GROUP BY r.activity_id
            ) rej_log ON a.activity_id = rej_log.activity_id
            WHERE a.intensity IN ({int_sql}) AND a.category_id IN ({cat_sql})
            ORDER BY COALESCE(rej_log.rej_cnt, 0) ASC, COALESCE(r_log.rec_cnt, 0) ASC, RAND()
            LIMIT 1
        """)

    activity = db.execute(query, {"uid": req.user_id}).fetchone()
    if not activity: return {"message": "조건에 맞는 활동이 없습니다."}

    # [6] Recommendation 테이블에 저장
    db.execute(text("INSERT INTO recommendation (user_id, activity_id, weather, user_condition) VALUES (:uid, :aid, :w, :c)"),
               {"uid": req.user_id, "aid": activity[0], "w": weather, "c": req.condition})
    db.commit()
    rec_id = db.execute(text("SELECT LAST_INSERT_ID()")).scalar()

    # 프론트엔드 반환 정보 가공 (온라인/오프라인)
    place_info = f"온라인: {activity[2]}" if activity[2] else f"장소: {activity[3]}" if activity[3] else "장소: 자유"

    return {
        "action": "recommend",
        "recommendation_id": rec_id,
        "activity_id": activity[0],
        "recommended_activity": activity[1],
        "weather_status": weather,
        "place_info": place_info,
        "reason": f"MBTI({mbti})와 컨디션({req.condition})을 고려했어요!"
    }

@app.post("/feedback/")
def submit_feedback(feedback: FeedbackRequest, db: Session = Depends(get_db)):
    """3. 활동 피드백 (수락/거절 분기 처리)"""
    if not feedback.is_liked:
        # [거절 시] 우선순위 페널티 적용(rejection_log) 및 카운트 증가
        user_dislike_count[feedback.user_id] = user_dislike_count.get(feedback.user_id, 0) + 1
        db.execute(text("INSERT INTO rejection_log (recommendation_id) VALUES (:rid)"), {"rid": feedback.recommendation_id})
        db.commit()
        return {"message": "다른 활동을 재추천합니다."}
    else:
        # [수락 시] 수행 기록 및 만족도 저장
        user_dislike_count[feedback.user_id] = 0
        db.execute(text("INSERT INTO exec_log (recommendation_id) VALUES (:rid)"), {"rid": feedback.recommendation_id})
        cat_id = db.execute(text("SELECT category_id FROM activity WHERE activity_id = :aid"), {"aid": feedback.activity_id}).scalar()
        db.execute(text("INSERT INTO usersatisfaction (user_id, category_id, satisfaction_score) VALUES (:uid, :cid, :score)"),
                   {"uid": feedback.user_id, "cid": cat_id, "score": feedback.satisfaction_score})
        db.commit()
        return {"message": "활동이 완료되고 만족도가 등록되었습니다."}

@app.post("/manual_select/")
def manual_select_activity(req: ManualSelectRequest, db: Session = Depends(get_db)):
    """4. 수동 선택 처리 (3회 거절 후 사용자가 직접 선택한 경우)"""
    # 사용자가 직접 고른 것도 향후 AI 분석을 위해 추천(강제 지정) 및 수행 기록으로 남김
    db.execute(text("INSERT INTO recommendation (user_id, activity_id, weather, user_condition) VALUES (:uid, :aid, :w, :c)"),
               {"uid": req.user_id, "aid": req.activity_id, "w": req.weather, "c": req.condition})
    db.commit()
    rec_id = db.execute(text("SELECT LAST_INSERT_ID()")).scalar()
    
    # 바로 수행(exec_log)한 것으로 처리
    db.execute(text("INSERT INTO exec_log (recommendation_id) VALUES (:rid)"), {"rid": rec_id})
    db.commit()
    return {"message": "직접 선택한 활동이 기록되었습니다."}
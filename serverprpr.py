from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from datetime import datetime, timedelta, timezone
import math
import requests
from fastapi.middleware.cors import CORSMiddleware
import os
from typing import Optional, List
import uuid

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
class SignupRequest(BaseModel):
    email: str
    name: str
    password: str

class LoginRequest(BaseModel):
    email: str
    password: str

# 💡 수정됨: 프론트엔드에서 성향(goal) 데이터도 함께 받도록 추가
class InterestRequest(BaseModel):
    user_id: str
    tags: List[str]
    goal: str

class RecommendRequest(BaseModel):
    user_id: str
    condition: str
    time_preference: str
    place_preference: str
    latitude: float
    longitude: float

class FeedbackRequest(BaseModel):
    user_id: str
    recommendation_id: int
    activity_id: int
    is_liked: bool

class ReviewRequest(BaseModel):
    user_id: str
    recommendation_id: int
    activity_id: int
    rating: int
    comment: Optional[str] = None

class ManualSelectRequest(BaseModel):
    user_id: str
    activity_id: int
    weather: str
    condition: str

class FavoriteToggleRequest(BaseModel):
    user_id: str
    activity_id: int

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
    now = datetime.now(timezone(timedelta(hours=9))) 
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
@app.post("/auth/signup")
def signup(req: SignupRequest, db: Session = Depends(get_db)):
    existing_user = db.execute(text("SELECT user_id FROM `user` WHERE email = :email"), {"email": req.email}).fetchone()
    if existing_user: 
        raise HTTPException(status_code=400, detail="이미 가입된 이메일입니다.")

    new_user_id = f"user_{str(uuid.uuid4())[:8]}"
    db.execute(
        text("INSERT INTO `user` (user_id, password, name, email) VALUES (:id, :pw, :name, :email)"),
        {"id": new_user_id, "pw": req.password, "name": req.name, "email": req.email}
    )
    db.commit()
    return {"message": "회원가입이 완료되었습니다. 관심 분야를 설정해주세요.", "user_id": new_user_id}

@app.post("/auth/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.execute(
        text("SELECT user_id, name, password FROM `user` WHERE email = :email"),
        {"email": req.email}
    ).fetchone()

    if not user or user[2] != req.password:
        raise HTTPException(status_code=401, detail="이메일 또는 비밀번호가 일치하지 않습니다.")

    return {"message": "로그인 성공", "user_id": user[0], "name": user[1]}


TAG_TO_CATEGORY_MAP = {
    "운동/건강": 2, "자기계발": 5, "독서": 4, "글쓰기": 4, 
    "여행": 6, "음악": 3, "요리": 3, "IT/기술": 5, "기타": 1
}

@app.post("/users/interests")
def save_interests(req: InterestRequest, db: Session = Depends(get_db)):
    """3. 관심 분야 & 목표 성향 선택 API"""
    
    # 💡 수정됨: 유저의 목표 성향(번아웃/자기계발/선택장애)을 user 테이블에 저장
    db.execute(
        text("UPDATE `user` SET goal = :goal WHERE user_id = :uid"),
        {"goal": req.goal, "uid": req.user_id}
    )

    selected_category_ids = set()
    for tag in req.tags:
        cat_id = TAG_TO_CATEGORY_MAP.get(tag)
        if cat_id:
            selected_category_ids.add(cat_id)

    for cat_id in selected_category_ids:
        exist = db.execute(
            text("SELECT satisfaction_id FROM usersatisfaction WHERE user_id = :uid AND category_id = :cid"),
            {"uid": req.user_id, "cid": cat_id}
        ).fetchone()
        
        if not exist:
            db.execute(
                text("INSERT INTO usersatisfaction (user_id, category_id, satisfaction_score) VALUES (:uid, :cid, :score)"),
                {"uid": req.user_id, "cid": cat_id, "score": 5}
            )
            
    db.commit()
    return {"message": "성향 및 관심사 설정이 완료되었습니다."}


@app.post("/recommend/")
def get_recommendation(req: RecommendRequest, db: Session = Depends(get_db)):
    """4. 맞춤 활동 추천 핵심 로직 (🔥 목표 성향 가중치 탑재)"""
    if user_dislike_count.get(req.user_id, 0) >= 3:
        user_dislike_count[req.user_id] = 0
        return {"action": "manual_selection", "message": "거절 3회 누적! 활동을 직접 선택해주세요."}

    nx, ny = grid(req.latitude, req.longitude)
    weather = get_weather(nx, ny)

    # 1. DB에서 이 유저의 목표 성향 가져오기
    user_info = db.execute(text("SELECT goal FROM `user` WHERE user_id = :uid"), {"uid": req.user_id}).fetchone()
    user_goal = user_info[0] if user_info and user_info[0] else "선택장애형"

    # 2. 목표 성향에 따른 가중치(정렬 우선순위) 설정
    goal_weight_sql = ""
    if user_goal == "번아웃형":
        goal_weight_sql = "a.intensity = '하' DESC," # 강도 '하'를 최우선으로
    elif user_goal == "자기계발형":
        goal_weight_sql = "a.category_id IN (2, 4, 5) DESC," # 운동, 독서/글쓰기, 자기계발을 최우선으로
    # 선택장애형은 가중치 없이 완전 랜덤(RAND)에 맡김

    time_condition = ""
    if req.time_preference == "짧게":
        time_condition = "AND a.duration <= 30"
    elif req.time_preference == "보통":
        time_condition = "AND a.duration > 30 AND a.duration <= 60"
    elif req.time_preference == "여유롭게":
        time_condition = "AND a.duration > 60"

    intensity_pool = ["'하'", "'중'", "'상'"]
    if req.condition in ["매우별로", "별로"]:
        intensity_pool = ["'하'"]
    elif req.condition == "보통":
        intensity_pool = ["'하'", "'중'"]
    elif req.condition in ["좋음", "매우좋음"]:
        intensity_pool = ["'중'", "'상'"]
    int_sql = ", ".join(intensity_pool)

    place_condition = ""
    if req.place_preference == "실내":
        place_condition = "AND (f.location = '집' OR f.location = '실내' OR o.activity_id IS NOT NULL)"
    elif req.place_preference == "실외":
        place_condition = "AND (f.location != '집' AND f.location != '실내')"

    # 💡 쿼리에 성향 가중치(goal_weight_sql) 반영
    query = text(f"""
        SELECT a.activity_id, a.activity_name, a.duration, o.platform, f.location
        FROM activity a
        LEFT JOIN onlineactivity o ON a.activity_id = o.activity_id
        LEFT JOIN offlineactivity f ON a.activity_id = f.activity_id
        LEFT JOIN usersatisfaction us ON a.category_id = us.category_id AND us.user_id = :uid
        LEFT JOIN (
            SELECT r.activity_id, COUNT(*) as rej_cnt FROM rejection_log rej
            JOIN recommendation r ON rej.recommendation_id = r.recommendation_id
            WHERE r.user_id = :uid GROUP BY r.activity_id
        ) rej_log ON a.activity_id = rej_log.activity_id
        WHERE a.intensity IN ({int_sql}) {time_condition} {place_condition}
        ORDER BY {goal_weight_sql} COALESCE(rej_log.rej_cnt, 0) ASC, COALESCE(us.satisfaction_score, 3) DESC, RAND()
        LIMIT 1
    """)

    activity = db.execute(query, {"uid": req.user_id}).fetchone()
    if not activity: 
        return {"action": "fail", "message": "조건에 맞는 활동이 없습니다. 다른 조건으로 시도해주세요."}

    db.execute(text("INSERT INTO recommendation (user_id, activity_id, weather, user_condition) VALUES (:uid, :aid, :w, :c)"),
               {"uid": req.user_id, "aid": activity[0], "w": weather, "c": req.condition})
    
    rec_id = db.execute(text("SELECT LAST_INSERT_ID()")).scalar()
    db.commit()

    place_info = f"온라인: {activity[3]}" if activity[3] else f"오프라인: {activity[4]}"

    return {
        "action": "recommend",
        "recommendation_id": rec_id,
        "activity_id": activity[0],
        "recommended_activity": activity[1],
        "duration": activity[2],
        "weather_status": weather,
        "place_info": place_info,
        "reason": f"[{user_goal}]인 당신의 [{req.condition}] 상태에 딱 맞는 활동이에요."
    }

@app.post("/feedback/")
def submit_feedback(feedback: FeedbackRequest, db: Session = Depends(get_db)):
    if not feedback.is_liked:
        user_dislike_count[feedback.user_id] = user_dislike_count.get(feedback.user_id, 0) + 1
        db.execute(text("INSERT INTO rejection_log (recommendation_id) VALUES (:rid)"), {"rid": feedback.recommendation_id})
        
        cat_id = db.execute(text("SELECT category_id FROM activity WHERE activity_id = :aid"), {"aid": feedback.activity_id}).scalar()
        if not cat_id:
            raise HTTPException(status_code=404, detail="해당 활동을 찾을 수 없습니다.")

        exist_score = db.execute(text("SELECT satisfaction_id, satisfaction_score FROM usersatisfaction WHERE user_id = :uid AND category_id = :cid"), 
                                 {"uid": feedback.user_id, "cid": cat_id}).fetchone()
        if exist_score:
            new_score = max(exist_score[1] - 1, 1) 
            db.execute(text("UPDATE usersatisfaction SET satisfaction_score = :score WHERE satisfaction_id = :sid"), 
                       {"score": new_score, "sid": exist_score[0]})
        db.commit()
        
        if user_dislike_count[feedback.user_id] >= 3:
            return {"action": "manual_selection", "message": "활동이 마음에 들지 않으시군요! 직접 선택해보세요."}
        return {"action": "retry", "message": "이 활동의 선호도를 낮췄습니다. 새로운 활동을 추천합니다."}

    else:
        user_dislike_count[feedback.user_id] = 0
        return {"action": "start_activity", "message": "좋아요! 활동을 완료하신 후 별점을 남겨주세요."}

@app.post("/review/")
def submit_review(review: ReviewRequest, db: Session = Depends(get_db)):
    db.execute(text("INSERT INTO exec_log (recommendation_id) VALUES (:rid)"), {"rid": review.recommendation_id})
    cat_id = db.execute(text("SELECT category_id FROM activity WHERE activity_id = :aid"), {"aid": review.activity_id}).scalar()
    
    if not cat_id:
        raise HTTPException(status_code=404, detail="해당 활동을 찾을 수 없습니다.")

    exist_score = db.execute(text("SELECT satisfaction_id FROM usersatisfaction WHERE user_id = :uid AND category_id = :cid"), 
                             {"uid": review.user_id, "cid": cat_id}).fetchone()
    
    if exist_score:
        db.execute(text("UPDATE usersatisfaction SET satisfaction_score = :score WHERE satisfaction_id = :sid"), 
                   {"score": review.rating, "sid": exist_score[0]})
    else:
        db.execute(text("INSERT INTO usersatisfaction (user_id, category_id, satisfaction_score) VALUES (:uid, :cid, :score)"),
                   {"uid": review.user_id, "cid": cat_id, "score": review.rating})
                   
    db.commit()
    return {"message": "평가가 성공적으로 저장되었습니다."}

@app.post("/manual_select/")
def manual_select_activity(req: ManualSelectRequest, db: Session = Depends(get_db)):
    db.execute(text("INSERT INTO recommendation (user_id, activity_id, weather, user_condition) VALUES (:uid, :aid, :w, :c)"),
               {"uid": req.user_id, "aid": req.activity_id, "w": req.weather, "c": req.condition})
    rec_id = db.execute(text("SELECT LAST_INSERT_ID()")).scalar()
    db.execute(text("INSERT INTO exec_log (recommendation_id) VALUES (:rid)"), {"rid": rec_id})
    db.commit()
    return {"message": "직접 선택한 활동이 기록되었습니다."}

@app.get("/recommend/history/{user_id}")
def get_recommend_history(user_id: str, db: Session = Depends(get_db)):
    query = text("""
        SELECT r.recommended_at, a.activity_name, r.user_condition, COALESCE(us.satisfaction_score, 0)
        FROM recommendation r
        JOIN activity a ON r.activity_id = a.activity_id
        LEFT JOIN usersatisfaction us ON r.user_id = us.user_id AND a.category_id = us.category_id
        WHERE r.user_id = :uid
        ORDER BY r.recommended_at DESC
    """)
    result = db.execute(query, {"uid": user_id}).fetchall()
    
    history_list = []
    for row in result:
        date_str = row[0].strftime("%Y-%m-%d") if row[0] else "날짜 없음"
        history_list.append({
            "date": date_str,
            "activity": row[1],
            "condition": row[2],
            "rating": str(row[3])
        })
    return history_list

@app.post("/activities/favorite")
def toggle_favorite_activity(req: FavoriteToggleRequest, db: Session = Depends(get_db)):
    exist = db.execute(
        text("SELECT favorite_id FROM favorite_activity WHERE user_id = :uid AND activity_id = :aid"),
        {"uid": req.user_id, "aid": req.activity_id}
    ).fetchone()

    if exist:
        db.execute(text("DELETE FROM favorite_activity WHERE favorite_id = :fid"), {"fid": exist[0]})
        db.commit()
        return {"action": "removed", "message": "즐겨찾기에서 삭제되었습니다."}
    else:
        db.execute(
            text("INSERT INTO favorite_activity (user_id, activity_id) VALUES (:uid, :aid)"),
            {"uid": req.user_id, "aid": req.activity_id}
        )
        db.commit()
        return {"action": "added", "message": "즐겨찾기에 추가되었습니다."}

@app.get("/activities/favorite/{user_id}")
def get_favorite_activities(user_id: str, db: Session = Depends(get_db)):
    query = text("""
        SELECT a.activity_id, a.activity_name, a.duration, a.intensity,
               o.platform, f.location, fa.created_at
        FROM favorite_activity fa
        JOIN activity a ON fa.activity_id = a.activity_id
        LEFT JOIN onlineactivity o ON a.activity_id = o.activity_id
        LEFT JOIN offlineactivity f ON a.activity_id = f.activity_id
        WHERE fa.user_id = :uid
        ORDER BY fa.created_at DESC
    """)
    
    results = db.execute(query, {"uid": user_id}).fetchall()
    if not results:
        return {"message": "저장된 즐겨찾기 활동이 없습니다.", "data": []}
        
    saved_activities = []
    for row in results:
        place_info = f"온라인: {row[4]}" if row[4] else f"오프라인: {row[5]}"
        saved_activities.append({
            "activity_id": row[0],
            "activity_name": row[1],
            "duration": row[2],
            "intensity": row[3],
            "place_info": place_info,
            "saved_at": row[6]
        })
    return {"message": "즐겨찾기 목록 조회 성공", "data": saved_activities}

@app.get("/users/profile/{user_id}")
def get_user_profile(user_id: str, db: Session = Depends(get_db)):
    """11. 마이페이지 프로필 정보 조회 API (🔥 스케줄 삭제 및 목표 성향 반환)"""
    user = db.execute(
        text("SELECT name, belong, goal FROM `user` WHERE user_id = :uid"), 
        {"uid": user_id}
    ).fetchone()
    
    if not user:
        raise HTTPException(status_code=404, detail="유저를 찾을 수 없습니다.")
        
    return {
        "name": user[0],
        "belong": user[1] if user[1] else "순천대학교 인공지능공학부",
        "goal": user[2] if user[2] else "선택장애형" # 스케줄 날리고 goal 반환
    }

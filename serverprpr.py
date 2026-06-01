from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from datetime import datetime, timedelta
import math
import requests
from fastapi.middleware.cors import CORSMiddleware
import os
from typing import Optional, List
import uuid

# 파이썬의 FastAPI 프레임워크와 각종 라이브러리를 조합하여 벡엔드 구현
# Rander 를 사용하여 서버 구동

# ==========================================
# 1. 데이터베이스 연결 설정
# ==========================================
DB_URL = os.environ.get("DB_URL", "mysql+pymysql://nsl02:nsl02@codingmaker.net:33068/nsl02") # db 주소
engine = create_engine(DB_URL) # db 엔진
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine) # db와 통신할 통로를 만드는 역할

SERVICE_KEY = os.environ.get("SERVICE_KEY", "915af7fc2df351dc8affe3e7ac89d734e0aba754d1e161d2685ddad45267f5fc") # 날씨 api 받아오기

app = FastAPI(title="Now App - 지능형 활동 추천 시스템") # FastAPI 객체 생성

app.add_middleware( # 프론트엔드와 도메인이 다를 때 발생할 수 있는 에러 방지
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db(): # API 요청이 들어올때마다 통로를 열고 끝나면 닫아주는 함수
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ==========================================
# 2. Pydantic 모델 검증 (회원가입/로그인 분리 복구)
# ==========================================
# 어떤 형태의 데이터를 받아야 하는지 정의해 둔 규격서 같은 느낌
class SignupRequest(BaseModel): # 회원가입 시 필요한 데이터
    email: str
    name: str
    password: str

class LoginRequest(BaseModel): # 로그인 시 필요한 데이터
    email: str
    password: str

class InterestRequest(BaseModel): # 관심 분야를 골랐을 때 필요한 데이터
    user_id: str
    tags: List[str]

class RecommendRequest(BaseModel): # 추천을 받을 때 필요한 데이터
    user_id: str
    condition: str          # "매우별로", "별로", "보통", "좋음", "매우좋음"
    time_preference: str    # "짧게", "보통", "여유롭게"
    place_preference: str   # "실내", "실외", "상관없음"
    latitude: float
    longitude: float

class FeedbackRequest(BaseModel): # 추천받은 활동이 마음에 드는지 안 드는지 체크할 때 필요한 데이터
    user_id: str
    recommendation_id: int
    activity_id: int
    is_liked: bool          # True(좋아요), False(싫어요)

class ReviewRequest(BaseModel): # 활동을 수행한 후 리뷰할 때 필요한 데이터
    user_id: str
    recommendation_id: int
    activity_id: int
    rating: int             # 1~5 별점
    comment: Optional[str] = None # 한 줄 소감

class ManualSelectRequest(BaseModel): # 3번 이상 거절했을 시 직접 선택할 때 필요한 데이터
    user_id: str
    activity_id: int
    weather: str
    condition: str

# 메모리 거절 횟수 카운터
user_dislike_count = {} # 몇 번이나 거절했는지 체크

# ==========================================
# 3. 유틸리티 함수 (좌표 및 기상청)
# ==========================================
def grid(v1, v2): # 위도 경도를 기상청에서 사용하는 격자로 변환해주는 함수
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

def get_weather(nx, ny): # 변환된 격자 좌표를 사용해 기상청으로부터 API 요청을 보내는 함수 , 비/눈 , 맑음 , 흐림 세 가지 중 하나를 반환
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

@app.post("/auth/signup")
def signup(req: SignupRequest, db: Session = Depends(get_db)):
    """1. 회원가입 API (이메일, 이름, 비밀번호)"""
    existing_user = db.execute(text("SELECT user_id FROM user WHERE email = :email"), {"email": req.email}).fetchone() # db에 같은 이메일이 있는지 체크
    if existing_user: # 만약 이미 존재하는 이메일이라면
        raise HTTPException(status_code=400, detail="이미 가입된 이메일입니다.") # 에러 띄우면서 거절

    new_user_id = f"user_{str(uuid.uuid4())[:8]}" # 중복 방지를 위한 유저 아이디 생성

    db.execute( # db에 없는 데이터라면 새로 등록해주기
        text("INSERT INTO user (user_id, password, name, email, mbti) VALUES (:id, :pw, :name, :email, NULL)"),
        {"id": new_user_id, "pw": req.password, "name": req.name, "email": req.email}
    )
    db.commit()
    
    return {"message": "회원가입이 완료되었습니다. 관심 분야를 설정해주세요.", "user_id": new_user_id}


@app.post("/auth/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    """2. 로그인 API"""
    user = db.execute(
        text("SELECT user_id, name, password FROM user WHERE email = :email"),
        {"email": req.email} # email 로 id , name, password 를 알아오기
    ).fetchone()

    if not user or user[2] != req.password: # 만약 이메일이 db에 없거나 , 비밀번호가 일치하지 않는다면
        raise HTTPException(status_code=401, detail="이메일 또는 비밀번호가 일치하지 않습니다.") # 거절하기

    return { # 정상적으로 되었다면 id 와 name 반환하기
        "message": "로그인 성공", 
        "user_id": user[0],
        "name": user[1]
    }


TAG_TO_CATEGORY_MAP = { # 태그를 숫자로 구별
    "운동/건강": 2, "자기계발": 5, "독서": 4, "글쓰기": 4, 
    "여행": 6, "음악": 3, "요리": 3, "IT/기술": 5, "기타": 1
}

@app.post("/users/interests")
def save_interests(req: InterestRequest, db: Session = Depends(get_db)):
    """3. 관심 분야 선택 API"""
    selected_category_ids = set()
    for tag in req.tags: # 프론트엔드로부터 가져온 태그를 하나씩 꺼내면서 반복
        cat_id = TAG_TO_CATEGORY_MAP.get(tag) # 태그를 숫자로 변환
        if cat_id: # 이상한 태그라면 목록에 없으니 무시
            selected_category_ids.add(cat_id) # 선택한 카테고리들을 따로 담기

    if not selected_category_ids: # 저장한 카테고리가 아예 없다면 예외 처리 하기
        return {"message": "유효한 관심사가 선택되지 않았습니다. 기본 설정으로 넘어갑니다."}

    for cat_id in selected_category_ids: # 중복이 없는 카테고리 id 들을 하나씩 꺼내면서 반복
        exist = db.execute( # 우선 id 로 유저를 찾은 뒤 카테고리를 저장해 둔적이 있는지 확인
            text("SELECT satisfaction_id FROM usersatisfaction WHERE user_id = :uid AND category_id = :cid"),
            {"uid": req.user_id, "cid": cat_id}
        ).fetchone()
        
        if not exist: # 저장해 둔적이 없다면 새로 고른 카테고리들을 넣어주기
            db.execute(
                text("INSERT INTO usersatisfaction (user_id, category_id, satisfaction_score) VALUES (:uid, :cid, :score)"),
                {"uid": req.user_id, "cid": cat_id, "score": 5}
            )
            
    db.commit()
    return {"message": "관심 분야 설정이 완료되었습니다.", "saved_categories": list(selected_category_ids)}


@app.post("/recommend/")
def get_recommendation(req: RecommendRequest, db: Session = Depends(get_db)):
    """4. 맞춤 활동 추천 핵심 로직"""
    
    if user_dislike_count.get(req.user_id, 0) >= 3: # 만약 싫어요가 3회 이상이라면
        user_dislike_count[req.user_id] = 0 # 다시 횟수를 0으로 초기화 해주고
        return {"action": "manual_selection", "message": "거절 3회 누적! 활동을 직접 선택해주세요."} # 직접 고르는 걸로 넘어가기

    nx, ny = grid(req.latitude, req.longitude) # 위도 경도를 격자로 변환
    weather = get_weather(nx, ny) # 격자를 넣어 날씨를 반환

    time_condition = "" # 소요시간을 추천 로직을 위해 SQL 쿼리 문으로 적절하게 변경
    if req.time_preference == "짧게":
        time_condition = "AND a.duration <= 30"
    elif req.time_preference == "보통":
        time_condition = "AND a.duration > 30 AND a.duration <= 60"
    elif req.time_preference == "여유롭게":
        time_condition = "AND a.duration > 60"

    intensity_pool = ["'하'", "'중'", "'상'"] # 컨디션을 저장
    if req.condition in ["매우별로", "별로"]:
        intensity_pool = ["'하'"]
    elif req.condition == "보통":
        intensity_pool = ["'하'", "'중'"]
    elif req.condition in ["좋음", "매우좋음"]:
        intensity_pool = ["'중'", "'상'"]
    int_sql = ", ".join(intensity_pool)

    place_condition = "" # 실내인지 실외인지 구분
    if req.place_preference == "실내":
        place_condition = "AND (f.location = '집' OR f.location = '실내' OR o.activity_id IS NOT NULL)"
    elif req.place_preference == "실외":
        place_condition = "AND (f.location != '집' AND f.location != '실내')"

    # 위에서 구했던 정보들을 통해 각 테이블들을 연결해주기
    # 과거에 몇번이나 싫어요 했는지 계산해서 연결
    # 완성된 조건을 쿼리문에 끼워넣기
    # 추천 로직 _______
    # 1. 거절한 횟수가 적은 활동을 최우선으로 올리기
    # 2. 거절 횟수가 같다면, 유저가 평소에 높게 평가한 카테고리를 위로 올리기
    # 3. 위의 조건까지 같다면 랜덤하기 섞어주기
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
        ORDER BY COALESCE(rej_log.rej_cnt, 0) ASC, COALESCE(us.satisfaction_score, 3) DESC, RAND()
        LIMIT 1
    """)

    # 쿼리 실행 후 예외 처리
    activity = db.execute(query, {"uid": req.user_id}).fetchone()
    if not activity: 
        return {"action": "fail", "message": "조건에 맞는 활동이 없습니다. 다른 조건으로 시도해주세요."}

    # 방금 추천해준 내용을 db에 저장
    db.execute(text("INSERT INTO recommendation (user_id, activity_id, weather, user_condition) VALUES (:uid, :aid, :w, :c)"),
               {"uid": req.user_id, "aid": activity[0], "w": weather, "c": req.condition})
    db.commit()
    rec_id = db.execute(text("SELECT LAST_INSERT_ID()")).scalar()

    place_info = f"온라인: {activity[3]}" if activity[3] else f"오프라인: {activity[4]}"

    return { # 프론트엔드로 추천 결과를 반환
        "action": "recommend",
        "recommendation_id": rec_id,
        "activity_id": activity[0],
        "recommended_activity": activity[1],
        "duration": activity[2],
        "weather_status": weather,
        "place_info": place_info,
        "reason": f"[{req.condition}] 상태에 맞는 {req.time_preference} 할 수 있는 활동이에요."
    }


@app.post("/feedback/")
def submit_feedback(feedback: FeedbackRequest, db: Session = Depends(get_db)):
    """5. 활동 피드백 (싫어요 시 선호도 차감 로직 포함)"""
    if not feedback.is_liked: # 유저가 싫어요를 눌렀을 경우
        user_dislike_count[feedback.user_id] = user_dislike_count.get(feedback.user_id, 0) + 1 # 싫어요 카운트 + 1
        db.execute(text("INSERT INTO rejection_log (recommendation_id) VALUES (:rid)"), {"rid": feedback.recommendation_id})
        # 어떤 추천을 거절했는지 db에 남기기
        
        # 거절당한 활동이 어느 카테고리인지 찾아내기
        cat_id = db.execute(text("SELECT category_id FROM activity WHERE activity_id = :aid"), {"aid": feedback.activity_id}).scalar()
        
        # 평소 해당 카테고리에 몇 점을 주고 있었는지 확인하기
        exist_score = db.execute(text("SELECT satisfaction_id, satisfaction_score FROM usersatisfaction WHERE user_id = :uid AND category_id = :cid"), 
                                 {"uid": feedback.user_id, "cid": cat_id}).fetchone()
        # db에 점수 기록이 존재한다면 점수 깎아주기 ( 최소 점수는 1점으로 막아두기 )
        if exist_score:
            new_score = max(exist_score[1] - 1, 1) 
            # 깎인 점수를 db에 업데이트
            db.execute(text("UPDATE usersatisfaction SET satisfaction_score = :score WHERE satisfaction_id = :sid"), 
                       {"score": new_score, "sid": exist_score[0]})
        
        db.commit()
        
        # 거절이 3번 이상이라면 직접 선택 화면으로 넘어가기
        if user_dislike_count[feedback.user_id] >= 3:
            return {"action": "manual_selection", "message": "활동이 마음에 들지 않으시군요! 직접 선택해보세요."}
        return {"action": "retry", "message": "이 활동의 선호도를 낮췄습니다. 새로운 활동을 추천합니다."}

    else:
        user_dislike_count[feedback.user_id] = 0
        return {"action": "start_activity", "message": "좋아요! 활동을 완료하신 후 별점을 남겨주세요."}


@app.post("/review/")
def submit_review(review: ReviewRequest, db: Session = Depends(get_db)):
    """6. 활동 완료 후 별점 및 소감 남기기"""
    # 수행한 활동을 db에 기록하기
    db.execute(text("INSERT INTO exec_log (recommendation_id) VALUES (:rid)"), 
               {"rid": review.recommendation_id})
    
    # 방금 완료한 활동이 어느 카테고리인지 찾아내기
    cat_id = db.execute(text("SELECT category_id FROM activity WHERE activity_id = :aid"), {"aid": review.activity_id}).scalar()
    # 그 카테고리에 기존에 가지고 있는 점수가 있는지 검색
    exist_score = db.execute(text("SELECT satisfaction_id FROM usersatisfaction WHERE user_id = :uid AND category_id = :cid"), 
                             {"uid": review.user_id, "cid": cat_id}).fetchone()
    
    # 만약 있다면 방금 유저가 준 별점으로 덮어씌우기
    if exist_score:
        db.execute(text("UPDATE usersatisfaction SET satisfaction_score = :score WHERE satisfaction_id = :sid"), 
                   {"score": review.rating, "sid": exist_score[0]})
    # 없다면 카테고리에 대한 점수 기록을 새로 생성하기
    else:
        db.execute(text("INSERT INTO usersatisfaction (user_id, category_id, satisfaction_score) VALUES (:uid, :cid, :score)"),
                   {"uid": review.user_id, "cid": cat_id, "score": review.rating})
                   
    db.commit()
    
    return {"message": "평가가 성공적으로 저장되었습니다."}


@app.post("/manual_select/")
def manual_select_activity(req: ManualSelectRequest, db: Session = Depends(get_db)):
    """7. 수동 선택 처리"""
    # 유저가 고른 활동을 db에 기록하기
    db.execute(text("INSERT INTO recommendation (user_id, activity_id, weather, user_condition) VALUES (:uid, :aid, :w, :c)"),
               {"uid": req.user_id, "aid": req.activity_id, "w": req.weather, "c": req.condition})
    db.commit()
    # 방금 생성된 추천 기록의 고유 id 가져오기
    rec_id = db.execute(text("SELECT LAST_INSERT_ID()")).scalar()
    
    # 수행 했다는 사실을 db에 기록하기
    db.execute(text("INSERT INTO exec_log (recommendation_id) VALUES (:rid)"), {"rid": rec_id})
    db.commit()
    return {"message": "직접 선택한 활동이 기록되었습니다."}
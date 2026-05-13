from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from datetime import datetime, timedelta
import math
import requests

# ==========================================
# 1. 데이터베이스 연결 설정 (MariaDB)
# ==========================================
now_db = "mysql+pymysql://root:1234@127.0.0.1:33061/now_db"
engine = create_engine(now_db)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 기상청 API 인증키 (본인 키로 유지)
SERVICE_KEY = '915af7fc2df351dc8affe3e7ac89d734e0aba754d1e161d2685ddad45267f5fc'

app = FastAPI(title="활동 추천 API (Now App)")

@app.get("/")
def read_root():
    return {"message": "Now App 서버가 정상적으로 실행 중입니다! API 테스트를 위해 주소창 끝에 /docs를 입력해 주세요."}

# DB 세션 의존성 주입 함수
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ==========================================
# 2. Pydantic 모델 (요청/응답 형식 검증)
# ==========================================
class UserSetup(BaseModel):
    user_id: str
    password: str
    name: str
    email: str
    mbti: str  

class RecommendRequest(BaseModel):
    user_id: str
    # weather: str <- 백엔드에서 GPS로 직접 구하므로 삭제됨!
    condition: str    # 예: "좋음", "보통", "나쁨"
    latitude: float   # GPS 위도
    longitude: float  # GPS 경도

class FeedbackRequest(BaseModel):
    user_id: str
    activity_id: int
    is_liked: bool           # True(좋아요/수락), False(싫어요/거절)
    satisfaction_score: int  # 1 ~ 5점

user_dislike_count = {} 

# ==========================================
# 3. 외부 기능 함수 (좌표 변환 및 날씨 조회)
# ==========================================
def grid(v1, v2):
    """위도(v1), 경도(v2)를 기상청 X, Y 격자로 변환하는 함수"""
    RE = 6371.00877 
    GRID = 5.0      
    SLAT1 = 30.0    
    SLAT2 = 60.0    
    OLON = 126.0    
    OLAT = 38.0     
    XO = 43         
    YO = 136        

    DEGRAD = math.pi / 180.0
    
    re = RE / GRID
    slat1 = SLAT1 * DEGRAD
    slat2 = SLAT2 * DEGRAD
    olon = OLON * DEGRAD
    olat = OLAT * DEGRAD

    sn = math.tan(math.pi * 0.25 + slat2 * 0.5) / math.tan(math.pi * 0.25 + slat1 * 0.5)
    sn = math.log(math.cos(slat1) / math.cos(slat2)) / math.log(sn)
    sf = math.tan(math.pi * 0.25 + slat1 * 0.5)
    sf = math.pow(sf, sn) * math.cos(slat1) / sn
    ro = math.tan(math.pi * 0.25 + olat * 0.5)
    ro = re * sf / math.pow(ro, sn)

    ra = math.tan(math.pi * 0.25 + (v1) * DEGRAD * 0.5)
    ra = re * sf / math.pow(ra, sn)

    theta = v2 * DEGRAD - olon
    if theta > math.pi: theta -= 2.0 * math.pi
    if theta < -math.pi: theta += 2.0 * math.pi
    theta *= sn
    
    nx = math.floor(ra * math.sin(theta) + XO + 0.5)
    ny = math.floor(ro - ra * math.cos(theta) + YO + 0.5)
    
    return int(nx), int(ny)

def get_detailed_weather(nx: int, ny: int):
    """격자 좌표를 바탕으로 초단기예보조회 API를 호출해 상세 날씨를 반환"""
    url = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
    
    now = datetime.now()
    # 초단기예보는 매시 30분에 생성되고 45분에 API 제공
    if now.minute < 45:
        now = now - timedelta(hours=1)
        
    base_date = now.strftime('%Y%m%d')
    base_time = now.strftime('%H30')
    
    params = {
        'serviceKey': SERVICE_KEY,
        'numOfRows': '50',
        'pageNo': '1',
        'dataType': 'JSON',
        'base_date': base_date,
        'base_time': base_time,
        'nx': str(nx),
        'ny': str(ny)
    }
    
    try:
        response = requests.get(url, params=params) # url 에 params을 보내기 (get방식)
        response.raise_for_status() # 코드 200 이 아닌 경우 에러
        data = response.json() # json 을 딕셔너리로 변환
        
        if data['response']['header']['resultCode'] != '00':
            return "알 수 없음"
            
        items = data['response']['body']['items']['item']
        sky, pty = "1", "0"
        
        for item in items:
            if item['category'] == 'SKY': sky = item['fcstValue']
            elif item['category'] == 'PTY': pty = item['fcstValue']
                
        if pty != "0": 
            if pty in ["1", "5"]: return "비"
            elif pty in ["2", "6"]: return "비/눈"
            elif pty in ["3", "7"]: return "눈"
            elif pty == "4": return "소나기"
        else: 
            if sky == "1": return "맑음"
            elif sky == "3": return "구름많음"
            elif sky == "4": return "흐림"
            
        return "알 수 없음"
    except Exception:
        return "날씨 조회 실패"

# ==========================================
# 4. API 엔드포인트
# ==========================================
@app.post("/users/setup")
def setup_user(user: UserSetup, db: Session = Depends(get_db)):
    """1. 초기 설정: 사용자 기본 정보 및 MBTI 기록"""
    query = text("""
        INSERT INTO user (user_id, password, name, email, mbti) 
        VALUES (:id, :pw, :name, :email, :mbti)
    """)
    db.execute(query, {"id": user.user_id, "pw": user.password, "name": user.name, "email": user.email, "mbti": user.mbti})
    db.commit()
    return {"message": f"{user.name}님의 초기 설정이 완료되었습니다."}

@app.post("/recommend/")
def get_recommendation(req: RecommendRequest, db: Session = Depends(get_db)):
    """2. 날씨 및 사용자 맞춤 활동 추천 (추천 기록 저장)"""
    
    # [1] 거절 횟수 체크
    current_dislikes = user_dislike_count.get(req.user_id, 0)
    if current_dislikes >= 3:
        user_dislike_count[req.user_id] = 0
        return {"action": "manual_selection", "message": "싫어요를 3회 누르셨습니다. 직접 활동을 선택해주세요!"}

    # [2] 사용자 MBTI 조회
    user_query = text("SELECT mbti FROM user WHERE user_id = :id")
    user_data = db.execute(user_query, {"id": req.user_id}).fetchone()
    if not user_data:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")
    mbti = user_data[0]

    # [3] 위경도 -> 격자 변환 후 날씨 조회
    nx, ny = grid(req.latitude, req.longitude)
    current_weather = get_detailed_weather(nx, ny)

    # [4] 조건에 따른 필터링 (컨디션, 날씨, MBTI)
    intensity_list = ["'하'"] if req.condition == "나쁨" else ["'하'", "'중'"] if req.condition == "보통" else ["'상'", "'중'", "'하'"]
    
    if current_weather in ["비", "비/눈", "눈", "소나기"] or "I" in mbti.upper():
        cat_list = [2, 3, 4] # 실내 활동 위주
    else:
        cat_list = [1, 2, 3, 4, 5] 

    int_sql = ", ".join(intensity_list)
    cat_sql = ", ".join(map(str, cat_list))

    # [5] 활동 조회 (추천 횟수가 적은 것을 우선 추천)
    rec_query = text(f"""
        SELECT a.activity_id, a.activity_name
        FROM activity a
        LEFT JOIN (
            SELECT activity_id, COUNT(*) as rec_count
            FROM recommendation
            WHERE user_id = :uid
            GROUP BY activity_id
        ) r ON a.activity_id = r.activity_id
        WHERE a.intensity IN ({int_sql})
          AND a.category_id IN ({cat_sql})
        ORDER BY COALESCE(r.rec_count, 0) ASC, RAND()
        LIMIT 1
    """)
    activity = db.execute(rec_query, {"uid": req.user_id}).fetchone()
    
    if not activity:
        return {"message": "조건에 맞는 활동이 없습니다."}

    activity_id, activity_name = activity[0], activity[1]

    # [6] 추천 기록 저장 (현재 날씨 정보 삽입)
    insert_query = text("""
        INSERT INTO recommendation (user_id, activity_id, weather, condition_status)
        VALUES (:uid, :aid, :weather, :condition)
    """)
    db.execute(insert_query, {
        "uid": req.user_id,
        "aid": activity_id,
        "weather": current_weather,
        "condition": req.condition
    })
    db.commit()

    return {
        "action": "recommend",
        "weather_status": current_weather,
        "recommended_activity": activity_name,
        "reason": f"현재 날씨({current_weather})와 컨디션({req.condition})을 고려했어요!"
    }

@app.post("/feedback/")
def submit_feedback(feedback: FeedbackRequest, db: Session = Depends(get_db)):
    """3. 활동 피드백 처리"""
    if not feedback.is_liked:
        count = user_dislike_count.get(feedback.user_id, 0)
        user_dislike_count[feedback.user_id] = count + 1
        return {"message": "추천을 거절했습니다. 다른 활동을 재추천합니다.", "current_dislike_count": count + 1}
    else:
        # 만족도 업데이트 등 추가 로직
        user_dislike_count[feedback.user_id] = 0
        return {"message": f"만족도 {feedback.satisfaction_score}점이 기록되었습니다."}
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from datetime import datetime, timedelta, timezone
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
# 2. Pydantic 모델 검증
# ==========================================
class SignupRequest(BaseModel):
    email: str
    name: str
    password: str

class LoginRequest(BaseModel):
    email: str
    password: str

class InterestRequest(BaseModel): 
    user_id: str
    tags: List[str]
    goal: str  

class RecommendRequest(BaseModel): 
    user_id: str
    condition: str          # "매우별로", "별로", "보통", "좋음", "매우좋음"
    time_preference: str    # "짧게", "보통", "여유롭게"
    place_preference: str   # "실내", "실외", "상관없음"
    # 날씨 제거로 인해 latitude, longitude 제거됨

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
    condition: str
    # weather 제거됨

class FavoriteToggleRequest(BaseModel):
    user_id: str
    activity_id: int

class HistorySaveRequest(BaseModel):
    user_id: str
    activity_id: int
    condition: str
    recommendation_id: int

# 메모리 거절 횟수 카운터
user_dislike_count = {} 

# ==========================================
# 3. 유틸리티 함수 (날씨 로직 제거됨)
# ==========================================
# grid 함수 및 get_weather 함수 삭제 완료

# ==========================================
# 4. API 엔드포인트
# ==========================================

@app.post("/auth/signup")
def signup(req: SignupRequest, db: Session = Depends(get_db)):
    """1. 회원가입 API"""
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
    """2. 로그인 API"""
    user = db.execute(
        text("SELECT user_id, name, password FROM `user` WHERE email = :email"),
        {"email": req.email} 
    ).fetchone()

    if not user or user[2] != req.password: 
        raise HTTPException(status_code=401, detail="이메일 또는 비밀번호가 일치하지 않습니다.") 

    return { 
        "message": "로그인 성공", 
        "user_id": user[0],
        "name": user[1]
    }


TAG_TO_CATEGORY_MAP = { 
    "운동/건강": 2, "자기계발": 5, "독서": 4, "글쓰기": 4, 
    "여행": 6, "음악": 3, "요리": 3, "IT/기술": 5, "기타": 1
}

@app.post("/users/interests")
def save_interests(req: InterestRequest, db: Session = Depends(get_db)):
    """3. 관심 분야 및 목표(성향) 선택 API"""
    
    db.execute(
        text("UPDATE `user` SET goal = :goal WHERE user_id = :uid"),
        {"goal": req.goal, "uid": req.user_id}
    )

    selected_category_ids = set()
    for tag in req.tags:
        cat_id = TAG_TO_CATEGORY_MAP.get(tag)
        if cat_id:
            selected_category_ids.add(cat_id)

    if not selected_category_ids:
        db.commit() 
        return {"message": "목표는 저장되었으나 유효한 관심사가 선택되지 않았습니다."}

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
    return {
        "message": "관심 분야와 목표 설정이 완료되었습니다.", 
        "saved_categories": list(selected_category_ids),
        "saved_goal": req.goal
    }


@app.post("/recommend/")
def get_recommendation(req: RecommendRequest, db: Session = Depends(get_db)):
    """4. 맞춤 활동 추천 핵심 로직 (목표 기반 가산점 적용)"""
    
    # 🌟 1. 유저의 현재 목표(goal) 가져오기
    user_info = db.execute(text("SELECT goal FROM `user` WHERE user_id = :uid"), {"uid": req.user_id}).fetchone()
    user_goal = user_info[0] if user_info and user_info[0] else ""

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

    # 🌟 2. 목표(Goal)에 따른 맞춤형 가산점(Bonus) SQL 생성
    goal_bonus_sql = "CASE WHEN 1=1 THEN 0 END"  # 에러 방지용 안전한 기본값
    if user_goal == "번아웃형":
        # 번아웃형: 강도가 '하'이거나, 힐링/휴식 카테고리에 가산점 +5
        goal_bonus_sql = "CASE WHEN a.intensity = '하' OR a.category_id IN (1, 3, 6) THEN 5 ELSE 0 END"
    elif user_goal == "자기계발형":
        # 자기계발형: 성장에 도움되는 카테고리에 가산점 +5
        goal_bonus_sql = "CASE WHEN a.category_id IN (2, 4, 5) THEN 5 ELSE 0 END"
    elif user_goal == "선택장애형":
        # 선택장애형: 짧은 활동(30분 이하)에 가산점 +3
        goal_bonus_sql = "CASE WHEN a.duration <= 30 THEN 3 ELSE 0 END"

    # 3. 쿼리문에 가산점 반영
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
        LEFT JOIN (
            SELECT activity_id, COUNT(*) as rec_cnt FROM recommendation
            WHERE user_id = :uid GROUP BY activity_id
        ) rec_log ON a.activity_id = rec_log.activity_id
        WHERE a.intensity IN ({int_sql}) {time_condition} {place_condition}
        ORDER BY COALESCE(rej_log.rej_cnt, 0) ASC, 
                 COALESCE(rec_log.rec_cnt, 0) ASC, 
                 ({goal_bonus_sql}) DESC,  -- 🌟 여기서 목표에 따른 가산점이 최우선으로 적용됩니다!
                 COALESCE(us.satisfaction_score, 3) DESC, 
                 RAND()
        LIMIT 1
    """)

    activity = db.execute(query, {"uid": req.user_id}).fetchone()
    if not activity: 
        return {"action": "fail", "message": "조건에 맞는 활동이 없습니다. 다른 조건으로 시도해주세요."}

    db.execute(text("INSERT INTO recommendation (user_id, activity_id, user_condition) VALUES (:uid, :aid, :c)"),
               {"uid": req.user_id, "aid": activity[0], "c": req.condition})
    
    rec_id = db.execute(text("SELECT LAST_INSERT_ID()")).scalar()
    db.commit()

    place_info = f"온라인: {activity[3]}" if activity[3] else f"오프라인: {activity[4]}"

    # 🌟 4. 프론트엔드에 응답할 때 유저의 목표를 슬쩍 멘트에 녹여주기
    goal_mention = ""
    if user_goal == "번아웃": goal_mention = "지친 몸과 마음을 달래줄 "
    elif user_goal == "자기계발": goal_mention = "성장에 집중할 수 있는 "
    elif user_goal == "선택장애": goal_mention = "고민 없이 가볍게 즐길 수 있는 "

    return { 
        "action": "recommend",
        "recommendation_id": rec_id,
        "activity_id": activity[0],
        "recommended_activity": activity[1],
        "duration": activity[2],
        "place_info": place_info,
        "reason": f"[{req.condition}] 상태에 맞는, {goal_mention}{req.time_preference} 할 수 있는 활동이에요."
    }


@app.post("/feedback/")
def submit_feedback(feedback: FeedbackRequest, db: Session = Depends(get_db)):
    """5. 활동 피드백"""
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
            user_dislike_count[feedback.user_id] = 0 
            return {"action": "manual_selection", "message": "활동이 마음에 들지 않으시군요! 직접 선택해보세요."}
            
        return {"action": "retry", "message": "이 활동의 선호도를 낮췄습니다. 새로운 활동을 추천합니다."}

    else:
        user_dislike_count[feedback.user_id] = 0
        return {"action": "start_activity", "message": "좋아요! 활동을 완료하신 후 별점을 남겨주세요."}


@app.post("/review/")
def submit_review(review: ReviewRequest, db: Session = Depends(get_db)):
    """6. 활동 완료 후 별점 남기기 (평균 X, 무조건 덮어쓰기)"""
    
    # 1. 수행 기록 (기존 컬럼만 사용)
    db.execute(text("INSERT INTO exec_log (recommendation_id) VALUES (:rid)"), 
               {"rid": review.recommendation_id})
    
    # 2. 방금 완료한 활동이 어느 카테고리인지 찾아내기
    cat_id = db.execute(text("SELECT category_id FROM activity WHERE activity_id = :aid"), {"aid": review.activity_id}).scalar()
    
    if not cat_id:
        raise HTTPException(status_code=404, detail="해당 활동을 찾을 수 없습니다.")

    # 3. 기존 카테고리 점수 찾기
    exist_score = db.execute(text("SELECT satisfaction_id FROM usersatisfaction WHERE user_id = :uid AND category_id = :cid"), 
                             {"uid": review.user_id, "cid": cat_id}).fetchone()
    
    if exist_score:
        db.execute(text("UPDATE usersatisfaction SET satisfaction_score = :score WHERE satisfaction_id = :sid"), 
                   {"score": review.rating, "sid": exist_score[0]})
                   
    # 기록이 없다면 새로 입력받은 별점 그대로 저장
    else:
        db.execute(text("INSERT INTO usersatisfaction (user_id, category_id, satisfaction_score) VALUES (:uid, :cid, :score)"),
                   {"uid": review.user_id, "cid": cat_id, "score": review.rating})
                   
    db.commit()
    
    return {"message": "평가가 성공적으로 덮어씌워졌습니다."}



@app.get("/activities/manual")
def get_manual_selection_list(db: Session = Depends(get_db)):
    """11. 수동 선택용 활동 리스트 제공 API (매번 랜덤 10개)"""
    
    # 전체 활동 중에서 무작위로 10개를 뽑아옵니다.
    query = text("""
        SELECT a.activity_id, a.activity_name, a.duration, o.platform, f.location
        FROM activity a
        LEFT JOIN onlineactivity o ON a.activity_id = o.activity_id
        LEFT JOIN offlineactivity f ON a.activity_id = f.activity_id
        ORDER BY RAND()
        LIMIT 10
    """)
    
    results = db.execute(query).fetchall()
    
    manual_list = []
    for row in results:
        place_info = f"온라인: {row[3]}" if row[3] else (f"오프라인: {row[4]}" if row[4] else "장소: 자유")
        manual_list.append({
            "activity_id": row[0],
            "activity_name": row[1],
            "duration": row[2],
            "place_info": place_info
        })
        
    return {
        "message": "수동 선택 목록 조회 성공",
        "data": manual_list
    }

@app.post("/activities/favorite")
def toggle_favorite_activity(req: FavoriteToggleRequest, db: Session = Depends(get_db)):
    """8. 즐겨찾기 추가/삭제 토글 API"""
    
    exist = db.execute(
        text("SELECT favorite_id FROM favorite_activity WHERE user_id = :uid AND activity_id = :aid"),
        {"uid": req.user_id, "aid": req.activity_id}
    ).fetchone()

    if exist:
        db.execute(
            text("DELETE FROM favorite_activity WHERE favorite_id = :fid"),
            {"fid": exist[0]}
        )
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
    """9. 저장한 활동 목록 조회 API"""
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
        
    return {
        "message": "즐겨찾기 목록 조회 성공",
        "data": saved_activities
    }

@app.get("/recommend/history/{user_id}")
def get_history(user_id: str, db: Session = Depends(get_db)):
    """10. 추천 기록 조회 API (싫어요 제외 + 덮어씌워진 별점 표시)"""
    
    query = text("""
        SELECT r.recommendation_id, r.user_condition, r.recommended_at,
               a.activity_id, a.activity_name, a.duration,
               COALESCE(us.satisfaction_score, 0) as rating
        FROM recommendation r
        JOIN activity a ON r.activity_id = a.activity_id
        LEFT JOIN usersatisfaction us ON a.category_id = us.category_id AND us.user_id = r.user_id
        WHERE r.user_id = :uid 
          AND r.recommendation_id NOT IN (SELECT recommendation_id FROM rejection_log)
        ORDER BY r.recommended_at DESC
    """)
    
    results = db.execute(query, {"uid": user_id}).fetchall()
    
    if not results:
        return {"message": "조회할 기록이 없습니다.", "data": []}
        
    history_list = []
    for row in results:
        history_list.append({
            "recommendation_id": row[0],
            "condition": row[1],
            "recommended_at": row[2],
            "activity_id": row[3],
            "activity_name": row[4],
            "duration": row[5],
            "rating": row[6]
        })
        
    return {
        "message": "기록 조회 성공",
        "data": history_list
    }

@app.post("/manual_select/")
def manual_select_activity(req: ManualSelectRequest, db: Session = Depends(get_db)):
    """7. 수동 선택 처리 (활동 시작 화면으로 넘겨주기)"""
    
    # 1. 수동 선택 창에 진입했으므로 거절 카운트 초기화
    user_dislike_count[req.user_id] = 0
    
    # 2. 유저가 리스트에서 클릭한 활동의 디테일한 정보 가져오기
    query = text("""
        SELECT a.activity_name, a.duration, o.platform, f.location
        FROM activity a
        LEFT JOIN onlineactivity o ON a.activity_id = o.activity_id
        LEFT JOIN offlineactivity f ON a.activity_id = f.activity_id
        WHERE a.activity_id = :aid
    """)
    activity = db.execute(query, {"aid": req.activity_id}).fetchone()

    if not activity:
        raise HTTPException(status_code=404, detail="활동을 찾을 수 없습니다.")

    # 3. 나중에 별점을 매기기 위해 '추천 영수증'을 발급해 DB에 저장합니다.
    db.execute(text("INSERT INTO recommendation (user_id, activity_id, user_condition) VALUES (:uid, :aid, :c)"),
               {"uid": req.user_id, "aid": req.activity_id, "c": req.condition})
    
    rec_id = db.execute(text("SELECT LAST_INSERT_ID()")).scalar()
    db.commit()
    
    place_info = f"온라인: {activity[2]}" if activity[2] else (f"오프라인: {activity[3]}" if activity[3] else "장소: 자유")
    
    # 4. 일반 추천 화면으로 자연스럽게 넘어가도록 프론트엔드에 데이터 반환
    return {
        "action": "recommend",
        "recommendation_id": rec_id,
        "activity_id": req.activity_id,
        "recommended_activity": activity[0],
        "duration": activity[1],
        "place_info": place_info,
        "reason": "내가 직접 선택한 맞춤 활동이에요!"
    }

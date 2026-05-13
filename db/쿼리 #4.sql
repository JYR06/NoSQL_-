-- 1. 사용자 (User) 테이블 [cite: 312]
CREATE TABLE User (
    user_id VARCHAR(50) PRIMARY KEY COMMENT '사용자 고유 식별자', -- [cite: 313]
    password VARCHAR(255) NOT NULL COMMENT '암호화된 계정 비밀번호', -- [cite: 314]
    name VARCHAR(50) NOT NULL COMMENT '사용자 실명', -- [cite: 315]
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '고유 이메일 주소', -- [cite: 316]
    mbti VARCHAR(10) COMMENT '성향 판별용 (I/E/중간)' -- [cite: 317]
);

-- 2. 카테고리 (Category) 테이블 [cite: 326]
CREATE TABLE Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '카테고리 고유 번호', -- [cite: 327]
    category_name VARCHAR(50) NOT NULL COMMENT '운동, 독서, 영화 등' -- [cite: 327]
);

-- 3. 활동 (Activity) 테이블 [cite: 333]
CREATE TABLE Activity (
    activity_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '활동 고유 번호', -- [cite: 334]
    activity_name VARCHAR(100) NOT NULL COMMENT '구체적인 할 일 이름', -- [cite: 335]
    duration INT COMMENT '예상 활동 시간(분 단위)', -- [cite: 336]
    category_id INT NOT NULL COMMENT '소속 카테고리 참조', -- [cite: 337]
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE CASCADE
);

-- 4. 오프라인 활동 (Offline_Activity) 테이블 (ISA 일반화 반영) [cite: 465, 469]
CREATE TABLE Offline_Activity (
    activity_id INT PRIMARY KEY COMMENT '활동ID (PK 겸 FK)', -- [cite: 468]
    location VARCHAR(255) NOT NULL COMMENT '활동 장소', -- [cite: 470]
    FOREIGN KEY (activity_id) REFERENCES Activity(activity_id) ON DELETE CASCADE
);

-- 5. 온라인 활동 (Online_Activity) 테이블 (ISA 일반화 반영) [cite: 465, 471]
CREATE TABLE Online_Activity (
    activity_id INT PRIMARY KEY COMMENT '활동ID (PK 겸 FK)', -- [cite: 468]
    platform VARCHAR(100) NOT NULL COMMENT '사용 플랫폼', -- [cite: 472]
    FOREIGN KEY (activity_id) REFERENCES Activity(activity_id) ON DELETE CASCADE
);

-- 6. 사용자 목적 (User_Goal) 테이블 [cite: 372]
CREATE TABLE User_Goal (
    goal_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '목적 설정 기록 ID', -- [cite: 373]
    user_id VARCHAR(50) NOT NULL COMMENT '해당 사용자', -- [cite: 374]
    current_goal VARCHAR(50) NOT NULL COMMENT '자기계발/번아웃 등 상태', -- [cite: 375]
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '설정 변경 시점', -- [cite: 376]
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- 7. 사용자 만족도 (User_Satisfaction) 테이블 [cite: 363]
CREATE TABLE User_Satisfaction (
    satisfaction_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '선호도 기록 고유 번호', -- [cite: 364]
    user_id VARCHAR(50) NOT NULL COMMENT '선호도의 주인인 사용자 식별', -- [cite: 364]
    category_id INT NOT NULL COMMENT '선호 대상인 카테고리 식별', -- [cite: 364]
    satisfaction_score INT NOT NULL COMMENT '만족도 기반으로 계산된 가중치', -- [cite: 364]
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE CASCADE
);

-- 8. 추천 (Recommendation) 테이블 [cite: 384]
-- 다대다 관계를 해소하고 속성을 포함하기 위한 교차 테이블 역할 수행 [cite: 480]
CREATE TABLE Recommendation (
    recommendation_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '활동 추천 고유번호', -- [cite: 388]
    user_id VARCHAR(50) NOT NULL COMMENT '추천받은 사용자',
    activity_id INT NOT NULL COMMENT '추천된 활동',
    weather VARCHAR(50) COMMENT '당시 기상 정보', -- [cite: 385]
    user_condition VARCHAR(50) COMMENT '사용자의 당시 상태/기분', -- [cite: 386]
    recommended_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '추천이 발생한 시각', -- [cite: 387]
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    FOREIGN KEY (activity_id) REFERENCES Activity(activity_id) ON DELETE CASCADE
);

-- 9. 수행 기록 (Exec_Log) 테이블 [cite: 345]
CREATE TABLE Exec_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '수행 완료 기록 ID', -- [cite: 346]
    recommendation_id INT COMMENT '사용자 및 활동 정보를 참조하기 위한 추천 식별자', -- 
    executed_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '완료 버튼을 누른 시각', -- 
    FOREIGN KEY (recommendation_id) REFERENCES Recommendation(recommendation_id) ON DELETE SET NULL -- NULL 허용 반영 
);

-- 10. 거절 기록 (Rejection_Log) 테이블 [cite: 354]
CREATE TABLE Rejection_Log (
    rejection_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '거절 기록 고유 식별자', -- [cite: 355]
    recommendation_id INT NOT NULL COMMENT '어떤 추천 내역을 거절했는지 식별', -- [cite: 356]
    rejected_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '싫어요 버튼을 누른 시각', -- [cite: 356]
    FOREIGN KEY (recommendation_id) REFERENCES Recommendation(recommendation_id) ON DELETE CASCADE
);
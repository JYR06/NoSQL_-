<<<<<<< HEAD
-- --------------------------------------------------------
-- 호스트:                          127.0.0.1
-- 서버 버전:                        11.8.6-MariaDB - MariaDB Server
-- 서버 OS:                        Win64
-- HeidiSQL 버전:                  12.14.0.7165
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- 테이블 now_db.activity 구조 내보내기
DROP TABLE IF EXISTS `activity`;
CREATE TABLE IF NOT EXISTS `activity` (
  `activity_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '활동 고유 번호',
  `activity_name` varchar(100) NOT NULL COMMENT '구체적인 할 일 이름',
  `duration` int(11) DEFAULT NULL COMMENT '예상 활동 시간(분)',
  `intensity` varchar(50) DEFAULT NULL COMMENT '활동 강도',
  `category_id` int(11) NOT NULL COMMENT '소속 카테고리 참조',
  PRIMARY KEY (`activity_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `activity_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.category 구조 내보내기
DROP TABLE IF EXISTS `category`;
CREATE TABLE IF NOT EXISTS `category` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '카테고리 고유 번호',
  `category_name` varchar(50) NOT NULL COMMENT '운동, 독서, 영화 등',
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.exec_log 구조 내보내기
DROP TABLE IF EXISTS `exec_log`;
CREATE TABLE IF NOT EXISTS `exec_log` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '수행 완료 기록 ID',
  `recommendation_id` int(11) DEFAULT NULL COMMENT '추천 식별자',
  `executed_at` datetime DEFAULT current_timestamp() COMMENT '완료 시각',
  PRIMARY KEY (`log_id`),
  KEY `recommendation_id` (`recommendation_id`),
  CONSTRAINT `exec_log_ibfk_1` FOREIGN KEY (`recommendation_id`) REFERENCES `recommendation` (`recommendation_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.offlineactivity 구조 내보내기
DROP TABLE IF EXISTS `offlineactivity`;
CREATE TABLE IF NOT EXISTS `offlineactivity` (
  `activity_id` int(11) NOT NULL COMMENT '활동ID (PK 겸 FK)',
  `location` varchar(255) NOT NULL COMMENT '활동 장소',
  PRIMARY KEY (`activity_id`),
  CONSTRAINT `offlineactivity_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.onlineactivity 구조 내보내기
DROP TABLE IF EXISTS `onlineactivity`;
CREATE TABLE IF NOT EXISTS `onlineactivity` (
  `activity_id` int(11) NOT NULL COMMENT '활동ID (PK 겸 FK)',
  `platform` varchar(100) NOT NULL COMMENT '사용 플랫폼',
  PRIMARY KEY (`activity_id`),
  CONSTRAINT `onlineactivity_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.recommendation 구조 내보내기
DROP TABLE IF EXISTS `recommendation`;
CREATE TABLE IF NOT EXISTS `recommendation` (
  `recommendation_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '추천 고유번호',
  `user_id` varchar(50) NOT NULL COMMENT '추천받은 사용자',
  `activity_id` int(11) NOT NULL COMMENT '추천된 활동',
  `weather` varchar(50) DEFAULT NULL COMMENT '당시 기상 정보',
  `user_condition` varchar(50) DEFAULT NULL COMMENT '사용자의 당시 상태/기분',
  `recommended_at` datetime DEFAULT current_timestamp() COMMENT '추천 발생 시각',
  PRIMARY KEY (`recommendation_id`),
  KEY `user_id` (`user_id`),
  KEY `activity_id` (`activity_id`),
  CONSTRAINT `recommendation_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `recommendation_ibfk_2` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.rejection_log 구조 내보내기
DROP TABLE IF EXISTS `rejection_log`;
CREATE TABLE IF NOT EXISTS `rejection_log` (
  `rejection_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '거절 기록 ID',
  `recommendation_id` int(11) NOT NULL COMMENT '거절된 추천',
  `rejected_at` datetime DEFAULT current_timestamp() COMMENT '거절 시각',
  PRIMARY KEY (`rejection_id`),
  KEY `recommendation_id` (`recommendation_id`),
  CONSTRAINT `rejection_log_ibfk_1` FOREIGN KEY (`recommendation_id`) REFERENCES `recommendation` (`recommendation_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.user 구조 내보내기
DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` varchar(50) NOT NULL COMMENT '사용자 고유 식별자',
  `password` varchar(255) NOT NULL COMMENT '암호화된 계정 비밀번호',
  `name` varchar(50) NOT NULL COMMENT '사용자 실명',
  `email` varchar(100) NOT NULL COMMENT '고유 이메일 주소',
  `mbti` varchar(10) DEFAULT NULL COMMENT '성향 판별용 (I/E/중간)',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.usergoal 구조 내보내기
DROP TABLE IF EXISTS `usergoal`;
CREATE TABLE IF NOT EXISTS `usergoal` (
  `goal_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '목적 설정 기록 ID',
  `user_id` varchar(50) NOT NULL COMMENT '해당 사용자',
  `current_goal` varchar(50) NOT NULL COMMENT '자기계발/번아웃 등 상태',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '설정 변경 시점',
  PRIMARY KEY (`goal_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `usergoal_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.usersatisfaction 구조 내보내기
DROP TABLE IF EXISTS `usersatisfaction`;
CREATE TABLE IF NOT EXISTS `usersatisfaction` (
  `satisfaction_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '선호도 기록 고유 번호',
  `user_id` varchar(50) NOT NULL COMMENT '사용자 식별',
  `category_id` int(11) NOT NULL COMMENT '선호 대상 카테고리',
  `satisfaction_score` int(11) NOT NULL COMMENT '만족도 기반 가중치',
  PRIMARY KEY (`satisfaction_id`),
  KEY `user_id` (`user_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `usersatisfaction_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `usersatisfaction_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
=======
-- --------------------------------------------------------
-- 호스트:                          127.0.0.1
-- 서버 버전:                        11.8.6-MariaDB - MariaDB Server
-- 서버 OS:                        Win64
-- HeidiSQL 버전:                  12.14.0.7165
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- 테이블 now_db.activity 구조 내보내기
DROP TABLE IF EXISTS `activity`;
CREATE TABLE IF NOT EXISTS `activity` (
  `activity_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '활동 고유 번호',
  `activity_name` varchar(100) NOT NULL COMMENT '구체적인 할 일 이름',
  `duration` int(11) DEFAULT NULL COMMENT '예상 활동 시간(분)',
  `intensity` varchar(50) DEFAULT NULL COMMENT '활동 강도',
  `category_id` int(11) NOT NULL COMMENT '소속 카테고리 참조',
  PRIMARY KEY (`activity_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `activity_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.category 구조 내보내기
DROP TABLE IF EXISTS `category`;
CREATE TABLE IF NOT EXISTS `category` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '카테고리 고유 번호',
  `category_name` varchar(50) NOT NULL COMMENT '운동, 독서, 영화 등',
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.exec_log 구조 내보내기
DROP TABLE IF EXISTS `exec_log`;
CREATE TABLE IF NOT EXISTS `exec_log` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '수행 완료 기록 ID',
  `recommendation_id` int(11) DEFAULT NULL COMMENT '추천 식별자',
  `executed_at` datetime DEFAULT current_timestamp() COMMENT '완료 시각',
  PRIMARY KEY (`log_id`),
  KEY `recommendation_id` (`recommendation_id`),
  CONSTRAINT `exec_log_ibfk_1` FOREIGN KEY (`recommendation_id`) REFERENCES `recommendation` (`recommendation_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.offlineactivity 구조 내보내기
DROP TABLE IF EXISTS `offlineactivity`;
CREATE TABLE IF NOT EXISTS `offlineactivity` (
  `activity_id` int(11) NOT NULL COMMENT '활동ID (PK 겸 FK)',
  `location` varchar(255) NOT NULL COMMENT '활동 장소',
  PRIMARY KEY (`activity_id`),
  CONSTRAINT `offlineactivity_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.onlineactivity 구조 내보내기
DROP TABLE IF EXISTS `onlineactivity`;
CREATE TABLE IF NOT EXISTS `onlineactivity` (
  `activity_id` int(11) NOT NULL COMMENT '활동ID (PK 겸 FK)',
  `platform` varchar(100) NOT NULL COMMENT '사용 플랫폼',
  PRIMARY KEY (`activity_id`),
  CONSTRAINT `onlineactivity_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.recommendation 구조 내보내기
DROP TABLE IF EXISTS `recommendation`;
CREATE TABLE IF NOT EXISTS `recommendation` (
  `recommendation_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '추천 고유번호',
  `user_id` varchar(50) NOT NULL COMMENT '추천받은 사용자',
  `activity_id` int(11) NOT NULL COMMENT '추천된 활동',
  `weather` varchar(50) DEFAULT NULL COMMENT '당시 기상 정보',
  `user_condition` varchar(50) DEFAULT NULL COMMENT '사용자의 당시 상태/기분',
  `recommended_at` datetime DEFAULT current_timestamp() COMMENT '추천 발생 시각',
  PRIMARY KEY (`recommendation_id`),
  KEY `user_id` (`user_id`),
  KEY `activity_id` (`activity_id`),
  CONSTRAINT `recommendation_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `recommendation_ibfk_2` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.rejection_log 구조 내보내기
DROP TABLE IF EXISTS `rejection_log`;
CREATE TABLE IF NOT EXISTS `rejection_log` (
  `rejection_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '거절 기록 ID',
  `recommendation_id` int(11) NOT NULL COMMENT '거절된 추천',
  `rejected_at` datetime DEFAULT current_timestamp() COMMENT '거절 시각',
  PRIMARY KEY (`rejection_id`),
  KEY `recommendation_id` (`recommendation_id`),
  CONSTRAINT `rejection_log_ibfk_1` FOREIGN KEY (`recommendation_id`) REFERENCES `recommendation` (`recommendation_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.user 구조 내보내기
DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` varchar(50) NOT NULL COMMENT '사용자 고유 식별자',
  `password` varchar(255) NOT NULL COMMENT '암호화된 계정 비밀번호',
  `name` varchar(50) NOT NULL COMMENT '사용자 실명',
  `email` varchar(100) NOT NULL COMMENT '고유 이메일 주소',
  `mbti` varchar(10) DEFAULT NULL COMMENT '성향 판별용 (I/E/중간)',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.usergoal 구조 내보내기
DROP TABLE IF EXISTS `usergoal`;
CREATE TABLE IF NOT EXISTS `usergoal` (
  `goal_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '목적 설정 기록 ID',
  `user_id` varchar(50) NOT NULL COMMENT '해당 사용자',
  `current_goal` varchar(50) NOT NULL COMMENT '자기계발/번아웃 등 상태',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '설정 변경 시점',
  PRIMARY KEY (`goal_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `usergoal_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 now_db.usersatisfaction 구조 내보내기
DROP TABLE IF EXISTS `usersatisfaction`;
CREATE TABLE IF NOT EXISTS `usersatisfaction` (
  `satisfaction_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '선호도 기록 고유 번호',
  `user_id` varchar(50) NOT NULL COMMENT '사용자 식별',
  `category_id` int(11) NOT NULL COMMENT '선호 대상 카테고리',
  `satisfaction_score` int(11) NOT NULL COMMENT '만족도 기반 가중치',
  PRIMARY KEY (`satisfaction_id`),
  KEY `user_id` (`user_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `usersatisfaction_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `usersatisfaction_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 내보낼 데이터가 선택되어 있지 않습니다.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
>>>>>>> 1409d248ad728e7b7af77e8453760784e963c6e3

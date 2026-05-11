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


-- now_db 데이터베이스 구조 내보내기
DROP DATABASE IF EXISTS `now_db`;
CREATE DATABASE IF NOT EXISTS `now_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;
USE `now_db`;

-- 테이블 now_db.activity 구조 내보내기
DROP TABLE IF EXISTS `activity`;
CREATE TABLE IF NOT EXISTS `activity` (
  `activity_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '활동 고유 번호',
  `activity_name` varchar(100) NOT NULL COMMENT '활동명',
  `duration` int(11) DEFAULT NULL COMMENT '예상 소요시간(분)',
  `intensity` varchar(10) DEFAULT NULL COMMENT '활동 강도 (상/중/하)',
  `category_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`activity_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `activity_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.activity:~100 rows (대략적) 내보내기
INSERT INTO `activity` (`activity_id`, `activity_name`, `duration`, `intensity`, `category_id`) VALUES
	(1, '공원 산책하기', 30, '하', 1),
	(2, '최신 영화 관람하기', 150, '하', 2),
	(3, '동네 한 바퀴 조깅', 40, '상', 1),
	(4, '카페에서 독서하기', 60, '하', 3),
	(5, '유튜브/OTT 정주행', 90, '하', 4),
	(6, '코인노래방 가기', 30, '중', 3),
	(7, '미술 전시회 관람', 120, '하', 2),
	(8, '근처 등산로 트레킹', 180, '상', 1),
	(9, '모바일 게임 한판', 30, '하', 3),
	(10, '짧은 낮잠 자기', 20, '하', 4),
	(11, '맛집 탐방하기', 90, '하', 5),
	(12, '사진 찍으러 출사 가기', 120, '중', 3),
	(13, '헬스장에서 근력 운동', 60, '상', 1),
	(14, '명상 및 스트레칭', 15, '하', 4),
	(15, '쇼핑몰 구경하기', 120, '중', 5),
	(16, '보드게임 카페 가기', 90, '하', 3),
	(17, '자전거 타기', 60, '중', 1),
	(18, '악기 연습하기', 45, '중', 3),
	(19, '도심 야경 감상하기', 60, '하', 5),
	(20, '웹툰 보며 쉬기', 30, '하', 4),
	(21, '동네 수영장 수영', 50, '상', 1),
	(22, '박물관 투어', 90, '하', 2),
	(23, '요리/베이킹 하기', 60, '중', 3),
	(24, '창밖 보며 멍 때리기', 10, '하', 4),
	(25, '드라이브 가기', 60, '하', 5),
	(26, '테니스/배드민턴', 60, '상', 1),
	(27, '연극/뮤지컬 관람', 160, '하', 2),
	(28, '컬러링북/그림 그리기', 60, '하', 3),
	(29, '반신욕/족욕 하기', 40, '하', 4),
	(30, '테마파크/놀이공원', 240, '상', 5),
	(31, '볼링 치기', 60, '중', 1),
	(32, '도서관에서 책 빌리기', 40, '하', 2),
	(33, '다이어리/글 쓰기', 30, '하', 3),
	(34, '음악 감상하며 휴식', 30, '하', 4),
	(35, '로컬 시장 구경하기', 60, '중', 5),
	(36, '스케이트/롤러 타기', 60, '중', 1),
	(37, '길거리 공연 감상', 30, '하', 2),
	(38, '퍼즐/프라모델 맞추기', 60, '하', 3),
	(39, '향기로운 차 마시기', 20, '하', 4),
	(40, '팝업스토어 방문하기', 60, '중', 5),
	(41, '스쿼시/라켓볼', 45, '상', 1),
	(42, '고궁/유적지 산책', 120, '하', 2),
	(43, '가드닝/식물 가꾸기', 30, '중', 3),
	(44, '따뜻한 물로 샤워하기', 20, '하', 4),
	(45, '소품샵 투어하기', 40, '중', 5),
	(46, '탁구 게임 하기', 40, '중', 1),
	(47, '도심 속 사찰 방문', 60, '하', 2),
	(48, '뜨개질/자수 하기', 60, '하', 3),
	(49, '반려동물과 놀아주기', 30, '중', 4),
	(50, '벤치에 앉아 사람들 구경', 20, '하', 5),
	(51, '실내 클라이밍 체험', 60, '상', 1),
	(52, '수채화 원데이 클래스', 90, '하', 3),
	(53, '도자기 공방 물레 체험', 120, '중', 3),
	(54, '전통 시장 먹거리 투어', 90, '중', 5),
	(55, '프로야구 경기 직관', 180, '중', 2),
	(56, '기구 필라테스 강습', 50, '상', 1),
	(57, '정밀 종이접기 연습', 40, '하', 3),
	(58, '프랑스 자수 소품 만들기', 90, '하', 3),
	(59, '숲 해설 프로그램 참여', 90, '하', 4),
	(60, '골프 연습장 연습', 60, '중', 1),
	(61, '독립 서점 투어', 60, '하', 2),
	(62, '만화 카페 시리즈 정주행', 120, '하', 3),
	(63, '수제 향수 만들기', 90, '하', 3),
	(64, '가죽 지갑 공예', 150, '중', 3),
	(65, '친구들과 풋살 게임', 90, '상', 1),
	(66, '길거리 농구 대결', 60, '상', 1),
	(67, '당구/포켓볼 치기', 60, '하', 3),
	(68, '스크린 야구 연습', 40, '중', 3),
	(69, '차박 캠핑 떠나기', 300, '중', 5),
	(70, '지역 문화 축제 구경', 120, '중', 5),
	(71, '클래식 실황 감상', 150, '하', 2),
	(72, '캘리그라피 연습', 60, '하', 3),
	(73, '보태니컬 아트 그리기', 120, '하', 3),
	(74, '천연 비누 공예', 90, '하', 3),
	(75, '플리마켓 구경하기', 60, '하', 5),
	(76, '산책로 둘레길 완주', 90, '중', 1),
	(77, '주말 농장 가꾸기', 120, '중', 3),
	(78, '반려식물 분갈이', 40, '중', 4),
	(79, '방 탈출 게임', 60, '상', 3),
	(80, '드론 촬영 연습', 60, '하', 3),
	(81, '크루저보드 타기', 60, '중', 1),
	(82, '크로스핏 운동', 60, '상', 1),
	(83, '줌바 댄스 클래스', 50, '상', 1),
	(84, '홈 요가 스트레칭', 40, '하', 4),
	(85, '아로마 캔들 휴식', 30, '하', 4),
	(86, '인센스 명상하기', 20, '하', 4),
	(87, '셀프 네일 아트', 90, '하', 3),
	(88, '3D 펜 소품 제작', 60, '하', 3),
	(89, '가구 조립/리폼', 120, '중', 3),
	(90, '수집품 정리하기', 60, '하', 3),
	(91, '실내 낚시 카페', 90, '하', 3),
	(92, '실내 사격 체험', 30, '중', 3),
	(93, '양궁 카페 체험', 40, '중', 1),
	(94, '패들보드 강습', 120, '상', 1),
	(95, '워터파크 물놀이', 300, '중', 5),
	(96, '아쿠아리움 관람', 120, '하', 2),
	(97, '테마 동물원 구경', 180, '중', 2),
	(98, '전망대 방문하기', 60, '하', 5),
	(99, '한강 유람선 투어', 60, '하', 5),
	(100, '골목 맛집 탐방', 90, '하', 5);

-- 테이블 now_db.category 구조 내보내기
DROP TABLE IF EXISTS `category`;
CREATE TABLE IF NOT EXISTS `category` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '카테고리 고유 번호',
  `category_name` varchar(50) NOT NULL COMMENT '카테고리명 (운동, 독서 등)',
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.category:~5 rows (대략적) 내보내기
INSERT INTO `category` (`category_id`, `category_name`) VALUES
	(1, '운동 및 산책'),
	(2, '문화 및 예술'),
	(3, '취미 및 오락'),
	(4, '휴식 및 재충전'),
	(5, '관광 및 기타');

-- 테이블 now_db.generaluser 구조 내보내기
DROP TABLE IF EXISTS `generaluser`;
CREATE TABLE IF NOT EXISTS `generaluser` (
  `user_id` varchar(50) NOT NULL,
  `rem_recom_count` int(11) DEFAULT 10 COMMENT '추천 잔여 횟수',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `generaluser_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.generaluser:~0 rows (대략적) 내보내기

-- 테이블 now_db.offlineactivity 구조 내보내기
DROP TABLE IF EXISTS `offlineactivity`;
CREATE TABLE IF NOT EXISTS `offlineactivity` (
  `activity_id` int(11) NOT NULL,
  `address` varchar(255) DEFAULT NULL COMMENT '활동 장소/주소',
  PRIMARY KEY (`activity_id`),
  CONSTRAINT `offlineactivity_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.offlineactivity:~0 rows (대략적) 내보내기

-- 테이블 now_db.onlineactivity 구조 내보내기
DROP TABLE IF EXISTS `onlineactivity`;
CREATE TABLE IF NOT EXISTS `onlineactivity` (
  `activity_id` int(11) NOT NULL,
  `platform` varchar(100) DEFAULT NULL COMMENT '사용 플랫폼 (유튜브, 앱 등)',
  PRIMARY KEY (`activity_id`),
  CONSTRAINT `onlineactivity_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.onlineactivity:~0 rows (대략적) 내보내기

-- 테이블 now_db.premiumuser 구조 내보내기
DROP TABLE IF EXISTS `premiumuser`;
CREATE TABLE IF NOT EXISTS `premiumuser` (
  `user_id` varchar(50) NOT NULL,
  `sub_start_date` date DEFAULT NULL COMMENT '구독 시작일',
  `grade` varchar(20) DEFAULT NULL COMMENT '구독 등급',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `premiumuser_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.premiumuser:~0 rows (대략적) 내보내기

-- 테이블 now_db.recommendation 구조 내보내기
DROP TABLE IF EXISTS `recommendation`;
CREATE TABLE IF NOT EXISTS `recommendation` (
  `recommendation_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '추천 고유 번호',
  `user_id` varchar(50) NOT NULL,
  `activity_id` int(11) NOT NULL,
  `weather` varchar(20) DEFAULT NULL COMMENT '추천 당시 날씨',
  `condition_status` varchar(50) DEFAULT NULL COMMENT '사용자 당시 컨디션',
  `recommendation_time` datetime DEFAULT current_timestamp() COMMENT '추천 발생 시각',
  PRIMARY KEY (`recommendation_id`),
  KEY `user_id` (`user_id`),
  KEY `activity_id` (`activity_id`),
  CONSTRAINT `recommendation_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `recommendation_ibfk_2` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.recommendation:~0 rows (대략적) 내보내기

-- 테이블 now_db.user 구조 내보내기
DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` varchar(50) NOT NULL COMMENT '사용자 아이디',
  `password` varchar(255) NOT NULL COMMENT '비밀번호',
  `name` varchar(50) NOT NULL COMMENT '사용자 이름',
  `email` varchar(100) NOT NULL COMMENT '이메일 주소',
  `mbti` char(4) DEFAULT NULL COMMENT '사용자 MBTI 성향',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.user:~0 rows (대략적) 내보내기

-- 테이블 now_db.usergoal 구조 내보내기
DROP TABLE IF EXISTS `usergoal`;
CREATE TABLE IF NOT EXISTS `usergoal` (
  `goal_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) DEFAULT NULL,
  `current_goal` varchar(50) DEFAULT NULL COMMENT '자기계발형, 번아웃 등',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`goal_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `usergoal_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.usergoal:~0 rows (대략적) 내보내기

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

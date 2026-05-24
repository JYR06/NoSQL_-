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
CREATE DATABASE IF NOT EXISTS `now_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `now_db`;

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

-- 테이블 데이터 now_db.activity:~99 rows (대략적) 내보내기
DELETE FROM `activity`;
INSERT INTO `activity` (`activity_id`, `activity_name`, `duration`, `intensity`, `category_id`) VALUES
	(1, '낮잠 자기', 30, '하', 1),
	(2, '가만히 멍때리기', 15, '하', 1),
	(3, '명상하기', 15, '하', 1),
	(4, '좋아하는 음악 감상', 30, '하', 1),
	(5, 'ASMR 들으며 휴식', 20, '하', 1),
	(6, '웹툰 정주행', 45, '하', 1),
	(7, '유튜브 알고리즘 탐험', 60, '하', 1),
	(8, '넷플릭스/OTT 시청', 90, '하', 1),
	(9, '감정 일기 쓰기', 20, '하', 1),
	(10, '따뜻한 물로 반신욕', 40, '하', 1),
	(11, '가벼운 전신 스트레칭', 15, '하', 1),
	(12, '반려동물과 교감하기', 30, '하', 1),
	(13, '따뜻한 차/커피 마시기', 20, '하', 1),
	(14, '창밖 풍경 구경하기', 10, '하', 1),
	(15, '향 피우기(인센스/캔들)', 30, '하', 1),
	(16, '헬스장 웨이트 트레이닝', 60, '상', 2),
	(17, '런닝머신(트레드밀) 뛰기', 40, '중', 2),
	(18, '가벼운 야외 러닝', 45, '상', 2),
	(19, '동네 산책하기', 30, '하', 2),
	(20, '홈트레이닝 (유튜브)', 30, '중', 2),
	(21, '요가 수련', 45, '중', 2),
	(22, '필라테스', 50, '중', 2),
	(23, '수영하기', 60, '상', 2),
	(24, '자전거 라이딩', 60, '중', 2),
	(25, '근교 산 등산', 120, '상', 2),
	(26, '배드민턴 치기', 60, '상', 2),
	(27, '볼링 치기', 60, '중', 2),
	(28, '실내 클라이밍', 90, '상', 2),
	(29, '테니스 치기', 60, '상', 2),
	(30, '축구/풋살', 90, '상', 2),
	(31, '농구', 60, '상', 2),
	(32, '줄넘기', 20, '중', 2),
	(33, '계단 오르기', 20, '중', 2),
	(34, '스쿼트 100개', 15, '중', 2),
	(35, '폼롤러 마사지', 20, '하', 2),
	(36, '모바일 게임하기', 30, '하', 3),
	(37, 'PC 게임(롤/발로란트 등)', 60, '중', 3),
	(38, '콘솔 게임(닌텐도/플스)', 60, '하', 3),
	(39, '보드게임', 90, '하', 3),
	(40, '퍼즐 맞추기', 60, '하', 3),
	(41, '레고/프라모델 조립', 60, '하', 3),
	(42, '홈베이킹(쿠키/빵)', 90, '중', 3),
	(43, '나만의 요리 만들기', 60, '중', 3),
	(44, '핸드드립 커피 내리기', 20, '하', 3),
	(45, '캘리그라피 연습', 30, '하', 3),
	(46, '뜨개질/코바늘', 60, '하', 3),
	(47, '디지털 드로잉(아이패드)', 60, '하', 3),
	(48, '컬러링북 색칠하기', 45, '하', 3),
	(49, '피아노 등 악기 연주', 45, '중', 3),
	(50, '스마트폰으로 풍경 사진 촬영', 30, '하', 3),
	(51, '일상 블로그 포스팅', 45, '중', 3),
	(52, '짧은 브이로그 편집', 60, '중', 3),
	(53, '방탈출 카페 가기', 60, '중', 3),
	(54, '코인노래방 가기', 30, '중', 3),
	(55, '오프라인 아이쇼핑', 60, '중', 3),
	(56, '온라인 쇼핑 장바구니 담기', 30, '하', 3),
	(57, '중고거래 앱 둘러보기', 20, '하', 3),
	(58, '새로운 맛집 탐방', 90, '중', 3),
	(59, '예쁜 카페 투어', 60, '하', 3),
	(60, '영화관에서 최신 개봉작 관람', 120, '하', 4),
	(61, '소극장 연극 관람', 100, '하', 4),
	(62, '뮤지컬 관람', 150, '하', 4),
	(63, '전시회 관람', 90, '하', 4),
	(64, '가까운 박물관 견학', 60, '하', 4),
	(65, '종이책 독서', 45, '하', 4),
	(66, '전자책(E-book) 읽기', 30, '하', 4),
	(67, '오디오북 들으며 휴식', 45, '하', 4),
	(68, '짧은 시/수필 쓰기', 30, '중', 4),
	(69, '성수/홍대 팝업스토어 방문', 60, '중', 4),
	(70, '가죽/도자기 원데이 클래스', 120, '중', 4),
	(71, '향수 만들기 체험', 60, '하', 4),
	(72, '동네 독립서점 구경하기', 45, '하', 4),
	(73, '공공 도서관 방문', 60, '하', 4),
	(74, '오케스트라/클래식 공연 관람', 120, '하', 4),
	(75, '영어 단어 30개 암기', 20, '중', 5),
	(76, '전화/화상 외국어 회화', 30, '상', 5),
	(77, '어학 자격증(토익 등) 공부', 60, '상', 5),
	(78, '온라인 코딩 강의 수강', 60, '상', 5),
	(79, '알고리즘 1문제 풀기', 45, '상', 5),
	(80, '오늘의 경제 기사 3편 읽기', 30, '중', 5),
	(81, '관심 기업 주식/재무 차트 분석', 45, '상', 5),
	(82, '재테크/부동산 유튜브 시청', 30, '중', 5),
	(83, 'TED 강연 1편 시청', 20, '중', 5),
	(84, '직무 관련 자격증 공부', 60, '상', 5),
	(85, '구독 중인 뉴스레터 읽기', 15, '하', 5),
	(86, '스터디 카페에서 개인 작업', 120, '중', 5),
	(87, '온라인 독서 모임 참여', 60, '중', 5),
	(88, '주간 플래너/다이어리 정리', 20, '하', 5),
	(89, '노션(Notion) 개인 페이지 꾸미기', 45, '중', 5),
	(90, '친한 친구와 전화 수다', 30, '하', 6),
	(91, '가까운 지인과 저녁 약속', 120, '중', 6),
	(92, '공원 돗자리 피크닉', 120, '하', 6),
	(93, '목적지 없이 드라이브', 60, '하', 6),
	(94, '주말 근교 여행', 240, '중', 6),
	(95, '식물원/수목원 산책', 90, '하', 6),
	(96, '호캉스(호텔 휴식)', 240, '하', 6),
	(97, '당일치기 캠핑/글램핑', 240, '중', 6),
	(98, '밤하늘 별 구경하기', 30, '하', 6),
	(99, '도심 야경 감상하기', 45, '하', 6);

-- 테이블 now_db.category 구조 내보내기
DROP TABLE IF EXISTS `category`;
CREATE TABLE IF NOT EXISTS `category` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '카테고리 고유 번호',
  `category_name` varchar(50) NOT NULL COMMENT '운동, 독서, 영화 등',
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.category:~6 rows (대략적) 내보내기
DELETE FROM `category`;
INSERT INTO `category` (`category_id`, `category_name`) VALUES
	(1, '휴식'),
	(2, '운동'),
	(3, '취미/오락'),
	(4, '문화/예술'),
	(5, '자기계발'),
	(6, '사교/나들이');

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

-- 테이블 데이터 now_db.exec_log:~0 rows (대략적) 내보내기
DELETE FROM `exec_log`;

-- 테이블 now_db.offlineactivity 구조 내보내기
DROP TABLE IF EXISTS `offlineactivity`;
CREATE TABLE IF NOT EXISTS `offlineactivity` (
  `activity_id` int(11) NOT NULL COMMENT '활동ID (PK 겸 FK)',
  `location` varchar(255) NOT NULL COMMENT '활동 장소',
  PRIMARY KEY (`activity_id`),
  CONSTRAINT `offlineactivity_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.offlineactivity:~71 rows (대략적) 내보내기
DELETE FROM `offlineactivity`;
INSERT INTO `offlineactivity` (`activity_id`, `location`) VALUES
	(1, '집'),
	(2, '실내'),
	(9, '실내'),
	(10, '집'),
	(11, '실내'),
	(12, '집'),
	(13, '근처 카페 또는 집'),
	(14, '실내'),
	(15, '집'),
	(16, '근처 헬스장'),
	(17, '근처 헬스장'),
	(18, '근처 공원/산책로'),
	(19, '집 근처 동네'),
	(21, '요가원 또는 집'),
	(22, '필라테스 센터'),
	(23, '실내 수영장'),
	(24, '자전거 도로/공원'),
	(25, '근교 산'),
	(26, '배드민턴장/공원'),
	(27, '볼링장'),
	(28, '클라이밍 센터'),
	(29, '테니스장'),
	(30, '풋살장/운동장'),
	(31, '농구장'),
	(32, '집 앞 공터'),
	(33, '아파트/건물 계단'),
	(34, '실내'),
	(35, '집'),
	(38, '집'),
	(39, '보드게임 카페/집'),
	(40, '집'),
	(41, '집'),
	(42, '집'),
	(43, '집'),
	(44, '집'),
	(45, '실내'),
	(46, '집/카페'),
	(48, '실내'),
	(49, '연주 공간'),
	(50, '근처 야외'),
	(53, '방탈출 카페'),
	(54, '근처 코인노래방'),
	(55, '백화점/복합쇼핑몰'),
	(58, '핫플레이스 식당'),
	(59, '분위기 좋은 카페'),
	(60, '근처 영화관'),
	(61, '대학로 등 소극장'),
	(62, '대형 공연장'),
	(63, '미술관/전시장'),
	(64, '박물관'),
	(65, '집 또는 카페'),
	(68, '실내'),
	(69, '팝업스토어 매장'),
	(70, '공방'),
	(71, '향수 공방'),
	(72, '독립서점'),
	(73, '시립/구립 도서관'),
	(74, '콘서트홀'),
	(77, '도서관/집'),
	(84, '독서실/카페'),
	(86, '근처 스터디 카페'),
	(88, '실내'),
	(91, '식당/술집'),
	(92, '근처 대형 공원'),
	(93, '차 안'),
	(94, '시외 근교'),
	(95, '수목원'),
	(96, '호텔'),
	(97, '캠핑장'),
	(98, '어두운 야외/루프탑'),
	(99, '야경 명소/전망대');

-- 테이블 now_db.onlineactivity 구조 내보내기
DROP TABLE IF EXISTS `onlineactivity`;
CREATE TABLE IF NOT EXISTS `onlineactivity` (
  `activity_id` int(11) NOT NULL COMMENT '활동ID (PK 겸 FK)',
  `platform` varchar(100) NOT NULL COMMENT '사용 플랫폼',
  PRIMARY KEY (`activity_id`),
  CONSTRAINT `onlineactivity_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.onlineactivity:~28 rows (대략적) 내보내기
DELETE FROM `onlineactivity`;
INSERT INTO `onlineactivity` (`activity_id`, `platform`) VALUES
	(3, '유튜브/명상앱'),
	(4, '멜론/스포티파이 등'),
	(5, '유튜브'),
	(6, '네이버/카카오웹툰'),
	(7, '유튜브'),
	(8, '넷플릭스/티빙 등'),
	(20, '유튜브'),
	(36, '모바일 앱'),
	(37, 'PC 플랫폼'),
	(47, '드로잉 앱(프로크리에이트 등)'),
	(51, '네이버 블로그/티스토리'),
	(52, '영상 편집 앱/프로그램'),
	(56, '쇼핑 앱(무신사/지그재그 등)'),
	(57, '당근마켓/번개장터'),
	(66, '밀리의서재/리디북스 등'),
	(67, '윌라/스포티파이 등'),
	(75, '단어장 앱'),
	(76, '화상회의 앱(Zoom 등)'),
	(78, '인프런/유데미 등'),
	(79, '백준/프로그래머스'),
	(80, '뉴스 포털/신문 앱'),
	(81, 'MTS/HTS 앱'),
	(82, '유튜브'),
	(83, 'TED 웹사이트/앱'),
	(85, '이메일'),
	(87, '화상회의 앱(Zoom 등)'),
	(89, '노션(Notion)'),
	(90, '전화/카카오톡');

-- 테이블 now_db.recommendation 구조 내보내기
DROP TABLE IF EXISTS `recommendation`;
CREATE TABLE IF NOT EXISTS `recommendation` (
  `recommendation_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '추천 고유번호',
  `user_id` varchar(50) NOT NULL COMMENT '추천받은 사용자',
  `activity_id` int(11) NOT NULL COMMENT '추천된 활동',
  `weather` varchar(50) DEFAULT NULL COMMENT '당시 기상 정보',
  `condition_status` varchar(20) DEFAULT NULL,
  `recommended_at` datetime DEFAULT current_timestamp() COMMENT '추천 발생 시각',
  PRIMARY KEY (`recommendation_id`),
  KEY `user_id` (`user_id`),
  KEY `activity_id` (`activity_id`),
  CONSTRAINT `recommendation_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `recommendation_ibfk_2` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 now_db.recommendation:~1 rows (대략적) 내보내기
DELETE FROM `recommendation`;
INSERT INTO `recommendation` (`recommendation_id`, `user_id`, `activity_id`, `weather`, `condition_status`, `recommended_at`) VALUES
	(1, 'test1', 32, '맑음', '좋음', '2026-05-13 13:14:48');

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

-- 테이블 데이터 now_db.rejection_log:~0 rows (대략적) 내보내기
DELETE FROM `rejection_log`;

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

-- 테이블 데이터 now_db.user:~1 rows (대략적) 내보내기
DELETE FROM `user`;
INSERT INTO `user` (`user_id`, `password`, `name`, `email`, `mbti`) VALUES
	('test1', '1234', '홍길동', 'fdfd@fdfd', 'i');

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

-- 테이블 데이터 now_db.usergoal:~0 rows (대략적) 내보내기
DELETE FROM `usergoal`;

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

-- 테이블 데이터 now_db.usersatisfaction:~0 rows (대략적) 내보내기
DELETE FROM `usersatisfaction`;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

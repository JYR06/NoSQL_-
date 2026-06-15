// Flutter에서 Material Design UI를 사용하기 위한 패키지
import 'package:flutter/material.dart';
// JSON 데이터 인코딩/디코딩을 위한 라이브러리
import 'dart:convert';
// 서버(API)와 통신하기 위한 HTTP 패키지
import 'package:http/http.dart' as http;

void main() {
  runApp(const NowFlowApp());
}

void Function()? loginThemeRefresher;

// 앱 최상위 루트 위젯 및 테마 설정
class NowFlowApp extends StatefulWidget {
  const NowFlowApp({super.key});

  @override
  State<NowFlowApp> createState() => _NowFlowAppState();
}

class _NowFlowAppState extends State<NowFlowApp> {
  @override
  void initState() {
    super.initState();
    loginThemeRefresher = () {
      setState(() {});
    };
  }

  // 앱 최상위 루트 테마 설정 및 초기 화면 라우팅 UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NowFlow',
      themeMode: AppData.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primaryColor: const Color(0xFF62BC47),
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF62BC47),
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: const LoginPage(),
    );
  }
}

// 전역 데이터 및 세션 정보 저장소
class AppData {
  static const String baseUrl = "https://nosql-749h.onrender.com";
  static String currentUserId = "";
  static String currentUserName = "사용자";
  static String currentGoal = "선택장애형";
  static int currentRecommendationId = 0;
  static int currentActivityId = 0;
  static String currentActivityName = "";
  static String currentReason = "";
  static bool isDarkMode = false;
}

// 1. 로그인 화면 (인증 및 세션 초기화)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  // 백엔드 로그인 API 요청 및 사용자 데이터 라우팅
  Future<void> requestLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("이메일과 비밀번호를 모두 입력해주세요.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse("${AppData.baseUrl}/auth/login");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        AppData.currentUserId = data["user_id"] ?? "";
        AppData.currentUserName = data["name"] ?? "사용자";
        AppData.currentGoal = data["goal"] ?? "선택장애형";

        _showSnackBar("${AppData.currentUserName}님, 환영합니다!");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        _showSnackBar("실패: ${errorData["detail"] ?? "로그인 정보 오류"}");
      }
    } catch (e) {
      _showSnackBar("서ver 연결 실패. 인터넷을 확인해주세요.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // 로그인 화면 UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Text('지금 뭐해?', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text('자투리 시간을 특별하게,\n나에게 딱 맞는 활동 추천!', style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : Colors.black87, height: 1.4), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              const Center(child: Icon(Icons.pets, size: 100, color: Color(0xFF62BC47))),
              const SizedBox(height: 40),
              TextField(controller: _emailController, decoration: _inputDecoration('이메일을 입력하세요')),
              const SizedBox(height: 12),
              TextField(controller: _passwordController, obscureText: true, decoration: _inputDecoration('비밀번호를 입력하세요')),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)))
                  : ElevatedButton(
                onPressed: requestLogin,
                style: _btnStyle(),
                child: const Text('시작하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('계정이 없으신가요? ', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                    child: Text('회원가입', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, decoration: TextDecoration.underline)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 2. 회원가입 화면 (사용자 계정 생성)
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  // 신규 회원 등록 API 호출 및 관심사 설정 화면 연동
  Future<void> requestSignup() async {
    final String email = _emailController.text.trim();
    final String name = _nameController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("모든 칸을 채워주세요.")));
      return;
    }

    setState(() => isLoading = true);
    try {
      final url = Uri.parse("${AppData.baseUrl}/auth/signup");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "name": name, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        AppData.currentUserId = data["user_id"] ?? "";
        AppData.currentUserName = name;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"] ?? "회원가입 완료!")));
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencePage()));
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("가입 실패: ${errorData["detail"]}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("연결 오류: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 회원가입 화면 UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text('회원가입', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('나에게 딱 맞는 활동 추천을 위해\n정보를 입력해주세요!', style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.black54, height: 1.4), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              TextField(controller: _emailController, decoration: _inputDecoration('이메일을 입력하세요')),
              const SizedBox(height: 12),
              TextField(controller: _nameController, decoration: _inputDecoration('사용자 이름을 입력하세요')),
              const SizedBox(height: 12),
              TextField(controller: _passwordController, obscureText: true, decoration: _inputDecoration('비밀번호를 입력하세요')),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)))
                  : ElevatedButton(
                onPressed: requestSignup,
                style: _btnStyle(),
                child: const Text('회원가입', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('이미 계정이 있으신가요? ', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('로그인', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, decoration: TextDecoration.underline)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 3. 성향 및 관심사 설정 화면 (초기 개인화 데이터 수집)
class PreferencePage extends StatefulWidget {
  const PreferencePage({super.key});

  @override
  State<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  String selectedGoal = "선택장애형";
  List<String> selectedInterests = ["자기계발"];
  final List<String> interests = ["운동/건강", "자기계발", "독서", "글쓰기", "여행", "음악", "요리", "IT/기술", "기타"];

  // 사용자가 선택한 성향(목표) 및 태그 정보 저장
  Future<void> saveInterestsToServer() async {
    try {
      final url = Uri.parse("${AppData.baseUrl}/users/interests");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppData.currentUserId,
          "tags": selectedInterests,
          "goal": selectedGoal,
        }),
      );

      if (response.statusCode == 200) {
        AppData.currentGoal = selectedGoal;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("관심사 저장 오류: $e")));
    }
  }

  // 성향 및 관심사 설정 화면 UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: isDark ? Colors.white : Colors.black),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('나를 더 잘 알면\n더 좋은 추천을 받을 수 있어요!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            const Center(child: Icon(Icons.assignment, size: 70, color: Color(0xFF62BC47))),
            const SizedBox(height: 20),
            const Text('현재 당신의 목표(상태)는 무엇인가요?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: ["번아웃형", "자기계발형", "선택장애형"].map((type) {
                bool isSel = selectedGoal == type;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: OutlinedButton(
                      onPressed: () => setState(() => selectedGoal = type),
                      style: _outlineStyle(isSel),
                      child: Text(type.replaceAll("형", ""), style: TextStyle(fontSize: 13, color: isSel ? const Color(0xFF62BC47) : (isDark ? Colors.white70 : Colors.black87), fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            const Text('관심 있는 분야를 선택해주세요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: Wrap(
                spacing: 8, runSpacing: 8,
                children: interests.map((interest) {
                  bool isSel = selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSel,
                    onSelected: (val) {
                      setState(() {
                        val ? selectedInterests.add(interest) : selectedInterests.remove(interest);
                      });
                    },
                    selectedColor: const Color(0xFF62BC47).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF62BC47),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: saveInterestsToServer,
              style: _btnStyle(),
              child: const Text('다음', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 4. 메인 화면 및 탭 내비게이션 (홈 컨트롤러)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 메인 스크린 탭 내비게이션 구조 및 바텀 바 UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(context),
            const HistoryPage(),
            const SavedActivitiesPage(),
            const MyPage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF62BC47),
        unselectedItemColor: isDark ? Colors.white60 : Colors.black45,
        backgroundColor: Theme.of(context).cardColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: '추천 기록'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '저장한 활동'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }

  // 메인 대시보드 홈 탭 내부 서브 UI
  Widget _buildHomeTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('안녕하세요, ${AppData.currentUserName}님', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text('오늘의 추천 키워드', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: const [
              _KeywordBadge('#집중력향상'), SizedBox(width: 8),
              _KeywordBadge('#힐링'), SizedBox(width: 8),
              _KeywordBadge('#소소한행복'),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConditionPage())),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF62BC47), borderRadius: BorderRadius.circular(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('활동 추천 받기', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 8),
                      Text('나에게 딱 맞는 활동을\n추천 받아 볼까요?', style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4)),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, size: 32, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('최근 추천 활동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
                future: fetchRecentHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("아직 추천받은 활동이 없습니다.", style: TextStyle(color: Colors.grey)));
                  }

                  final recentActivities = snapshot.data!.take(3).toList();
                  return ListView.builder(
                    itemCount: recentActivities.length,
                    itemBuilder: (context, index) {
                      final act = recentActivities[index];
                      final activityTitle = act["activity"] ?? act["activity_name"] ?? "추천 활동";
                      final conditionText = act["condition"] ?? "보통";
                      final dateText = act["date"] ?? "";

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                        color: Theme.of(context).cardColor,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF62BC47).withOpacity(0.1),
                            child: const Icon(Icons.check_circle_outline, color: Color(0xFF62BC47)),
                          ),
                          title: Text(activityTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("상태: $conditionText"),
                          trailing: Text(dateText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      );
                    },
                  );
                }
            ),
          )
        ],
      ),
    );
  }

  // 메인 대시보드용 최신 추천 데이터 가져오기
  Future<List<dynamic>> fetchRecentHistory() async {
    try {
      final url = Uri.parse("${AppData.baseUrl}/recommend/history/${AppData.currentUserId}");
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedData is Map) {
          if (decodedData.containsKey("data") && decodedData["data"] is List) return decodedData["data"];
          if (decodedData.containsKey("history") && decodedData["history"] is List) return decodedData["history"];
          if (decodedData.containsKey("result") && decodedData["result"] is List) return decodedData["result"];
          return [decodedData];
        }
        if (decodedData is List) return decodedData;
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

// 5. 추천 기록 화면 (전체 히스토리 뷰)
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // 누적된 모든 추천 로그와 사용자 별점 리스트 조회
  Future<List<dynamic>> fetchHistory() async {
    try {
      final url = Uri.parse("${AppData.baseUrl}/recommend/history/${AppData.currentUserId}");
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedData is Map) {
          if (decodedData.containsKey("data") && decodedData["data"] is List) return decodedData["data"];
          if (decodedData.containsKey("history") && decodedData["history"] is List) return decodedData["history"];
          if (decodedData.containsKey("result") && decodedData["result"] is List) return decodedData["result"];
          return [decodedData];
        }
        if (decodedData is List) return decodedData;
      }
      return [];
    } catch (e) {
      print("History 데이터 파싱 및 로드 중 예외 발생: $e");
      return [];
    }
  }

  // 추천 기록(히스토리 목록) 화면 UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('추천 기록', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('그동안 NowFlow와 함께한 시간들이에요.', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
                future: fetchHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)));
                  }
                  if (snapshot.hasError) return Center(child: Text("오류: ${snapshot.error}"));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("추천 기록이 비어있거나 없습니다.", style: TextStyle(color: Colors.grey)));
                  }

                  final historyData = snapshot.data!;
                  return ListView.builder(
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      final item = historyData[index];
                      final activityTitle = item["activity"] ?? item["activity_name"] ?? "추천 활동";
                      final conditionText = item["condition"] ?? "보통";
                      final dateText = item["date"] ?? "";

                      final rawRating = item["rating"] ?? item["review_rating"] ?? item["user_rating"];
                      final int ratingValue = rawRating != null ? int.parse(rawRating.toString()) : 5;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: const Color(0xFF62BC47).withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.history, color: Color(0xFF62BC47)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(activityTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('상태: $conditionText | 별점: ⭐ $ratingValue', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13)),
                                  ],
                                ),
                              ),
                              Text(dateText, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}

// 6. 저장한 활동 화면 (즐겨찾기 목록)
class SavedActivitiesPage extends StatelessWidget {
  const SavedActivitiesPage({super.key});

  // 사용자가 찜(북마크)한 북마크 리스트 호출
  Future<List<dynamic>> fetchSaved() async {
    try {
      final url = Uri.parse("${AppData.baseUrl}/activities/favorite/${AppData.currentUserId}");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final resData = jsonDecode(utf8.decode(response.bodyBytes));
        return resData["data"] ?? [];
      }
    } catch (_) {}
    return [];
  }

  // 저장한 활동(북마크/즐겨찾기 그리드 뷰) 화면 UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('저장한 활동', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('나중에 꼭 다시 해보고 싶은 활동 모음이에요.', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
                future: fetchSaved(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)));
                  if (snapshot.hasError) return Center(child: Text("오류: ${snapshot.error}"));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("아직 저장한 활동이 없어요. 하트를 눌러보세요!", style: TextStyle(color: Colors.grey)));

                  final savedData = snapshot.data!;
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: savedData.length,
                    itemBuilder: (context, index) {
                      final item = savedData[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Align(alignment: Alignment.topRight, child: Icon(Icons.favorite, color: Colors.redAccent)),
                            const Spacer(),
                            Text(item["activity_name"] ?? "활동명", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3)),
                            const SizedBox(height: 8),
                            Text(item["place_info"] ?? "", style: const TextStyle(fontSize: 12, color: Color(0xFF62BC47))),
                          ],
                        ),
                      );
                    },
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}

// 7. 마이페이지 화면 (사용자 정보 관리 및 성향 수정 인터페이스)
class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // 사용 가능한 성향 목록 정의
  final List<String> _goalOptions = ["번아웃형", "자기계발형", "선택장애형"];
  String? _currentGoal;
  bool _isUpdating = false;
  Future<Map<String, dynamic>>? _profileFuture;

  @override
  void initState() {
    super.initState();
    // 초기 프로필 데이터 로드 호출
    _profileFuture = fetchProfile();
  }

  // 유저 개인 프로필 및 성향 데이터 쿼리
  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final url = Uri.parse("${AppData.baseUrl}/users/profile/${AppData.currentUserId}");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // 서버에서 받아온 성향을 상태 변수에 동기화
        setState(() {
          _currentGoal = data["goal"] ?? AppData.currentGoal;
        });
        return data;
      }
    } catch (_) {}

    // 실패 시 로컬 캐시 데이터 반환
    setState(() {
      _currentGoal = AppData.currentGoal;
    });
    return {"name": AppData.currentUserName, "goal": AppData.currentGoal};
  }

  // 변경된 성향(목표) 데이터를 서버 및 로컬에 저장하는 함수
  Future<void> updateGoalOnServer(String newGoal) async {
    setState(() => _isUpdating = true);
    try {
      // 기존 3번 관심사 설정 API 아키텍처와 호환되는 엔드포인트 호출
      final url = Uri.parse("${AppData.baseUrl}/users/interests");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppData.currentUserId,
          "goal": newGoal,
          // tags의 경우 기존 데이터를 보존해야 하므로 우선 빈 배열 혹은 백엔드 스펙에 맞춤 처리
          "tags": [],
        }),
      );

      if (response.statusCode == 200) {
        // 서버 반영 성공 시 앱 전역 변수 및 로컬 상태 동기화
        AppData.currentGoal = newGoal;
        setState(() {
          _currentGoal = newGoal;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("추천 목표 성향이 '$newGoal'로 변경되었습니다.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("성향 변경 실패. 다시 시도해주세요.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("서버 연결 오류: $e")),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  // 마이페이지 화면 UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _currentGoal == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)));
          }

          final profile = snapshot.data ?? {"name": AppData.currentUserName, "goal": AppData.currentGoal};
          final displayName = profile["name"] ?? AppData.currentUserName;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF62BC47),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.flag, color: Color(0xFF62BC47)),
                          title: const Text('나의 추천 목표 성향', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('클릭하여 언제든지 변경할 수 있습니다.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: _isUpdating
                              ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Color(0xFF62BC47), strokeWidth: 2),
                          )
                          // 목표 설정 선택
                              : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _goalOptions.contains(_currentGoal) ? _currentGoal : _goalOptions.last,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                              onChanged: (String? newValue) {
                                if (newValue != null && newValue != _currentGoal) {
                                  updateGoalOnServer(newValue);
                                }
                              },
                              items: _goalOptions.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: Icon(Icons.settings, color: isDark ? Colors.white60 : Colors.grey),
                          title: const Text('앱 환경 설정'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsPage()),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.redAccent),
                          title: const Text('로그아웃', style: TextStyle(color: Colors.redAccent)),
                          onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}

// 8. 컨디션 선택 화면 (추천 필터 입력 단)
class ConditionPage extends StatefulWidget {
  const ConditionPage({super.key});

  @override
  State<ConditionPage> createState() => _ConditionPageState();
}

class _ConditionPageState extends State<ConditionPage> {
  String selectedMood = "보통";
  String selectedTime = "보통";
  String selectedEnv = "실내";
  bool isLoading = false;

  // 기분, 가용 시간, 장소 및 위치 정보를 기반으로 서버에 추천 요청
  Future<void> getSmartRecommendation() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse("${AppData.baseUrl}/recommend/");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppData.currentUserId,
          "condition": selectedMood,
          "time_preference": selectedTime,
          "place_preference": selectedEnv,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // 데이터 무매칭 등의 사유로 수동 화면 진입 시, 수집된 모든 파라미터(mood, time, env) 동시 전달
        if (data["action"] == "manual_selection") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => ManualSelectPage(
                    mood: selectedMood,
                    time: selectedTime,
                    env: selectedEnv,
                  )
              )
          );
          return;
        }

        AppData.currentRecommendationId = data["recommendation_id"];
        AppData.currentActivityId = data["activity_id"];
        AppData.currentActivityName = data["recommended_activity"];
        AppData.currentReason = data["reason"] ?? "현재 상태에 꼭 어울리는 활동이에요.";

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => RecommendationResultPage(
                  selectedMood: selectedMood,
                  selectedTime: selectedTime,
                  selectedEnv: selectedEnv,
                )
            )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("추천 실패. 조건에 맞는 활동 데이터가 없습니다.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("추천 요청 오류: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 컨디션 선택(사용자 다차원 상태값 서베이 폼) 화면 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)))
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('오늘 기분은 어떤가요?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('현재 상태에 맞는 활동을 추천해드릴게요.', style: TextStyle(color: Colors.black45, fontSize: 14)),
            const SizedBox(height: 24),
            const Text('기분 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["매우별로", "별로", "보통", "좋음", "매우좋음"].map((mood) {
                bool isSel = selectedMood == mood;
                return GestureDetector(
                  onTap: () => setState(() => selectedMood = mood),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: isSel ? const Color(0xFF62BC47).withOpacity(0.2) : Colors.white,
                        radius: 24,
                        child: Icon(Icons.sentiment_satisfied, color: isSel ? const Color(0xFF62BC47) : Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(mood, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('시간 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSelectBox('짧게', '10~30분', selectedTime == '짧게', () => setState(() => selectedTime = '짧게')),
                const SizedBox(width: 8),
                _buildSelectBox('보통', '30~60분', selectedTime == '보통', () => setState(() => selectedTime = '보통')),
                const SizedBox(width: 8),
                _buildSelectBox('여유롭게', '1시간 이상', selectedTime == '여유롭게', () => setState(() => selectedTime = '여유롭게')),
              ],
            ),
            const SizedBox(height: 24),
            const Text('환경 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSelectBox('🏠  실내', '', selectedEnv == '실내', () => setState(() => selectedEnv = '실내')),
                const SizedBox(width: 8),
                _buildSelectBox('🌲  실외', '', selectedEnv == '실외', () => setState(() => selectedEnv = '실외')),
                const SizedBox(width: 8),
                _buildSelectBox('상관없음', '', selectedEnv == '상관없음', () => setState(() => selectedEnv = '상관없음')),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: getSmartRecommendation,
              style: _btnStyle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('추천받기 ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectBox(String title, String sub, bool isSel, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSel ? const Color(0xFF62BC47) : Colors.black12, width: isSel ? 2 : 1),
          ),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
              if (sub.isNotEmpty) ...[const SizedBox(height: 4), Text(sub, style: const TextStyle(fontSize: 11, color: Colors.black38))],
            ],
          ),
        ),
      ),
    );
  }
}

// 9. 추천 결과 화면 (피드백 수집 및 다음 활동 라우팅)
class RecommendationResultPage extends StatefulWidget {
  final String selectedMood;
  final String selectedTime;
  final String selectedEnv;

  const RecommendationResultPage({
    super.key,
    this.selectedMood = "보통",
    this.selectedTime = "보통",
    this.selectedEnv = "상관없음",
  });

  @override
  State<RecommendationResultPage> createState() => _RecommendationResultPageState();
}

class _RecommendationResultPageState extends State<RecommendationResultPage> {
  bool isSaved = false;
  bool isRefreshing = false;
  bool isProcessingActivity = false;
  int _dislikeCount = 0;

  late String currentActivityName;
  late String currentReason;

  static List<int> rejectedActivityIds = [];

  @override
  void initState() {
    super.initState();
    currentActivityName = AppData.currentActivityName;
    currentReason = AppData.currentReason;
  }

  // 데이터 성향에 매핑되는 디자인 메타데이터 동적 변환
  Map<String, dynamic> _getDesignTheme(String reason) {
    if (reason.contains("휴식") || reason.contains("번아웃")) {
      return {"icon": Icons.king_bed, "color": Colors.blue.shade100, "iconColor": Colors.blue};
    } else if (reason.contains("자기계발") || reason.contains("IT")) {
      return {"icon": Icons.lightbulb, "color": Colors.yellow.shade100, "iconColor": Colors.amber};
    } else if (reason.contains("운동")) {
      return {"icon": Icons.directions_run, "color": Colors.green.shade100, "iconColor": Colors.green};
    }
    return {"icon": Icons.palette, "color": Colors.orange.shade100, "iconColor": Colors.orange};
  }

  // 현재 활동을 추천 로그 히스토리에 기록
  Future<void> sendActivityToHistory() async {
    if (isProcessingActivity) return;
    setState(() => isProcessingActivity = true);

    try {
      final url = Uri.parse("${AppData.baseUrl}/recommend/history");
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppData.currentUserId,
          "activity_id": AppData.currentActivityId,
          "condition": widget.selectedMood,
          "recommendation_id": AppData.currentRecommendationId
        }),
      );
    } catch (e) {
      print("추천 기록 명시적 저장 중 오류 발생: $e");
    } finally {
      setState(() => isProcessingActivity = false);
    }
  }

  // 거절(싫어요) 누적 시 기존 ID를 제외한 재생성 아키텍처
  Future<void> getNextRecommendation(BuildContext context) async {
    try {
      rejectedActivityIds.add(AppData.currentActivityId);
      final url = Uri.parse("${AppData.baseUrl}/recommend/");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppData.currentUserId,
          "condition": widget.selectedMood,
          "time_preference": widget.selectedTime,
          "place_preference": widget.selectedEnv,
          "exclude_ids": rejectedActivityIds
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // 거절 대응 로직의 수동 이동 분기 시에도 변수 누락 없이 온전히 매핑 처리
        if (data["action"] == "manual_selection") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => ManualSelectPage(
                      mood: widget.selectedMood,
                      time: widget.selectedTime,
                      env: widget.selectedEnv
                  )
              )
          );
          return;
        }

        setState(() {
          AppData.currentRecommendationId = data["recommendation_id"];
          AppData.currentActivityId = data["activity_id"];
          AppData.currentActivityName = data["recommended_activity"];
          AppData.currentReason = data["reason"] ?? "이전 활동을 제외하고 새로 추천된 활동이에요.";

          currentActivityName = AppData.currentActivityName;
          currentReason = AppData.currentReason;
          isSaved = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("조건에 맞는 다른 활동 데이터가 더 이상 없습니다.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("새 추천 요청 오류: $e")));
    }
  }

  // 좋아요/싫어요 인터랙션 전송 (싫어요 3회 누적 시 수동 풀로 이관)
  Future<void> sendFeedback(BuildContext context, bool isLiked) async {
    if (!isLiked) {
      _dislikeCount++;
      if (_dislikeCount >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("싫어요가 3회 누적되어 활동 직접 선택 화면으로 이동합니다.")),
        );
        // 싫어요 누적 초과로 수동 이관 시에도 사용자의 세부 옵션(time, env) 바인딩 유지
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ManualSelectPage(
                mood: widget.selectedMood,
                time: widget.selectedTime,
                env: widget.selectedEnv,
              )
          ),
        );
        return;
      }
    }

    setState(() => isRefreshing = true);

    try {
      if (isLiked) {
        await sendActivityToHistory();
      }

      final url = Uri.parse("${AppData.baseUrl}/feedback/");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppData.currentUserId,
          "recommendation_id": AppData.currentRecommendationId,
          "activity_id": AppData.currentActivityId,
          "is_liked": isLiked
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // 피드백 수신 데이터에 따른 강제 수동 풀 렌더링 스위치 시 데이터 유실 보완
        if (data["action"] == "manual_selection") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => ManualSelectPage(
                      mood: widget.selectedMood,
                      time: widget.selectedTime,
                      env: widget.selectedEnv
                  )
              )
          );
          return;
        }

        if (!isLiked) {
          await getNextRecommendation(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"] ?? "선호도가 반영되었습니다!")));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("피드백 전송 실패: $e")));
    } finally {
      setState(() => isRefreshing = false);
    }
  }

  // 즐겨찾기 상태 토글 스위치
  Future<void> toggleFavorite() async {
    try {
      final url = Uri.parse("${AppData.baseUrl}/activities/favorite");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppData.currentUserId,
          "activity_id": AppData.currentActivityId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() => isSaved = (data["action"] == "added"));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("즐겨찾기 실패: $e")));
    }
  }

  // 추천 결과(AI 매칭 콘텐츠 정보 및 피드백 액션) 화면 UI
  @override
  Widget build(BuildContext context) {
    final theme = _getDesignTheme(currentReason);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: isDark ? Colors.white : Colors.black, actions: [
        IconButton(
          icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent, size: 30),
          onPressed: toggleFavorite,
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('추천 활동', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(currentReason, style: TextStyle(color: isDark ? Colors.white54 : Colors.black45)),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: isRefreshing || isProcessingActivity
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)))
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 180, width: 180,
                      decoration: BoxDecoration(color: theme["color"], borderRadius: BorderRadius.circular(16)),
                      child: Icon(theme["icon"], size: 80, color: theme["iconColor"]),
                    ),
                    const SizedBox(height: 24),
                    Text(currentActivityName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text('추천된 활동이 마음에 드시나요?\n좋아요를 누르면 선호도가 올라갑니다.', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, height: 1.4), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: isRefreshing || isProcessingActivity ? null : () => sendFeedback(context, true), icon: const Icon(Icons.thumb_up_alt_outlined), label: const Text('좋아요'), style: _outlineStyle(false))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(onPressed: isRefreshing || isProcessingActivity ? null : () => sendFeedback(context, false), icon: const Icon(Icons.thumb_down_alt_outlined), label: const Text('싫어요'), style: _outlineStyle(false))),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isRefreshing || isProcessingActivity ? null : () async {
                await sendActivityToHistory();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SatisfactionPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF62BC47),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('활동 진행하기 ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 10. 수동 활동 선택 전용 화면 (하드코딩 풀을 완전히 파괴하고 GET /activities/manual API 연동)
class ManualSelectPage extends StatefulWidget {
  final String mood;
  final String time;
  final String env;

  const ManualSelectPage({
    super.key,
    required this.mood,
    required this.time,
    required this.env
  });

  @override
  State<ManualSelectPage> createState() => _ManualSelectPageState();
}

class _ManualSelectPageState extends State<ManualSelectPage> {
  // 💡 정적 리스트를 제거하고 서버의 데이터를 바인딩할 동적 풀 구성
  List<dynamic> _finalRandomPool = [];
  bool _isApiLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRandomActivitiesFromLiveServer(); // 초기 실행 시 연동 함수 호출
  }

  // [GET API 연동 처리 핵심 로직] Swagger 명세에 기술된 전용 API 호출
  Future<void> _fetchRandomActivitiesFromLiveServer() async {
    setState(() => _isApiLoading = true);

    try {
      // Swagger 문서 명세: GET /activities/manual 호출
      final url = Uri.parse("${AppData.baseUrl}/activities/manual");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 서버가 내려준 데이터 디코딩 처리
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

        // 받아온 리스트 원본 추출 (형태에 따라 리스트 자체가 오거나 특정 키 안에 들어올 수 있으므로 유연하게 매핑)
        List<dynamic> rawServerPool = [];
        if (decodedData is List) {
          rawServerPool = decodedData;
        } else if (decodedData is Map) {
          rawServerPool = decodedData["activities"] ?? decodedData["data"] ?? [];
        }

        // 서버에서 받아온 데이터 모수를 기반으로 유저가 ConditionPage에서 선택한 환경 조건(실내/실외) 필터 분기
        List<dynamic> localFiltered = rawServerPool.where((item) {
          // 서버 데이터의 place_preference, env, 혹은 유사 조건 필드가 필터와 매칭되는지 대조
          final String itemEnv = item["env"] ?? item["place_preference"] ?? "상관없음";
          return (widget.env == "상관없음" || itemEnv == "상관없음" || itemEnv == widget.env);
        }).toList();

        // 조건 필터링 후 가용 데이터가 부족하면 전체 수신 모수를 기본 사용하도록 안전 가드 적재
        if (localFiltered.isEmpty) {
          localFiltered = List.from(rawServerPool);
        }

        setState(() {
          // 실시간 랜덤성을 위해 수집된 필터 리스트를 뒤섞은(shuffle) 뒤 최상위 3종 추출
          localFiltered.shuffle();
          _finalRandomPool = localFiltered.take(3).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("활동 제공 API 통신에 실패했습니다.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 예외가 발생했습니다: $e")),
      );
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  // 사용자가 추천 활동 중 하나를 선택했을 때 서버 DB 로그에 기록을 적재하는 핸들러
  Future<void> selectManualActivity(BuildContext context, Map<String, dynamic> item) async {
    setState(() => _isApiLoading = true);

    try {
      // 이미지 명세: POST /manual_select/ 호출 연동
      final url = Uri.parse("${AppData.baseUrl}/manual_select/");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppData.currentUserId,
          "activity_id": item["id"] ?? item["activity_id"],
          "condition": widget.mood // 컨디션 화면에서 수집된 유저 기분 상시 동기화
        }),
      );

      if (response.statusCode == 200) {
        // 전역 데이터 정보 업데이트 수행
        AppData.currentActivityId = item["id"] ?? item["activity_id"];
        AppData.currentActivityName = item["name"] ?? item["activity_name"] ?? "선택 활동";
        AppData.currentReason = "사용자가 [${widget.env}/${widget.time}] 조건에서 직접 선택한 동적 API 맞춤 활동입니다.";

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SatisfactionPage(isManualSelection: true)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("기록 처리 중 서버 오류가 발생했습니다.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("서버 통신 실패: $e")),
      );
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  // 수동 활동 선택 화면 UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
          title: const Text('활동 직접 선택'),
          backgroundColor: const Color(0xFF62BC47),
          foregroundColor: Colors.white
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
                '${AppData.currentUserName}님의 취향 맞춤 추천 리스트\n취향에 맞는 활동을 직접 골라보세요!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '선택하신 조건\n➔ 기분: ${widget.mood} | 시간: ${widget.time} | 환경: ${widget.env}\n이 조건에 맞는 활동이 랜덤 편성되었습니다.',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isApiLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)))
                  : _finalRandomPool.isEmpty
                  ? const Center(child: Text("조건에 일치하는 활동 추천 리스트를 조회하지 못했습니다."))
                  : ListView.builder(
                itemCount: _finalRandomPool.length,
                itemBuilder: (context, index) {
                  final item = _finalRandomPool[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    color: Theme.of(context).cardColor,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(item["name"] ?? item["activity_name"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(item["desc"] ?? item["activity_desc"] ?? "서버 실시간 맞춤형 추천 콘텐츠", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ),
                      trailing: const Icon(Icons.touch_app, color: Color(0xFF62BC47)),
                      onTap: () => selectManualActivity(context, Map<String, dynamic>.from(item)),
                    ),
                  );
                },
              ),
            ),
            // 하단 셔플 리프레시 버튼 (클릭 시 실시간으로 API를 재호출하여 무작위 3종 새로고침)
            OutlinedButton.icon(
              onPressed: _isApiLoading ? null : _fetchRandomActivitiesFromLiveServer,
              icon: const Icon(Icons.refresh, color: Color(0xFF62BC47)),
              label: const Text('다른 추천 보기', style: TextStyle(color: Color(0xFF62BC47))),
              style: _outlineStyle(false),
            ),
          ],
        ),
      ),
    );
  }
}

// 11. 만족도 평가 화면 (리뷰 및 별점 서브밋 단)
class SatisfactionPage extends StatefulWidget {
  final bool isManualSelection;
  const SatisfactionPage({super.key, this.isManualSelection = false});

  @override
  State<SatisfactionPage> createState() => _SatisfactionPageState();
}

class _SatisfactionPageState extends State<SatisfactionPage> {
  int selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool isSaving = false;

  // 정량 별점 점수 및 텍스트 코멘트를 서버 DB로 전송하고 메인 홈 진입
  Future<void> submitReviewToServer() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("활동에 대한 별점을 최소 1개 이상 선택해주세요.")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final reviewUrl = Uri.parse("${AppData.baseUrl}/review/");
      final response = await http.post(
        reviewUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppData.currentUserId,
          "recommendation_id": AppData.currentRecommendationId,
          "activity_id": AppData.currentActivityId,
          "rating": selectedRating,
          "comment": _commentController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("기록이 안전하게 보관되었습니다!")));
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("제출 중 에러가 발생했습니다: $e")));
    } finally {
      setState(() => isSaving = false);
    }
  }

  // 활동 수행 만족도 평가(별점 및 코멘트 폼) 화면 UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: isDark ? Colors.white : Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('이 활동은 어떠셨나요?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('별점을 선택하고 한 줄 소감을 남겨주세요.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black45)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                int starValue = index + 1;
                bool isSelected = starValue <= selectedRating;

                return IconButton(
                  icon: Icon(isSelected ? Icons.star : Icons.star_border, size: 44),
                  color: isSelected ? Colors.orangeAccent : (isDark ? Colors.white30 : Colors.black26),
                  onPressed: () {
                    setState(() {
                      selectedRating = starValue;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('매우 아쉬워요', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
                Text('매우 만족스러워요', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF232323) : const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(16)),
              child: TextField(
                controller: _commentController,
                maxLines: null,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(hintText: '한 줄 소감을 남겨주세요.', border: InputBorder.none, hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
              ),
            ),
            const SizedBox(height: 60),
            isSaving
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)))
                : ElevatedButton(
              onPressed: submitReviewToServer,
              style: _btnStyle(),
              child: const Text('제출하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// 12. 앱 환경설정 화면 (글로벌 다크모드 및 세션 생명주기 관리 단)
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotification = true;

  // 앱 환경설정(알림 토글, 테마 스위치, 회원 탈퇴 다이얼로그 리스트뷰) 화면 UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 환경설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('알림 설정'),
            _buildSettingsCard([
              _buildSwitchRow(
                title: '푸시 알림 허용',
                subtitle: '앱에서 보내는 중요한 알림을 받습니다.',
                value: _pushNotification,
                onChanged: (val) => setState(() => _pushNotification = val),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('화면 및 기본 설정'),
            _buildSettingsCard([
              _buildSwitchRow(
                title: '다크 모드',
                subtitle: '어두운 테마로 앱을 사용하여 눈을 보호합니다.',
                value: AppData.isDarkMode,
                onChanged: (val) {
                  setState(() {
                    AppData.isDarkMode = val;
                  });
                  if (loginThemeRefresher != null) {
                    loginThemeRefresher!();
                  }
                },
              ),
              const Divider(height: 1, color: Colors.black12),
              _buildActionRow(
                title: '앱 버전 정보',
                trailingText: 'v1.0.0 (최신버전)',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('현재 최신 버전을 사용 중입니다.'))
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('계정 관리'),
            _buildSettingsCard([
              _buildActionRow(
                title: '로그아웃',
                titleColor: Colors.redAccent,
                onTap: () => _showConfirmDialog(
                  title: '로그아웃',
                  content: '현재 기기에서 로그아웃 하시겠습니까?',
                  onConfirm: () {
                    AppData.currentUserId = "";
                    AppData.currentUserName = "사용자";
                    AppData.currentGoal = "선택장애형";
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: Colors.black12),
              _buildActionRow(
                title: '회원 탈퇴',
                titleColor: isDark ? Colors.white38 : Colors.black38,
                onTap: () => _showConfirmDialog(
                  title: '회원 탈퇴',
                  content: '정말로 탈퇴하시겠습니까?\n그동안 기록된 모든 추천 활동 데이터와 즐겨찾기가 영구히 삭제됩니다.',
                  onConfirm: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('회원 탈퇴가 완료되었습니다. 이용해 주셔서 감사합니다.'))
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                    );
                  },
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF62BC47)),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required String title,
    String? trailingText,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor ?? (isDark ? Colors.white : Colors.black))),
            Row(
              children: [
                if (trailingText != null)
                  Text(trailingText, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black45)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white24 : Colors.black26),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.black45)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('확인', style: TextStyle(color: Color(0xFF62BC47), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// 공통 가공 디자인 유틸 패키지
InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint, filled: true, fillColor: Colors.white,
    hintStyle: const TextStyle(color: Colors.black38),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12)),
  );
}

ButtonStyle _btnStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF62BC47), foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 0,
  );
}

ButtonStyle _outlineStyle(bool isSelected) {
  return OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14),
    side: BorderSide(color: isSelected ? const Color(0xFF62BC47) : Colors.black12, width: isSelected ? 2 : 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

class _KeywordBadge extends StatelessWidget {
  final String text;
  const _KeywordBadge(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white12 : Colors.black12)),
      child: Text(text, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)),
    );
  }
}
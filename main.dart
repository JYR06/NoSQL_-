import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const NowFlowApp());
}

class NowFlowApp extends StatelessWidget {
  const NowFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NowFlow',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primaryColor: const Color(0xFF62BC47),
      ),
      home: const LoginPage(),
    );
  }
}

// ==========================================
// 🌍 전역 데이터 저장소
// ==========================================
class AppData {
  static const String baseUrl = "https://nosql-749h.onrender.com";
  static String currentUserId = ""; 
  static String currentUserName = "사용자";
  
  static int currentRecommendationId = 0;
  static int currentActivityId = 0;
  static String currentActivityName = "";
  static String currentReason = "";
}

// ==========================================
// 1. 로그인 화면
// ==========================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

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
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        AppData.currentUserId = data["user_id"]; 
        AppData.currentUserName = data["name"];
        
        _showSnackBar("${AppData.currentUserName}님, 환영합니다!");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        _showSnackBar("실패: ${errorData["detail"] ?? "로그인 정보 오류"}");
      }
    } catch (e) {
      _showSnackBar("서버 연결 실패. 인터넷을 확인해주세요.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
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
              const Text('자투리 시간을 특별하게,\n나에게 딱 맞는 활동 추천!', style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.4), textAlign: TextAlign.center),
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
                  const Text('계정이 없으신가요? ', style: TextStyle(color: Colors.black54)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                    child: const Text('회원가입', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
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

// ==========================================
// 2. 회원가입 화면
// ==========================================
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
        AppData.currentUserId = data["user_id"]; 
        AppData.currentUserName = name;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));
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

  @override
  Widget build(BuildContext context) {
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
              const Text('나에게 딱 맞는 활동 추천을 위해\n정보를 입력해주세요!', style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.4), textAlign: TextAlign.center),
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
                  const Text('이미 계정이 있으신가요? ', style: TextStyle(color: Colors.black54)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('로그인', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
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

// ==========================================
// 3. 성향 및 관심사 설정 화면 (🔥 번아웃/자기계발/선택장애 목표 탑재!)
// ==========================================
class PreferencePage extends StatefulWidget {
  const PreferencePage({super.key});

  @override
  State<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  String selectedGoal = "선택장애형"; 
  List<String> selectedInterests = ["자기계발"];
  final List<String> interests = ["운동/건강", "자기계발", "독서", "글쓰기", "여행", "음악", "요리", "IT/기술", "기타"];

  Future<void> saveInterestsToServer() async {
    try {
      final url = Uri.parse("${AppData.baseUrl}/users/interests");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppData.currentUserId,
          "tags": selectedInterests,
          "goal": selectedGoal, // 👈 백엔드로 목표 성향 전송!
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("관심사 저장 오류: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
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
                      child: Text(type.replaceAll("형", ""), style: TextStyle(fontSize: 13, color: isSel ? const Color(0xFF62BC47) : Colors.black87, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
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

// ==========================================
// 4. 메인 화면 & 탭 네비게이션
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(context),
            const HistoryPage(),        // 추천 기록 탭 (DB 연동 완료)
            const SavedActivitiesPage(), // 저장한 활동 탭 (DB 연동 완료)
            const MyPage(),             // 마이페이지 탭 (DB 연동 완료)
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF62BC47),
        unselectedItemColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: '추천 기록'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '저장한 활동'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('최근 추천 활동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('더보기', style: TextStyle(color: Colors.black45)),
            ],
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchRecentHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("아직 추천받은 활동이 없습니다.", style: TextStyle(color: Colors.grey)));
                }
                
                final recentActivities = snapshot.data!.take(3).toList(); // 최근 3개만 표시
                return ListView.builder(
                  itemCount: recentActivities.length,
                  itemBuilder: (context, index) {
                    final act = recentActivities[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                      color: Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF62BC47).withOpacity(0.1),
                          child: const Icon(Icons.check_circle_outline, color: Color(0xFF62BC47)),
                        ),
                        title: Text(act["activity"], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("상태: ${act["condition"]}"),
                        trailing: Text(act["date"], style: const TextStyle(color: Colors.grey, fontSize: 12)),
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

  Future<List<dynamic>> fetchRecentHistory() async {
    final url = Uri.parse("${AppData.baseUrl}/recommend/history/${AppData.currentUserId}");
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    return [];
  }
}

// ==========================================
// 💡 추천 기록 화면 (DB 실시간 연동)
// ==========================================
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<List<dynamic>> fetchHistory() async {
    final url = Uri.parse("${AppData.baseUrl}/recommend/history/${AppData.currentUserId}");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("기록 로드 실패");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('추천 기록', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('그동안 NowFlow와 함께한 시간들이에요.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)));
                if (snapshot.hasError) return Center(child: Text("오류: ${snapshot.error}"));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("기록이 없습니다.", style: TextStyle(color: Colors.grey)));

                final historyData = snapshot.data!;
                return ListView.builder(
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    final item = historyData[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
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
                                  Text(item["activity"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('상태: ${item["condition"]} | 별점: ⭐ ${item["rating"]}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                ],
                              ),
                            ),
                            Text(item["date"], style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontSize: 12)),
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

// ==========================================
// 💡 저장한 활동 화면 (DB 실시간 연동)
// ==========================================
class SavedActivitiesPage extends StatelessWidget {
  const SavedActivitiesPage({super.key});

  Future<List<dynamic>> fetchSaved() async {
    final url = Uri.parse("${AppData.baseUrl}/activities/favorite/${AppData.currentUserId}");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final resData = jsonDecode(utf8.decode(response.bodyBytes));
      return resData["data"] ?? [];
    }
    throw Exception("저장 목록 로드 실패");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('저장한 활동', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('나중에 꼭 다시 해보고 싶은 활동 모음이에요.', style: TextStyle(color: Colors.black54)),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(alignment: Alignment.topRight, child: Icon(Icons.favorite, color: Colors.redAccent)),
                          const Spacer(),
                          Text(item["activity_name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3)),
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

// ==========================================
// 💡 마이페이지 화면 (🔥 DB 실시간 연동 및 목표 표시)
// ==========================================
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  Future<Map<String, dynamic>> fetchProfile() async {
    final url = Uri.parse("${AppData.baseUrl}/users/profile/${AppData.currentUserId}");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception("프로필 로드 실패");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF62BC47)));
        }
        
        final profile = snapshot.data ?? {"name": AppData.currentUserName, "belong": "순천대학교", "goal": "선택장애형"};

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
              Text(profile["name"], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(profile["belong"], style: const TextStyle(color: Colors.black54, fontSize: 14)),
              const SizedBox(height: 30),
              
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.flag, color: Color(0xFF62BC47)),
                        title: const Text('나의 추천 목표 성향', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(profile["goal"], style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.settings, color: Colors.grey),
                        title: const Text('앱 환경 설정'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {},
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

// ==========================================
// 5. 컨디션 선택 화면
// ==========================================
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
          "latitude": 34.966, 
          "longitude": 127.478
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (data["action"] == "manual_selection") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ManualSelectPage(mood: selectedMood)));
          return;
        }

        AppData.currentRecommendationId = data["recommendation_id"];
        AppData.currentActivityId = data["activity_id"];
        AppData.currentActivityName = data["recommended_activity"];
        AppData.currentReason = data["reason"] ?? "현재 상태에 꼭 어울리는 활동이에요.";

        Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendationResultPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("추천 실패. 조건에 맞는 활동 데이터가 없습니다.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("추천 요청 오류: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

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
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (sub.isNotEmpty) ...[const SizedBox(height: 4), Text(sub, style: const TextStyle(fontSize: 11, color: Colors.black38))],
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. 추천 결과 화면
// ==========================================
class RecommendationResultPage extends StatefulWidget {
  const RecommendationResultPage({super.key});

  @override
  State<RecommendationResultPage> createState() => _RecommendationResultPageState();
}

class _RecommendationResultPageState extends State<RecommendationResultPage> {
  bool isSaved = false;

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

  Future<void> sendFeedback(BuildContext context, bool isLiked) async {
    try {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));
        
        if (data["action"] == "manual_selection") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ManualSelectPage(mood: "보통")));
        } else if (!isLiked) {
          Navigator.pop(context);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SatisfactionPage()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("피드백 전송 실패: $e")));
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = _getDesignTheme(AppData.currentReason);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black, actions: [
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
            Text(AppData.currentReason, style: const TextStyle(color: Colors.black45)),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 180, width: 180,
                      decoration: BoxDecoration(color: theme["color"], borderRadius: BorderRadius.circular(16)),
                      child: Icon(theme["icon"], size: 80, color: theme["iconColor"]),
                    ),
                    const SizedBox(height: 24),
                    Text(AppData.currentActivityName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('추천된 활동이 마음에 드시나요?\n좋아요를 누르면 선호도가 올라갑니다.', style: TextStyle(color: Colors.black54, height: 1.4), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => sendFeedback(context, true), icon: const Icon(Icons.thumb_up_alt_outlined), label: const Text('좋아요'), style: _outlineStyle(false))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(onPressed: () => sendFeedback(context, false), icon: const Icon(Icons.thumb_down_alt_outlined), label: const Text('싫어요'), style: _outlineStyle(false))),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SatisfactionPage())),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB0B0B0),
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

// ==========================================
// 수동 활동 선택 전용 화면
// ==========================================
class ManualSelectPage extends StatelessWidget {
  final String mood;
  const ManualSelectPage({super.key, required this.mood});

  final List<Map<String, dynamic>> manualPool = const [
    {"id": 1, "name": "스트레칭 하기", "desc": "가볍게 몸 풀기"},
    {"id": 2, "name": "유튜브 코딩 영상 시청", "desc": "침대 위에서 공부하기"},
    {"id": 3, "name": "따뜻한 차 마시기", "desc": "마음 가라앉히기"},
  ];

  Future<void> submitManualSelection(BuildContext context, int activityId) async {
    try {
      final url = Uri.parse("${AppData.baseUrl}/manual_select/");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppData.currentUserId,
          "activity_id": activityId,
          "weather": "맑음",
          "condition": mood
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("수동 선택 활동이 백엔드 DB에 안전하게 기록되었습니다!")));
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("수동 선택 전송 에러: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('활동 직접 선택'), backgroundColor: const Color(0xFF62BC47), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('취향에 맞는 활동을 직접 골라보세요!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('3회 거절 누적으로 발생한 직접 선택 화면입니다.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: manualPool.length,
                itemBuilder: (context, index) {
                  final item = manualPool[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(item["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item["desc"]),
                      trailing: const Icon(Icons.touch_app, color: Color(0xFF62BC47)),
                      onTap: () => submitManualSelection(context, item["id"]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. 만족도 평가 화면
// ==========================================
class SatisfactionPage extends StatefulWidget {
  const SatisfactionPage({super.key});

  @override
  State<SatisfactionPage> createState() => _SatisfactionPageState(); 
}

class _SatisfactionPageState extends State<SatisfactionPage> {
  int selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();

  Future<void> submitReviewToServer() async {
    try {
      final url = Uri.parse("${AppData.baseUrl}/review/");
      final response = await http.post(
        url,
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("리뷰와 만족도가 서버에 안전하게 보관되었습니다!")));
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("리뷰 전송 에러: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('이 활동은 어떠셨나요?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('별점을 선택하고 한 줄 소감을 남겨주세요.', style: TextStyle(color: Colors.black45)),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                int starValue = index + 1;
                return IconButton(
                  icon: Icon(
                    starValue <= selectedRating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.orange,
                  ),
                  onPressed: () => setState(() => selectedRating = starValue),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('매우 아쉬워요', style: TextStyle(fontSize: 12, color: Colors.black38)),
                Text('매우 만족스러워요', style: TextStyle(fontSize: 12, color: Colors.black38)),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(16)),
              child: TextField(
                controller: _commentController,
                maxLines: null,
                decoration: const InputDecoration(hintText: '한 줄 소감을 남겨주세요.', border: InputBorder.none, hintStyle: TextStyle(color: Colors.black38)),
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
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

// ==========================================
// 공통 가공 스타일 꾸러미
// ==========================================
InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint, filled: true, fillColor: Colors.white,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
    );
  }
}

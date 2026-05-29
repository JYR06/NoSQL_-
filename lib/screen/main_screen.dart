import 'package:flutter/material.dart';
import 'condition_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      /// 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,

        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "홈",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: "추천 기록",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "저장한 활동",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "마이페이지",
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 36),

                /// 인사말
                const Text(
                  "안녕하세요, 사용자님",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 48),

                /// 오늘의 추천 키워드
                const Text(
                  "오늘의 추천 키워드",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                /// 키워드 태그
                Wrap(
                  spacing: 10,
                  runSpacing: 10,

                  children: [
                    keywordChip("#집중력향상"),
                    keywordChip("#힐링"),
                    keywordChip("#소소한행복"),
                  ],
                ),

                const SizedBox(height: 32),

                /// 활동 추천 카드
                GestureDetector(
                  onTap: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (context) =>
                        const ConditionScreen(),
                      ),
                    );
                  },

                  child: Container(
                    width: double.infinity,
                    height: 190,

                    decoration: BoxDecoration(
                      color: const Color(0xFF5E9F45),
                      borderRadius: BorderRadius.circular(24),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(20),

                      child: Stack(
                        children: [

                          /// 오른쪽 위 화살표
                          const Positioned(
                            top: 0,
                            right: 0,

                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),

                          /// 왼쪽 가운데 텍스트
                          Align(
                            alignment: Alignment.centerLeft,

                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: const [

                                Text(
                                  "활동 추천 받기",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 12),

                                Text(
                                  "나에게 딱 맞는 활동을\n추천 받아 볼까요?",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// 캐릭터 이미지
                          Positioned(
                              bottom: 0,
                              right: 0,

                              child: Image.asset(
                                "assets/images/screen_images/03_main_char.png",
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                /// 최근 추천 활동
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: const [

                    Text(
                      "최근 추천 활동",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "더보기",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 활동 리스트 박스
                Container(
                  width: double.infinity,
                  height: 250,

                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(24),

                    border: Border.all(
                      color: Colors.blue,
                      width: 4,
                    ),
                  ),

                  child: const Center(
                    child: Text(
                      "활동 목록",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 키워드 태그 위젯
  static Widget keywordChip(String text) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: const Color(0xFFD9D9D9),
        ),
      ),

      child: Text(
        text,

        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
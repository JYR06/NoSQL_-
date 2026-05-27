import 'package:flutter/material.dart';
import 'main_screen.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  String selectedMbti = "";
  List<String> selectedInterests = [];

  final List<String> interests = [
    "운동/건강",
    "자기계발",
    "독서",
    "글쓰기",
    "여행",
    "음악",
    "요리",
    "IT/기술",
    "기타"
  ];

  void toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  Widget mbtiButton(String text) {
    bool isSelected = selectedMbti == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMbti = text;
          });
        },
        child: Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6CC04A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD9D9D9),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget interestButton(String text) {
    bool isSelected = selectedInterests.contains(text);

    return GestureDetector(
      onTap: () => toggleInterest(text),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6CC04A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD9D9D9),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
      elevation: 0,

      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.black,
          size: 28,
        ),

        onPressed: (){
          Navigator.pop(context);

        },
      ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 제목
              const Center(
                child: Text(
                  "나를 더 잘 알면\n더 좋은 추천을 받을 수 있어요!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// 캐릭터 이미지
              Center(
                child: Image.asset(
                  "assets/images/02_preference_char.png",
                  width: 220,
                  height: 220,
                ),
              ),

              const SizedBox(height: 28),

              /// MBTI 질문
              const Text(
                "당신의 MBTI는 무엇인가요?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              /// MBTI 버튼들
              Row(
                children: [
                  mbtiButton("I(내향)"),
                  mbtiButton("E(외향)"),
                  mbtiButton("중간"),
                ],
              ),

              const SizedBox(height: 32),

              /// 관심사 제목
              Row(
                children: const [
                  Text(
                    "관심 있는 분야를 선택해주세요",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "(복수 선택 가능)",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// 관심사 버튼
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: interests
                    .map((interest) => interestButton(interest))
                    .toList(),
              ),

              const Spacer(),

              /// 다음 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                //main화면으로 넘어가기
                child: ElevatedButton(
                  onPressed: () {Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(),
                    ),
                  );},

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6CC04A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),

                  child: const Text(
                    "다음",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
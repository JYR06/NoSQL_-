import 'package:flutter/material.dart';
import 'recommendation_screen.dart';

class ConditionScreen extends StatefulWidget {
  const ConditionScreen({super.key});

  @override
  State<ConditionScreen> createState() =>
      _ConditionScreenState();
}

class _ConditionScreenState
    extends State<ConditionScreen> {

  /// 선택 상태
  String selectedMood = "";
  String selectedTime = "";
  String selectedEnvironment = "";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 24,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 20),

                /// 제목
                const Text(
                  "오늘 기분은 어떤가요?",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "현재 상태에 맞는 활동을 추천해드릴게요.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                /// 기분 선택
                const Text(
                  "기분 선택",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    MoodButton(
                      imagePath:
                      "assets/images/moods/1_angry_img.png",
                      label: "매우별로",

                      isSelected:
                      selectedMood == "매우별로",

                      onTap: () {
                        setState(() {
                          selectedMood = "매우별로";
                        });
                      },
                    ),

                    MoodButton(
                      imagePath:
                      "assets/images/moods/2_sad_img.png",
                      label: "별로",

                      isSelected:
                      selectedMood == "별로",

                      onTap: () {
                        setState(() {
                          selectedMood = "별로";
                        });
                      },
                    ),

                    MoodButton(
                      imagePath:
                      "assets/images/moods/3_normal_img.png",
                      label: "보통",

                      isSelected:
                      selectedMood == "보통",

                      onTap: () {
                        setState(() {
                          selectedMood = "보통";
                        });
                      },
                    ),

                    MoodButton(
                      imagePath:
                      "assets/images/moods/4_happy_img.png",
                      label: "좋음",

                      isSelected:
                      selectedMood == "좋음",

                      onTap: () {
                        setState(() {
                          selectedMood = "좋음";
                        });
                      },
                    ),

                    MoodButton(
                      imagePath:
                      "assets/images/moods/5_veryhappy_img.png",
                      label: "매우좋음",

                      isSelected:
                      selectedMood == "매우좋음",

                      onTap: () {
                        setState(() {
                          selectedMood = "매우좋음";
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 42),

                /// 시간 선택
                const Text(
                  "시간 선택",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [

                    Expanded(
                      child: SelectCard(
                        title: "짧게",
                        subtitle: "10~30분",

                        isSelected:
                        selectedTime == "짧게",

                        onTap: () {
                          setState(() {
                            selectedTime = "짧게";
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: SelectCard(
                        title: "보통",
                        subtitle: "30~60분",

                        isSelected:
                        selectedTime == "보통",

                        onTap: () {
                          setState(() {
                            selectedTime = "보통";
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: SelectCard(
                        title: "여유롭게",
                        subtitle: "1시간 이상",

                        isSelected:
                        selectedTime == "여유롭게",

                        onTap: () {
                          setState(() {
                            selectedTime = "여유롭게";
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 42),

                /// 환경 선택
                const Text(
                  "환경 선택",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [

                    /// 실내 버튼
                    Expanded(
                      child: EnvironmentButton(
                        icon: Icons.home_outlined,
                        label: "실내",

                        isSelected:
                        selectedEnvironment ==
                            "실내",

                        onTap: () {
                          setState(() {
                            selectedEnvironment =
                            "실내";
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// 실외 버튼
                    Expanded(
                      child: EnvironmentButton(
                        icon: Icons.park_outlined,
                        label: "실외",

                        isSelected:
                        selectedEnvironment ==
                            "실외",

                        onTap: () {
                          setState(() {
                            selectedEnvironment =
                            "실외";
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// 상관없음 버튼
                    Expanded(
                      child: GestureDetector(

                        onTap: () {
                          setState(() {
                            selectedEnvironment =
                            "상관없음";
                          });
                        },

                        child: Container(
                          height: 70,

                          decoration: BoxDecoration(
                            color:
                            selectedEnvironment ==
                                "상관없음"
                                ? const Color(
                                0xFF4A82E8)
                                : Colors.white,

                            borderRadius:
                            BorderRadius.circular(
                                20),

                            border: Border.all(
                              color:
                              selectedEnvironment ==
                                  "상관없음"
                                  ? const Color(
                                  0xFF4A82E8)
                                  : Colors.grey
                                  .shade300,
                            ),
                          ),

                          child: Center(
                            child: Text(
                              "상관없음",

                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,

                                color:
                                selectedEnvironment ==
                                    "상관없음"
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                /// 추천받기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 60,

                  child: ElevatedButton(

                    onPressed: () {

                      if (selectedMood.isEmpty ||
                          selectedTime.isEmpty ||
                          selectedEnvironment
                              .isEmpty) {

                        ScaffoldMessenger.of(
                            context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "모든 항목을 선택해주세요.",
                            ),
                          ),
                        );

                        return;
                      }

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                              RecommendationScreen(
                                selectedMood:
                                selectedMood,
                              ),
                        ),
                      );
                    },

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF5E9F45),

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            20),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: const [

                        SizedBox(width: 24),

                        Text(
                          "추천받기",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 26,
                        ),
                      ],
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
}

/// 이모지 버튼
class MoodButton extends StatelessWidget {

  final String imagePath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodButton({
    super.key,
    required this.imagePath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,

      child: Column(
        children: [

          Container(
            width: 56,
            height: 56,

            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF4A82E8)
                  : Colors.white,

              borderRadius:
              BorderRadius.circular(18),

              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4A82E8)
                    : Colors.grey.shade300,
              ),
            ),

            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(18),

              child: Image.asset(
                imagePath,

                width: 56,
                height: 56,

                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,

              color: isSelected
                  ? const Color(0xFF4A82E8)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// 시간 선택 카드
class SelectCard extends StatelessWidget {

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding:
        const EdgeInsets.symmetric(
          vertical: 18,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A82E8)
              : Colors.white,

          borderRadius:
          BorderRadius.circular(20),

          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A82E8)
                : Colors.grey.shade300,
          ),
        ),

        child: Column(
          children: [

            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,

                color: isSelected
                    ? Colors.white
                    : Colors.black,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,

                color: isSelected
                    ? Colors.white70
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 환경 버튼
class EnvironmentButton
    extends StatelessWidget {

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const EnvironmentButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 70,

        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A82E8)
              : Colors.white,

          borderRadius:
          BorderRadius.circular(20),

          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A82E8)
                : Colors.grey.shade300,
          ),
        ),

        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Colors.black,
            ),

            const SizedBox(width: 10),

            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,

                color: isSelected
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
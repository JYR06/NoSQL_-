import 'package:flutter/material.dart';
import 'feedback_screen.dart';

class RecommendationScreen extends StatefulWidget {

  final String selectedMood;

  const RecommendationScreen({
    super.key,
    required this.selectedMood,
  });

  @override
  State<RecommendationScreen> createState() =>
      _RecommendationScreenState();
}

class _RecommendationScreenState
    extends State<RecommendationScreen> {

  int currentIndex = 0;
  bool isLiked = false;

  /// 기분별 추천 리스트
  late List<Map<String, String>> activities;

  @override
  void initState() {
    super.initState();

    if (widget.selectedMood == "매우별로") {

      activities = [

        {
          "title": "감정 정리 산책",
          "description":
          "조용한 음악과 함께\n10분 정도 걸어보세요.",
          "image":
          "assets/images/recommend/walking.png",
        },

        {
          "title": "마음 정리 일기",
          "description":
          "오늘 있었던 일을\n천천히 적어보세요.",
          "image":
          "assets/images/recommend/diary.png",
        },

      ];

    } else if (widget.selectedMood == "별로") {

      activities = [

        {
          "title": "따뜻한 차 마시기",
          "description":
          "따뜻한 음료로 마음을\n편안하게 만들어보세요.",
          "image":
          "assets/images/recommend/tea_drinking.png",
        },

        {
          "title": "조용한 음악 듣기",
          "description":
          "편안한 음악으로\n긴장을 풀어보세요.",
          "image":
          "assets/images/recommend/quiet_music.png",
        },

      ];

    } else if (widget.selectedMood == "보통") {

      activities = [

        {
          "title": "가벼운 스트레칭",
          "description":
          "몸을 천천히 움직이며\n기분 전환을 해보세요.",
          "image":
          "assets/images/recommend/stretching.png",
        },

        {
          "title": "짧은 산책",
          "description":
          "밖에 나가 바람을\n쐬어보세요.",
          "image":
          "assets/images/recommend/short_walking.png",
        },

      ];

    } else if (widget.selectedMood == "좋음") {

      activities = [

        {
          "title": "좋아하는 음악 듣기",
          "description":
          "신나는 음악과 함께\n즐거운 시간을 보내보세요.",
          "image":
          "assets/images/recommend/listening_music.png",
        },

        {
          "title": "친구와 대화하기",
          "description":
          "좋은 기분을 함께\n나눠보세요.",
          "image":
          "assets/images/recommend/chat.png",
        },

      ];

    } else {

      activities = [

        {
          "title": "새로운 취미 도전",
          "description":
          "좋은 기분을 유지하며\n새로운 활동을 해보세요.",
          "image":
          "assets/images/recommend/hobby.png",
        },

        {
          "title": "운동하기",
          "description":
          "에너지를 발산하며\n활기찬 시간을 보내보세요.",
          "image":
          "assets/images/recommend/exercise.png",
        },

      ];
    }
  }

  @override
  Widget build(BuildContext context) {

    final activity = activities[currentIndex];

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

              const Text(
                "추천 활동",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "${widget.selectedMood} 상태에 어울리는 활동이에요.",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              /// 추천 카드
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                      28),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.05),

                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    Image.asset(
                      activity["image"]!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 24),

                    Text(
                      activity["title"]!,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      activity["description"]!,
                      textAlign:
                      TextAlign.center,

                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// 좋아요 / 싫어요 버튼
              Row(
                children: [

                  /// 좋아요 버튼
                  Expanded(
                    child: GestureDetector(

                      onTap: () {

                        setState(() {
                          isLiked = true;
                        });

                      },

                      child: Container(
                        height: 58,

                        decoration: BoxDecoration(
                          color: isLiked
                              ? Colors.blue.shade50
                              : Colors.white,

                          borderRadius:
                          BorderRadius.circular(
                              18),

                          border: Border.all(
                            color:
                            Colors.grey.shade300,
                          ),
                        ),

                        child: const Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                          children: [

                            Icon(
                              Icons
                                  .thumb_up_alt_outlined,
                              color: Colors.blue,
                            ),

                            SizedBox(width: 8),

                            Text(
                              "좋아요",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// 싫어요 버튼
                  Expanded(
                    child: GestureDetector(

                      onTap: () {

                        setState(() {

                          isLiked = false;

                          /// 다음 추천으로 변경
                          currentIndex =
                              (currentIndex + 1) %
                                  activities.length;
                        });

                      },

                      child: Container(
                        height: 58,

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                          BorderRadius.circular(
                              18),

                          border: Border.all(
                            color:
                            Colors.grey.shade300,
                          ),
                        ),

                        child: const Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                          children: [

                            Icon(
                              Icons
                                  .thumb_down_alt_outlined,
                              color: Colors.red,
                            ),

                            SizedBox(width: 8),

                            Text(
                              "싫어요",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// 활동 선택 버튼
              SizedBox(
                width: double.infinity,
                height: 60,

                child: ElevatedButton(

                  onPressed: isLiked
                      ? () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (context) =>
                        const FeedbackScreen(),
                      ),
                    );

                  }
                      : null,

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF5E9F45),

                    disabledBackgroundColor:
                    Colors.grey.shade400,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                          20),
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                    children: const [

                      SizedBox(width: 24),

                      Text(
                        "활동 선택",
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
    );
  }
}
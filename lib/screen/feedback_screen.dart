import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() =>
      _FeedbackScreenState();
}

class _FeedbackScreenState
    extends State<FeedbackScreen> {

  int selectedRating = 0;

  final TextEditingController
  feedbackController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: const BackButton(
          color: Colors.black,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            /// 제목
            const Text(
              "이 활동은 어떠셨나요?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// 설명
            const Text(
              "별점을 선택하고 한 줄 소감을 남겨주세요.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 50),

            /// 별점
            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) {

                  final starIndex = index + 1;

                  return GestureDetector(

                    onTap: () {

                      setState(() {
                        selectedRating =
                            starIndex;
                      });
                    },

                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 6,
                      ),

                      child: Icon(
                        selectedRating >=
                            starIndex
                            ? Icons.star
                            : Icons.star_border,

                        color: Colors.orange,
                        size: 42,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// 별점 텍스트
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: const [

                Text(
                  "매우 아쉬워요",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                Text(
                  "매우 만족스러워요",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            /// 후기 입력창
            TextField(
              controller: feedbackController,

              maxLines: 5,

              decoration: InputDecoration(
                hintText:
                "한 줄 소감을 남겨주세요.",

                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),

                filled: true,
                fillColor:
                const Color(0xFFF7F7F7),

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),

                  borderSide: BorderSide.none,
                ),

                contentPadding:
                const EdgeInsets.all(18),
              ),
            ),

            const Spacer(),

            /// 제출 버튼
            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton(

                onPressed: () {

                  if (selectedRating == 0) {

                    ScaffoldMessenger.of(
                        context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "별점을 선택해주세요.",
                        ),
                      ),
                    );

                    return;
                  }

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "피드백이 제출되었습니다!",
                      ),
                    ),
                  );
                  /// 제출하기 버튼을 누를 시 첫 화면으로 이동
                  Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF5E9F45),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),

                child: const Text(
                  "제출하기",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class SkinQuizPage extends StatefulWidget {
  const SkinQuizPage({super.key});

  @override
  _SkinQuizPageState createState() => _SkinQuizPageState();
}

class _SkinQuizPageState extends State<SkinQuizPage> {
  int _score = 0;
  int _currentQuestionIndex = 0;

  // q&a data
  final List<Map<String, Object>> _questions = [
    {
      'question': 'How does your skin feel in the morning after waking up?',
      'answers': [
        {'text': 'Tight, dry, or flaky', 'points': 1},
        {'text': 'Normal and comfortable', 'points': 2},
        {'text': 'Oily all over the face', 'points': 3},
        {'text': 'Oily only in the T-zone (forehead/nose)', 'points': 2},
      ],
    },
    {
      'question': 'How visible are the pores on your nose and cheeks?',
      'answers': [
        {'text': 'Barely visible', 'points': 1},
        {'text': 'Visible but not large', 'points': 2},
        {'text': 'Large and often clogged', 'points': 3},
      ],
    },
    {
      'question': 'How does your skin feel by mid-afternoon?',
      'answers': [
        {'text': 'Rough or dull', 'points': 1},
        {'text': 'Fresh and smooth', 'points': 2},
        {'text': 'Very shiny and greasy', 'points': 3},
      ],
    },
    {
      'question':
          'How often does your skin react to new products (stinging/redness)?',
      'answers': [
        {'text': 'Frequently (Sensitive skin)', 'points': 1},
        {'text': 'Occasionally', 'points': 2},
        {'text': 'Rarely or never', 'points': 3},
      ],
    },
    {
      'question': 'How often do you experience blackheads or breakouts?',
      'answers': [
        {'text': 'Rarely', 'points': 1},
        {'text': 'Sometimes in specific areas', 'points': 2},
        {'text': 'Frequently and all over', 'points': 3},
      ],
    },
  ];

  void _answerQuestion(int points) {
    setState(() {
      _score += points;
      _currentQuestionIndex++;
    });
  }

  void _resetQuiz() {
    setState(() {
      _score = 0;
      _currentQuestionIndex = 0;
    });
  }

  // result
  Map<String, String> get _resultData {
    if (_score <= 7) {
      return {
        'type': 'DRY / SENSITIVE',
        'tip':
            'Use creamy, hydrating cleansers and thick moisturizers. Avoid harsh scrubs.',
      };
    } else if (_score <= 11) {
      return {
        'type': 'NORMAL / COMBINATION',
        'tip':
            'Focus on balancing. Use a gentle cleanser and a lightweight moisturizer daily.',
      };
    } else {
      return {
        'type': 'OILY / ACNE-PRONE',
        'tip':
            'Use oil-free, gel-based cleansers and moisturizers. Look for non-comedogenic products.',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFinished = _currentQuestionIndex >= _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Skin Type Analysis"),
        backgroundColor: const Color(0xFF008080),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (!isFinished)
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.teal.withOpacity(0.1),
              color: Colors.teal,
              minHeight: 6,
            ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: !isFinished
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // question number
                        Text(
                          "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Question text
                        Text(
                          _questions[_currentQuestionIndex]['question']
                              as String,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        // answer buttons
                        ...(_questions[_currentQuestionIndex]['answers']
                                as List<Map<String, Object>>)
                            .map((answer) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.teal,
                                      side: const BorderSide(
                                        color: Colors.teal,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () => _answerQuestion(
                                      answer['points'] as int,
                                    ),
                                    child: Text(
                                      answer['text'] as String,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ],
                    )
                  : _buildResultPage(),
            ),
          ),
        ],
      ),
    );
  }

  // rslt page
  Widget _buildResultPage() {
    final data = _resultData;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, size: 80, color: Colors.orangeAccent),
          const SizedBox(height: 20),
          const Text(
            "YOUR SKIN TYPE IS",
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            data['type']!,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF008080),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                const Text(
                  "✨ Expert Recommendation:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  data['tip']!,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Back to Dashboard",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          TextButton(
            onPressed: _resetQuiz,
            child: const Text(
              "Retake Quiz",
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

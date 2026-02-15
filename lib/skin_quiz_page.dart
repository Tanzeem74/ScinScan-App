import 'package:flutter/material.dart';

class SkinQuizPage extends StatefulWidget {
  const SkinQuizPage({super.key});

  @override
  _SkinQuizPageState createState() => _SkinQuizPageState();
}

class _SkinQuizPageState extends State<SkinQuizPage> {
  int _score = 0;
  int _currentQuestionIndex = 0;

  final List<Map<String, Object>> _questions = [
    {
      'question': 'How does your skin feel after washing?',
      'answers': [
        {'text': 'Tight or itchy', 'points': 1},
        {'text': 'Normal/Smooth', 'points': 2},
        {'text': 'Shiny or oily', 'points': 3},
      ],
    },
    {
      'question': 'How often do you get breakouts or pimples?',
      'answers': [
        {'text': 'Rarely', 'points': 1},
        {'text': 'Sometimes', 'points': 2},
        {'text': 'Very Often', 'points': 3},
      ],
    },
    {
      'question': 'How does your skin look in the afternoon?',
      'answers': [
        {'text': 'Flaky or dull', 'points': 1},
        {'text': 'Fresh', 'points': 2},
        {'text': 'Greasy in T-zone', 'points': 3},
      ],
    },
  ];

  void _answerQuestion(int points) {
    setState(() {
      _score += points;
      _currentQuestionIndex++;
    });
  }

  String get _resultText {
    if (_currentQuestionIndex < _questions.length) return "";
    if (_score <= 4) return "Your Skin Type is: DRY";
    if (_score <= 7) return "Your Skin Type is: NORMAL/COMBINATION";
    return "Your Skin Type is: OILY";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Skin Type Quiz"),
        backgroundColor: Color(0xFF008080),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _currentQuestionIndex < _questions.length
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _questions[_currentQuestionIndex]['question'] as String,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ...(_questions[_currentQuestionIndex]['answers']
                          as List<Map<String, Object>>)
                      .map((answer) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () =>
                                  _answerQuestion(answer['points'] as int),
                              child: Text(answer['text'] as String),
                            ),
                          ),
                        );
                      })
                      // ignore: unnecessary_to_list_in_spreads
                      .toList(),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 80, color: Colors.orange),
                    SizedBox(height: 20),
                    Text(
                      _resultText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Back to Dashboard"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

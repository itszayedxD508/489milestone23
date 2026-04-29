import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/static_data.dart';
import '../services/session_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'results_screen.dart';

class TestScreen extends StatefulWidget {
  final String userId;
  const TestScreen({required this.userId, super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final SessionService _sessionService = SessionService();

  int _currentQuestionIndex = 0;
  QuizSession? _currentSession;
  bool _isLoading = true;
  int _score = 0;

  final List<dynamic> _questions = [];

  List<String> _selectedWords = [];
  List<String> _availableWords = [];

  @override
  void initState() {
    super.initState();
    _initTest();
  }

  Future<void> _initTest() async {
    final List<Map<String, String>> wordsList = List.from(
      StaticData.wordsLesson,
    )..shuffle();
    final List<Map<String, String>> introList = List.from(
      StaticData.introLesson,
    )..shuffle();
    final List<Map<String, String>> smallList = List.from(
      StaticData.smallSentencesLesson,
    )..shuffle();
    final List<Map<String, String>> largeList = List.from(
      StaticData.largeSentencesLesson,
    )..shuffle();

    final rawItems = [];
    rawItems.addAll(wordsList.take(2));
    rawItems.addAll(introList.take(2));
    rawItems.addAll(smallList.take(2));
    rawItems.addAll(largeList.take(2));
    rawItems.shuffle();

    final allItems = [
      ...StaticData.wordsLesson,
      ...StaticData.introLesson,
      ...StaticData.smallSentencesLesson,
      ...StaticData.largeSentencesLesson,
    ];

    final random = Random();

    for (var item in rawItems) {
      final typeInt = random.nextInt(3);
      String typeStr;
      List<String> options = [];

      if (typeInt == 0) {
        typeStr = 'translation';
      } else if (typeInt == 1) {
        typeStr = 'multiple_choice';
        final wrongAnswers =
            allItems.where((e) => e['spanish'] != item['spanish']).toList()
              ..shuffle();

        options = [
          item['spanish']!,
          ...wrongAnswers.take(3).map((e) => e['spanish'] as String),
        ];
        options.shuffle();
      } else {
        typeStr = 'rearrange';
        String cleanSpanish = item['spanish']!.replaceAll(
          RegExp(r'[^\w\s\u00C0-\u017F]'),
          '',
        );
        options = cleanSpanish.split(' ').where((w) => w.isNotEmpty).toList()
          ..shuffle();
      }

      _questions.add({
        'english': item['english'],
        'spanish': item['spanish'],
        'type': typeStr,
        'options': options,
      });
    }

    _setupQuestionState();

    // Start session
    _currentSession = await _sessionService.startSession(
      widget.userId,
      'final_test',
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _setupQuestionState() {
    if (_currentQuestionIndex < _questions.length) {
      final q = _questions[_currentQuestionIndex];
      _answerController.clear();
      if (q['type'] == 'rearrange') {
        _availableWords = List<String>.from(q['options']);
        _selectedWords = [];
      }
    }
  }

  void _submitAnswer(bool isCorrect) {
    if (isCorrect) {
      _score += 50;
    } else {
      _score += 10;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _setupQuestionState();
      });
    } else {
      _finishTest();
    }
  }

  Future<void> _finishTest() async {
    setState(() => _isLoading = true);
    await _sessionService.endSessionAndAddXp(
      widget.userId,
      _currentSession!.id!,
      _score,
    );
    if (!mounted) return;
    await context.read<AuthProvider>().refreshUser();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultsScreen(xpEarned: _score)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No questions available.")),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Evaluation (${_currentQuestionIndex + 1}/${_questions.length})',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Text(
                question['type'] == 'translation'
                    ? 'Translate this into Spanish:'
                    : question['type'] == 'multiple_choice'
                    ? 'Select the correct translation:'
                    : 'Rearrange the words into a sentence:',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  question['english'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              if (question['type'] == 'translation')
                _buildTextInputCard(question['spanish'])
              else if (question['type'] == 'multiple_choice')
                _buildMultipleChoiceCard(question)
              else if (question['type'] == 'rearrange')
                _buildRearrangeCard(question),
            ],
          ),
        ),
      ),
    );
  }

  final TextEditingController _answerController = TextEditingController();

  void _showFeedbackMessage(bool isCorrect, String correctAnswer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? 'Correct! +50 XP'
              : 'Incorrect. The answer was: $correctAnswer',
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTextInputCard(String correctAnswer) {
    return Column(
      children: [
        TextField(
          controller: _answerController,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
          decoration: InputDecoration(
            hintText: 'Type Spanish translation...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
            backgroundColor: const Color(0xFF6C63FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size(double.infinity, 60),
          ),
          onPressed: () {
            if (_answerController.text.trim().isEmpty) return;

            final userAnswer = _answerController.text.trim().toLowerCase();
            final actualAnswer = correctAnswer.toLowerCase();
            final isCorrect =
                userAnswer == actualAnswer ||
                userAnswer ==
                    actualAnswer.replaceAll(
                      RegExp(r'[^\w\s\u00C0-\u017F]'),
                      '',
                    );

            _showFeedbackMessage(isCorrect, correctAnswer);
            _answerController.clear();
            _submitAnswer(isCorrect);
          },
          child: const Text(
            'Submit Answer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceCard(Map<dynamic, dynamic> question) {
    final options = question['options'] as List<String>;
    final correctAnswer = question['spanish'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              backgroundColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                ),
              ),
            ),
            onPressed: () {
              final isCorrect = option == correctAnswer;
              _showFeedbackMessage(isCorrect, correctAnswer);
              _submitAnswer(isCorrect);
            },
            child: Text(
              option,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRearrangeCard(Map<dynamic, dynamic> question) {
    final correctAnswerStr = question['spanish'] as String;

    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 80),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedWords.map((word) {
              return ActionChip(
                label: Text(
                  word,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.8),
                onPressed: () {
                  setState(() {
                    _selectedWords.remove(word);
                    _availableWords.add(word);
                  });
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _availableWords.map((word) {
            return ActionChip(
              label: Text(
                word,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              backgroundColor: Colors.white.withOpacity(0.1),
              side: const BorderSide(color: Colors.white24),
              onPressed: () {
                setState(() {
                  _availableWords.remove(word);
                  _selectedWords.add(word);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
            backgroundColor: const Color(0xFF6C63FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size(double.infinity, 60),
          ),
          onPressed: () {
            if (_selectedWords.isEmpty) return;

            final cleanSpanish = correctAnswerStr.replaceAll(
              RegExp(r'[^\w\s\u00C0-\u017F]'),
              '',
            );
            final userAnswer = _selectedWords.join(' ').toLowerCase();
            final expectedAnswer = cleanSpanish.toLowerCase();

            final isCorrect = userAnswer == expectedAnswer;
            _showFeedbackMessage(isCorrect, correctAnswerStr);
            _submitAnswer(isCorrect);
          },
          child: const Text(
            'Check Answer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

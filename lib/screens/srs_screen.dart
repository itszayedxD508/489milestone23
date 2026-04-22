import 'package:flutter/material.dart';
import '../services/srs_service.dart';
import '../services/session_service.dart';
import '../services/user_service.dart';
import 'results_screen.dart';

class SRSScreen extends StatefulWidget {
  final String userId;
  const SRSScreen({required this.userId, super.key});

  @override
  State<SRSScreen> createState() => _SRSScreenState();
}

class _SRSScreenState extends State<SRSScreen> {
  final SRSService _srsService = SRSService();
  final SessionService _sessionService = SessionService();
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _queue = [];
  bool _loading = true;
  int _currentIndex = 0;
  bool _showAnswer = false;
  int _xpEarned = 0;

  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final session = await _sessionService.startSession(
      widget.userId,
      'srs_review',
    );
    _sessionId = session.id;
    final words = await _srsService.getDueCards(widget.userId);
    setState(() {
      _queue = words;
      _loading = false;
    });
  }

  Future<void> _answer(bool correct) async {
    final word = _queue[_currentIndex];
    final wordId = word['word_id'];

    if (correct) {
      _xpEarned += 5;
    }

    await _srsService.answerCard(widget.userId, wordId, correct);
    await _sessionService.updateUserWordProgress(
      widget.userId,
      wordId,
      correct,
    );

    if (_currentIndex < _queue.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    } else {
      // Session Complete
      await _sessionService.endSessionAndAddXp(
        widget.userId,
        _sessionId!,
        _xpEarned,
      );
      final user = await _userService.getCurrentUser();
      if (user != null) {
        await _userService.addXp(user, _xpEarned);
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ResultsScreen(xpEarned: _xpEarned)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('SRS Review')),
        body: const Center(child: Text('No words to review today!')),
      );
    }

    final currentWord = _queue[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${_currentIndex + 1} / ${_queue.length}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentWord['translation'],
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_showAnswer) ...[
                          Text(
                            currentWord['word'],
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Example: ${currentWord['example_sentence']}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!_showAnswer)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                  ),
                  onPressed: () => setState(() => _showAnswer = true),
                  child: const Text(
                    'Show Answer',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                        ),
                        onPressed: () => _answer(false),
                        child: const Text(
                          'Incorrect',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                        ),
                        onPressed: () => _answer(true),
                        child: const Text(
                          'Correct',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

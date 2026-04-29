import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../data/static_data.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'results_screen.dart';

class TranslationScreen extends StatefulWidget {
  final String userId;
  const TranslationScreen({required this.userId, super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final SessionService _sessionService = SessionService();

  final List<Map<String, dynamic>> _queue = List.from(StaticData.translations)
    ..shuffle();
  bool _loading = true;
  int _currentIndex = 0;
  int _xpEarned = 0;

  String? _sessionId;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final session = await _sessionService.startSession(
      widget.userId,
      'translation',
    );
    _sessionId = session.id;
    setState(() {
      _loading = false;
    });
  }

  double calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    // VERY simple similarity fallback, checks if completely matching word count ratio.
    var words1 = s1.split(' ');
    var words2 = s2.split(' ');
    int matches = 0;
    for (var w in words1) {
      if (words2.contains(w)) matches++;
    }
    return matches /
        (words1.length > words2.length ? words1.length : words2.length);
  }

  Future<void> _submit() async {
    final currentDict = _queue[_currentIndex];
    final answer = _controller.text.trim().toLowerCase();
    final correct = currentDict['spanish'].toString().toLowerCase();

    final score = calculateSimilarity(answer, correct);

    // xp scales slightly with how close they were
    if (score >= 1.0) {
      _xpEarned += 15;
    } else if (score > 0.5) {
      _xpEarned += 5;
    }

    await _sessionService.logTranslationAttempt(
      widget.userId,
      _sessionId!,
      currentDict['template_id'],
      score,
    );

    bool isCorrect = score == 1.0;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isCorrect
            ? Colors.green
            : (score > 0.5 ? Colors.orange : Colors.red),
        content: Text(
          isCorrect
              ? 'Perfect!'
              : 'Correct translation: ${currentDict['spanish']} (Similarity: ${(score * 100).toInt()}%)',
        ),
        duration: const Duration(milliseconds: 2500),
      ),
    );

    _controller.clear();

    if (_currentIndex < _queue.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      await _sessionService.endSessionAndAddXp(
        widget.userId,
        _sessionId!,
        _xpEarned,
      );

      if (!mounted) return;
      await context.read<AuthProvider>().refreshUser();

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
      return const Scaffold(
        body: Center(child: Text('No translations available')),
      );
    }

    final currentDict = _queue[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Translate ${_currentIndex + 1} / ${_queue.length}'),
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
                        const Text(
                          'Translate to Spanish:',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentDict['english'],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        TextField(
                          controller: _controller,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type translation',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          maxLines: null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                ),
                onPressed: _submit,
                child: const Text('Check', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

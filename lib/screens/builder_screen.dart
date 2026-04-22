import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/user_service.dart';
import '../data/static_data.dart';
import 'results_screen.dart';

class BuilderScreen extends StatefulWidget {
  final String userId;
  const BuilderScreen({required this.userId, super.key});

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen> {
  final SessionService _sessionService = SessionService();
  final UserService _userService = UserService();

  final List<Map<String, dynamic>> _queue = List.from(
    StaticData.sentenceTemplates,
  )..shuffle();
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
      'sentence_builder',
    );
    _sessionId = session.id;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _submit() async {
    final currentTemplate = _queue[_currentIndex];
    final answer = _controller.text.trim().toLowerCase();
    final isCorrect =
        answer == currentTemplate['answer'].toString().toLowerCase();

    if (isCorrect) {
      _xpEarned += 10;
    }

    await _sessionService.logBuilderAttempt(
      widget.userId,
      _sessionId!,
      currentTemplate['template_id'],
      isCorrect,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        content: Text(
          isCorrect
              ? 'Correct!'
              : 'Incorrect! Exact answer is: ${currentTemplate['answer']}',
        ),
        duration: const Duration(milliseconds: 1500),
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
      return const Scaffold(
        body: Center(child: Text('No sentences available')),
      );
    }

    final currentTemplate = _queue[_currentIndex];
    final textParts = currentTemplate['template_text'].toString().split('___');

    return Scaffold(
      appBar: AppBar(
        title: Text('Sentence Builder ${_currentIndex + 1} / ${_queue.length}'),
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
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              textParts[0],
                              style: const TextStyle(fontSize: 24),
                            ),
                            Container(
                              width: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: TextField(
                                controller: _controller,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                                decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (textParts.length > 1)
                              Text(
                                textParts[1],
                                style: const TextStyle(fontSize: 24),
                              ),
                          ],
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
                child: const Text('Submit', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LessonScreen extends StatefulWidget {
  final String title;
  final List<Map<String, String>> lessonItems;

  const LessonScreen({
    required this.title,
    required this.lessonItems,
    super.key,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("es-ES"); // Spanish language by default
    await _flutterTts.setSpeechRate(
      0.45,
    ); // Slightly slower for better learning pronunciation
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: widget.lessonItems.length,
          itemBuilder: (context, index) {
            final item = widget.lessonItems[index];
            final english = item['english'] ?? '';
            final spanish = item['spanish'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.language, color: Color(0xFF6C63FF)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            english,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.translate, color: Colors.amber),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            spanish,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.amber,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.volume_up,
                            color: Colors.amber,
                          ),
                          onPressed: () => _speak(spanish),
                          tooltip: 'Listen to pronunciation',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

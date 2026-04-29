import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../models/models.dart';
import 'package:intl/intl.dart';

class SessionService {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  String get _baseUrl {
    if (kIsWeb)
      return 'http://localhost:3000';
    else if (Platform.isAndroid)
      return 'http://10.0.2.2:3000';
    else
      return 'http://localhost:3000';
  }

  Future<QuizSession> startSession(String userId, String sessionType) async {
    final nowStr = _dateFormat.format(DateTime.now());
    final response = await http.post(
      Uri.parse('$_baseUrl/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'session_type': sessionType,
        'created_at': nowStr,
        'xp_earned': 0,
      }),
    );
    return QuizSession.fromMap(jsonDecode(response.body));
  }

  Future<void> endSessionAndAddXp(
    String userId,
    String sessionId,
    int xpEarned,
  ) async {
    await http.put(
      Uri.parse('$_baseUrl/sessions/$sessionId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'xp_earned': xpEarned}),
    );

    // Also push the XP earned directly to the user's total
    await http.post(
      Uri.parse('$_baseUrl/users/$userId/xp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'xp': xpEarned}),
    );
  }

  Future<void> logBuilderAttempt(
    String userId,
    String sessionId,
    int templateId,
    bool isCorrect,
  ) async {
    await http.post(
      Uri.parse('$_baseUrl/attempts/builder'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'session_id': sessionId,
        'template_id': templateId,
        'is_correct': isCorrect,
        'created_at': _dateFormat.format(DateTime.now()),
      }),
    );
  }

  Future<void> logTranslationAttempt(
    String userId,
    String sessionId,
    int templateId,
    double matchScore,
  ) async {
    await http.post(
      Uri.parse('$_baseUrl/attempts/translation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'session_id': sessionId,
        'template_id': templateId,
        'match_score': matchScore,
        'created_at': _dateFormat.format(DateTime.now()),
      }),
    );
  }

  Future<void> updateUserWordProgress(
    String userId,
    int wordId,
    bool isCorrect,
  ) async {
    await http.post(
      Uri.parse('$_baseUrl/progress/word'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'word_id': wordId,
        'isCorrect': isCorrect,
      }),
    );
  }
}

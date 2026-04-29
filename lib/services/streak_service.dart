import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../models/models.dart';
import 'package:intl/intl.dart';

class StreakService {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String get _baseUrl {
    if (kIsWeb)
      return 'http://localhost:3000';
    else if (Platform.isAndroid)
      return 'http://10.0.2.2:3000';
    else
      return 'http://localhost:3000';
  }

  Future<StreakTracking> getOrCreateStreak(String userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/streaks/$userId'));
    if (response.statusCode == 200) {
      return StreakTracking.fromMap(jsonDecode(response.body));
    }
    return StreakTracking(userId: userId);
  }

  Future<StreakTracking> updateStreakOnLogin(String userId) async {
    StreakTracking current = await getOrCreateStreak(userId);

    final today = _dateFormat.format(DateTime.now());
    if (current.lastActivityDate == today) {
      return current;
    }

    int newStreak = current.currentStreak;
    int longest = current.longestStreak;

    if (current.lastActivityDate != null) {
      final lastActivity = _dateFormat.parse(current.lastActivityDate!);
      final difference = DateTime.now().difference(lastActivity).inDays;
      if (difference == 1) {
        newStreak += 1;
      } else if (difference > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    if (newStreak > longest) {
      longest = newStreak;
    }

    final updatedStreak = StreakTracking(
      id: current.id,
      userId: userId,
      currentStreak: newStreak,
      longestStreak: longest,
      lastActivityDate: today,
    );

    final response = await http.put(
      Uri.parse('$_baseUrl/streaks/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedStreak.toMap()),
    );

    if (response.statusCode == 200) {
      return StreakTracking.fromMap(jsonDecode(response.body));
    }
    return updatedStreak;
  }
}

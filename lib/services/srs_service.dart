import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../models/models.dart';
import '../data/static_data.dart';
import 'package:intl/intl.dart';

class SRSService {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String get _baseUrl {
    if (kIsWeb)
      return 'http://localhost:3000';
    else if (Platform.isAndroid)
      return 'http://10.0.2.2:3000';
    else
      return 'http://localhost:3000';
  }

  Future<void> answerCard(String userId, int wordId, bool isCorrect) async {
    await http.post(
      Uri.parse('$_baseUrl/srs/answer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'word_id': wordId,
        'isCorrect': isCorrect,
      }),
    );
  }

  Future<List<Map<String, dynamic>>> getDueCards(String userId) async {
    final today = _dateFormat.format(DateTime.now());
    final response = await http.get(
      Uri.parse('$_baseUrl/srs/due/$userId/$today'),
    );

    List<Map<String, dynamic>> dueWords = [];
    if (response.statusCode == 200) {
      final List<dynamic> cardsJson = jsonDecode(response.body);
      for (var doc in cardsJson) {
        final card = SRSCard.fromMap(doc);
        final wordDetails = StaticData.vocabulary.firstWhere(
          (w) => w['word_id'] == card.wordId,
          orElse: () => {},
        );
        if (wordDetails.isNotEmpty) {
          dueWords.add({...wordDetails, 'card_id': card.id});
        }
      }
    }

    if (dueWords.isEmpty) {
      final allResponse = await http.get(
        Uri.parse('$_baseUrl/srs/all/$userId'),
      );
      if (allResponse.statusCode == 200) {
        final List<dynamic> allCardsJson = jsonDecode(allResponse.body);
        final knownWordIds = allCardsJson
            .map((e) => e['word_id'] as int)
            .toSet();

        for (var w in StaticData.vocabulary) {
          if (!knownWordIds.contains(w['word_id'])) {
            dueWords.add(w);
            if (dueWords.length >= 5) break;
          }
        }
      }
    }
    return dueWords;
  }
}

import '../models/models.dart';
import '../data/static_data.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SRSService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> answerCard(String userId, int wordId, bool isCorrect) async {
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('srs_cards')
        .where('word_id', isEqualTo: wordId)
        .get();

    SRSCard card;
    DocumentReference docRef;
    if (query.docs.isNotEmpty) {
      card = SRSCard.fromMap(query.docs.first.data());
      docRef = query.docs.first.reference;
    } else {
      docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('srs_cards')
          .doc();
      card = SRSCard(id: docRef.id, userId: userId, wordId: wordId);
    }

    double easeFactor = card.easeFactor;
    int intervalDays = card.intervalDays;
    int repetitions = card.repetitions;

    if (isCorrect) {
      repetitions += 1;
      if (repetitions == 1) {
        intervalDays = 1;
      } else if (repetitions == 2) {
        intervalDays = 6;
      } else {
        intervalDays = (intervalDays * easeFactor).round();
      }
      easeFactor += 0.1;
    } else {
      repetitions = 0;
      intervalDays = 1;
      easeFactor -= 0.2;
      if (easeFactor < 1.3) easeFactor = 1.3;
    }

    final nextReviewDate = DateTime.now().add(Duration(days: intervalDays));
    final nextReviewStr = _dateFormat.format(nextReviewDate);

    final updatedCard = SRSCard(
      id: card.id,
      userId: userId,
      wordId: wordId,
      easeFactor: easeFactor,
      intervalDays: intervalDays,
      repetitions: repetitions,
      nextReviewAt: nextReviewStr,
    );

    await docRef.set(updatedCard.toMap());
  }

  Future<List<Map<String, dynamic>>> getDueCards(String userId) async {
    final today = _dateFormat.format(DateTime.now());

    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('srs_cards')
        .where('next_review_at', isLessThanOrEqualTo: today)
        .get();

    List<Map<String, dynamic>> dueWords = [];
    for (var doc in query.docs) {
      final card = SRSCard.fromMap(doc.data());
      final wordDetails = StaticData.vocabulary.firstWhere(
        (w) => w['word_id'] == card.wordId,
        orElse: () => {},
      );
      if (wordDetails.isNotEmpty) {
        dueWords.add({...wordDetails, 'card_id': card.id});
      }
    }

    if (dueWords.isEmpty) {
      final allSrs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('srs_cards')
          .get();
      final knownWordIds = allSrs.docs
          .map((e) => e.data()['word_id'] as int)
          .toSet();

      for (var w in StaticData.vocabulary) {
        if (!knownWordIds.contains(w['word_id'])) {
          dueWords.add(w);
          if (dueWords.length >= 5) break;
        }
      }
    }
    return dueWords;
  }
}

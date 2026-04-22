import '../models/models.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  Future<QuizSession> startSession(String userId, String sessionType) async {
    final nowStr = _dateFormat.format(DateTime.now());

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('quiz_sessions')
        .doc();

    final session = QuizSession(
      id: docRef.id,
      userId: userId,
      sessionType: sessionType,
      createdAt: nowStr,
    );
    await docRef.set(session.toMap());
    return session;
  }

  Future<void> endSessionAndAddXp(
    String userId,
    String sessionId,
    int xpEarned,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('quiz_sessions')
        .doc(sessionId)
        .update({'xp_earned': xpEarned});
  }

  Future<void> logBuilderAttempt(
    String userId,
    String sessionId,
    int templateId,
    bool isCorrect,
  ) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('builder_attempts')
        .doc();

    final attempt = BuilderAttempt(
      id: docRef.id,
      userId: userId,
      sessionId: sessionId,
      templateId: templateId,
      isCorrect: isCorrect,
      createdAt: _dateFormat.format(DateTime.now()),
    );
    await docRef.set(attempt.toMap());
  }

  Future<void> logTranslationAttempt(
    String userId,
    String sessionId,
    int templateId,
    double matchScore,
  ) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('translation_attempts')
        .doc();

    final attempt = TranslationAttempt(
      id: docRef.id,
      userId: userId,
      sessionId: sessionId,
      templateId: templateId,
      matchScore: matchScore,
      createdAt: _dateFormat.format(DateTime.now()),
    );
    await docRef.set(attempt.toMap());
  }

  Future<void> updateUserWordProgress(
    String userId,
    int wordId,
    bool isCorrect,
  ) async {
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('word_progress')
        .where('word_id', isEqualTo: wordId)
        .get();

    UserWordProgress progress;
    DocumentReference docRef;
    if (query.docs.isNotEmpty) {
      progress = UserWordProgress.fromMap(query.docs.first.data());
      docRef = query.docs.first.reference;
    } else {
      docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('word_progress')
          .doc();
      progress = UserWordProgress(
        id: docRef.id,
        userId: userId,
        wordId: wordId,
      );
    }

    int timesSeen = progress.timesSeen + 1;
    int timesCorrect = progress.timesCorrect + (isCorrect ? 1 : 0);
    double masteryLevel = (timesCorrect / timesSeen) * 5.0;
    if (masteryLevel > 5.0) masteryLevel = 5.0;

    final updated = UserWordProgress(
      id: docRef.id,
      userId: userId,
      wordId: wordId,
      timesSeen: timesSeen,
      timesCorrect: timesCorrect,
      masteryLevel: masteryLevel,
    );

    await docRef.set(updated.toMap());
  }
}

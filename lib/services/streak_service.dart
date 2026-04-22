import '../models/models.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreakService {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<StreakTracking> getOrCreateStreak(String userId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('streak_tracking')
        .doc('current');

    final snapshot = await docRef.get();
    if (snapshot.exists && snapshot.data() != null) {
      return StreakTracking.fromMap(snapshot.data()!);
    } else {
      final docId = docRef.id;
      final streak = StreakTracking(id: docId, userId: userId);
      await docRef.set(streak.toMap());
      return streak;
    }
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

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('streak_tracking')
        .doc('current')
        .update(updatedStreak.toMap());

    return updatedStreak;
  }
}

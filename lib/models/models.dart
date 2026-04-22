class User {
  final String? id;
  final String username;
  final int totalXp;

  User({this.id, required this.username, this.totalXp = 0});

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'total_xp': totalXp,
  };

  factory User.fromMap(Map<String, dynamic> map) =>
      User(id: map['id'], username: map['username'], totalXp: map['total_xp']);
}

class SRSCard {
  final String? id;
  final String userId;
  final int wordId;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final String? nextReviewAt;

  SRSCard({
    this.id,
    required this.userId,
    required this.wordId,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    this.repetitions = 0,
    this.nextReviewAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'word_id': wordId,
    'ease_factor': easeFactor,
    'interval_days': intervalDays,
    'repetitions': repetitions,
    'next_review_at': nextReviewAt,
  };

  factory SRSCard.fromMap(Map<String, dynamic> map) => SRSCard(
    id: map['id'],
    userId: map['user_id'],
    wordId: map['word_id'],
    easeFactor: (map['ease_factor'] ?? 2.5).toDouble(),
    intervalDays: map['interval_days'] ?? 1,
    repetitions: map['repetitions'] ?? 0,
    nextReviewAt: map['next_review_at'],
  );
}

class QuizSession {
  final String? id;
  final String userId;
  final String sessionType;
  final int xpEarned;
  final String? createdAt;

  QuizSession({
    this.id,
    required this.userId,
    required this.sessionType,
    this.xpEarned = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'session_type': sessionType,
    'xp_earned': xpEarned,
    'created_at': createdAt,
  };

  factory QuizSession.fromMap(Map<String, dynamic> map) => QuizSession(
    id: map['id'],
    userId: map['user_id'],
    sessionType: map['session_type'],
    xpEarned: map['xp_earned'] ?? 0,
    createdAt: map['created_at'],
  );
}

class BuilderAttempt {
  final String? id;
  final String userId;
  final String sessionId;
  final int templateId;
  final bool isCorrect;
  final String? createdAt;

  BuilderAttempt({
    this.id,
    required this.userId,
    required this.sessionId,
    required this.templateId,
    required this.isCorrect,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'session_id': sessionId,
    'template_id': templateId,
    'is_correct': isCorrect ? 1 : 0,
    'created_at': createdAt,
  };

  factory BuilderAttempt.fromMap(Map<String, dynamic> map) => BuilderAttempt(
    id: map['id'],
    userId: map['user_id'],
    sessionId: map['session_id'],
    templateId: map['template_id'],
    isCorrect: map['is_correct'] == 1,
    createdAt: map['created_at'],
  );
}

class TranslationAttempt {
  final String? id;
  final String userId;
  final String sessionId;
  final int templateId;
  final double matchScore;
  final String? createdAt;

  TranslationAttempt({
    this.id,
    required this.userId,
    required this.sessionId,
    required this.templateId,
    required this.matchScore,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'session_id': sessionId,
    'template_id': templateId,
    'match_score': matchScore,
    'created_at': createdAt,
  };

  factory TranslationAttempt.fromMap(Map<String, dynamic> map) =>
      TranslationAttempt(
        id: map['id'],
        userId: map['user_id'],
        sessionId: map['session_id'],
        templateId: map['template_id'],
        matchScore: (map['match_score'] ?? 0.0).toDouble(),
        createdAt: map['created_at'],
      );
}

class StreakTracking {
  final String? id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;

  StreakTracking({
    this.id,
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'last_activity_date': lastActivityDate,
  };

  factory StreakTracking.fromMap(Map<String, dynamic> map) => StreakTracking(
    id: map['id'],
    userId: map['user_id'],
    currentStreak: map['current_streak'] ?? 0,
    longestStreak: map['longest_streak'] ?? 0,
    lastActivityDate: map['last_activity_date'],
  );
}

class UserWordProgress {
  final String? id;
  final String userId;
  final int wordId;
  final int timesSeen;
  final int timesCorrect;
  final double masteryLevel;

  UserWordProgress({
    this.id,
    required this.userId,
    required this.wordId,
    this.timesSeen = 0,
    this.timesCorrect = 0,
    this.masteryLevel = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'word_id': wordId,
    'times_seen': timesSeen,
    'times_correct': timesCorrect,
    'mastery_level': masteryLevel,
  };

  factory UserWordProgress.fromMap(Map<String, dynamic> map) =>
      UserWordProgress(
        id: map['id'],
        userId: map['user_id'],
        wordId: map['word_id'],
        timesSeen: map['times_seen'] ?? 0,
        timesCorrect: map['times_correct'] ?? 0,
        masteryLevel: (map['mastery_level'] ?? 0.0).toDouble(),
      );
}

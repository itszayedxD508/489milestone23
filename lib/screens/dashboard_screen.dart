import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/streak_service.dart';
import '../models/models.dart';
import 'lesson_screen.dart';
import 'test_screen.dart';
import 'friends_screen.dart';
import '../data/static_data.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  const DashboardScreen({required this.userId, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StreakService _streakService = StreakService();
  StreakTracking? _streak;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final streak = await _streakService.updateStreakOnLogin(widget.userId);
    if (!mounted) return;
    await context.read<AuthProvider>().refreshUser();

    if (mounted) {
      setState(() {
        _streak = streak;
        _loading = false;
      });
    }
  }

  Future<void> _startSession(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LingoVault Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatsCard(),
              const SizedBox(height: 32),
              const Text(
                'Learning Journey',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildLearningStep(
                number: '1',
                title: 'Learn Words',
                subtitle: 'Master basic vocabulary',
                icon: Icons.school,
                color: Colors.blue,
                onTap: () => _startSession(
                  const LessonScreen(
                    title: 'Learn Words',
                    lessonItems: StaticData.wordsLesson,
                  ),
                ),
              ),
              _buildLearningStep(
                number: '2',
                title: 'Basic Introductions',
                subtitle: 'Short introduction sentences',
                icon: Icons.chat_bubble_outline,
                color: Colors.green,
                onTap: () => _startSession(
                  const LessonScreen(
                    title: 'Basic Introductions',
                    lessonItems: StaticData.introLesson,
                  ),
                ),
              ),
              _buildLearningStep(
                number: '3',
                title: 'Smaller Sentences',
                subtitle: 'Common daily phrases',
                icon: Icons.translate,
                color: Colors.orange,
                onTap: () => _startSession(
                  const LessonScreen(
                    title: 'Smaller Sentences',
                    lessonItems: StaticData.smallSentencesLesson,
                  ),
                ),
              ),
              _buildLearningStep(
                number: '4',
                title: 'Large Sentences',
                subtitle: 'Complex conversational structures',
                icon: Icons.menu_book,
                color: Colors.purple,
                onTap: () => _startSession(
                  const LessonScreen(
                    title: 'Large Sentences',
                    lessonItems: StaticData.largeSentencesLesson,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Community & Evaluation',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildFriendsCard(),
              const SizedBox(height: 16),
              _buildTestCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.deepOrangeAccent,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                '${_streak?.currentStreak ?? 0} Day Streak',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Container(height: 40, width: 1, color: Colors.white24),
          Column(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 36),
              const SizedBox(height: 8),
              Text(
                '${context.watch<AuthProvider>().currentUser?.totalXp ?? 0} XP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStep({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: color, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsCard() {
    return InkWell(
      onTap: () => _startSession(FriendsScreen(userId: widget.userId)),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B32C0), Color(0xFF6C63FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people, color: Colors.white, size: 40),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Friends & Chat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add users and chat with them!',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard() {
    return InkWell(
      onTap: () => _startSession(TestScreen(userId: widget.userId)),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3B32C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Take the Test',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Prove your skills and earn massive XP rewards!',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/streak_service.dart';
import '../services/user_service.dart';
import '../models/models.dart';
import 'login_screen.dart';
import 'srs_screen.dart';
import 'builder_screen.dart';
import 'translation_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  const DashboardScreen({required this.userId, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StreakService _streakService = StreakService();
  final UserService _userService = UserService();

  StreakTracking? _streak;
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final streak = await _streakService.updateStreakOnLogin(widget.userId);
    final user = await _userService.getCurrentUser();
    setState(() {
      _streak = streak;
      _user = user;
      _loading = false;
    });
  }

  void _logout() async {
    await _userService.logout();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  Future<void> _startSession(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    // Reload dynamically on returning from session (for xp update)
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatsCard(),
              const SizedBox(height: 32),
              const Text(
                'Start Learning',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildActionCard('SRS Review', Icons.school, Colors.blue, () {
                _startSession(SRSScreen(userId: widget.userId));
              }),
              _buildActionCard(
                'Sentence Builder',
                Icons.build,
                Colors.green,
                () {
                  _startSession(BuilderScreen(userId: widget.userId));
                },
              ),
              _buildActionCard(
                'Translation',
                Icons.translate,
                Colors.orange,
                () {
                  _startSession(TranslationScreen(userId: widget.userId));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_streak?.currentStreak ?? 0} Day Streak',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 40),
                const SizedBox(height: 8),
                Text(
                  '${_user?.totalXp ?? 0} XP',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'mood_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MoodStore.instance,
      builder: (context, _) {
        final store = MoodStore.instance;
        final total = store.totalCount;
        final mostFrequent = store.mostFrequentMood() ?? '-';
        final streak = store.currentStreak();

        return Scaffold(
          backgroundColor: const Color(0xFFFAF8FF),
          appBar: AppBar(
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _profileCard(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _statTile(
                        icon: Icons.bookmark_rounded,
                        label: 'Total Entries',
                        value: '$total',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statTile(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Streak',
                        value: '$streak days',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _statTile(
                  icon: Icons.favorite_rounded,
                  label: 'Most Frequent Mood',
                  value: mostFrequent,
                ),
                const SizedBox(height: 22),
                _settingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => _showSnack(context, 'Notification settings (demo)'),
                ),
                _settingsTile(
                  icon: Icons.color_lens_outlined,
                  title: 'Theme',
                  onTap: () => _showSnack(context, 'Theme selection (demo)'),
                ),
                _settingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () => _showSnack(context, 'Help & Support (demo)'),
                ),
                const SizedBox(height: 22),
                OutlinedButton.icon(
                  onPressed: total == 0
                      ? null
                      : () => _confirmReset(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Reset All Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFCC4A4A),
                    side: const BorderSide(color: Color(0xFFFFC7C7)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meltem',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'meltemyanoglu@gmail.com',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6B3FD6)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Color(0xFF777184))),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF6B3FD6)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB7B2C2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'All mood entries will be deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              MoodStore.instance.clear();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All records deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFCC4A4A),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

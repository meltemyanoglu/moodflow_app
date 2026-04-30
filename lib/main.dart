import 'package:flutter/material.dart';

import 'models/music_item.dart';
import 'services/auth_service.dart';
import 'services/music_recommendation_service.dart';
import 'stores/mood_store.dart';
import 'screens/login_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore the auth session first; AuthGate then decides what to show.
  await LocalAuthService.instance.init();
  // If a user is already logged in, load their mood data immediately so the
  // first frame of MainScaffold has data.
  final currentUser = LocalAuthService.instance.currentUser;
  if (currentUser != null) {
    await MoodStore.instance.setUser(currentUser.id);
  }
  runApp(const MoodFlowApp());
}

/// Decides between [LoginScreen] and [MainScaffold] based on auth state.
/// Also keeps [MoodStore]'s active user in sync with [LocalAuthService].
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastSyncedUserId;

  @override
  void initState() {
    super.initState();
    LocalAuthService.instance.addListener(_syncMoodStore);
    _lastSyncedUserId = LocalAuthService.instance.currentUser?.id;
  }

  @override
  void dispose() {
    LocalAuthService.instance.removeListener(_syncMoodStore);
    super.dispose();
  }

  /// Whenever the logged-in user changes, switch the MoodStore's bucket.
  void _syncMoodStore() {
    final newUserId = LocalAuthService.instance.currentUser?.id;
    if (newUserId == _lastSyncedUserId) return;
    _lastSyncedUserId = newUserId;
    MoodStore.instance.setUser(newUserId);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocalAuthService.instance,
      builder: (context, _) {
        final auth = LocalAuthService.instance;
        if (!auth.isInitialized) {
          return const Scaffold(
            backgroundColor: Color(0xFFFAF8FF),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6B3FD6)),
            ),
          );
        }
        return auth.isLoggedIn ? const MainScaffold() : const LoginScreen();
      },
    );
  }
}

class MoodFlowApp extends StatelessWidget {
  const MoodFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF8FF),
        colorSchemeSeed: const Color(0xFF6B3FD6),
      ),
      home: const AuthGate(),
    );
  }
}

class Mood {
  final String name;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final String imagePath;

  const Mood({
    required this.name,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.imagePath,
  });
}

const kMoods = <Mood>[
  Mood(
    name: 'Calm',
    description: 'Soft, peaceful, relaxed',
    icon: Icons.spa_rounded,
    gradient: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
    imagePath: 'assets/images/calm.jpg',
  ),
  Mood(
    name: 'Happy',
    description: 'Bright, positive, uplifting',
    icon: Icons.wb_sunny_rounded,
    gradient: [Color(0xFFFFB74D), Color(0xFFFF7043)],
    imagePath: 'assets/images/happy.jpg',
  ),
  Mood(
    name: 'Melancholic',
    description: 'Emotional, reflective, slow',
    icon: Icons.water_drop_rounded,
    gradient: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
    imagePath: 'assets/images/melancholic.jpg',
  ),
  Mood(
    name: 'Energetic',
    description: 'Fast, active, motivated',
    icon: Icons.bolt_rounded,
    gradient: [Color(0xFFFF6F61), Color(0xFFD81B60)],
    imagePath: 'assets/images/energetic.jpg',
  ),
];

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _goTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onOpenProfile: () => _goTo(3)),
      const HistoryScreen(),
      const StatsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        bottom: false,
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _goTo,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.home_rounded, 'Home'),
      (Icons.history_rounded, 'History'),
      (Icons.bar_chart_rounded, 'Stats'),
      (Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            _NavItem(
              icon: items[i].$1,
              label: items[i].$2,
              active: currentIndex == i,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF6B3FD6) : const Color(0xFF8C8AA0);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;

  const HomeScreen({
    super.key,
    required this.onOpenProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMoodIndex = 0;
  final TextEditingController journalController = TextEditingController();

  Mood get _selectedMood => kMoods[selectedMoodIndex];

  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    final mood = _selectedMood;

    await MoodStore.instance.add(
      MoodEntry.create(
        moodName: mood.name,
        note: journalController.text.trim(),
      ),
    );

    if (!mounted) return;

    journalController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${mood.name} saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mood = _selectedMood;
    final musicItems =
        MusicRecommendationService.instance.getMusicForMood(mood.name);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(onOpenProfile: widget.onOpenProfile),
          const SizedBox(height: 28),
          const _Intro(),
          const SizedBox(height: 24),
          _MoodGrid(
            selectedIndex: selectedMoodIndex,
            onSelect: (i) => setState(() => selectedMoodIndex = i),
          ),
          const SizedBox(height: 30),
          _SectionTitle('Daily Journal', Icons.notes_rounded),
          const SizedBox(height: 12),
          _JournalBox(controller: journalController),
          const SizedBox(height: 16),
          _SaveMoodButton(onPressed: _saveMood),
          const SizedBox(height: 28),
          _SectionTitle('Suggestions for you', Icons.auto_awesome_rounded),
          const SizedBox(height: 12),
          _MoodSuggestions(
            mood: mood,
            onUsePrompt: (prompt) {
              journalController.text = prompt;
              journalController.selection = TextSelection.collapsed(
                offset: prompt.length,
              );
            },
          ),
          const SizedBox(height: 28),
          _SectionTitle(
            'Music for ${mood.name.toLowerCase()} mood',
            Icons.music_note_rounded,
          ),
          const SizedBox(height: 12),
          for (final item in musicItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MusicCard(item: item),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onOpenProfile;

  const _Header({required this.onOpenProfile});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'MoodFlow',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            color: Color(0xFF14133B),
          ),
        ),
        InkWell(
          onTap: onOpenProfile,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Color(0xFFE5DFFF)),
            ),
            child: const Icon(Icons.person_outline_rounded),
          ),
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you\nfeeling today?',
          style: TextStyle(
            fontSize: 36,
            height: 1.08,
            fontWeight: FontWeight.w900,
            color: Color(0xFF161633),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Choose your mood and get personalized music + self-care suggestions.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Color(0xFF6F6B80),
          ),
        ),
      ],
    );
  }
}

class _MoodGrid extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _MoodGrid({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: kMoods.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final mood = kMoods[index];

        return _MoodCard(
          mood: mood,
          isSelected: selectedIndex == index,
          onTap: () => onSelect(index),
        );
      },
    );
  }
}

class _MoodCard extends StatefulWidget {
  final Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<_MoodCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final mood = widget.mood;
    final isSelected = widget.isSelected;
    final accent = mood.gradient.last;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : isSelected ? 1.025 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? accent.withOpacity(0.34)
                    : Colors.black.withOpacity(0.12),
                blurRadius: isSelected ? 24 : 14,
                spreadRadius: isSelected ? 1 : 0,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.95)
                  : Colors.transparent,
              width: isSelected ? 3 : 0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  mood.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: mood.gradient,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.02),
                        mood.gradient.last.withOpacity(0.58),
                        Colors.black.withOpacity(0.56),
                      ],
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: RadialGradient(
                          center: Alignment.topRight,
                          radius: 1.1,
                          colors: [
                            Colors.white.withOpacity(0.14),
                            accent.withOpacity(0.10),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          mood.name,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(
                                color: Color(0x66000000),
                                blurRadius: 7,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        mood.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: Colors.white.withOpacity(0.94),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B3FD6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: Color(0xFF171733),
            ),
          ),
        ),
      ],
    );
  }
}

class _JournalBox extends StatelessWidget {
  final TextEditingController controller;

  const _JournalBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDE8FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Write a few words about your mood...',
          hintStyle: TextStyle(color: Color(0xFF8D889A)),
        ),
      ),
    );
  }
}

class _SaveMoodButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveMoodButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3FD6).withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(Icons.bookmark_rounded),
        label: const Text(
          'Save Mood',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _MoodSuggestions extends StatelessWidget {
  final Mood mood;
  final ValueChanged<String> onUsePrompt;

  const _MoodSuggestions({
    required this.mood,
    required this.onUsePrompt,
  });

  @override
  Widget build(BuildContext context) {
    final service = MusicRecommendationService.instance;
    final selfCare = service.getSelfCareSuggestion(mood.name);
    final prompt = service.getJournalingPrompt(mood.name);
    final breath = service.getBreathingSuggestion(mood.name);

    return Column(
      children: [
        _SuggestionTile(
          icon: Icons.favorite_border_rounded,
          title: 'Self-care',
          body: selfCare,
          color: const Color(0xFFFF7E6B),
          onTap: () => _showInfoSheet(
            context,
            title: 'Self-care for ${mood.name.toLowerCase()} mood',
            body: selfCare,
            color: const Color(0xFFFF7E6B),
            icon: Icons.favorite_border_rounded,
          ),
        ),
        const SizedBox(height: 10),
        _SuggestionTile(
          icon: Icons.edit_note_rounded,
          title: 'Journaling prompt',
          body: prompt,
          color: const Color(0xFF6B3FD6),
          trailingLabel: 'Use',
          onTap: () => onUsePrompt(prompt),
        ),
        const SizedBox(height: 10),
        _SuggestionTile(
          icon: Icons.air_rounded,
          title: breath.title,
          body: breath.steps,
          color: const Color(0xFF1687A7),
          onTap: () => _showInfoSheet(
            context,
            title: breath.title,
            body: '${breath.steps}\n\n${breath.description}',
            color: const Color(0xFF1687A7),
            icon: Icons.air_rounded,
          ),
        ),
      ],
    );
  }

  void _showInfoSheet(
    BuildContext context, {
    required String title,
    required String body,
    required Color color,
    required IconData icon,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(
                fontSize: 15,
                height: 1.55,
                color: Color(0xFF4A4761),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final VoidCallback onTap;
  final String? trailingLabel;

  const _SuggestionTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.onTap,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF171733),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF6F6B80),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingLabel != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trailingLabel!,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MusicCard extends StatelessWidget {
  final MusicItem item;

  const _MusicCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _CoverArt(item: item, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF171733),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777184),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.gradient.last.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.mood,
                        style: TextStyle(
                          fontSize: 11,
                          color: item.gradient.last,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showPlayingSnack(context),
                icon: Icon(
                  Icons.play_arrow_rounded,
                  color: item.gradient.last,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlayingSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing "${item.title}" (demo)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _CoverArt(item: item, size: 180)),
            const SizedBox(height: 18),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              style: const TextStyle(color: Color(0xFF777184)),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showPlayingSnack(context);
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Play Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.gradient.last,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            if (item.externalLink != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Open link: ${item.externalLink}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open in music app'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CoverArt extends StatelessWidget {
  final MusicItem item;
  final double size;

  const _CoverArt({
    required this.item,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size > 100 ? 24 : 18),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.gradient,
          ),
        ),
        child: item.imageUrl != null
            ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _iconFallback(),
              )
            : _iconFallback(),
      ),
    );
  }

  Widget _iconFallback() {
    return Center(
      child: Icon(
        item.icon,
        color: Colors.white,
        size: size * 0.4,
      ),
    );
  }
}
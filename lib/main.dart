import 'package:flutter/material.dart';

void main() {
  runApp(const MoodFlowApp());
}

class MoodFlowApp extends StatelessWidget {
  const MoodFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const MoodFlowHome(),
    );
  }
}

class Mood {
  final String name;
  final String description;
  final String imageUrl;

  const Mood({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

class MusicItem {
  final String title;
  final String subtitle;
  final String imageUrl;

  const MusicItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

class MoodFlowHome extends StatefulWidget {
  const MoodFlowHome({super.key});

  @override
  State<MoodFlowHome> createState() => _MoodFlowHomeState();
}

class _MoodFlowHomeState extends State<MoodFlowHome> {
  int selectedMoodIndex = 0;
  final TextEditingController journalController = TextEditingController();

  final List<Mood> moods = const [
    Mood(
      name: 'Calm',
      description: 'Soft, peaceful, relaxed',
      imageUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80',
    ),
    Mood(
      name: 'Happy',
      description: 'Bright, positive, uplifting',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
    ),
    Mood(
      name: 'Melancholic',
      description: 'Emotional, reflective, slow',
      imageUrl:
          'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=800&q=80',
    ),
    Mood(
      name: 'Energetic',
      description: 'Fast, active, motivated',
      imageUrl:
          'https://images.unsplash.com/photo-1549476464-37392f717541?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  final List<MusicItem> musicItems = const [
    MusicItem(
      title: 'Deep Focus',
      subtitle: 'Ambient · 50 tracks',
      imageUrl:
          'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=400&q=80',
    ),
    MusicItem(
      title: 'Peaceful Piano',
      subtitle: 'Piano · 32 tracks',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
    ),
    MusicItem(
      title: 'Nature Sounds',
      subtitle: 'Relaxation · 40 tracks',
      imageUrl:
          'https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedMood = moods[selectedMoodIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 28),
              _intro(),
              const SizedBox(height: 24),
              _moodGrid(),
              const SizedBox(height: 30),
              _sectionTitle('Daily Journal', Icons.notes_rounded),
              const SizedBox(height: 12),
              _journalBox(),
              const SizedBox(height: 22),
              _saveButton(),
              const SizedBox(height: 32),
              _selectedMoodCard(selectedMood),
              const SizedBox(height: 26),
              _sectionTitle('Recommended for you', Icons.music_note_rounded),
              const SizedBox(height: 14),
              ...musicItems.map((item) => _musicCard(item)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _header() {
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
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5DFFF)),
          ),
          child: const Icon(Icons.person_outline_rounded),
        ),
      ],
    );
  }

  Widget _intro() {
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
          'Choose your mood and get personalized music suggestions.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Color(0xFF6F6B80),
          ),
        ),
      ],
    );
  }

  Widget _moodGrid() {
    return GridView.builder(
      itemCount: moods.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final mood = moods[index];
        final isSelected = selectedMoodIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedMoodIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    mood.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.1),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Color(0xFF6B3FD6),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mood.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mood.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B3FD6)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: Color(0xFF171733),
          ),
        ),
      ],
    );
  }

  Widget _journalBox() {
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
        controller: journalController,
        maxLines: 5,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Write a few words about your mood...',
          hintStyle: TextStyle(color: Color(0xFF8D889A)),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7C4DFF),
            Color(0xFF5E35B1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3FD6).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mood saved successfully')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
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

  Widget _selectedMoodCard(Mood mood) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE4DCFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF4527A0)],
              ),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Good choice!\n${mood.name} vibes. Let’s enjoy some peaceful tunes.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: Color(0xFF22203A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _musicCard(MusicItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              item.imageUrl,
              width: 74,
              height: 74,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF171733),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777184),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Calm',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1687A7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE5FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Color(0xFF6B3FD6),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNav() {
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Home', active: true),
          _NavItem(icon: Icons.history_rounded, label: 'History'),
          _NavItem(icon: Icons.bar_chart_rounded, label: 'Stats'),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: active ? const Color(0xFF6B3FD6) : const Color(0xFF2F2D3B),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF6B3FD6) : const Color(0xFF2F2D3B),
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
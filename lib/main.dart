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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class Mood {
  final String name;
  final String emoji;
  final String description;

  const Mood({
    required this.name,
    required this.emoji,
    required this.description,
  });
}

class MusicRecommendation {
  final String title;
  final String subtitle;
  final String mood;

  const MusicRecommendation({
    required this.title,
    required this.subtitle,
    required this.mood,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Mood? selectedMood;
  final TextEditingController journalController = TextEditingController();

  final List<Mood> moods = const [
    Mood(
      name: 'Calm',
      emoji: '🌿',
      description: 'Soft, peaceful, relaxed',
    ),
    Mood(
      name: 'Happy',
      emoji: '☀️',
      description: 'Bright, positive, uplifting',
    ),
    Mood(
      name: 'Melancholic',
      emoji: '🌙',
      description: 'Emotional, reflective, slow',
    ),
    Mood(
      name: 'Energetic',
      emoji: '⚡',
      description: 'Fast, active, motivated',
    ),
  ];

  List<MusicRecommendation> getRecommendations() {
    if (selectedMood == null) return [];

    switch (selectedMood!.name) {
      case 'Calm':
        return const [
          MusicRecommendation(
            title: 'Ambient Focus',
            subtitle: 'Soft textures and slow soundscapes',
            mood: 'Calm',
          ),
          MusicRecommendation(
            title: 'Peaceful Piano',
            subtitle: 'Minimal piano pieces for relaxation',
            mood: 'Calm',
          ),
        ];
      case 'Happy':
        return const [
          MusicRecommendation(
            title: 'Sunny Pop',
            subtitle: 'Upbeat songs with warm melodies',
            mood: 'Happy',
          ),
          MusicRecommendation(
            title: 'Feel Good Indie',
            subtitle: 'Light and cheerful indie tracks',
            mood: 'Happy',
          ),
        ];
      case 'Melancholic':
        return const [
          MusicRecommendation(
            title: 'Late Night Reflections',
            subtitle: 'Emotional songs for quiet moments',
            mood: 'Melancholic',
          ),
          MusicRecommendation(
            title: 'Soft Acoustic Mood',
            subtitle: 'Gentle guitar and intimate vocals',
            mood: 'Melancholic',
          ),
        ];
      case 'Energetic':
        return const [
          MusicRecommendation(
            title: 'Workout Energy',
            subtitle: 'Fast beats for motivation',
            mood: 'Energetic',
          ),
          MusicRecommendation(
            title: 'Electronic Boost',
            subtitle: 'Dynamic electronic tracks',
            mood: 'Energetic',
          ),
        ];
      default:
        return [];
    }
  }

  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = getRecommendations();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        title: const Text(
          'MoodFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your mood and get a personalized music suggestion.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: moods.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) {
                final mood = moods[index];
                final isSelected = selectedMood?.name == mood.name;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = mood;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 34),
                        ),
                        const Spacer(),
                        Text(
                          mood.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? Colors.white.withOpacity(0.85)
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            const Text(
              'Daily Journal',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: journalController,
              minLines: 4,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Write a few words about your mood...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: selectedMood == null
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Mood saved: ${selectedMood!.name}',
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Save Mood',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),

            if (selectedMood != null) ...[
              Text(
                'Music for ${selectedMood!.name}',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ...recommendations.map(
                (music) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              music.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              music.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
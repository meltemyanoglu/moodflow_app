import 'package:flutter/material.dart';
import '../models/music_item.dart';

/// Returns mood-based suggestions for the home screen.
///
/// Right now everything is **local** — there is no network call. The service
/// is structured so that swapping in a real provider (Spotify / YouTube Music
/// / Apple Music) later only requires touching this file.
///
/// To plug in Spotify later:
///   1. Add the `spotify_sdk` (playback) and/or `http` (Web API) packages.
///   2. Implement `_fetchFromSpotify(mood)` returning `Future<List<MusicItem>>`.
///   3. In [getMusicForMood], try Spotify first; on error fall back to local.
///
/// The UI does not need to know which source was used.
class MusicRecommendationService {
  MusicRecommendationService._();
  static final MusicRecommendationService instance =
      MusicRecommendationService._();

  // ---------------- MUSIC ----------------

  /// Returns 3 suggestions for the given mood. Synchronous + always non-empty
  /// so the UI never has to deal with loading/empty states for the local path.
  ///
  /// When you wire up a real API, change the signature to
  /// `Future<List<MusicItem>>` and have the caller `await` it.
  List<MusicItem> getMusicForMood(String mood) {
    final list = _localCatalog[mood];
    if (list == null || list.isEmpty) return _localCatalog['Calm']!;
    return list;
  }

  /*
  // ---- FUTURE: Spotify Web API integration ----
  //
  // Future<List<MusicItem>> _fetchFromSpotify(String mood) async {
  //   final seedGenres = _spotifySeedsForMood(mood);
  //   final token = await SpotifyAuth.getAccessToken();
  //   final response = await http.get(
  //     Uri.parse(
  //       'https://api.spotify.com/v1/recommendations'
  //       '?seed_genres=$seedGenres&limit=10',
  //     ),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (response.statusCode != 200) {
  //     throw Exception('Spotify error: ${response.statusCode}');
  //   }
  //   final data = jsonDecode(response.body) as Map<String, dynamic>;
  //   final tracks = data['tracks'] as List;
  //   return tracks.map((t) => MusicItem(
  //     title: t['name'],
  //     subtitle: (t['artists'] as List).map((a) => a['name']).join(', '),
  //     mood: mood,
  //     imageUrl: (t['album']['images'] as List).first['url'],
  //     externalLink: t['external_urls']['spotify'],
  //     gradient: _gradientForMood(mood),
  //     icon: Icons.music_note_rounded,
  //   )).toList();
  // }
  //
  // String _spotifySeedsForMood(String mood) {
  //   switch (mood) {
  //     case 'Calm':        return 'ambient,acoustic,chill';
  //     case 'Happy':       return 'pop,happy,summer';
  //     case 'Energetic':   return 'work-out,electronic,dance';
  //     case 'Melancholic': return 'sad,indie,piano';
  //     default:            return 'pop';
  //   }
  // }
  */

  // ---------------- SELF-CARE / PROMPT / BREATHING ----------------

  /// One short, actionable self-care tip for the mood.
  String getSelfCareSuggestion(String mood) {
    switch (mood) {
      case 'Happy':
        return 'Capture this energy: text someone you appreciate or write '
            'down 3 things that made today good.';
      case 'Energetic':
        return 'Channel it. A 15-minute walk, quick tidy-up, or a workout '
            'will turn this into momentum.';
      case 'Melancholic':
        return 'Be gentle with yourself. Warm drink, soft light, no big '
            'decisions tonight. Feelings pass.';
      case 'Calm':
      default:
        return 'Protect this state. Step away from screens for 10 minutes '
            'and just notice your surroundings.';
    }
  }

  /// One reflective journaling prompt tailored to the mood.
  String getJournalingPrompt(String mood) {
    switch (mood) {
      case 'Happy':
        return 'What specifically lifted you today, and what would it take '
            'to feel this way again next week?';
      case 'Energetic':
        return 'Where will you direct this energy in the next hour?';
      case 'Melancholic':
        return 'If a close friend felt exactly what you feel right now, '
            'what would you tell them?';
      case 'Calm':
      default:
        return 'Describe this calm in three sentences. What helped you '
            'arrive here?';
    }
  }

  /// A short breathing or grounding exercise for the mood.
  BreathingSuggestion getBreathingSuggestion(String mood) {
    switch (mood) {
      case 'Energetic':
        return const BreathingSuggestion(
          title: 'Box Breathing',
          steps: 'Inhale 4s · Hold 4s · Exhale 4s · Hold 4s. Repeat 4 times.',
          description: 'Steadies the nervous system without dulling the spark.',
        );
      case 'Melancholic':
        return const BreathingSuggestion(
          title: '4-7-8 Breath',
          steps: 'Inhale 4s · Hold 7s · Exhale 8s. Repeat 4 times.',
          description: 'Activates the parasympathetic system. A soft reset.',
        );
      case 'Happy':
        return const BreathingSuggestion(
          title: 'Savoring Pause',
          steps: 'Inhale slowly · Smile · Exhale longer than the inhale.',
          description: 'Anchors the good feeling into your body.',
        );
      case 'Calm':
      default:
        return const BreathingSuggestion(
          title: 'Coherent Breathing',
          steps: 'Inhale 5s · Exhale 5s. Continue for 2 minutes.',
          description: 'Keeps heart rate variability in the calm zone.',
        );
    }
  }

  // ---------------- LOCAL CATALOG ----------------

  static const _calmGradient = [Color(0xFF7C4DFF), Color(0xFF5E35B1)];
  static const _happyGradient = [Color(0xFFFFB74D), Color(0xFFFF7043)];
  static const _energeticGradient = [Color(0xFFFF6F61), Color(0xFFD81B60)];
  static const _melancholicGradient = [Color(0xFF5C6BC0), Color(0xFF3949AB)];

  static final Map<String, List<MusicItem>> _localCatalog = {
    'Calm': const [
      MusicItem(
        title: 'Peaceful Piano',
        subtitle: 'Soft solo piano · 32 tracks',
        mood: 'Calm',
        gradient: _calmGradient,
        icon: Icons.piano_rounded,
      ),
      MusicItem(
        title: 'Ambient Focus',
        subtitle: 'Drone & textures · 50 tracks',
        mood: 'Calm',
        gradient: _calmGradient,
        icon: Icons.cloud_rounded,
      ),
      MusicItem(
        title: 'Nature Sounds',
        subtitle: 'Rain · forest · ocean',
        mood: 'Calm',
        gradient: _calmGradient,
        icon: Icons.spa_rounded,
      ),
    ],
    'Happy': const [
      MusicItem(
        title: 'Feel Good Pop',
        subtitle: 'Upbeat pop hits · 45 tracks',
        mood: 'Happy',
        gradient: _happyGradient,
        icon: Icons.wb_sunny_rounded,
      ),
      MusicItem(
        title: 'Sunny Indie',
        subtitle: 'Bright indie & folk · 38 tracks',
        mood: 'Happy',
        gradient: _happyGradient,
        icon: Icons.emoji_emotions_rounded,
      ),
      MusicItem(
        title: 'Summer Drive',
        subtitle: 'Open windows · 30 tracks',
        mood: 'Happy',
        gradient: _happyGradient,
        icon: Icons.directions_car_rounded,
      ),
    ],
    'Energetic': const [
      MusicItem(
        title: 'Workout Power',
        subtitle: 'High BPM hype · 40 tracks',
        mood: 'Energetic',
        gradient: _energeticGradient,
        icon: Icons.fitness_center_rounded,
      ),
      MusicItem(
        title: 'Dance Floor',
        subtitle: 'House & techno · 50 tracks',
        mood: 'Energetic',
        gradient: _energeticGradient,
        icon: Icons.flash_on_rounded,
      ),
      MusicItem(
        title: 'Hype Hip-Hop',
        subtitle: 'Heavy beats · 35 tracks',
        mood: 'Energetic',
        gradient: _energeticGradient,
        icon: Icons.headphones_rounded,
      ),
    ],
    'Melancholic': const [
      MusicItem(
        title: 'Sad Songs',
        subtitle: 'Slow & emotional · 28 tracks',
        mood: 'Melancholic',
        gradient: _melancholicGradient,
        icon: Icons.water_drop_rounded,
      ),
      MusicItem(
        title: 'Indie Bittersweet',
        subtitle: 'Reflective indie · 32 tracks',
        mood: 'Melancholic',
        gradient: _melancholicGradient,
        icon: Icons.cloud_outlined,
      ),
      MusicItem(
        title: 'Late Night Piano',
        subtitle: 'Slow piano nocturnes · 24 tracks',
        mood: 'Melancholic',
        gradient: _melancholicGradient,
        icon: Icons.nightlight_round,
      ),
    ],
  };
}

/// Small value type for breathing exercise content.
class BreathingSuggestion {
  final String title;
  final String steps;
  final String description;
  const BreathingSuggestion({
    required this.title,
    required this.steps,
    required this.description,
  });
}

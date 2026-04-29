import 'package:flutter/material.dart';

/// A single music recommendation item.
///
/// Designed to be source-agnostic: today the data is local, tomorrow it can
/// come from Spotify / Apple Music / YouTube Music. Set [externalLink] to a
/// `spotify:` URI or web URL when you wire up a real provider.
class MusicItem {
  final String title;
  final String subtitle;
  final String mood;

  /// Used when [imageUrl] is null OR fails to load. Two-color soft gradient.
  final List<Color> gradient;

  /// Optional cover art. Falls back to a gradient + icon if null.
  final String? imageUrl;

  /// Optional. Tapping "Open" can launch this in the user's music app later.
  /// Examples: `spotify:playlist:37i9dQZF1DX...`,
  /// `https://music.youtube.com/playlist?list=...`,
  /// `https://music.apple.com/...`
  final String? externalLink;

  /// Material icon shown over the gradient when there is no image.
  final IconData icon;

  const MusicItem({
    required this.title,
    required this.subtitle,
    required this.mood,
    required this.gradient,
    required this.icon,
    this.imageUrl,
    this.externalLink,
  });
}

// lib/services/garden_generation_service.dart
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../replicate_nano_banana_service_multi.dart';
import '../safe_prompt_filter.dart';

export '../replicate_nano_banana_service_multi.dart'
    show GenerationConfig, UnsafePromptException, NetworkException;

/// Builds an optimised Imagen / Replicate prompt from the settings that the
/// user selected in [CustomStudioScreen].
class GardenPromptBuilder {
  static String build({
    required String styleName,
    required Map<String, dynamic> settings,
  }) {
    final parts = <String>[];

    // ── Preservation prefix ──────────────────────────────────────────────
    parts.add(
      'Transform this existing outdoor garden photo while preserving the '
      'exact same camera angle, perspective, spatial layout, '
      'and surrounding architecture.',
    );

    // ── Style ────────────────────────────────────────────────────────────
    parts.add('Apply a $styleName garden design style to the outdoor space.');

    // ── Season ───────────────────────────────────────────────────────────
    final season = settings['season'] as String?;
    if (season != null && season.isNotEmpty) {
      parts.add('Set the garden in $season season with appropriate seasonal '
          'plants, colors, and atmosphere.');
    }

    // ── Time of Day ──────────────────────────────────────────────────────
    final timeOfDay = settings['timeOfDay'] as String?;
    if (timeOfDay != null && timeOfDay.isNotEmpty) {
      parts.add('Lighting should reflect $timeOfDay ambiance.');
    }

    // ── Plant density ────────────────────────────────────────────────────
    final density = (settings['density'] as num?)?.toDouble() ?? 0.5;
    if (density > 0.7) {
      parts.add('Dense, lush planting with abundant greenery and full canopy.');
    } else if (density < 0.3) {
      parts.add('Sparse, minimalist planting with open space and breathing room.');
    } else {
      parts.add('Balanced planting density with well-spaced plants.');
    }

    // ── Flower intensity ─────────────────────────────────────────────────
    final flowers = (settings['flowers'] as num?)?.toDouble() ?? 0.3;
    if (flowers > 0.6) {
      parts.add(
          'Abundant colorful flowering plants and blooming borders.');
    } else if (flowers > 0.2) {
      parts.add('Moderate floral accents and flowering shrubs.');
    }

    // ── Water ────────────────────────────────────────────────────────────
    final water = (settings['water'] as num?)?.toDouble() ?? 0.0;
    if (water > 0.4) {
      parts.add('Include water features such as a fountain or pond.');
    }

    // ── Sunlight ─────────────────────────────────────────────────────────
    final sunlight = (settings['sunlight'] as num?)?.toDouble() ?? 0.7;
    final lightDesc = sunlight > 0.6
        ? 'bright, sun-drenched'
        : sunlight > 0.3
            ? 'partially shaded, dappled light'
            : 'softly shaded, cool tones';
    parts.add('Garden has $lightDesc sunlight conditions.');

    // ── Tree size ────────────────────────────────────────────────────────
    final treeSize = (settings['treeSize'] as num?)?.toDouble() ?? 0.5;
    if (treeSize > 0.7) {
      parts.add('Include tall mature trees for scale and shade.');
    } else if (treeSize < 0.3) {
      parts.add('Small ornamental trees and compact shrubs only.');
    }

    // ── Color vibrancy ───────────────────────────────────────────────────
    final vibrancy = (settings['colorVibrancy'] as num?)?.toDouble() ?? 0.6;
    if (vibrancy > 0.7) {
      parts.add('Bold, vibrant color palette with high saturation.');
    } else if (vibrancy < 0.3) {
      parts.add('Muted, neutral, and earthy tones throughout.');
    }

    // ── Pathway ──────────────────────────────────────────────────────────
    final pathwayIdx = (settings['pathway'] as num?)?.toInt() ?? 0;
    const pathways = [
      'stone path',
      'wood deck',
      'gravel',
      'brick',
      'concrete',
      'flagstone',
    ];
    if (pathwayIdx < pathways.length) {
      parts.add(
          'Pathways made of ${pathways[pathwayIdx]} material.');
    }

    // ── Lighting fixture ─────────────────────────────────────────────────
    final lightingIdx = (settings['lighting'] as num?)?.toInt() ?? 0;
    const lightingNames = [
      'warm ambient lamps',
      'moonlight-style cool lighting',
      'fairy string lights',
      'directional spotlights',
      'decorative lanterns',
      'solar path lights',
    ];
    if (lightingIdx < lightingNames.length) {
      parts.add('Garden lighting uses ${lightingNames[lightingIdx]}.');
    }

    // ── Water feature ────────────────────────────────────────────────────
    final waterFeatureIdx = (settings['waterFeature'] as num?)?.toInt() ?? -1;
    const waterFeatures = [
      'fountain',
      'koi pond',
      'winding stream',
      'waterfall',
      'bird bath',
      'rain chain',
    ];
    if (waterFeatureIdx >= 0 && waterFeatureIdx < waterFeatures.length) {
      parts.add(
          'Include a decorative ${waterFeatures[waterFeatureIdx]} as a focal point.');
    }

    // ── Quality suffix ───────────────────────────────────────────────────
    parts.add(
      'Photorealistic result, professional landscape photography, '
      'consistent lighting and shadows, high resolution, 8K quality, '
      'maintaining exact same outdoor space proportions and surroundings.',
    );

    return parts.join(' ');
  }
}

/// Thin wrapper that loads image bytes from a file path and calls the API.
class GardenGenerationService {
  GardenGenerationService()
      : _api = ReplicateGardenAIService(
          filter: SafePromptFilter(mode: 'strict'),
        );

  final ReplicateGardenAIService _api;

  /// [imagePath] — absolute path of the uploaded garden photo.
  /// [styleName] — selected style name.
  /// [settings]  — map of all custom-studio slider / picker values.
  Future<String?> generate({
    required String imagePath,
    required String styleName,
    required Map<String, dynamic> settings,
    GenerationConfig config = const GenerationConfig(),
  }) async {
    final bytes = await File(imagePath).readAsBytes();
    final prompt = GardenPromptBuilder.build(
      styleName: styleName,
      settings: settings,
    );
    debugPrint('[GardenGeneration] Prompt: $prompt');

    return _api.generateMultiBytes(
      images: [bytes],
      prompt: prompt,
      config: config,
    );
  }

  void dispose() => _api.dispose();
}

// lib/services/pantry_generation_service.dart
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../replicate_nano_banana_service_multi.dart';
import '../safe_prompt_filter.dart';

export '../replicate_nano_banana_service_multi.dart'
    show GenerationConfig, UnsafePromptException, NetworkException;

/// Builds an optimised Imagen / Replicate prompt from the settings that the
/// user selected in [CustomStudioScreen].
class PantryPromptBuilder {
  static String build({
    required String styleName,
    required Map<String, dynamic> settings,
  }) {
    final parts = <String>[];

    // ── Preservation prefix ──────────────────────────────────────────────
    parts.add(
      'Transform this existing indoor pantry photo while preserving the '
      'exact same camera angle, perspective, spatial layout, '
      'and surrounding architecture.',
    );

    // ── Style ────────────────────────────────────────────────────────────
    parts.add('Apply a $styleName pantry design style to the indoor space.');

    // ── Season ───────────────────────────────────────────────────────────
    final season = settings['season'] as String?;
    if (season != null && season.isNotEmpty) {
      parts.add('Set the pantry in $season season with appropriate seasonal '
          'ingredients, containers, and lighting.');
    }

    // ── Time of Day ──────────────────────────────────────────────────────
    final timeOfDay = settings['timeOfDay'] as String?;
    if (timeOfDay != null && timeOfDay.isNotEmpty) {
      parts.add('Lighting should reflect $timeOfDay ambiance.');
    }

    // ── Ingredient density ────────────────────────────────────────────────────
    final density = (settings['density'] as num?)?.toDouble() ?? 0.5;
    if (density > 0.7) {
      parts.add('Dense storage with abundant items and full shelves.');
    } else if (density < 0.3) {
      parts.add('Sparse, minimalist storage with open space and breathing room.');
    } else {
      parts.add('Balanced container density with well-spaced items.');
    }

    // ── Flower intensity ─────────────────────────────────────────────────
    final flowers = (settings['flowers'] as num?)?.toDouble() ?? 0.3;
    if (flowers > 0.6) {
      parts.add(
          'Abundant colorful spices and well-organized borders.');
    } else if (flowers > 0.2) {
      parts.add('Moderate spice displays and neatly aligned containers.');
    }

    // ── Water ────────────────────────────────────────────────────────────
    final water = (settings['water'] as num?)?.toDouble() ?? 0.0;
    if (water > 0.4) {
      parts.add('Include container organization features such as matching sets.');
    }

    // ── Sunlight ─────────────────────────────────────────────────────────
    final sunlight = (settings['sunlight'] as num?)?.toDouble() ?? 0.7;
    final lightDesc = sunlight > 0.6
        ? 'bright, sun-drenched'
        : sunlight > 0.3
            ? 'partially shaded, dappled light'
            : 'softly shaded, cool tones';
    parts.add('Pantry has $lightDesc lighting conditions.');

    // ── Container size ────────────────────────────────────────────────────────
    final containerSize = (settings['containerSize'] as num?)?.toDouble() ?? 0.5;
    if (containerSize > 0.7) {
      parts.add('Include large containers and bulk bins.');
    } else if (containerSize < 0.3) {
      parts.add('Small spice jars and neat organizers only.');
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
      parts.add('Pantry lighting uses ${lightingNames[lightingIdx]}.');
    }

    // ── Container organization ────────────────────────────────────────────────────
    final waterFeatureIdx = (settings['waterFeature'] as num?)?.toInt() ?? -1;
    const containerFeatures = [
      'fountain',
      'koi pond',
      'winding stream',
      'waterfall',
      'bird bath',
      'rain chain',
    ];
    if (waterFeatureIdx >= 0 && waterFeatureIdx < containerFeatures.length) {
      parts.add(
          'Include a decorative ${containerFeatures[waterFeatureIdx]} as a focal point.');
    }

    // ── Quality suffix ───────────────────────────────────────────────────
    parts.add(
      'Photorealistic result, professional interior photography, '
      'consistent lighting and shadows, high resolution, 8K quality, '
      'maintaining exact same indoor space proportions and surroundings.',
    );

    return parts.join(' ');
  }
}

/// Thin wrapper that loads image bytes from a file path and calls the API.
class PantryGenerationService {
  PantryGenerationService()
      : _api = ReplicatePantryAIService(
          filter: SafePromptFilter(mode: 'strict'),
        );

  final ReplicatePantryAIService _api;

  /// [imagePath] — absolute path of the uploaded pantry photo.
  /// [styleName] — selected style name.
  /// [settings]  — map of all custom-studio slider / picker values.
  Future<String?> generate({
    required String imagePath,
    required String styleName,
    required Map<String, dynamic> settings,
    GenerationConfig config = const GenerationConfig(),
  }) async {
    final bytes = await File(imagePath).readAsBytes();
    final prompt = PantryPromptBuilder.build(
      styleName: styleName,
      settings: settings,
    );
    debugPrint('[PantryGeneration] Prompt: $prompt');

    return _api.generateMultiBytes(
      images: [bytes],
      prompt: prompt,
      config: config,
    );
  }

  void dispose() => _api.dispose();
}

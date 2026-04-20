import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import 'safe_prompt_filter.dart';

class UnsafePromptException implements Exception {
  UnsafePromptException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Configuration for image generation that controls how similar
/// the output is to the input image.
class GenerationConfig {
  /// How much to preserve the original room structure (0.0 - 1.0).
  /// Higher = more faithful to original layout.
  final double structureStrength;

  /// How much the output should resemble the input image (0.0 - 1.0).
  /// Higher = more similar to original.
  final double imageStrength;

  /// How closely to follow the text prompt (1.0 - 30.0).
  /// Lower = more faithful to image, Higher = more creative.
  final double guidanceScale;

  /// Number of inference steps. More = higher quality but slower.
  final int numInferenceSteps;

  /// Output format
  final String outputFormat;

  /// Output quality (1-100)
  final int outputQuality;

  const GenerationConfig({
    this.structureStrength = 0.92,
    this.imageStrength = 0.88,
    this.guidanceScale = 7.5,
    this.numInferenceSteps = 30,
    this.outputFormat = 'jpg',
    this.outputQuality = 100,
  });

  /// Preset: Maximum similarity to original image.
  /// Only subtle material/color changes.
  factory GenerationConfig.subtle() => const GenerationConfig(
    structureStrength: 0.95,
    imageStrength: 0.92,
    guidanceScale: 5.0,
    numInferenceSteps: 35,
  );

  /// Preset: Balanced - preserves layout but allows material changes.
  /// Default for garden redesign.
  factory GenerationConfig.balanced() => const GenerationConfig(
    structureStrength: 0.92,
    imageStrength: 0.85,
    guidanceScale: 7.5,
    numInferenceSteps: 30,
  );

  /// Preset: More creative - allows bigger design changes
  /// while keeping room structure.
  factory GenerationConfig.creative() => const GenerationConfig(
    structureStrength: 0.85,
    imageStrength: 0.75,
    guidanceScale: 10.0,
    numInferenceSteps: 30,
  );

  GenerationConfig copyWith({
    double? structureStrength,
    double? imageStrength,
    double? guidanceScale,
    int? numInferenceSteps,
    String? outputFormat,
    int? outputQuality,
  }) {
    return GenerationConfig(
      structureStrength: structureStrength ?? this.structureStrength,
      imageStrength: imageStrength ?? this.imageStrength,
      guidanceScale: guidanceScale ?? this.guidanceScale,
      numInferenceSteps: numInferenceSteps ?? this.numInferenceSteps,
      outputFormat: outputFormat ?? this.outputFormat,
      outputQuality: outputQuality ?? this.outputQuality,
    );
  }
}

class ReplicateGardenAIService {
  ReplicateGardenAIService({SafePromptFilter? filter})
    : _filter = filter ?? SafePromptFilter(mode: 'strict');

  static const _apiToken = 'API_KEY';
  static const _model =
      'landscaping/garden-ai'; // Generic garden model placeholder

  final _client = http.Client();
  final SafePromptFilter _filter;

  /// Builds an optimized prompt for garden image-to-image generation.
  ///
  /// The prompt is constructed to:
  /// 1. Explicitly preserve outdoor structure, perspective, and dimensions
  /// 2. Only modify the specified landscape materials
  /// 3. Maintain lighting consistency with the original garden photo
  /// 4. Keep the same camera angle and composition
  static String buildGardenPrompt({
    required Map<String, dynamic> config,
    Map<String, dynamic>? layoutConfig,
  }) {
    final parts = <String>[];

    // ── Structure Preservation Prefix ──
    parts.add(
      'Transform this existing garden photo while preserving the exact same '
      'outdoor structure, dimensions, camera angle, perspective, boundary positions, '
      'and spatial layout.',
    );

    // ── Style ──
    final style = config['style'] as String? ?? 'Modern';
    parts.add('Apply a $style garden design style.');

    // ── Cabinet ──
    final cabinet = config['cabinet_finish'] as String?;
    if (cabinet != null && cabinet.isNotEmpty) {
      parts.add(
        'Replace cabinet doors and drawer fronts with $cabinet finish, '
        'keeping the same cabinet layout, sizes, and positions.',
      );
    }

    // ── Countertop ──
    final countertop = config['countertop_type'] as String?;
    if (countertop != null && countertop.isNotEmpty) {
      parts.add(
        'Change countertop surfaces to $countertop material '
        'while maintaining the same countertop shape and dimensions.',
      );
    }

    // ── Backsplash ──
    final backsplash = config['backsplash'] as String?;
    if (backsplash != null && backsplash.isNotEmpty) {
      parts.add(
        'Apply $backsplash backsplash between countertops and upper cabinets.',
      );
    }

    // ── Flooring ──
    final flooring = config['flooring'] as String?;
    if (flooring != null && flooring.isNotEmpty) {
      parts.add(
        'Change floor material to $flooring, matching the existing floor area.',
      );
    }

    // ── Appliances ──
    final appliance = config['appliance_finish'] as String?;
    if (appliance != null && appliance.isNotEmpty) {
      parts.add(
        'Update appliance finishes to $appliance, keeping appliances '
        'in their exact same positions and sizes.',
      );
    }

    // ── Hardware ──
    final hardware = config['hardware'] as String?;
    if (hardware != null && hardware.isNotEmpty) {
      parts.add('Use $hardware cabinet hardware and handles.');
    }

    // ── Sink ──
    final sink = config['sink'] as String?;
    if (sink != null && sink.isNotEmpty) {
      parts.add('Install a $sink style sink in the existing sink location.');
    }

    // ── Lighting ──
    final lightingTemp = config['lighting_temp'] as double?;
    if (lightingTemp != null) {
      String lightDesc;
      if (lightingTemp < 0.25) {
        lightDesc = 'cool white (daylight) lighting around 4000-5000K';
      } else if (lightingTemp < 0.5) {
        lightDesc = 'neutral white lighting around 3500-4000K';
      } else if (lightingTemp < 0.75) {
        lightDesc = 'warm white lighting around 2700-3500K';
      } else {
        lightDesc = 'warm amber lighting around 2200-2700K';
      }
      parts.add(
        'Set ambient lighting to $lightDesc, matching natural light from existing windows.',
      );
    }

    // ── Layout extras from layout step ──
    if (layoutConfig != null) {
      final hasIsland = layoutConfig['has_island'] == true;
      final hasBreakfastBar = layoutConfig['has_breakfast_bar'] == true;
      final openConcept = layoutConfig['open_concept'] == true;

      if (hasIsland) {
        parts.add(
          'Include a decorative garden island feature if space allows.',
        );
      }
      if (hasBreakfastBar) {
        parts.add('Add a breakfast bar counter extension for casual seating.');
      }
      if (openConcept) {
        parts.add('Maintain an open concept flow to adjacent rooms.');
      }
    }

    // ── Quality & Consistency Suffix ──
    parts.add(
      'Photorealistic result, professional interior photography, '
      'consistent lighting and shadows, high resolution, 8K quality, '
      'maintaining exact same room proportions and architecture.',
    );

    return parts.join(' ');
  }

  /// Converts image bytes to a compressed data URL suitable for the API.
  Future<String> _bytesToDataUrlJpegUnder(
    Uint8List bytes, {
    int targetKB = 280,
  }) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      final b64 = base64Encode(bytes);
      return 'data:image/png;base64,$b64';
    }

    int quality = 92;
    img.Image current = decoded;

    // Resize to reasonable dimensions while preserving aspect ratio.
    // Larger images = better structure preservation.
    const maxW = 2048, maxH = 2048;
    if (decoded.width > maxW || decoded.height > maxH) {
      current = img.copyResize(
        decoded,
        width: decoded.width > decoded.height ? maxW : null,
        height: decoded.height >= decoded.width ? maxH : null,
        interpolation: img.Interpolation.cubic,
      );
    }

    // Also ensure minimum size for good results
    const minDim = 768;
    if (current.width < minDim && current.height < minDim) {
      current = img.copyResize(
        current,
        width: current.width > current.height ? null : minDim,
        height: current.height >= current.width ? null : minDim,
        interpolation: img.Interpolation.cubic,
      );
    }

    Uint8List out = Uint8List.fromList(
      img.encodeJpg(current, quality: quality),
    );
    while (out.lengthInBytes > targetKB * 1024 && quality > 40) {
      quality -= 8;
      out = Uint8List.fromList(img.encodeJpg(current, quality: quality));
    }
    final b64 = base64Encode(out);
    debugPrint(
      '[Replicate] Image encoded: ${current.width}x${current.height}, '
      'quality=$quality, size=${(out.lengthInBytes / 1024).toStringAsFixed(1)}KB',
    );
    return 'data:image/jpeg;base64,$b64';
  }

  /// Generates a garden redesign image using image-to-image transformation.
  ///
  /// [images] - Source garden photo(s) as byte arrays.
  /// [prompt] - Text description of desired changes.
  /// [config] - Generation parameters controlling similarity to original.
  Future<String?> generateMultiBytes({
    required List<Uint8List> images,
    required String prompt,
    GenerationConfig config = const GenerationConfig(),
    int targetKBPerImage = 280,
  }) async {
    assert(images.isNotEmpty, 'images must have at least one element');

    final check = _filter.check(prompt);
    if (!check.allowed) {
      throw UnsafePromptException(
        'Your prompt violates our content policy: "${check.reason}"',
      );
    }
    final safePrompt = check.sanitized;

    final dataUrls = <String>[];
    for (final bytes in images) {
      final dataUrl = await _bytesToDataUrlJpegUnder(
        bytes,
        targetKB: targetKBPerImage,
      );
      dataUrls.add(dataUrl);
    }

    final uri = Uri.parse('https://api.replicate.com/v1/predictions');

    // Build the API request with structure-preserving parameters
    final body = {
      'version': _model,
      'input': {
        // The prompt with structure preservation instructions baked in
        'prompt': safePrompt,

        // Negative prompt to prevent unwanted changes
        'negative_prompt':
            'different outdoor space, different angle, different perspective, '
            'different layout, distorted garden, warped landscape, '
            'different fence positions, different yard size, '
            'cartoon, illustration, painting, sketch, drawing, '
            'blurry, low quality, artifacts, watermark, text',

        // Input image(s)
        'image_input': dataUrls,

        // Structure preservation - how much to keep room geometry
        'structure_strength': config.structureStrength,

        // Image similarity - how close output looks to input
        'image_strength': config.imageStrength,

        // Guidance scale - how much to follow the prompt
        // Lower = more faithful to image, Higher = more creative
        'guidance_scale': config.guidanceScale,

        // Inference steps - more = higher quality
        'num_inference_steps': config.numInferenceSteps,

        // Output settings
        'output_format': config.outputFormat,
        'output_quality': config.outputQuality,
      },
    };

    debugPrint('[Replicate] Sending request with:');
    debugPrint('  structure_strength: ${config.structureStrength}');
    debugPrint('  image_strength: ${config.imageStrength}');
    debugPrint('  guidance_scale: ${config.guidanceScale}');
    debugPrint('  steps: ${config.numInferenceSteps}');
    debugPrint('  prompt length: ${safePrompt.length} chars');

    try {
      final res = await _client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
          'Prefer': 'wait',
        },
        body: jsonEncode(body),
      );

      debugPrint('[Replicate] status=${res.statusCode}');
      debugPrint('[Replicate] body=${res.body}');

      if (res.statusCode != 201 && res.statusCode != 200) {
        final errorData = jsonDecode(res.body);
        final detail =
            errorData['detail'] ?? errorData['error'] ?? 'Unknown error';
        debugPrint('[Replicate] API Error: $detail');
        return null;
      }

      final data = jsonDecode(res.body);
      final output = data['output'];
      if (output is List && output.isNotEmpty) return output[0] as String;
      if (output is String) return output;
      return null;
    } on UnsafePromptException {
      rethrow;
    } on SocketException catch (e, st) {
      debugPrint('[Replicate] NETWORK ERROR: $e\n$st');
      throw NetworkException(
        'Unable to reach servers. Check your internet connection.',
      );
    } catch (e, st) {
      debugPrint('[Replicate] ERROR: $e\n$st');
      return null;
    }
  }

  /// Downloads image bytes from a URL.
  Future<Uint8List?> downloadBytes(String url) async {
    try {
      final res = await _client.get(Uri.parse(url));
      if (res.statusCode == 200) return res.bodyBytes;
      return null;
    } on SocketException catch (e, st) {
      debugPrint('[Replicate] NETWORK ERROR downloadBytes: $e\n$st');
      throw NetworkException(
        'Unable to download generated image. Please check your connection.',
      );
    } catch (e, st) {
      debugPrint('[Replicate] ERROR downloadBytes: $e\n$st');
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}

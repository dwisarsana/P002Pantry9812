import 'package:flutter/material.dart';

class GardenStyle {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String category;
  final List<String> tags;
  final double popularity;
  final String difficulty;
  final String estimatedTime;
  final List<String> keyFeatures;
  final String moodDescription;
  final Color? accentColor;

  const GardenStyle({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    this.category = 'All',
    this.tags = const [],
    this.popularity = 0.0,
    this.difficulty = 'Medium',
    this.estimatedTime = '2-3 hours',
    this.keyFeatures = const [],
    this.moodDescription = '',
    this.accentColor,
  });
}
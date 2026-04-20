import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/garden_model.dart';
import '../../services/storage_service.dart';
import '../../mock/mock_data.dart';
import '../../widgets/glass_container.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<GardenModel>> _gardensFuture;

  @override
  void initState() {
    super.initState();
    _gardensFuture = context.read<StorageService>().loadGardens();
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "My Sanctuary",
                style: Theme.of(context).textTheme.headlineSmall,
              ).animate().fadeIn(),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<GardenModel>>(
                  future: _gardensFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final favorites = (snapshot.data ?? []).where((g) => g.isFavorite).toList();

                    if (favorites.isEmpty) {
                      return Center(
                        child: Text(
                          "No favorites yet.",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return GridView.builder(
                      itemCount: favorites.length,
                      padding: const EdgeInsets.only(bottom: 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final garden = favorites[index];
                        return GlassContainer(
                          padding: EdgeInsets.zero,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildImage(garden.resultImagePath),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.8),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        garden.styleName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (index * 100).ms).scale();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

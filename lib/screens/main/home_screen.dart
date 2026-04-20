import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/parallax_button.dart';
import '../../widgets/glass_container.dart';
import '../../mock/mock_data.dart';
import '../../models/garden_model.dart';
import '../../services/storage_service.dart';
import '../account/history_screen.dart';
import '../account/settings_screen.dart';
import '../production/upload_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildHistoryImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _errorImg());
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _errorImg());
    }
    return _errorImg();
  }

  Widget _errorImg() => Container(
        color: AppTheme.charcoal.withValues(alpha: 0.1),
        child: const Icon(Icons.broken_image_rounded, color: AppTheme.slate, size: 24),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── IMMERSIVE TOP ABAR ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor: AppTheme.mossGreen,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/images/The Nano Banana.jpeg",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      "assets/images/banana_hero.png",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.network(
                      "https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?q=80&w=2000&auto=format&fit=crop",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          AppTheme.mossGreen.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: const Text(
                'Garden AI',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              centerTitle: true,
            ),
            actions: [
              _HeaderIconAction(
                icon: Icons.history_rounded,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
              ),
              const SizedBox(width: 8),
              _HeaderIconAction(
                icon: Icons.settings_rounded,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // ── WELCOME CARD (FLOATING OVERLAY EFFECT) ────────────────────────
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  opacity: 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Good Morning,",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.slate,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Landscape Artist",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.mossGreen,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: AppTheme.sunGlow, shape: BoxShape.circle),
                            child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mossGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: AppTheme.mossGreen.withValues(alpha: 0.5),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded, size: 20),
                            SizedBox(width: 12),
                            Text("New Transformation", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                      ).animate().shimmer(delay: 1.seconds, duration: 2.seconds),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── RECENT PROJECTS (GLASS CAROUSEL) ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recent Visions", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.mossGreen, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                    child: const Icon(Icons.arrow_forward_rounded, color: AppTheme.mossGreen),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: FutureBuilder<List<GardenModel>>(
              future: context.read<StorageService>().loadGardens(),
              builder: (context, snapshot) {
                final gardens = snapshot.data ?? [];
                if (gardens.isEmpty) return const SizedBox();
                
                return SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: gardens.length > 5 ? 5 : gardens.length,
                    itemBuilder: (context, index) {
                      final garden = gardens[index];
                      return _GlassProjectCard(
                        garden: garden,
                        imageBuilder: _buildHistoryImage,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                      ).animate().fadeIn(delay: (200 + index * 100).ms).slideX(begin: 0.2);
                    },
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),

          // ── STYLE GRID (TRENDING NOW) ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Trending Themes", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.mossGreen, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  Text("The most loved styles by the community", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate.withValues(alpha: 0.9))),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final style = MockData.styles[index];
                  return _FuturisticStyleCard(
                    name: style.name,
                    image: style.imagePath,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen())),
                  ).animate().fadeIn(delay: (400 + index * 100).ms).scale(begin: const Offset(0.95, 0.95));
                },
                childCount: MockData.styles.length > 4 ? 4 : MockData.styles.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _HeaderIconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 24),
      onPressed: onTap,
    );
  }
}

class _GlassProjectCard extends StatelessWidget {
  final GardenModel garden;
  final Widget Function(String) imageBuilder;
  final VoidCallback onTap;

  const _GlassProjectCard({required this.garden, required this.imageBuilder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageBuilder(garden.resultImagePath),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      garden.styleName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${garden.timestamp.day}/${garden.timestamp.month}",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FuturisticStyleCard extends StatelessWidget {
  final String name;
  final String image;
  final VoidCallback onTap;

  const _FuturisticStyleCard({required this.name, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          boxShadow: [
            BoxShadow(
              color: AppTheme.mossGreen.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

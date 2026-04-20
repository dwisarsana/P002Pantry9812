// lib/screens/create/style_library_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../mock/mock_data.dart';
import '../../models/garden_style.dart';
import 'custom_studio_screen.dart';

class StyleLibraryScreen extends StatefulWidget {
  final String imagePath;
  const StyleLibraryScreen({super.key, required this.imagePath});

  @override
  State<StyleLibraryScreen> createState() => _StyleLibraryScreenState();
}

class _StyleLibraryScreenState extends State<StyleLibraryScreen>
    with TickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  String _sortBy = 'Popular';
  final Set<String> _favoriteStyles = {};
  bool _isGridView = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps_rounded, 'emoji': '🌍'},
    {'name': 'Minimal', 'icon': Icons.spa_rounded, 'emoji': '🧘'},
    {'name': 'Lush', 'icon': Icons.forest_rounded, 'emoji': '🌴'},
    {'name': 'Classic', 'icon': Icons.account_balance_rounded, 'emoji': '🏛️'},
    {'name': 'Modern', 'icon': Icons.architecture_rounded, 'emoji': '🏙️'},
    {'name': 'Wild', 'icon': Icons.nature_rounded, 'emoji': '🌿'},
  ];

  List<GardenStyle> get _filteredStyles {
    final category = _categories[_selectedCategoryIndex]['name'] as String;
    var styles = category == 'All'
        ? MockData.styles
        : MockData.styles
            .where((s) => s.category == category)
            .toList();

    if (_sortBy == 'Popular') {
      styles = List.from(styles)
        ..sort((a, b) => b.popularity.compareTo(a.popularity));
    } else if (_sortBy == 'A-Z') {
      styles = List.from(styles)..sort((a, b) => a.name.compareTo(b.name));
    }

    return styles;
  }

  void _showStyleDetail(GardenStyle style) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StyleDetailSheet(
        style: style,
        isFavorite: _favoriteStyles.contains(style.id),
        onFavorite: () {
          setState(() {
            if (_favoriteStyles.contains(style.id)) {
              _favoriteStyles.remove(style.id);
            } else {
              _favoriteStyles.add(style.id);
            }
          });
        },
        onSelect: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, _) => CustomStudioScreen(
                imagePath: widget.imagePath,
                selectedStyle: style,
              ),
              transitionsBuilder: (_, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.charcoal,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Sort button
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sort_rounded,
                      color: Colors.white, size: 18),
                ),
                onSelected: (value) => setState(() => _sortBy = value),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'Popular', child: Text('Most Popular')),
                  const PopupMenuItem(value: 'A-Z', child: Text('A to Z')),
                  const PopupMenuItem(value: 'New', child: Text('Newest')),
                ],
              ),
              // View toggle
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isGridView
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                onPressed: () =>
                    setState(() => _isGridView = !_isGridView),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/images/Styles Library.jpeg",
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose Your Vision",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${_filteredStyles.length} styles available",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  final cat = _categories[index];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategoryIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.mossGreen
                            : AppTheme.mistWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.mossGreen
                              : Colors.transparent,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppTheme.mossGreen.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cat['emoji'] as String,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat['name'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.charcoal,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn().slideX(begin: -0.1),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Grid / List
          _isGridView ? _buildGrid() : _buildList(),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final styles = _filteredStyles;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final style = styles[index];
            return _StyleGridCard(
              style: style,
              isFavorite: _favoriteStyles.contains(style.id),
              onTap: () => _showStyleDetail(style),
              onFavorite: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (_favoriteStyles.contains(style.id)) {
                    _favoriteStyles.remove(style.id);
                  } else {
                    _favoriteStyles.add(style.id);
                  }
                });
              },
              index: index,
            );
          },
          childCount: styles.length,
        ),
      ),
    );
  }

  Widget _buildList() {
    final styles = _filteredStyles;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final style = styles[index];
            return _StyleListCard(
              style: style,
              isFavorite: _favoriteStyles.contains(style.id),
              onTap: () => _showStyleDetail(style),
              onFavorite: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (_favoriteStyles.contains(style.id)) {
                    _favoriteStyles.remove(style.id);
                  } else {
                    _favoriteStyles.add(style.id);
                  }
                });
              },
              index: index,
            );
          },
          childCount: styles.length,
        ),
      ),
    );
  }
}

class _StyleGridCard extends StatelessWidget {
  final GardenStyle style;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final int index;

  const _StyleGridCard({
    required this.style,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'style_${style.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                _styleImage(style.imagePath),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0, 0.4, 0.65, 1.0],
                    ),
                  ),
                ),

                // Favorite button
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite ? Colors.redAccent : Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // Difficulty badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(style.difficulty)
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      style.difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Bottom info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          style.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          style.moodDescription.isNotEmpty
                              ? style.moodDescription
                              : style.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Tags
                        Wrap(
                          spacing: 4,
                          children: style.tags.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 6),
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppTheme.sunGlow, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              style.popularity.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 80))
        .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppTheme.mossGreen;
      case 'Medium':
        return AppTheme.sunGlow;
      case 'Hard':
        return AppTheme.coral;
      default:
        return AppTheme.slate;
    }
  }
}

class _StyleListCard extends StatelessWidget {
  final GardenStyle style;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final int index;

  const _StyleListCard({
    required this.style,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.mistWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _styleImage(style.imagePath, width: 90, height: 90),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          style.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.charcoal,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onFavorite,
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? Colors.redAccent
                              : AppTheme.slate.withValues(alpha: 0.3),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    style.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.slate.withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppTheme.sunGlow, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        style.popularity.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.deepSoil,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.schedule_rounded,
                          size: 13,
                          color: AppTheme.slate.withValues(alpha: 0.5)),
                      const SizedBox(width: 3),
                      Text(
                        style.estimatedTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.slate.withValues(alpha: 0.6),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.mossGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          style.difficulty,
                          style: const TextStyle(
                            color: AppTheme.mossGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 80))
        .slideX(begin: 0.05, curve: Curves.easeOutCubic);
  }
}

class _StyleDetailSheet extends StatelessWidget {
  final GardenStyle style;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onSelect;

  const _StyleDetailSheet({
    required this.style,
    required this.isFavorite,
    required this.onFavorite,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.mistWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Hero image
                Container(
                  height: 280,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'style_${style.id}',
                          child: _styleImage(style.imagePath),
                        ),
                        // Favorite & share
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Row(
                            children: [
                              _CircleAction(
                                icon: isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFavorite
                                    ? Colors.redAccent
                                    : Colors.white,
                                onTap: onFavorite,
                              ),
                              const SizedBox(width: 8),
                              _CircleAction(
                                icon: Icons.share_rounded,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              style.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.charcoal,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppTheme.sunGlow, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                style.popularity.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.charcoal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (style.moodDescription.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          style.moodDescription,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.mossGreen.withValues(alpha: 0.8),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        style.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.slate.withValues(alpha: 0.8),
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Quick stats
                      Row(
                        children: [
                          _StatChip(
                            icon: Icons.schedule_rounded,
                            label: style.estimatedTime,
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            icon: Icons.trending_up_rounded,
                            label: style.difficulty,
                            color: style.difficulty == 'Easy'
                                ? AppTheme.mossGreen
                                : style.difficulty == 'Medium'
                                    ? AppTheme.sunGlow
                                    : AppTheme.coral,
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            icon: Icons.category_rounded,
                            label: style.category,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tags
                      const Text(
                        'Style Tags',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepSoil,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: style.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.mossGreen.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.mossGreen.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: AppTheme.mossGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Key Features
                      const Text(
                        'Key Features',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepSoil,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...style.keyFeatures.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.mintGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppTheme.mossGreen,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.deepSoil.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 30),

                      // CTA Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: onSelect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.mossGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 4,
                            shadowColor:
                                AppTheme.mossGreen.withValues(alpha: 0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.auto_awesome_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Apply This Style',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    this.color = AppTheme.slate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _styleImage(String path,
    {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (path.startsWith('http')) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: AppTheme.slate.withValues(alpha: 0.05),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: AppTheme.slate.withValues(alpha: 0.1),
        child: const Icon(Icons.image, color: AppTheme.slate),
      ),
    );
  }
  return Image.asset(
    path,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, _, _) => Container(
      width: width,
      height: height,
      color: AppTheme.slate.withValues(alpha: 0.1),
      child: const Icon(Icons.broken_image, color: AppTheme.slate),
    ),
  );
}
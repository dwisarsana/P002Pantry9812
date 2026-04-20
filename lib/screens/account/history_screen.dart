// lib/screens/account/history_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../models/garden_model.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────
// Sort options
// ─────────────────────────────────────────────────────────
enum _SortOption { newest, oldest, styleName }

extension _SortOptionLabel on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.newest:
        return 'Newest First';
      case _SortOption.oldest:
        return 'Oldest First';
      case _SortOption.styleName:
        return 'Style Name';
    }
  }

  IconData get icon {
    switch (this) {
      case _SortOption.newest:
        return Icons.arrow_downward_rounded;
      case _SortOption.oldest:
        return Icons.arrow_upward_rounded;
      case _SortOption.styleName:
        return Icons.sort_by_alpha_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────
// Main History Screen
// ─────────────────────────────────────────────────────────
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<GardenModel>> _gardensFuture;
  _SortOption _sortOption = _SortOption.newest;
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _gardensFuture = context.read<StorageService>().loadGardens();
  }

  void _reload() {
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
      _loadData();
    });
  }

  List<GardenModel> _sort(List<GardenModel> list) {
    final sorted = [...list];
    switch (_sortOption) {
      case _SortOption.newest:
        sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      case _SortOption.oldest:
        sorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      case _SortOption.styleName:
        sorted.sort((a, b) => a.styleName.compareTo(b.styleName));
    }
    return sorted;
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imgError(),
      );
    }
    final f = File(path);
    if (f.existsSync()) {
      return Image.file(f, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imgError());
    }
    return _imgError();
  }

  Widget _imgError() => Container(
        color: AppTheme.charcoal.withValues(alpha: 0.3),
        child: const Center(
          child: Icon(Icons.broken_image_rounded, color: Colors.white30, size: 32),
        ),
      );

  // ── Delete selected ──────────────────────────────────────
  Future<void> _deleteSelected(List<GardenModel> all) async {
    final confirm = await _showDeleteDialog(
        context, '${_selectedIds.length} item(s)');
    if (!confirm) return;

    final storage = context.read<StorageService>();
    final remaining = all.where((g) => !_selectedIds.contains(g.id)).toList();
    await storage.saveGardens(remaining);
    _reload();
  }

  Future<bool> _showDeleteDialog(BuildContext ctx, String label) async {
    return await showDialog<bool>(
          context: ctx,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.charcoal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Delete Garden?',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            content: Text(
              'Remove $label from your history? This cannot be undone.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete',
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ── Sort menu ────────────────────────────────────────────
  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.charcoal,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Sort By',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
            const SizedBox(height: 16),
            ..._SortOption.values.map((opt) {
              final selected = _sortOption == opt;
              return GestureDetector(
                onTap: () {
                  setState(() => _sortOption = opt);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.mossGreen.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? AppTheme.mossGreen.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(opt.icon,
                          color: selected ? AppTheme.mintGreen : Colors.white54,
                          size: 20),
                      const SizedBox(width: 12),
                      Text(opt.label,
                          style: TextStyle(
                            color: selected ? AppTheme.mintGreen : Colors.white70,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 15,
                          )),
                      const Spacer(),
                      if (selected)
                        const Icon(Icons.check_rounded,
                            color: AppTheme.mintGreen, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmSand,
      body: SafeArea(
        child: FutureBuilder<List<GardenModel>>(
          future: _gardensFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.mossGreen),
                ),
              );
            }

            final all = _sort(snapshot.data ?? []);

            return RefreshIndicator(
              onRefresh: () async {
                _reload();
              },
              color: AppTheme.mossGreen,
              backgroundColor: AppTheme.warmSand,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // ── Header ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.charcoal, size: 18),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Garden Timeline',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.mossGreen)),
                            Text(
                              '${all.length} transformation${all.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                  color: AppTheme.slate.withValues(alpha: 0.7),
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Home button
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.home_rounded, color: AppTheme.mossGreen, size: 20),
                        ),
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      ),
                      const SizedBox(width: 8),
                      // Sort button
                      _HeaderIconBtn(
                        icon: Icons.sort_rounded,
                        onTap: _showSortMenu,
                        badge: _sortOption != _SortOption.newest
                            ? AppTheme.sunGlow
                            : null,
                      ),
                      const SizedBox(width: 8),
                      // Select / cancel
                      _HeaderIconBtn(
                        icon: _isSelecting
                            ? Icons.close_rounded
                            : Icons.checklist_rounded,
                        onTap: () => setState(() {
                          _isSelecting = !_isSelecting;
                          _selectedIds.clear();
                        }),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),

                // ── Selection toolbar ───────────────────────────────
                if (_isSelecting && _selectedIds.isNotEmpty)
                  _SelectionBar(
                    count: _selectedIds.length,
                    onDelete: () => _deleteSelected(all),
                    onSelectAll: () => setState(() {
                      if (_selectedIds.length == all.length) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds.addAll(all.map((g) => g.id));
                      }
                    }),
                    allSelected: _selectedIds.length == all.length,
                  ),

                // ── Empty state ─────────────────────────────────────
                if (all.isEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.mossGreen.withValues(alpha: 0.08),
                              ),
                              child: const Icon(Icons.eco_rounded,
                                  size: 52, color: AppTheme.mintGreen),
                            ),
                            const SizedBox(height: 20),
                            Text('No gardens yet',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'Start creating your first garden transformation!',
                              style: TextStyle(
                                  color: AppTheme.slate.withValues(alpha: 0.7),
                                  fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  // ── List ──────────────────────────────────────────
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      itemCount: all.length,
                      itemBuilder: (context, index) {
                        final garden = all[index];
                        final selected = _selectedIds.contains(garden.id);

                        return _HistoryCard(
                          garden: garden,
                          buildImage: _buildImage,
                          isSelecting: _isSelecting,
                          isSelected: selected,
                          onTap: () {
                            if (_isSelecting) {
                              setState(() {
                                if (selected) {
                                  _selectedIds.remove(garden.id);
                                } else {
                                  _selectedIds.add(garden.id);
                                }
                              });
                            } else {
                              _openDetail(context, garden, all);
                            }
                          },
                          onLongPress: () {
                            HapticFeedback.mediumImpact();
                            if (!_isSelecting) {
                              setState(() {
                                _isSelecting = true;
                                _selectedIds.add(garden.id);
                              });
                            }
                          },
                        ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.1, end: 0);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openDetail(BuildContext ctx, GardenModel garden, List<GardenModel> all) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HistoryDetailSheet(
        garden: garden,
        buildImage: _buildImage,
        onDelete: () async {
          Navigator.pop(ctx);
          final confirm = await _showDeleteDialog(ctx, 'this garden');
          if (!confirm) return;
          final storage = context.read<StorageService>();
          final remaining = all.where((g) => g.id != garden.id).toList();
          await storage.saveGardens(remaining);
          _reload();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// History Card
// ─────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final GardenModel garden;
  final Widget Function(String) buildImage;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _HistoryCard({
    required this.garden,
    required this.buildImage,
    required this.isSelecting,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: AppTheme.mossGreen, width: 2.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              buildImage(garden.resultImagePath),
              // Gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Info
              Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            garden.styleName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(garden.timestamp),
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (garden.isFavorite)
                      const Icon(Icons.favorite_rounded,
                          color: Colors.redAccent, size: 18),
                  ],
                ),
              ),
              // Selection check
              if (isSelecting)
                Positioned(
                  top: 12,
                  right: 12,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.mossGreen
                          : Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.mossGreen : Colors.white54,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}  •  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────
// History Detail Bottom Sheet
// ─────────────────────────────────────────────────────────
class HistoryDetailSheet extends StatefulWidget {
  final GardenModel garden;
  final Widget Function(String) buildImage;
  final VoidCallback onDelete;

  const HistoryDetailSheet({
    super.key,
    required this.garden,
    required this.buildImage,
    required this.onDelete,
  });

  @override
  State<HistoryDetailSheet> createState() => _HistoryDetailSheetState();
}

class _HistoryDetailSheetState extends State<HistoryDetailSheet> {
  double _sliderX = 0.5;

  @override
  Widget build(BuildContext context) {
    final g = widget.garden;
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.92,
      decoration: const BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),

          // Before/After Comparison
          Expanded(
            child: GestureDetector(
              onPanUpdate: (d) {
                setState(() {
                  _sliderX += d.delta.dx / MediaQuery.of(context).size.width;
                  _sliderX = _sliderX.clamp(0.02, 0.98);
                });
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.buildImage(g.originalImagePath),
                  ClipRect(
                    clipper: _RightClipper(_sliderX),
                    child: widget.buildImage(g.resultImagePath),
                  ),
                  // Slider divider
                  Positioned(
                    left: MediaQuery.of(context).size.width * _sliderX - 20,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(width: 2, color: Colors.white),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chevron_left,
                                    size: 16, color: AppTheme.charcoal),
                                Icon(Icons.chevron_right,
                                    size: 16, color: AppTheme.charcoal),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Labels
                  Positioned(
                    top: 12, left: 12,
                    child: _SliderLabel(text: 'BEFORE'),
                  ),
                  Positioned(
                    top: 12, right: 12,
                    child: _SliderLabel(
                        text: 'AFTER', color: AppTheme.sunGlow),
                  ),
                ],
              ),
            ),
          ),

          // Info & Actions
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.styleName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(g.timestamp),
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (g.isFavorite)
                      const Icon(Icons.favorite_rounded,
                          color: Colors.redAccent, size: 22),
                  ],
                ),

                const SizedBox(height: 20),

                // Action row
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _DetailAction(
                        icon: Icons.fullscreen_rounded,
                        label: 'Full View',
                        onTap: () => _openFullscreen(context, g),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _DetailAction(
                        icon: Icons.delete_rounded,
                        label: 'Delete from History',
                        color: Colors.redAccent,
                        onTap: widget.onDelete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SnackBar _snackBar(String msg, {bool isSuccess = false}) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: isSuccess ? AppTheme.mossGreen : AppTheme.slate,
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  void _openFullscreen(BuildContext ctx, GardenModel g) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => _FullscreenView(
          garden: g,
          buildImage: widget.buildImage,
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}  •  '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────
// Full Screen View
// ─────────────────────────────────────────────────────────
class _FullscreenView extends StatefulWidget {
  final GardenModel garden;
  final Widget Function(String) buildImage;

  const _FullscreenView({required this.garden, required this.buildImage});

  @override
  State<_FullscreenView> createState() => _FullscreenViewState();
}

class _FullscreenViewState extends State<_FullscreenView> {
  double _sliderX = 0.5;
  bool _showBefore = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _sliderX += d.delta.dx / MediaQuery.of(context).size.width;
            _sliderX = _sliderX.clamp(0.02, 0.98);
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.buildImage(widget.garden.originalImagePath),
            ClipRect(
              clipper: _RightClipper(_sliderX),
              child: widget.buildImage(widget.garden.resultImagePath),
            ),
            // Divider
            Positioned(
              left: MediaQuery.of(context).size.width * _sliderX - 20,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(width: 2, color: Colors.white),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chevron_left,
                              size: 16, color: AppTheme.charcoal),
                          Icon(Icons.chevron_right,
                              size: 16, color: AppTheme.charcoal),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Labels
            Positioned(
              top: 60, left: 16,
              child: _SliderLabel(text: 'BEFORE'),
            ),
            Positioned(
              top: 60, right: 16,
              child: _SliderLabel(text: 'AFTER', color: AppTheme.sunGlow),
            ),
            // Close
            Positioned(
              top: 52,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
            // Style badge
            Positioned(
              bottom: 48,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.garden.styleName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Small helper widgets
// ─────────────────────────────────────────────────────────
class _RightClipper extends CustomClipper<Rect> {
  final double split;
  _RightClipper(this.split);
  @override
  Rect getClip(Size size) => Rect.fromLTWH(
      size.width * split, 0, size.width * (1 - split), size.height);
  @override
  bool shouldReclip(_RightClipper old) => old.split != split;
}

class _SliderLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SliderLabel({required this.text, this.color = Colors.white70});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2)),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? badge;

  const _HeaderIconBtn({required this.icon, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.mossGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.mossGreen, size: 22),
          ),
          if (badge != null)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: badge, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onDelete;
  final VoidCallback onSelectAll;
  final bool allSelected;

  const _SelectionBar({
    required this.count,
    required this.onDelete,
    required this.onSelectAll,
    required this.allSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.mossGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text('$count selected',
              style: const TextStyle(
                  color: AppTheme.mintGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const Spacer(),
          GestureDetector(
            onTap: onSelectAll,
            child: Text(
              allSelected ? 'Deselect All' : 'Select All',
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onDelete,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_rounded, color: Colors.redAccent, size: 18),
                SizedBox(width: 4),
                Text('Delete',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _DetailAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color == Colors.redAccent
              ? Colors.redAccent.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color == Colors.redAccent
                ? Colors.redAccent.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                  color: color == Colors.redAccent
                      ? Colors.redAccent
                      : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

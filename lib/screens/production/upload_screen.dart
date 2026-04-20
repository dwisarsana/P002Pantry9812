// lib/screens/create/upload_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sunlight_overlay.dart';
import '../../widgets/glass_container.dart';
import 'scene_detection_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with TickerProviderStateMixin {
  bool _isAnalyzing = false;
  String? _selectedImage;
  int _currentTipIndex = 0;
  late final PageController _tipController;
  late final AnimationController _pulseController;

  final List<Map<String, dynamic>> _tips = [
    {
      'icon': Icons.wb_sunny_rounded,
      'title': 'Good Lighting',
      'desc': 'Natural daylight works best for accurate analysis',
      'color': const Color(0xFFFFB74D),
    },
    {
      'icon': Icons.crop_free_rounded,
      'title': 'Full Area Visible',
      'desc': 'Capture the entire space you want to transform',
      'color': const Color(0xFF64B5F6),
    },
    {
      'icon': Icons.straighten_rounded,
      'title': 'Straight Angle',
      'desc': 'Hold your phone level for the best perspective',
      'color': const Color(0xFF81C784),
    },
    {
      'icon': Icons.hd_rounded,
      'title': 'High Resolution',
      'desc': 'Clear photos produce more detailed garden designs',
      'color': const Color(0xFFB39DDB),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tipController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Auto-scroll tips
    Future.delayed(const Duration(seconds: 3), _autoScrollTips);
  }

  void _autoScrollTips() {
    if (!mounted) return;
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
    });
    if (_tipController.hasClients) {
      _tipController.animateToPage(
        _currentTipIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    Future.delayed(const Duration(seconds: 4), _autoScrollTips);
  }

  @override
  void dispose() {
    _tipController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSourcePicker(),
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2048,
    );

    if (image != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isAnalyzing = true;
        _selectedImage = image.path;
      });

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() => _isAnalyzing = false);
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, _) => SceneDetectionScreen(
                imagePath: _selectedImage!,
              ),
              transitionsBuilder: (_, animation, _, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      }
    }
  }

  Widget _buildSourcePicker() {
    return GlassContainer(
      color: AppTheme.charcoal,
      opacity: 0.95,
      blur: 30,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Add Your Garden Photo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you\'d like to capture your space',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _SourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  subtitle: 'Take a photo now',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  subtitle: 'Choose existing',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size; // Removed unused variable

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.mistWhite.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.charcoal, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.mossGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco_rounded,
                  color: AppTheme.mossGreen, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              "Upload Garden",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.mistWhite.withValues(alpha: 0.9),
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
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5F0E8),
                  Color(0xFFEDE7DB),
                  Color(0xFFE8E0D0),
                ],
              ),
            ),
          ),
          const Positioned.fill(child: SunlightOverlay(opacity: 0.06)),

          // Decorative circles
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.mossGreen.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.sunGlow.withValues(alpha: 0.04),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Hero Text
                  Text(
                    "Let's Transform\nYour Space",
                    style:
                        Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 32,
                              height: 1.15,
                            ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.15, end: 0),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.mossGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "AI-powered garden design in seconds",
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.mossGreen,
                                fontWeight: FontWeight.w500,
                              ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 32),

                  // Upload Area
                  Expanded(
                    child: GestureDetector(
                      onTap: _isAnalyzing ? null : _pickImage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _selectedImage != null
                              ? Colors.black
                              : AppTheme.mistWhite.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: _isAnalyzing
                                ? AppTheme.mossGreen
                                : AppTheme.mossGreen.withValues(alpha: 0.2),
                            width: _isAnalyzing ? 2 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isAnalyzing
                                  ? AppTheme.mossGreen.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.05),
                              blurRadius: _isAnalyzing ? 30 : 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Selected image
                              if (_selectedImage != null)
                                Positioned.fill(
                                  child: Image.file(
                                    File(_selectedImage!),
                                    fit: BoxFit.cover,
                                  ).animate().fadeIn(duration: 500.ms),
                                ),

                              // Analyzing overlay
                              if (_isAnalyzing && _selectedImage != null)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 56,
                                          height: 56,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                    AppTheme.mossGreen),
                                            backgroundColor: Colors
                                                .white
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Preparing image...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 300.ms),
                                ),

                              // Empty state
                              if (_selectedImage == null) ...[
                                // Hero background image
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/images/AI Garden Transformation.jpeg',
                                    fit: BoxFit.cover,
                                  ).animate().blur(begin: const Offset(4, 4), end: Offset.zero, duration: 1.seconds).scale(begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0), duration: 1.seconds),
                                ),
                                // Darken overlay
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.2),
                                          Colors.black.withValues(alpha: 0.6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Center content
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppTheme.mossGreen
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Container(
                                        padding:
                                            const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppTheme.mossGreen
                                              .withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          'assets/icon.png',
                                          width: 80,
                                          height: 80,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      "Tap to Upload Photo",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "JPG, PNG • Max 20MB",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.white70,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ).animate().scale(
                            delay: 300.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1, 1),
                          ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tips Carousel
                  SizedBox(
                    height: 80,
                    child: PageView.builder(
                      controller: _tipController,
                      onPageChanged: (i) =>
                          setState(() => _currentTipIndex = i),
                      itemCount: _tips.length,
                      itemBuilder: (context, index) {
                        final tip = _tips[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.mistWhite.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (tip['color'] as Color)
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (tip['color'] as Color)
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  tip['icon'] as IconData,
                                  color: tip['color'] as Color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tip['title'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppTheme.charcoal,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tip['desc'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.slate
                                            .withValues(alpha: 0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

                  const SizedBox(height: 12),

                  // Tip indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_tips.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentTipIndex == index ? 24 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _currentTipIndex == index
                              ? AppTheme.mossGreen
                              : AppTheme.mossGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
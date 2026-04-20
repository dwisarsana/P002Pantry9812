import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class ParallaxButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final String subLabel;
  final String imagePath; // URL or asset

  const ParallaxButton({
    super.key,
    required this.onTap,
    this.label = 'Create New Garden Vision',
    this.subLabel = 'Powered by Garden AI',
    this.imagePath = 'assets/images/styles/tropical.png',
  });

  Widget _buildImage() {
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, fit: BoxFit.cover);
    }
    return Image.asset(imagePath, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.mossGreen.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // Parallax Background
              Positioned.fill(
                child: _buildImage()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1.1, 1.1), end: const Offset(1.2, 1.2), duration: 5.seconds, curve: Curves.easeInOut),
              ),
              
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/icon.png', width: 24, height: 24),
                        const SizedBox(width: 8),
                        Text(
                          subLabel.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Floating Action Icon
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.mintGreen.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                      )
                    ]
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppTheme.mossGreen,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.1, end: 0, delay: 200.ms),
    );
  }
}

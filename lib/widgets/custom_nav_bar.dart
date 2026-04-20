import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'glass_container.dart';
import '../theme/app_theme.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: BorderRadius.circular(30),
          blur: 20,
          opacity: 0.8,
          color: AppTheme.mistWhite,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavBarItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                icon: Icons.history_rounded,
                label: 'History',
                isActive: currentIndex == 2, // Skip 1 (Create)
                onTap: () => onTap(2),
              ),
              _CreateButton(
                onTap: () => onTap(1),
              ),
              _NavBarItem(
                icon: Icons.favorite_rounded,
                label: 'Favorites',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavBarItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isActive
                    ? AppTheme.mossGreen
                    : AppTheme.slate.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: 4,
              decoration: const BoxDecoration(
                color: AppTheme.mossGreen,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          gradient: AppTheme.leafGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x665A7D5A),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 2.seconds,
            curve: Curves.easeInOut,
          ),
    );
  }
}

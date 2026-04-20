import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/garden_style.dart';
import 'rendering_screen.dart';

class BeforeAfterScreen extends StatefulWidget {
  final String originalPath;
  final String resultPath;
  final GardenStyle style;
  final Map<String, dynamic> settings;

  const BeforeAfterScreen({
    super.key,
    required this.originalPath,
    required this.resultPath,
    required this.style,
    required this.settings,
  });

  @override
  State<BeforeAfterScreen> createState() => _BeforeAfterScreenState();
}

class _BeforeAfterScreenState extends State<BeforeAfterScreen> {
  double _splitX = 0.5; // 0.0 to 1.0

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    return Image.file(File(path), fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Original Image (Bottom Layer)
          Positioned.fill(
            child: _buildImageWidget(widget.originalPath),
          ),
          
          // Result Image (Top Layer - Clipped)
          Positioned.fill(
            child: ClipRect(
              clipper: _SplitClipper(_splitX),
              child: _buildImageWidget(widget.resultPath),
            ),
          ),

          // Slider Handle
          Positioned(
            left: MediaQuery.of(context).size.width * _splitX - 2, // Center the 4px line
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _splitX += details.delta.dx / MediaQuery.of(context).size.width;
                  _splitX = _splitX.clamp(0.0, 1.0);
                });
              },
              child: Container(
                width: 40, // Hit area
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: 4,
                    height: double.infinity,
                    color: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.sunGlow.withValues(alpha: 0.8),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Floating Button "Finalize"
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RenderingScreen(
                        originalPath: widget.originalPath,
                        resultPath: widget.resultPath,
                        style: widget.style,
                        settings: widget.settings,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mossGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  "Finalize & Save",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ).animate().fadeIn(delay: 1.seconds).slideY(begin: 1, end: 0),
            ),
          ),

          // Labels
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              "ORIGINAL",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(blurRadius: 5, color: Colors.black)],
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: Text(
              widget.style.name.toUpperCase(),
              style: TextStyle(
                color: AppTheme.sunGlow.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(blurRadius: 5, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitClipper extends CustomClipper<Rect> {
  final double splitX;

  _SplitClipper(this.splitX);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(size.width * splitX, 0, size.width * (1 - splitX), size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => true;
}

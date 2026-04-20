// lib/screens/create/custom_studio_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/garden_style.dart';
import '../../mock/mock_data.dart';
import '../../widgets/glass_container.dart';
import 'generating_screen.dart';
import '../../src/constant.dart';

class CustomStudioScreen extends StatefulWidget {
  final String imagePath;
  final GardenStyle selectedStyle;

  const CustomStudioScreen({
    super.key,
    required this.imagePath,
    required this.selectedStyle,
  });

  @override
  State<CustomStudioScreen> createState() => _CustomStudioScreenState();
}

class _CustomStudioScreenState extends State<CustomStudioScreen>
    with TickerProviderStateMixin {
  // Core Settings
  double _density = 0.5;
  double _flowers = 0.3;
  double _water = 0.0;
  double _sunlight = 0.7;
  double _treeSize = 0.5;
  double _colorVibrancy = 0.6;

  // Selection States
  String _season = 'Spring';
  String _timeOfDay = 'Golden Hour';
  int _selectedPathway = 0;
  int _selectedLighting = 0;
  int _selectedWaterFeature = -1;

  late TabController _tabController;
  late PageController _previewController;

  final List<Map<String, dynamic>> _seasonData = [
    {'name': 'Spring', 'icon': '🌸', 'color': const Color(0xFFE91E63), 'desc': 'Cherry blossoms & fresh greens'},
    {'name': 'Summer', 'icon': '☀️', 'color': const Color(0xFFFF9800), 'desc': 'Full bloom & vibrant colors'},
    {'name': 'Autumn', 'icon': '🍂', 'color': const Color(0xFFFF5722), 'desc': 'Warm tones & falling leaves'},
    {'name': 'Winter', 'icon': '❄️', 'color': const Color(0xFF2196F3), 'desc': 'Frost-kissed & evergreen'},
  ];

  final List<Map<String, dynamic>> _timeData = [
    {'name': 'Dawn', 'icon': '🌅', 'color': const Color(0xFFE1BEE7)},
    {'name': 'Morning', 'icon': '🌤️', 'color': const Color(0xFFFFF176)},
    {'name': 'Golden Hour', 'icon': '🌇', 'color': const Color(0xFFFFB74D)},
    {'name': 'Sunset', 'icon': '🌆', 'color': const Color(0xFFFF8A65)},
    {'name': 'Twilight', 'icon': '🌙', 'color': const Color(0xFF9FA8DA)},
    {'name': 'Night', 'icon': '🌃', 'color': const Color(0xFF5C6BC0)},
  ];

  final List<String> _sectionTabs = [
    'Environment',
    'Plants',
    'Hardscape',
    'Lighting',
    'Water',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sectionTabs.length, vsync: this);
    _previewController = PageController();
    _tabController.addListener(() {
      setState(() {}); // Using setState to rebuild based on tab change
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _previewController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _allSettings => {
        'density': _density,
        'flowers': _flowers,
        'water': _water,
        'sunlight': _sunlight,
        'treeSize': _treeSize,
        'colorVibrancy': _colorVibrancy,
        'season': _season,
        'timeOfDay': _timeOfDay,
        'pathway': _selectedPathway,
        'lighting': _selectedLighting,
        'waterFeature': _selectedWaterFeature,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Preview
          Positioned.fill(
            child: _styleImage(widget.selectedStyle.imagePath),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0, 0.25, 0.5, 0.75],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customize',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.selectedStyle.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Reset button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _density = 0.5;
                            _flowers = 0.3;
                            _water = 0.0;
                            _sunlight = 0.7;
                            _treeSize = 0.5;
                            _colorVibrancy = 0.6;
                            _season = 'Spring';
                            _timeOfDay = 'Golden Hour';
                            _selectedPathway = 0;
                            _selectedLighting = 0;
                            _selectedWaterFeature = -1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.3),

                // Style info chip
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: AppTheme.sunGlow.withValues(alpha: 0.8),
                          size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Adjust every detail to create your perfect ${widget.selectedStyle.name.toLowerCase()} garden',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const Spacer(),

                // Controls Panel
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.52,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(
                      top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Section Tabs
                      SizedBox(
                        height: 42,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: AppTheme.mossGreen,
                          indicatorWeight: 3,
                          indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white38,
                          labelStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          tabs: _sectionTabs
                              .map((t) => Tab(text: t))
                              .toList(),
                        ),
                      ),

                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildEnvironmentTab(),
                            _buildPlantsTab(),
                            _buildHardscapeTab(),
                            _buildLightingTab(),
                            _buildWaterTab(),
                          ],
                        ),
                      ),

                      // Preview Button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              // Check Premium/Token Gate
                              final canProceed = await PremiumGate.checkGate(context);
                              if (!canProceed) return;

                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GeneratingScreen(
                                    imagePath: widget.imagePath,
                                    style: widget.selectedStyle,
                                    settings: _allSettings,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.mossGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 6,
                              shadowColor:
                                  AppTheme.mossGreen.withValues(alpha: 0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.auto_awesome_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Generate Garden Design',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .slideY(
                        begin: 0.5,
                        duration: 600.ms,
                        curve: Curves.easeOutQuint),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ ENVIRONMENT TAB ============
  Widget _buildEnvironmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Season Selector
          _SectionLabel(label: 'Season', icon: Icons.eco_rounded),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _seasonData.length,
              itemBuilder: (context, index) {
                final s = _seasonData[index];
                final isSelected = _season == s['name'];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _season = s['name'] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 130,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (s['color'] as Color).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? (s['color'] as Color).withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.08),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              s['icon'] as String,
                              style: const TextStyle(fontSize: 20),
                            ),
                            if (isSelected) ...[
                              const Spacer(),
                              Icon(Icons.check_circle_rounded,
                                  color: s['color'] as Color, size: 16),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Text(
                          s['name'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white60,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          s['desc'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Time of Day
          _SectionLabel(label: 'Time of Day', icon: Icons.schedule_rounded),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _timeData.length,
              itemBuilder: (context, index) {
                final t = _timeData[index];
                final isSelected = _timeOfDay == t['name'];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _timeOfDay = t['name'] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (t['color'] as Color).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? (t['color'] as Color).withValues(alpha: 0.5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t['icon'] as String,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          t['name'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Sunlight slider
          _SliderRow(
            label: 'Sunlight Intensity',
            value: _sunlight,
            icon: Icons.wb_sunny_rounded,
            activeColor: AppTheme.sunGlow,
            onChanged: (v) => setState(() => _sunlight = v),
          ),

          const SizedBox(height: 8),

          _SliderRow(
            label: 'Color Vibrancy',
            value: _colorVibrancy,
            icon: Icons.palette_rounded,
            activeColor: AppTheme.coral,
            onChanged: (v) => setState(() => _colorVibrancy = v),
          ),
        ],
      ),
    );
  }

  // ============ PLANTS TAB ============
  Widget _buildPlantsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SliderRow(
            label: 'Plant Density',
            value: _density,
            icon: Icons.grass_rounded,
            activeColor: AppTheme.mossGreen,
            onChanged: (v) => setState(() => _density = v),
            leftLabel: 'Sparse',
            rightLabel: 'Dense',
          ),
          const SizedBox(height: 8),
          _SliderRow(
            label: 'Flower Coverage',
            value: _flowers,
            icon: Icons.local_florist_rounded,
            activeColor: AppTheme.roseGold,
            onChanged: (v) => setState(() => _flowers = v),
            leftLabel: 'Subtle',
            rightLabel: 'Abundant',
          ),
          const SizedBox(height: 8),
          _SliderRow(
            label: 'Tree Scale',
            value: _treeSize,
            icon: Icons.park_rounded,
            activeColor: const Color(0xFF66BB6A),
            onChanged: (v) => setState(() => _treeSize = v),
            leftLabel: 'Small',
            rightLabel: 'Grand',
          ),

          const SizedBox(height: 20),

          _SectionLabel(label: 'Plant Categories', icon: Icons.category_rounded),
          const SizedBox(height: 12),

          // Plant categories grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MockData.plantCategories.map((cat) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat['icon'] as String,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${cat['count']} varieties',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============ HARDSCAPE TAB ============
  Widget _buildHardscapeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'Pathway Material', icon: Icons.route_rounded),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.hardscapeOptions.length,
              itemBuilder: (context, index) {
                final option = MockData.hardscapeOptions[index];
                final isSelected = _selectedPathway == index;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPathway = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 90,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.mossGreen.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.mossGreen.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.08),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option['icon'] as String,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option['name'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Additional hardscape options
          _SectionLabel(label: 'Garden Structures', icon: Icons.fence_rounded),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ToggleChip(label: '🏡 Pergola', isOn: true),
              _ToggleChip(label: '🪑 Seating', isOn: false),
              _ToggleChip(label: '🔥 Fire Pit', isOn: false),
              _ToggleChip(label: '🏗️ Raised Beds', isOn: true),
              _ToggleChip(label: '🧱 Retaining Wall', isOn: false),
              _ToggleChip(label: '🚪 Garden Gate', isOn: false),
            ],
          ),
        ],
      ),
    );
  }

  // ============ LIGHTING TAB ============
  Widget _buildLightingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'Lighting Style', icon: Icons.lightbulb_outline_rounded),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.lightingOptions.length,
              itemBuilder: (context, index) {
                final option = MockData.lightingOptions[index];
                final isSelected = _selectedLighting == index;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedLighting = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 100,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.sunGlow.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.sunGlow.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.08),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option['icon'] as String,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          option['name'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option['temp'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.sunGlow
                                : Colors.white30,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          _SliderRow(
            label: 'Brightness',
            value: 0.6,
            icon: Icons.brightness_6_rounded,
            activeColor: AppTheme.sunGlow,
            onChanged: (_) {},
            leftLabel: 'Dim',
            rightLabel: 'Bright',
          ),
        ],
      ),
    );
  }

  // ============ WATER TAB ============
  Widget _buildWaterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SliderRow(
            label: 'Water Element Scale',
            value: _water,
            icon: Icons.water_drop_rounded,
            activeColor: AppTheme.skyBlue,
            onChanged: (v) => setState(() => _water = v),
            leftLabel: 'None',
            rightLabel: 'Grand',
          ),

          const SizedBox(height: 20),

          _SectionLabel(label: 'Water Feature Type', icon: Icons.waves_rounded),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.waterFeatures.length,
              itemBuilder: (context, index) {
                final option = MockData.waterFeatures[index];
                final isSelected = _selectedWaterFeature == index;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedWaterFeature =
                          isSelected ? -1 : index;
                      if (!isSelected && _water < 0.2) {
                        _water = 0.4;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 90,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.skyBlue.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.skyBlue.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.08),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option['icon'] as String,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option['name'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============ REUSABLE WIDGETS ============

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color activeColor;
  final ValueChanged<double> onChanged;
  final String leftLabel;
  final String rightLabel;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.activeColor,
    required this.onChanged,
    this.leftLabel = '',
    this.rightLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: activeColor, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  color: activeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
            thumbColor: Colors.white,
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
              elevation: 4,
            ),
            overlayColor: activeColor.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
          ),
        ),
        if (leftLabel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  leftLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 10,
                  ),
                ),
                Text(
                  rightLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ToggleChip extends StatefulWidget {
  final String label;
  final bool isOn;

  const _ToggleChip({required this.label, required this.isOn});

  @override
  State<_ToggleChip> createState() => _ToggleChipState();
}

class _ToggleChipState extends State<_ToggleChip> {
  late bool _on;

  @override
  void initState() {
    super.initState();
    _on = widget.isOn;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _on = !_on);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _on
              ? AppTheme.mossGreen.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _on
                ? AppTheme.mossGreen.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: _on ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: _on ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

Widget _styleImage(String path, {BoxFit fit = BoxFit.cover}) {
  if (path.startsWith('http')) {
    return Image.network(path, fit: fit);
  }
  return Image.asset(path, fit: fit);
}
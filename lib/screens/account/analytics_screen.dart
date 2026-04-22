import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/storage_service.dart';
import '../../models/pantry_model.dart';
import '../../mock/mock_data.dart';
import '../../widgets/glass_container.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<List<PantryModel>> _pantriesFuture;

  @override
  void initState() {
    super.initState();
    _pantriesFuture = context.read<StorageService>().loadPantries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmSand,
      appBar: AppBar(
        title: const Text("Pantry Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<PantryModel>>(
        future: _pantriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pantries = snapshot.data ?? [];
          final allPantries = [...pantries, ...MockData.initialHistory];
          
          // Analytics Logic
          int total = allPantries.length;
          
          // Style Distribution
          final styleCounts = <String, int>{};
          for (var g in allPantries) {
            styleCounts[g.styleName] = (styleCounts[g.styleName] ?? 0) + 1;
          }
          
          final mostUsedStyle = styleCounts.isEmpty ? "None" : styleCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

          // Season Distribution (mock settings check)
          final seasonCounts = <String, int>{};
          for (var g in allPantries) {
            final season = g.settings['season'] as String? ?? 'Unknown';
            seasonCounts[season] = (seasonCounts[season] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(label: "Total Created", value: "$total", icon: Icons.kitchen),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(label: "Top Style", value: mostUsedStyle, icon: Icons.style),
                    ),
                  ],
                ).animate().slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 30),
                
                // Style Chart
                Text("Style Distribution", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: styleCounts.entries.map((e) {
                        final index = styleCounts.keys.toList().indexOf(e.key);
                        final color = [
                          AppTheme.mossGreen,
                          AppTheme.sunGlow,
                          const Color(0xFF8B735B),
                          const Color(0xFF3E5C3E),
                          const Color(0xFFD4B483),
                          Colors.grey
                        ][index % 6];
                        
                        return PieChartSectionData(
                          color: color,
                          value: e.value.toDouble(),
                          title: "${((e.value / total) * 100).toInt()}%",
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.mistWhite),
                        );
                      }).toList(),
                    ),
                  ),
                ).animate().scale(delay: 200.ms),
                
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: styleCounts.keys.map((key) {
                    final index = styleCounts.keys.toList().indexOf(key);
                    final color = [
                      AppTheme.mossGreen,
                      AppTheme.sunGlow,
                      const Color(0xFF8B735B),
                      const Color(0xFF3E5C3E),
                      const Color(0xFFD4B483),
                      Colors.grey
                    ][index % 6];
                    return Chip(
                      label: Text(key, style: const TextStyle(color: AppTheme.mistWhite, fontSize: 10)),
                      backgroundColor: color,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),
                
                // Season Bar Chart
                Text("Seasonal Preferences", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final seasons = seasonCounts.keys.toList();
                              if (value.toInt() < seasons.length) {
                                return Text(seasons[value.toInt()], style: const TextStyle(fontSize: 10));
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: seasonCounts.entries.map((e) {
                        final index = seasonCounts.keys.toList().indexOf(e.key);
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.toDouble(),
                              color: AppTheme.mossGreen,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ).animate().slideX(delay: 400.ms),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      color: AppTheme.mistWhite,
      opacity: 0.5,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, size: 30, color: AppTheme.mossGreen),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.deepSoil)),
        ],
      ),
    );
  }
}

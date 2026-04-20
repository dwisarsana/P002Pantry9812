// lib/screens/onboarding/onboarding_screen.dart
// Garden AI — Onboarding Screen (Enhanced Survey for User Retention)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../main/home_screen.dart';
import '../../src/constant.dart' show openPaywallFromUserAction;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pg = PageController();
  int _page = 0;

  final TextEditingController _nameCtl = TextEditingController();
  bool _isFinalizing = false;

  // ── 7 Survey questions for garden personalization ──
  final List<_Question> _questions = [
    _Question(
      keyName: 'q_type',
      title: 'What\'s your garden type?',
      subtitle: 'We\'ll tailor AI designs to fit your landscape.',
      icon: Icons.eco_rounded,
      accentEmoji: '🌿',
      options: [
        _Option('Backyard', Icons.home_rounded),
        _Option('Front Yard', Icons.door_front_door_rounded),
        _Option('Terrace/Balcony', Icons.apartment_rounded),
        _Option('Rooftop', Icons.vertical_align_top_rounded),
        _Option('Small Courtyard', Icons.crop_square_rounded),
      ],
    ),
    _Question(
      keyName: 'q_goal',
      title: 'What\'s your design goal?',
      subtitle: 'How would you like to transform your space?',
      icon: Icons.lightbulb_outline_rounded,
      accentEmoji: '✨',
      options: [
        _Option('Modern Sanctuary', Icons.spa_rounded),
        _Option('English Cottage', Icons.villa_rounded),
        _Option('Zen Garden', Icons.self_improvement_rounded),
        _Option('Productive Vegetable', Icons.agriculture_rounded),
        _Option('Entertaining Space', Icons.groups_rounded),
      ],
    ),
    _Question(
      keyName: 'q_style',
      title: 'Choose your style',
      subtitle: 'Pick the aesthetic that excites you most.',
      icon: Icons.brush_rounded,
      accentEmoji: '🎨',
      options: [
        _Option('Tropical Jungle', Icons.wb_sunny_rounded),
        _Option('Minimalist Desert', Icons.terrain_rounded),
        _Option('Mediterranean', Icons.sunny_snowing),
        _Option('Wildflower Meadow', Icons.filter_vintage_rounded),
        _Option('Geometric Modern', Icons.architecture_rounded),
      ],
    ),
    _Question(
      keyName: 'q_budget',
      title: 'Estimated budget?',
      subtitle: 'We\'ll suggest designs within your range.',
      icon: Icons.account_balance_wallet_rounded,
      accentEmoji: '💰',
      options: [
        _Option('Under \$1k', Icons.savings_rounded),
        _Option('\$1k – \$5k', Icons.credit_card_rounded),
        _Option('\$5k – \$15k', Icons.trending_up_rounded),
        _Option('\$15k+', Icons.workspace_premium_rounded),
        _Option('Just exploring', Icons.search_rounded),
      ],
    ),
    _Question(
      keyName: 'q_timeline',
      title: 'Project timeline?',
      subtitle: 'When would you like to start planting?',
      icon: Icons.calendar_month_rounded,
      accentEmoji: '📅',
      options: [
        _Option('Immediately', Icons.flash_on_rounded),
        _Option('Next season', Icons.timelapse_rounded),
        _Option('Within 6 months', Icons.schedule_rounded),
        _Option('Next year', Icons.hourglass_empty_rounded),
        _Option('No set plans', Icons.explore_rounded),
      ],
    ),
    _Question(
      keyName: 'q_pain',
      title: 'Biggest challenge?',
      subtitle: 'We\'ll focus on solving this for you.',
      icon: Icons.warning_amber_rounded,
      accentEmoji: '🔧',
      options: [
        _Option('Poor soil', Icons.grass_rounded),
        _Option('Lack of privacy', Icons.visibility_off_rounded),
        _Option('High maintenance', Icons.build_circle_rounded),
        _Option('Extreme weather', Icons.cloud_rounded),
        _Option('Small space', Icons.zoom_in_map_rounded),
      ],
    ),
    _Question(
      keyName: 'q_usage',
      title: 'Main garden usage?',
      subtitle: 'Helps us design for your lifestyle.',
      icon: Icons.beach_access_rounded,
      accentEmoji: '🍹',
      options: [
        _Option('Relaxation', Icons.weekend_rounded),
        _Option('Family & Kids', Icons.child_care_rounded),
        _Option('Social BBQ', Icons.outdoor_grill_rounded),
        _Option('Urban farming', Icons.agriculture_rounded),
        _Option('Visual decor', Icons.auto_awesome_rounded),
      ],
    ),
  ];

  final Map<String, int> _answers = {};

  int get _totalPages => 2 + _questions.length;
  bool get _onLastQuestion => _page == (_totalPages - 1);

  @override
  void initState() {
    super.initState();
    _preloadName();
  }

  Future<void> _preloadName() async {
    final p = await SharedPreferences.getInstance();
    final existing = p.getString('user_name');
    if (existing != null && existing.isNotEmpty) {
      _nameCtl.text = existing;
    }
  }

  Future<void> _saveAll() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('onboarding_done', true);
    await p.setString('user_name', _nameCtl.text.trim());
    for (final entry in _answers.entries) {
      await p.setInt('onboard_${entry.key}', entry.value);
    }
  }

  Future<void> _finish() async {
    setState(() => _isFinalizing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    await _saveAll();
    if (!mounted) return;

    await openPaywallFromUserAction(context);

    final p = await SharedPreferences.getInstance();
    await p.setBool('has_seen_onboarding_paywall', true);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _next() async {
    FocusScope.of(context).unfocus();
    if (!_canContinueForPage(_page)) return;

    if (_onLastQuestion) {
      await _finish();
    } else {
      _pg.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prev() {
    if (_page == 0) return;
    FocusScope.of(context).unfocus();
    _pg.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }

  bool _canContinueForPage(int pageIndex) {
    if (pageIndex == 0) return true;
    if (pageIndex == 1) return _nameCtl.text.trim().isNotEmpty;
    final q = _questions[pageIndex - 2];
    return _answers[q.keyName] != null;
  }

  @override
  void dispose() {
    _pg.dispose();
    _nameCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _canContinueForPage(_page);

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.mossGreen.withValues(alpha: 0.06),
                    AppTheme.charcoal,
                    AppTheme.charcoal,
                  ],
                  stops: const [0, 0.3, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      Image.asset('assets/icon.png', width: 30, height: 30),
                      const SizedBox(width: 10),
                      const Text(
                        'GARDEN AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Text(
                          '${_page + 1} of $_totalPages',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: List.generate(_totalPages, (i) {
                      final isCompleted = i < _page;
                      final isCurrent = i == _page;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < _totalPages - 1 ? 3 : 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: isCompleted || isCurrent
                                  ? (isCurrent
                                        ? AppTheme.mossGreen.withValues(alpha: 0.7)
                                        : AppTheme.mossGreen)
                                  : Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pg,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: _totalPages,
                    itemBuilder: (_, idx) {
                      if (idx == 0) return const _IntroPage();
                      if (idx == 1) return _NamePage(controller: _nameCtl);
                      final q = _questions[idx - 2];
                      return _QuestionPage(
                        question: q,
                        questionNumber: idx - 1,
                        totalQuestions: _questions.length,
                        selectedIndex: _answers[q.keyName],
                        onSelect: (i) =>
                            setState(() => _answers[q.keyName] = i),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Row(
                    children: [
                      if (_page > 0)
                        GestureDetector(
                          onTap: _prev,
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Icon(
                              CupertinoIcons.chevron_left,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: canContinue ? _next : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 52,
                            decoration: BoxDecoration(
                              color: canContinue
                                  ? AppTheme.mossGreen
                                  : Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: canContinue
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.mossGreen.withValues(alpha: 0.35),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _onLastQuestion ? '🚀  Get Started' : 'Continue',
                                  style: TextStyle(
                                    color: canContinue ? Colors.black : Colors.white.withValues(alpha: 0.25),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.5,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                if (!_onLastQuestion) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    CupertinoIcons.arrow_right,
                                    size: 15,
                                    color: canContinue ? Colors.black : Colors.white.withValues(alpha: 0.2),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isFinalizing)
            Positioned.fill(
              child: Container(
                color: AppTheme.charcoal.withValues(alpha: 0.96),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.mossGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.mossGreen, size: 32),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Building your\npersonalized garden...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const CupertinoActivityIndicator(radius: 12, color: AppTheme.mossGreen),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Option {
  final String label;
  final IconData icon;
  const _Option(this.label, this.icon);
}

class _Question {
  final String keyName;
  final String title;
  final String? subtitle;
  final IconData icon;
  final String accentEmoji;
  final List<_Option> options;
  const _Question({
    required this.keyName,
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentEmoji = '',
    required this.options,
  });
}

class _IntroPage extends StatelessWidget {
  const _IntroPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.mossGreen.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'assets/images/AI Garden Transformation.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 36),
          const Text(
            'Redesign Your\nGarden with AI',
            style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.8),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            'Upload a photo and let AI instantly redesign your garden — from tropical jungle to zen sanctuary.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 15.5, height: 1.55),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...[
            (CupertinoIcons.camera, 'Snap a photo of your space'),
            (CupertinoIcons.wand_stars, 'AI generates stunning designs'),
            (CupertinoIcons.arrow_down_doc, 'Save & share your favorites'),
          ].map((item) => Padding(padding: const EdgeInsets.only(bottom: 14), child: _IntroFeature(icon: item.$1, text: item.$2))),
        ],
      ),
    );
  }
}

class _IntroFeature extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IntroFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppTheme.mossGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, size: 17, color: AppTheme.mossGreen),
        ),
        const SizedBox(width: 14),
        Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14.5, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  const _NamePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(
              color: AppTheme.mossGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.25)),
            ),
            child: const Icon(CupertinoIcons.person, size: 34, color: AppTheme.mossGreen),
          ),
          const SizedBox(height: 28),
          const Text('What\'s your name?', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('We\'ll personalize every design recommendation for you.', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 15, height: 1.4), textAlign: TextAlign.center),
          const SizedBox(height: 36),
          CupertinoTextField(
            controller: controller,
            placeholder: 'Enter your name',
            placeholderStyle: TextStyle(color: Colors.white.withValues(alpha: 0.22)),
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.25), width: 1.5),
            ),
            textAlign: TextAlign.center,
            cursorColor: AppTheme.mossGreen,
          ),
        ],
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  final _Question question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _QuestionPage({required this.question, required this.questionNumber, required this.totalQuestions, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.mossGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.2)),
            ),
            child: Text('Question $questionNumber of $totalQuestions', style: const TextStyle(color: AppTheme.mossGreen, fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(question.accentEmoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(child: Text(question.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.2))),
            ],
          ),
          if (question.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(question.subtitle!, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 15, height: 1.4)),
          ],
          const SizedBox(height: 32),
          ...List.generate(question.options.length, (i) {
            final opt = question.options[i];
            final isSelected = selectedIndex == i;
            return GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.mossGreen.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? AppTheme.mossGreen.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08), width: isSelected ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Icon(opt.icon, color: isSelected ? AppTheme.mossGreen : Colors.white.withValues(alpha: 0.35), size: 22),
                    const SizedBox(width: 14),
                    Expanded(child: Text(opt.label, style: TextStyle(color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7), fontSize: 15, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500))),
                    if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.mossGreen, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}


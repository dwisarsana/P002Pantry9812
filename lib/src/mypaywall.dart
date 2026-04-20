// lib/src/mypaywall.dart
// Garden AI — Premium Paywall Screen

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import 'credits_vault.dart';
import 'constant.dart'
    show
        markJustPurchased,
        checkPremiumFresh,
        kToken5ProductId,
        kPrivacyPolicyUrl,
        kTermsOfUseUrl;

class GardenAIPaywall extends StatefulWidget {
  final bool forceLoading;
  const GardenAIPaywall({super.key, this.forceLoading = false});

  @override
  State<GardenAIPaywall> createState() => _GardenAIPaywallState();
}

class _GardenAIPaywallState extends State<GardenAIPaywall>
    with SingleTickerProviderStateMixin {
  Offerings? _offerings;
  StoreProduct? _token5;

  String? _busyPkgId;
  bool _busyToken = false;
  late final AnimationController _ctaPulse;
  late final Animation<double> _ctaCurve;

  bool _loadingError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
    _fetchToken5();
    _ctaPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _ctaCurve = CurvedAnimation(parent: _ctaPulse, curve: Curves.easeInOut);

    // Listen for external premium changes
    Purchases.addCustomerInfoUpdateListener((_) async {
      final isPro = await checkPremiumFresh();
      if (!mounted) return;
      if (isPro && Navigator.canPop(context)) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Premium activates.')));
      }
    });
  }

  @override
  void dispose() {
    _ctaPulse.dispose();
    super.dispose();
  }

  Future<void> _fetchOfferings() async {
    setState(() {
      _loadingError = false;
      _errorMessage = null;
    });
    try {
      final offerings = await Purchases.getOfferings().timeout(
        const Duration(seconds: 15),
        onTimeout: () =>
            throw TimeoutException('Connection to store timed out.'),
      );
      if (offerings.current == null && offerings.all.isEmpty) {
        if (mounted) {
          setState(() {
            _loadingError = true;
            _errorMessage = 'No subscriptions available in dashboard.';
          });
        }
        return;
      }
      if (mounted) setState(() => _offerings = offerings);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingError = true;
          _errorMessage = e is TimeoutException
              ? 'Request timed out. Please check your connection.'
              : e.toString();
        });
      }
    }
  }

  Future<void> _fetchToken5() async {
    try {
      final prods = await Purchases.getProducts([
        kToken5ProductId,
      ]).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      setState(() => _token5 = prods.isNotEmpty ? prods.first : null);
    } catch (e) {
      debugPrint('❌ Error fetching tokens: $e');
    }
  }

  Future<void> _buyPackage(Package pkg) async {
    if (_busyPkgId != null) return;
    setState(() => _busyPkgId = pkg.identifier);
    try {
      await Purchases.purchase(PurchaseParams.package(pkg));
      await markJustPurchased();
      final isPro = await checkPremiumFresh();
      if (!mounted) return;
      if (isPro) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome to Garden AI Premium!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Purchase failed.')));
      }
    } finally {
      if (mounted) setState(() => _busyPkgId = null);
    }
  }

  Future<void> _buyToken5() async {
    if (_busyToken || _token5 == null) return;
    setState(() => _busyToken = true);
    try {
      await Purchases.purchase(PurchaseParams.storeProduct(_token5!));
      await CreditsVault.add(5);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('5 tokens added.')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Token purchase failed.')));
      }
    } finally {
      if (mounted) setState(() => _busyToken = false);
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      final isPro = await checkPremiumFresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isPro ? 'Premium restored!' : 'No subscription found.'),
        ),
      );
      if (isPro && Navigator.canPop(context)) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Restore failed.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final offering = _offerings?.current;
    final packages = (offering?.availablePackages ?? []).toList();
    final annualPkg = packages
        .where((p) => p.packageType == PackageType.annual)
        .firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.mossGreen.withValues(alpha: 0.18),
                    const Color(0xFF0F1117),
                    const Color(0xFF0F1117),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child:
                (_offerings == null && (widget.forceLoading || _loadingError))
                ? (_loadingError ? _buildErrorView() : _buildLoadingView())
                : _buildContent(context, packages),
          ),
          if (annualPkg != null) _bottomAnnualCta(annualPkg),
          _topCloseButton(),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(
            radius: 16,
            color: AppTheme.mossGreen,
          ),
          SizedBox(height: 20),
          Text(
            'Syncing with Store…',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.wifi_exclamationmark,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 20),
            const Text(
              'Connection Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Store unavailable. Please try again later.',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CupertinoButton(
              color: AppTheme.mossGreen,
              onPressed: () {
                _fetchOfferings();
                _fetchToken5();
              },
              child: const Text(
                'Retry Connection',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topCloseButton() {
    return Positioned(
      top: 10,
      right: 10,
      child: SafeArea(
        child: IconButton(
          icon: const Icon(
            CupertinoIcons.xmark_circle_fill,
            color: Colors.white70,
            size: 30,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Package> packages) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // App Logo Placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.mossGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.mossGreen.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.eco_rounded,
              size: 40,
              color: AppTheme.mossGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Garden AI Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Transform your landscape with unlimited AI power and exclusive designs.',
            style: TextStyle(color: Colors.white60, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          _sectionTitle('Premium Features'),
          _feature(CupertinoIcons.infinite, 'Unlimited Garden generations'),
          _feature(
            CupertinoIcons.paintbrush,
            'Access all 100+ Premium garden styles',
          ),
          _feature(CupertinoIcons.photo_fill, 'High-resolution 4K exports'),
          _feature(CupertinoIcons.bolt_fill, 'Priority AI Rendering'),
          _feature(CupertinoIcons.star_fill, 'Exclusive early-access plants'),

          const SizedBox(height: 40),

          if (packages.isEmpty)
            const Text(
              'Loading available plans...',
              style: TextStyle(color: Colors.white30),
            )
          else
            ...packages.map((p) => _planCard(p)),

          if (_token5 != null) ...[
            const SizedBox(height: 24),
            _sectionTitle('Token Packs'),
            _tokenCard(),
          ],

          const SizedBox(height: 40),
          CupertinoButton(
            onPressed: _restorePurchases,
            child: const Text(
              'Restore Purchases',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _linkText('Terms of Use', kTermsOfUseUrl),
              const SizedBox(width: 24),
              _linkText('Privacy Policy', kPrivacyPolicyUrl),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomAnnualCta(Package pkg) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: const Color(0xFF0F1117).withValues(alpha: 0.95),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: _ctaPulse,
            builder: (context, child) => Transform.scale(
              scale: 1.0 + (_ctaCurve.value * 0.03),
              child: child,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: CupertinoButton(
                color: AppTheme.mossGreen,
                borderRadius: BorderRadius.circular(16),
                onPressed: () => _buyPackage(pkg),
                child: const Text(
                  'Start Yearly Subscription',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.mossGreen, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard(Package pkg) {
    final isBusy = _busyPkgId == pkg.identifier;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.storeProduct.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  pkg.storeProduct.description,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: AppTheme.mossGreen,
            borderRadius: BorderRadius.circular(10),
            onPressed: isBusy ? null : () => _buyPackage(pkg),
            child: isBusy
                ? const CupertinoActivityIndicator(color: Colors.black)
                : Text(
                    pkg.storeProduct.priceString,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tokenCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.cube_box,
            color: AppTheme.mossGreen,
            size: 28,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '5 AI Design Tokens',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Permanent tokens, never expire',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            onPressed: _busyToken ? null : _buyToken5,
            child: _busyToken
                ? const CupertinoActivityIndicator()
                : Text(
                    _token5?.priceString ?? '...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _linkText(String label, String url) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}


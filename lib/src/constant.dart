// RevenueCat + helper premium for Garden AI (iOS + Android ready)

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'credits_vault.dart';
import 'mypaywall.dart';
import '../theme/app_theme.dart';

// =================== API KEYS ===================
const googleApiKey = 'googl_api_key'; // Android (Play Store)
const amazonApiKey = 'amazon_api_key'; // Android (Amazon)
const appleApiKey = 'appl_KEWWHMhhILmVXtUgAYxPqCiwpbB'; // iOS

const appId =
    'app.garden.ai'; // Garden AI identifier

const entitlementKey = 'garden'; // Generic entitlement key
const int kPremiumDailyLimit = 10;

const tokenPack5Id = 'ai.garden.token5';
const String kToken5ProductId = tokenPack5Id;

const String kPrivacyPolicyUrl = 'https://appsbylily.com/privacy.html';
const String kTermsOfUseUrl = 'https://appsbylily.com/terms.html';

// =================== PREMIUM STATE ===================
final ValueNotifier<bool> _premiumState = ValueNotifier<bool>(false);
ValueListenable<bool> get premiumListenable => _premiumState;
final ValueNotifier<int> _premiumDailyUsage = ValueNotifier<int>(0);
ValueListenable<int> get premiumDailyUsageListenable => _premiumDailyUsage;
final ValueNotifier<int> _tokenBalance = ValueNotifier<int>(0);
ValueListenable<int> get tokenBalanceListenable => _tokenBalance;
StreamSubscription<int>? _tokenSubscription;

// =================== TOTAL GENERATION COUNT ===================
const String _kTotalGenerationKey = 'garden_ai_total_generations';

Future<int> getTotalGenerationCount() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_kTotalGenerationKey) ?? 0;
}

Future<void> incrementTotalGenerationCount() async {
  final prefs = await SharedPreferences.getInstance();
  final current = prefs.getInt(_kTotalGenerationKey) ?? 0;
  await prefs.setInt(_kTotalGenerationKey, current + 1);
}

// =================== DEVELOPER MODE (Debug Only) ===================
const String _kDevModeKey = 'garden_developer_mode_enabled';
bool _devModeEnabled = false;

/// Check if developer mode is enabled (bypasses premium checks for testing)
Future<bool> isDeveloperModeEnabled() async {
  if (!kDebugMode) return false; // Strictly disabled in release
  final prefs = await SharedPreferences.getInstance();
  _devModeEnabled = prefs.getBool(_kDevModeKey) ?? false;
  return _devModeEnabled;
}

/// Enable/disable developer mode for testing premium features
Future<void> setDeveloperMode(bool enabled) async {
  if (!kDebugMode) return; // Prevent setting in release
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kDevModeKey, enabled);
  _devModeEnabled = enabled;
  debugPrint('🔧 Developer Mode: ${enabled ? 'ENABLED ✅' : 'DISABLED ❌'}');
  if (enabled) {
    debugPrint('   → Premium checks will be BYPASSED for testing');
  }
}

/// Get current dev mode state synchronously (after initial load)
bool get isDevMode => _devModeEnabled;

// =================== DEBUG HELPERS ===================
/// Simulate premium user for testing
Future<void> debugSetPremium(bool value) async {
  _premiumState.value = value;
  debugPrint('🔧 [DEBUG] Premium set to: $value');
}

/// Simulate adding tokens for testing
Future<void> debugAddTokens(int count) async {
  await CreditsVault.add(count);
  await _syncTokenBalance();
  debugPrint(
    '🔧 [DEBUG] Added $count tokens. New balance: ${_tokenBalance.value}',
  );
}

/// Reset tokens to zero for testing
Future<void> debugResetTokens() async {
  await CreditsVault.clear();
  await _syncTokenBalance();
  debugPrint('🔧 [DEBUG] Tokens reset to 0');
}

/// Reset daily usage count for testing
Future<void> debugResetDailyUsage() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_todayPremiumKey(), 0);
  await _syncDailyUsage();
  debugPrint('🔧 [DEBUG] Daily usage reset to 0');
}

/// Simulate free user (disable premium + reset tokens)
Future<void> debugSetFreeUser() async {
  _premiumState.value = false;
  await CreditsVault.clear();
  await _syncTokenBalance();
  debugPrint('🔧 [DEBUG] Set as FREE user');
}

// =================== INTERNAL GUARDS ===================
bool _paywallShowing = false;
const _justPurchasedKey = 'just_purchased_ms';
const _suppressMinutesAfterPurchase = 10;
const _kPremiumDailyKeyPrefix = 'garden_ai_premium_daily_';

// =================== INIT ===================
Future<void> initRevenueCat() async {
  debugPrint('🚀 initRevenueCat() started...');
  await Purchases.setLogLevel(LogLevel.info);

  final apiKey = Platform.isIOS
      ? appleApiKey
      : (Platform.isAndroid ? googleApiKey : appleApiKey);

  final config = PurchasesConfiguration(apiKey);

  await Purchases.configure(config);
  debugPrint('✅ Purchases configured with API key: $apiKey');

  await checkPremiumFresh();
  debugPrint('🔄 Initial premium status checked.');
  await isDeveloperModeEnabled(); // Load dev mode state
  await _syncDailyUsage();
  await _syncTokenBalance();
  _startTokenListener();

  startRevenueCatListeners();
  debugPrint('👂 RevenueCat listeners attached.');
}

// =================== LISTENER ===================
void startRevenueCatListeners() {
  Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    final isPro = customerInfo.entitlements.active.containsKey(entitlementKey);
    debugPrint('📡 Premium listener fired → $isPro');
    _premiumState.value = isPro;
  });
}

Future<bool> checkPremium() async {
  try {
    debugPrint('🔍 checkPremium() called...');
    final info = await Purchases.getCustomerInfo();
    final isPro = info.entitlements.active.containsKey(entitlementKey);
    debugPrint('🔑 checkPremium → isPro: $isPro');
    _premiumState.value = isPro;
    return isPro;
  } catch (e) {
    debugPrint('❌ checkPremium failed: $e');
    return false;
  }
}

Future<bool> checkPremiumFresh() async {
  try {
    debugPrint('🔄 checkPremiumFresh() → invalidate cache...');
    await Purchases.invalidateCustomerInfoCache();
    final info = await Purchases.getCustomerInfo();
    final isPro = info.entitlements.active.containsKey(entitlementKey);
    debugPrint('🔑 checkPremiumFresh → isPro: $isPro');
    _premiumState.value = isPro;
    return isPro;
  } catch (e) {
    debugPrint('❌ checkPremiumFresh failed: $e');
    return false;
  }
}

Future<bool> presentPaywallGuarded(
  BuildContext context, {
  bool forceLoading = false,
}) async {
  if (_paywallShowing) {
    debugPrint('⚠️ Paywall already visible, ignoring duplicate request.');
    return false;
  }
  _paywallShowing = true;

  try {
    debugPrint('🟢 Opening Garden AI paywall (forceLoading: $forceLoading)...');
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => GardenAIPaywall(forceLoading: forceLoading),
      ),
    );

    debugPrint('✅ Paywall closed by user or transaction finished.');

    final isPro = await checkPremiumFresh();
    debugPrint('🔑 Premium status after paywall: $isPro');
    return isPro;
  } catch (e, st) {
    debugPrint('❌ Paywall error: $e\n$st');
    return false;
  } finally {
    _paywallShowing = false;
    debugPrint('ℹ️ _paywallShowing reset → false.');
  }
}

Future<void> openPaywallFromUserAction(
  BuildContext context, {
  bool forceLoading = false,
}) async {
  debugPrint('👆 openPaywallFromUserAction() triggered by user.');
  if (await shouldSuppressPaywall()) {
    debugPrint('⏳ Paywall suppressed because a purchase just happened.');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You\'re all set — syncing your purchase…'),
        ),
      );
    }
    return;
  }
  if (!context.mounted) return;
  await postPurchaseRefresh(
    context: context,
    alsoDo: () async {
      debugPrint('📲 Calling presentPaywallGuarded() via postPurchaseRefresh.');
      await presentPaywallGuarded(context, forceLoading: forceLoading);
    },
  );
}

Future<void> manageOrUpgrade(BuildContext context) async {
  debugPrint('⚙️ manageOrUpgrade() called → Forcing loading in Paywall.');
  await openPaywallFromUserAction(context, forceLoading: true);
}

Future<bool> restorePurchases() async {
  try {
    debugPrint('♻️ restorePurchases()…');
    await Purchases.restorePurchases();
    final isPro = await checkPremiumFresh();
    debugPrint('✅ restorePurchases → isPro: $isPro');
    return isPro;
  } catch (e) {
    debugPrint('❌ restorePurchases failed: $e');
    return false;
  }
}

Future<void> postPurchaseRefresh({
  required BuildContext context,
  Future<void> Function()? alsoDo,
}) async {
  debugPrint('🔄 postPurchaseRefresh() started...');

  showCupertinoDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CupertinoActivityIndicator(
        radius: 14,
        color: AppTheme.mintGreen,
      ),
    ),
  );

  try {
    if (alsoDo != null) {
      debugPrint('▶️ Running alsoDo() (paywall / purchase)…');
      await alsoDo();
    }

    await Future.delayed(const Duration(milliseconds: 200));

    final info = await Purchases.getCustomerInfo();
    final isPro = info.entitlements.active.containsKey(entitlementKey);
    _premiumState.value = isPro;
    debugPrint('🔑 Immediate result → isPro: $isPro');

    if (!isPro) {
      for (int i = 0; i < 2; i++) {
        await Future.delayed(const Duration(milliseconds: 250));
        final retry = await Purchases.getCustomerInfo();
        final retryPro = retry.entitlements.active.containsKey(entitlementKey);
        debugPrint('🔁 Polling #$i → $retryPro');
        _premiumState.value = retryPro;
        if (retryPro) break;
      }
    }
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).maybePop();
      debugPrint('✅ Spinner dismissed.');
    }
  }
}

Future<void> _syncDailyUsage() async {
  try {
    final count = await getTodayPremiumCount();
    if (_premiumDailyUsage.value != count) {
      _premiumDailyUsage.value = count;
    }
  } catch (e) {
    debugPrint('❌ _syncDailyUsage failed: $e');
  }
}

Future<void> _syncTokenBalance() async {
  try {
    final balance = await CreditsVault.get();
    if (_tokenBalance.value != balance) {
      _tokenBalance.value = balance;
    }
  } catch (e) {
    debugPrint('❌ _syncTokenBalance failed: $e');
  }
}

void _startTokenListener() {
  if (_tokenSubscription != null) return;
  _tokenSubscription = CreditsVault.changes.listen((balance) {
    if (_tokenBalance.value != balance) {
      _tokenBalance.value = balance;
    }
  });
}

String _todayPremiumKey() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '$_kPremiumDailyKeyPrefix${now.year}$month$day';
}

Future<int> getTodayPremiumCount() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_todayPremiumKey()) ?? 0;
}

Future<void> incrementTodayPremiumCount() async {
  final prefs = await SharedPreferences.getInstance();
  final key = _todayPremiumKey();
  final current = prefs.getInt(key) ?? 0;
  final next = current + 1;
  await prefs.setInt(key, next);
  if (_premiumDailyUsage.value != next) {
    _premiumDailyUsage.value = next;
  }
}

Future<void> markJustPurchased() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_justPurchasedKey, DateTime.now().millisecondsSinceEpoch);
  debugPrint('📝 markJustPurchased → timestamp stored.');
}

Future<bool> shouldSuppressPaywall() async {
  final prefs = await SharedPreferences.getInstance();
  final last = prefs.getInt(_justPurchasedKey) ?? 0;
  final diffMs = DateTime.now().millisecondsSinceEpoch - last;
  final suppress = diffMs < _suppressMinutesAfterPurchase * 60 * 1000;
  debugPrint('⏳ shouldSuppressPaywall → $suppress (diffMs=$diffMs)');
  return suppress;
}

Future<void> promptInAppReview() async {
  try {
    debugPrint('⭐ promptInAppReview() checking status…');
    final prefs = await SharedPreferences.getInstance();
    final lastReview = prefs.getInt('last_review') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastReview > 86400000) {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        debugPrint('📣 Requesting in-app review…');
        await inAppReview.requestReview();
        await prefs.setInt('last_review', now);
      }
    }
  } catch (e) {
    debugPrint('❌ promptInAppReview error: $e');
  }
}

/// Clear all app data (history, preferences, tokens)
Future<void> clearAllData() async {
  final prefs = await SharedPreferences.getInstance();
  // Preserve onboarding and dev mode state
  final devMode = prefs.getBool(_kDevModeKey) ?? false;
  await prefs.clear();
  await prefs.setBool(_kDevModeKey, devMode);
  await CreditsVault.clear();
  _premiumState.value = false;
  _premiumDailyUsage.value = 0;
  _tokenBalance.value = 0;
  debugPrint('🗑️ All app data cleared.');
}

class PremiumGateStatus {
  const PremiumGateStatus({
    required this.isPremium,
    required this.dailyCount,
    required this.dailyLimit,
    required this.tokenBalance,
    required this.isDevMode,
  });

  final bool isPremium;
  final int dailyCount;
  final int dailyLimit;
  final int tokenBalance;
  final bool isDevMode;

  bool get premiumHasQuota => isPremium && dailyCount < dailyLimit;
  bool get premiumLimitReached => isPremium && dailyCount >= dailyLimit;
  bool get tokensAvailable => tokenBalance > 0;
  bool get canGenerate => isDevMode || premiumHasQuota || tokensAvailable;
}

class PremiumGate {
  PremiumGate._();

  static const int premiumDailyLimit = kPremiumDailyLimit;

  static Future<PremiumGateStatus> currentStatus({
    bool refreshPremium = false,
  }) async {
    if (refreshPremium) {
      await checkPremiumFresh();
    }
    await _syncDailyUsage();
    await _syncTokenBalance();
    final dev = await isDeveloperModeEnabled();
    return PremiumGateStatus(
      isPremium: _premiumState.value,
      dailyCount: _premiumDailyUsage.value,
      dailyLimit: premiumDailyLimit,
      tokenBalance: _tokenBalance.value,
      isDevMode: dev,
    );
  }

  /// Check if generation is allowed, and show paywall if not.
  /// Returns true if allowed (either already allowed or user purchased in paywall).
  static Future<bool> checkGate(BuildContext context) async {
    debugPrint('🔍 [GATE] checkGate() started...');

    // 🔧 DEVELOPER MODE OVERRIDE (Debug Only)
    if (kDebugMode) {
      final devMode = await isDeveloperModeEnabled();
      if (devMode) {
        debugPrint('🔧 [DEV MODE] ACTIVE → Allowed.');
        return true;
      }
    }

    final status = await currentStatus(refreshPremium: true);
    debugPrint(
      '📊 [GATE] Status: Premium=${status.isPremium}, Daily=${status.dailyCount}/${status.dailyLimit}, Tokens=${status.tokenBalance}',
    );

    if (status.canGenerate) {
      debugPrint('✅ [GATE] Path: Access allowed via quota or tokens.');
      return true;
    }

    // No quota and no tokens → Show paywall
    if (!context.mounted) return false;
    debugPrint('🚧 [GATE] Path: PAYWALL → No quota/tokens found.');
    final result = await presentPaywallGuarded(context, forceLoading: false);

    if (result) {
      debugPrint('🎉 [GATE] User became premium or bought tokens in paywall.');
      // Re-check after paywall
      final refreshed = await currentStatus(refreshPremium: true);
      return refreshed.canGenerate;
    }

    debugPrint('🚫 [GATE] Generation denied.');
    return false;
  }

  /// Consume quota or token after SUCCESSFUL generation.
  static Future<void> consumeQuotaOrToken() async {
    if (kDebugMode) {
      final devMode = await isDeveloperModeEnabled();
      if (devMode) {
        debugPrint('🔧 [DEV MODE] ACTIVE → No consumption.');
        await incrementTotalGenerationCount();
        return;
      }
    }

    final status = await currentStatus();

    // 1. Premium users use daily quota first
    if (status.isPremium && status.dailyCount < status.dailyLimit) {
      debugPrint(
        '💎 [GATE] Consuming DAILY quota: ${status.dailyCount + 1}/${status.dailyLimit}',
      );
      await incrementTodayPremiumCount();
    }
    // 2. Otherwise use tokens
    else if (status.tokensAvailable) {
      debugPrint(
        '🪙 [GATE] Consuming 1 TOKEN. Current Balance: ${status.tokenBalance}',
      );
      await CreditsVault.consume(1);
      await _syncTokenBalance();
    }

    await incrementTotalGenerationCount();
  }
}

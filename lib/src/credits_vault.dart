// lib/src/credits_vault.dart
//
// CreditsVault — simple consumable token store for Garden AI.
// Atomic ops & persistence with SharedPreferences.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditsVault {
  CreditsVault._();

  /// Storage keys (bump suffix for schema migration)
  static const String _kBalanceKey = 'garden_ai_tokens_balance_v1';

  /// Single-flight op chain to serialize mutations.
  static Future<void> _opChain = Future.value();

  /// Broadcast stream of balance changes.
  static final StreamController<int> _changesCtrl =
      StreamController<int>.broadcast();

  static Stream<int> get changes => _changesCtrl.stream;

  /// -------- Helpers --------
  static Future<SharedPreferences> _prefs() =>
      SharedPreferences.getInstance();

  static int _sanitize(int v) => v < 0 ? 0 : v;

  static Future<void> _emit(int v) async {
    if (!_changesCtrl.isClosed) {
      scheduleMicrotask(() {
        if (!_changesCtrl.isClosed) _changesCtrl.add(v);
      });
    }
  }

  /// -------- Public API --------

  /// Current token balance. Never negative.
  static Future<int> get() async {
    final sp = await _prefs();
    final v = sp.getInt(_kBalanceKey) ?? 0;
    return _sanitize(v);
  }

  /// Set absolute balance (clamped to >= 0). Emits change if modified.
  static Future<int> set(int value) {
    value = _sanitize(value);
    final completer = Completer<int>();
    _opChain = _opChain.then((_) async {
      final sp = await _prefs();
      final cur = sp.getInt(_kBalanceKey) ?? 0;
      if (cur != value) {
        await sp.setInt(_kBalanceKey, value);
        await _emit(value);
      }
      completer.complete(value);
    }).catchError((e, st) {
      if (!completer.isCompleted) completer.completeError(e, st);
    });
    return completer.future;
  }

  /// Add delta (positive to add, negative to subtract). Returns new balance.
  static Future<int> add(int delta) {
    final completer = Completer<int>();
    _opChain = _opChain.then((_) async {
      final sp = await _prefs();
      final cur = _sanitize(sp.getInt(_kBalanceKey) ?? 0);
      final next = _sanitize(cur + delta);
      if (next != cur) {
        await sp.setInt(_kBalanceKey, next);
        await _emit(next);
      }
      completer.complete(next);
    }).catchError((e, st) {
      if (!completer.isCompleted) completer.completeError(e, st);
    });
    return completer.future;
  }

  /// Can we consume [n] tokens right now? (fast check; not reserved)
  static Future<bool> canConsume(int n) async {
    if (n <= 0) return true;
    final cur = await get();
    return cur >= n;
  }

  /// Atomically consume [n] tokens if available.
  /// Returns true if success (and balance reduced), false otherwise.
  static Future<bool> consume(int n) {
    if (n <= 0) return Future.value(true);
    final completer = Completer<bool>();
    _opChain = _opChain.then((_) async {
      try {
        final sp = await _prefs();
        final cur = _sanitize(sp.getInt(_kBalanceKey) ?? 0);
        debugPrint('🏦 [VAULT] Attempting to consume $n. Current: $cur');
        if (cur >= n) {
          final next = cur - n;
          await sp.setInt(_kBalanceKey, next);
          await _emit(next);
          debugPrint('🏦 [VAULT] Consumption success. Next: $next');
          completer.complete(true);
        } else {
          debugPrint('🏦 [VAULT] Consumption failed (insufficient)');
          completer.complete(false);
        }
      } catch (e) {
        debugPrint('🏦 [VAULT] Consumption ERROR: $e');
        completer.complete(false);
      }
    }).catchError((e, st) {
      if (!completer.isCompleted) completer.completeError(e, st);
    });
    return completer.future;
  }

  /// Reset to zero.
  static Future<void> clear() async {
    await set(0);
  }

  /// Close stream (usually not needed; app lifetime).
  static Future<void> dispose() async {
    await _changesCtrl.close();
  }
}
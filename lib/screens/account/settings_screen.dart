import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_container.dart';
import '../../src/constant.dart';
import '../../src/credits_vault.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDevMode = false;

  @override
  void initState() {
    super.initState();
    _loadDevMode();
  }

  Future<void> _loadDevMode() async {
    final enabled = await isDeveloperModeEnabled();
    if (mounted) setState(() => _isDevMode = enabled);
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmSand,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.charcoal, size: 18),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Studio Settings",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.mossGreen,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                ],
              ).animate().fadeIn(),
              const SizedBox(height: 20),

              // Account Status
              Text("ACCOUNT", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 10),
              ValueListenableBuilder<bool>(
                valueListenable: premiumListenable,
                builder: (context, isPro, _) {
                  return GlassContainer(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            isPro ? Icons.verified_rounded : Icons.account_circle_outlined,
                            color: isPro ? Colors.amber : AppTheme.mossGreen,
                          ),
                          title: Text(isPro ? "Premium Member" : "Free Member"),
                          subtitle: Text(isPro ? "Unlimited access active" : "Upgrade for full potential"),
                          trailing: isPro
                              ? null
                              : CupertinoButton(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  color: AppTheme.mossGreen,
                                  borderRadius: BorderRadius.circular(8),
                                  onPressed: () => manageOrUpgrade(context),
                                  child: const Text("Upgrade", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.generating_tokens_outlined, color: AppTheme.mossGreen),
                          title: const Text("Available Tokens"),
                          trailing: ValueListenableBuilder<int>(
                            valueListenable: tokenBalanceListenable,
                            builder: (context, balance, _) => Text(
                              "$balance",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        FutureBuilder<int>(
                          future: getTotalGenerationCount(),
                          builder: (context, snapshot) {
                            return ListTile(
                              leading: const Icon(Icons.auto_awesome_rounded, color: AppTheme.mossGreen),
                              title: const Text("Total Generations"),
                              trailing: Text(
                                "${snapshot.data ?? 0}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 50.ms).slideX();
                },
              ),

              const SizedBox(height: 24),

              // Support & Links
              Text("SUPPORT", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 10),
              GlassContainer(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.restore_rounded, color: AppTheme.mossGreen),
                      title: const Text("Restore Purchases"),
                      onTap: () => restorePurchases(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.mossGreen),
                      title: const Text("Privacy Policy"),
                      onTap: () => _launchURL(kPrivacyPolicyUrl),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined, color: AppTheme.mossGreen),
                      title: const Text("Terms of Use"),
                      onTap: () => _launchURL(kTermsOfUseUrl),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(),

              const SizedBox(height: 24),

              // Debug / Developer Mode (Hidden in Release)
              if (!kReleaseMode)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("DEVELOPER", style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 10),
                    GlassContainer(
                      color: Colors.purple.withValues(alpha: 0.1),
                      child: SwitchListTile(
                        title: const Text("Developer Mode"),
                        subtitle: const Text("Bypass paywall for testing"),
                        value: _isDevMode,
                        activeColor: Colors.purple,
                        onChanged: (v) async {
                          await setDeveloperMode(v);
                          setState(() => _isDevMode = v);
                        },
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(),
                    const SizedBox(height: 24),
                  ],
                ),

              // Data Management
              Text("DATA MANAGEMENT", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 10),
              GlassContainer(
                color: Colors.redAccent.withValues(alpha: 0.1),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                  title: const Text("Reset All Garden Data", style: TextStyle(color: Colors.redAccent)),
                  onTap: () async {
                    final storage = context.read<StorageService>();
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.charcoal,
                        title: const Text("Reset Data?"),
                        content: const Text("This will delete all your saved gardens and reset tokens. This action cannot be undone."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await storage.clearAll();
                      await clearAllData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All data has been cleared.")));
                      }
                    }
                  },
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  "Garden AI v1.0.0",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

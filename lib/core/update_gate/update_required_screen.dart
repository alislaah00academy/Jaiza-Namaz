import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';

const _androidPackage = 'com.alislaah.jaiza';
const _iosBundleId = 'com.alislaah.jaiza';

/// Blocking screen shown app-wide when `min_supported_build` (Remote
/// Config) is higher than this install's build number (17 §7). Sits above
/// the router in [JaizaNamazApp]'s `builder`, so there is no way around it.
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key});

  Uri get _storeUri {
    if (kIsWeb) return Uri.base;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Uri.parse('https://apps.apple.com/app/$_iosBundleId');
    }
    return Uri.parse(
      'https://play.google.com/store/apps/details?id=$_androidPackage',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = Theme.of(context).colorScheme;
    return Material(
      color: c.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.system_update_rounded, size: 64, color: c.primary),
                const SizedBox(height: 24),
                Text(
                  l.updateRequiredTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l.updateRequiredBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => launchUrl(
                    _storeUri,
                    mode: kIsWeb
                        ? LaunchMode.platformDefault
                        : LaunchMode.externalApplication,
                  ),
                  child: Text(l.updateRequiredButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

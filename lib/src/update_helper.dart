import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:satisfied_version/satisfied_version.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'utils.dart';

// TODO: Make this plugin works on more platforms. It currently depend on in_app_review
class UpdateHelper {
  static bool _isDebug = false;

  static Future<void> initial({
    /// Current context.
    required BuildContext context,

    /// Configuration for each platform.
    required UpdateConfig updateConfig,

    /// Force update on this version. The user can't close this dialog until it's updated.
    bool forceUpdate = false,

    /// Use `satisfied_version` package to compare with current version to force update.
    ///
    /// Ex: ["<=1.0.0"] means the app have to update if current version <= 1.0.0
    List<String> bannedVersions = const [],

    /// Title of the dialog.
    String title = 'Update',

    /// Content of the dialog (No force).
    String content = 'New version is available!\n\n'
        'Current version: %currentVersion\n'
        'Latest version: %latestVersion\n\n'
        'Do you want to update?',

    /// OK button text
    String okButtonText = 'OK',

    /// Later button text
    String laterButtonText = 'Later',

    /// Content of the dialog in force mode.
    String forceUpdateContent = 'New version is available!\n\n'
        'Current version: %currentVersion\n'
        'Latest version: %latestVersion\n\n'
        'You have to update to continue using the app!',

    /// Show changelogs if `changelogs` is not empty.
    ///
    /// Changelogs:
    /// - Changelog 1
    /// - Changelog 2
    List<String> changelogs = const [],

    /// Changelogs text: 'Changelogs' -> 'Changelogs:'
    String changelogsText = 'Changelogs',

    /// Print debuglog.
    bool isDebug = false,
  }) async {
    _isDebug = isDebug;

    UpdatePlatformConfig? updatePlatformConfig;
    if (UniversalPlatform.isAndroid) {
      updatePlatformConfig = updateConfig.android;
    } else if (UniversalPlatform.isIOS) {
      updatePlatformConfig = updateConfig.ios;
    } else if (UniversalPlatform.isWeb) {
      updatePlatformConfig = updateConfig.web;
    } else if (UniversalPlatform.isWindows) {
      updatePlatformConfig = updateConfig.windows;
    } else if (UniversalPlatform.isLinux) {
      updatePlatformConfig = updateConfig.linux;
    } else if (UniversalPlatform.isMacOS) {
      updatePlatformConfig = updateConfig.macos;
    }

    updatePlatformConfig ??= updateConfig.defaultConfig;

    if (updatePlatformConfig == null ||
        updatePlatformConfig.latestVersion == null) {
      _print('Config from this platform is null');
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();

    final currentVersion = packageInfo.version;
    _print('current version: $currentVersion');

    if (updatePlatformConfig.latestVersion!.compareTo(currentVersion) <= 0) {
      _print('Current version is up to date');
      return;
    }

    if (!forceUpdate && SatisfiedVersion.list(currentVersion, bannedVersions)) {
      _print('Current version have to force to update');
      forceUpdate = true;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        content: WillPopScope(
          onWillPop: () async => forceUpdate ? false : true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Divider(),
              Text(
                (forceUpdate ? forceUpdateContent : content)
                    .replaceFirst('%currentVersion', currentVersion)
                    .replaceFirst(
                        '%latestVersion', updatePlatformConfig!.latestVersion!),
                style: const TextStyle(fontSize: 15),
              ),
              if (changelogs.isNotEmpty) ...[
                const Divider(),
                Text(
                  '$changelogsText:',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 4),
              ],
              if (changelogs.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final text in changelogs) ...[
                      Text(
                        '- $text',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                    ]
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    child: Text(okButtonText),
                    onPressed: () async {
                      if (UniversalPlatform.isAndroid ||
                          UniversalPlatform.isIOS ||
                          UniversalPlatform.isMacOS) {
                        InAppReview.instance.openStoreListing(
                            appStoreId: packageInfo.packageName);
                      } else {
                        if (updatePlatformConfig!.storeUrl != null &&
                            await canLaunchUrlString(
                                updatePlatformConfig.storeUrl!)) {
                          await launchUrlString(
                            updatePlatformConfig.storeUrl!,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }
                    },
                  ),
                  if (!forceUpdate)
                    MaterialButton(
                      child: Text(laterButtonText),
                      onPressed: () => Navigator.pop(context),
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _print(Object? object) =>
      // ignore: avoid_print
      _isDebug ? print('[Update Helper] $object') : null;
}

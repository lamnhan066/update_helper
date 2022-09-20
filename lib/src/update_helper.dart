import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
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

    /// Title of the dialog.
    String title = 'Update Information',

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

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(
              (forceUpdate ? forceUpdateContent : content)
                  .replaceFirst('%currentVersion', currentVersion)
                  .replaceFirst(
                      '%latestVersion', updatePlatformConfig!.latestVersion!),
              style: const TextStyle(fontSize: 16),
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
    );
  }

  static void _print(Object? object) =>
      // ignore: avoid_print
      _isDebug ? print('[Update Helper] $object') : null;
}

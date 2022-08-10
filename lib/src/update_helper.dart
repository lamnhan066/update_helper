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
    required BuildContext context,
    required UpdateConfig latestConfig,
    String title = 'Update Information',
    String content = 'New version is available!\n\n'
        'Current version: %currentVersion\n'
        'Latest version: %latestVersion\n\n'
        'Do you want to update?',
    String okButtonText = 'OK',
    String laterButtonText = 'Later',
    bool forceUpdate = false,
    String forceUpdateContent = 'New version is available!\n\n'
        'Current version: %currentVersion\n'
        'Latest version: %latestVersion\n\n'
        'You have to update to continue using the app!',
    bool isDebug = false,
  }) async {
    _isDebug = isDebug;

    UpdatePlatformConfig? updateConfig;
    if (UniversalPlatform.isAndroid) {
      updateConfig = latestConfig.android;
    } else if (UniversalPlatform.isIOS) {
      updateConfig = latestConfig.ios;
    } else if (UniversalPlatform.isWeb) {
      updateConfig = latestConfig.web;
    } else if (UniversalPlatform.isWindows) {
      updateConfig = latestConfig.windows;
    } else if (UniversalPlatform.isLinux) {
      updateConfig = latestConfig.linux;
    } else if (UniversalPlatform.isMacOS) {
      updateConfig = latestConfig.macos;
    }

    if (updateConfig == null || updateConfig.latestVersion == null) {
      _print('Config from this platform is null');
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();

    final currentVersion = packageInfo.version;
    _print('current version: $currentVersion');

    if (updateConfig.latestVersion!.compareTo(currentVersion) <= 0) {
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
                  .replaceFirst('%latestVersion', updateConfig!.latestVersion!),
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
                        UniversalPlatform.isIOS) {
                      InAppReview.instance.openStoreListing(
                          appStoreId: packageInfo.packageName);
                    } else {
                      if (updateConfig!.storeUrl != null &&
                          await canLaunchUrlString(updateConfig.storeUrl!)) {
                        await launchUrlString(
                          updateConfig.storeUrl!,
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

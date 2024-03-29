import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:universal_platform/universal_platform.dart';
import 'package:update_helper/src/utils/reload_web/reload_web.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> openStoreImpl(
  /// Package name.
  String packageName,

  /// Custom store URL.
  String? storeUrl,

  /// On print debug log.
  Function(String) onPrint,
) async {
  try {
    if (UniversalPlatform.isAndroid) {
      try {
        onPrint('Android try to launch: market://details?id=$packageName');
        await launchUrlString(
          'market://details?id=$packageName',
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        try {
          onPrint(
              'Android try to launch: https://play.google.com/store/apps/details?id=$packageName');
          await launchUrlString(
            'https://play.google.com/store/apps/details?id=$packageName',
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          onPrint(
              'Cannot get the Store URL on iOS or MacOS, try to launch: $storeUrl');
          if (storeUrl != null && await canLaunchUrlString(storeUrl)) {
            await launchUrlString(
              storeUrl,
              mode: LaunchMode.externalApplication,
            );
          } else {
            rethrow;
          }
        }
      }

      return;
    }

    if (UniversalPlatform.isIOS || UniversalPlatform.isMacOS) {
      try {
        final response = await http.get((Uri.parse(
            'http://itunes.apple.com/lookup?bundleId=$packageName')));
        final json = jsonDecode(response.body);

        onPrint('iOS or MacOS get json from bundleId: $json');
        onPrint('iOS or MacOS get trackId: ${json['results'][0]['trackId']}');

        await launchUrlString(
          'https://apps.apple.com/app/id${json['results'][0]['trackId']}',
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        onPrint(
            'Cannot get the Store URL on iOS or MacOS, try to launch: $storeUrl');
        if (storeUrl != null && await canLaunchUrlString(storeUrl)) {
          await launchUrlString(
            storeUrl,
            mode: LaunchMode.externalApplication,
          );
        } else {
          rethrow;
        }
      }

      return;
    }

    if (UniversalPlatform.isWeb) {
      reloadWeb();

      return;
    }

    if (storeUrl != null && await canLaunchUrlString(storeUrl)) {
      onPrint('Other platforms, try to launch: $storeUrl');
      await launchUrlString(
        storeUrl,
        mode: LaunchMode.externalApplication,
      );
    }
  } catch (e) {
    onPrint('Cannot open the Store automatically!');

    rethrow;
  }
}

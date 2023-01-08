import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:satisfied_version/satisfied_version.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'utils.dart';

class UpdateHelper {
  static final instance = UpdateHelper._();

  UpdateHelper._();

  bool _isDebug = false;

  @visibleForTesting
  String packageName = '';

  Future<void> initial({
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

    /// Only show the update dialog when the current version is banned or
    /// [forceUpdate] is `true`.
    bool onlyShowDialogWhenBanned = false,

    /// Title of the dialog.
    String title = 'Update',

    /// Content of the dialog (No force).
    ///
    /// `%currentVersion` will be replaced with the current version
    /// `%latestVersion` wull be replaced with the latest version
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

    /// Show this text if the Store cannot be opened
    ///
    /// `%error` will be replaced with the error log.
    String failToOpenStoreError = 'Got an error when trying to open the Store, '
        'please update the app manually. '
        '\nSorry for the inconvenience.\n(Logs: %error)',

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

    if (!onlyShowDialogWhenBanned ||
        (onlyShowDialogWhenBanned && forceUpdate)) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => _StatefulAlert(
            forceUpdate: forceUpdate,
            title: title,
            content: content,
            forceUpdateContent: forceUpdateContent,
            changelogs: changelogs,
            changelogsText: changelogsText,
            okButtonText: okButtonText,
            laterButtonText: laterButtonText,
            updatePlatformConfig: updatePlatformConfig!,
            currentVersion: currentVersion,
            packageInfo: packageInfo,
            failToOpenStoreError: failToOpenStoreError),
      );
    }
  }

  void _print(Object? object) =>
      // ignore: avoid_print
      _isDebug ? print('[Update Helper] $object') : null;
}

class _StatefulAlert extends StatefulWidget {
  const _StatefulAlert({
    Key? key,
    required this.forceUpdate,
    required this.title,
    required this.content,
    required this.forceUpdateContent,
    required this.changelogs,
    required this.changelogsText,
    required this.okButtonText,
    required this.laterButtonText,
    required this.updatePlatformConfig,
    required this.currentVersion,
    required this.packageInfo,
    required this.failToOpenStoreError,
  }) : super(key: key);

  final bool forceUpdate;
  final String title;
  final String content;
  final String forceUpdateContent;
  final List<String> changelogs;
  final String changelogsText;
  final String okButtonText;
  final String laterButtonText;
  final UpdatePlatformConfig updatePlatformConfig;
  final String currentVersion;
  final PackageInfo packageInfo;
  final String failToOpenStoreError;

  @override
  State<_StatefulAlert> createState() => _StatefulAlertState();
}

class _StatefulAlertState extends State<_StatefulAlert> {
  String errorText = '';
  final updateHelper = UpdateHelper.instance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      content: WillPopScope(
        onWillPop: () async => widget.forceUpdate ? false : true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            Text(
              (widget.forceUpdate ? widget.forceUpdateContent : widget.content)
                  .replaceAll('%currentVersion', widget.currentVersion)
                  .replaceAll('%latestVersion',
                      widget.updatePlatformConfig.latestVersion!),
              style: const TextStyle(fontSize: 15),
            ),
            if (widget.changelogs.isNotEmpty) ...[
              const Divider(),
              Text(
                '${widget.changelogsText}:',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 4),
            ],
            if (widget.changelogs.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final text in widget.changelogs) ...[
                    Text(
                      '- $text',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                  ]
                ],
              ),
            const SizedBox(height: 20),
            if (errorText.isNotEmpty)
              Text(
                widget.failToOpenStoreError.replaceAll('%error', errorText),
                style: const TextStyle(fontSize: 13, color: Colors.red),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                  child: Text(widget.okButtonText),
                  onPressed: () async {
                    String packageName = widget.packageInfo.packageName;

                    // For testing
                    if (updateHelper._isDebug &&
                        updateHelper.packageName != '') {
                      packageName = updateHelper.packageName;
                    }

                    try {
                      if (UniversalPlatform.isAndroid) {
                        try {
                          updateHelper._print(
                              'Android try to launch: market://details?id=$packageName');
                          await launchUrlString(
                            'market://details?id=$packageName',
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (_) {
                          updateHelper._print(
                              'Android try to launch: https://play.google.com/store/apps/details?id=$packageName');
                          await launchUrlString(
                            'https://play.google.com/store/apps/details?id=$packageName',
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }
                      if (UniversalPlatform.isIOS ||
                          UniversalPlatform.isMacOS) {
                        final response = await http.get((Uri.parse(
                            'http://itunes.apple.com/lookup?bundleId=$packageName')));
                        final json = jsonDecode(response.body);

                        updateHelper
                            ._print('iOS get json from bundleId: $json');
                        updateHelper._print(
                            'iOS get trackId: ${json['results'][0]['trackId']}');

                        launchUrlString(
                          'https://apps.apple.com/app/id${json['results'][0]['trackId']}',
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        if (widget.updatePlatformConfig.storeUrl != null &&
                            await canLaunchUrlString(
                                widget.updatePlatformConfig.storeUrl!)) {
                          updateHelper._print(
                              'Other platforms, try to launch: ${widget.updatePlatformConfig.storeUrl}');
                          await launchUrlString(
                            widget.updatePlatformConfig.storeUrl!,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }
                    } catch (e) {
                      updateHelper
                          ._print('Cannot open the Store automatically!');
                      setState(() {
                        errorText = e.toString();
                      });
                    }
                  },
                ),
                if (!widget.forceUpdate)
                  MaterialButton(
                    child: Text(widget.laterButtonText),
                    onPressed: () => Navigator.pop(context),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:satisfied_version/satisfied_version.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:update_helper/src/utils/open_store.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'models/stateful_alert.dart';
part 'models/update_platform_config.dart';

class UpdateHelper extends WidgetsBindingObserver {
  /// Create instance for UpdateHelper
  static final instance = UpdateHelper._();

  UpdateHelper._();

  /// Is update available. This value is useful when you set the [onlyShowDialogWhenBanned]
  /// to `true`.
  bool get isAvailable => _isAvailable;
  bool _isAvailable = false;

  /// Is force update ([forceUpdate] is `true` or the current version is banned)
  bool get isForceUpdate => _isForceUpdate;
  bool _isForceUpdate = false;

  /// This is internal variable. Only use for testing.
  @visibleForTesting
  String packageName = '';

  // If the [_context] is non-null => others will also non-null.
  BuildContext? _context;
  late final UpdateConfig _updateConfig;
  late final bool _checkWhenResume;
  late final bool _forceUpdate;
  late final List<String> _bannedVersions;
  late final bool _onlyShowDialogWhenBanned;
  late final String _title;
  late final String _content;
  late final String _okButtonText;
  late final String _laterButtonText;
  late final String _forceUpdateContent;
  late final List<String> _changelogs;
  late final String _changelogsText;
  late final String _failToOpenStoreError;
  late final bool _isDebug;

  /// Intitalize the package.
  ///
  /// This
  Future<void> initial({
    /// Current context.
    required BuildContext context,

    /// Configuration for each platform.
    required UpdateConfig updateConfig,

    /// Re-check for update when the app is resumed.
    bool checkWhenResume = true,

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
    _context = context;
    _updateConfig = updateConfig;
    _checkWhenResume = checkWhenResume;
    _forceUpdate = forceUpdate;
    _bannedVersions = bannedVersions;
    _onlyShowDialogWhenBanned = onlyShowDialogWhenBanned;
    _title = title;
    _content = content;
    _okButtonText = okButtonText;
    _laterButtonText = laterButtonText;
    _forceUpdateContent = forceUpdateContent;
    _changelogs = changelogs;
    _changelogsText = changelogsText;
    _failToOpenStoreError = failToOpenStoreError;
    _isDebug = isDebug;

    WidgetsBinding.instance.addObserver(this);

    await _initial();
  }

  Future<void> _initial() async {
    UpdatePlatformConfig? updatePlatformConfig;
    if (UniversalPlatform.isAndroid) {
      updatePlatformConfig = _updateConfig.android;
    } else if (UniversalPlatform.isIOS) {
      updatePlatformConfig = _updateConfig.ios;
    } else if (UniversalPlatform.isWeb) {
      updatePlatformConfig = _updateConfig.web;
    } else if (UniversalPlatform.isWindows) {
      updatePlatformConfig = _updateConfig.windows;
    } else if (UniversalPlatform.isLinux) {
      updatePlatformConfig = _updateConfig.linux;
    } else if (UniversalPlatform.isMacOS) {
      updatePlatformConfig = _updateConfig.macos;
    }

    updatePlatformConfig ??= _updateConfig.defaultConfig;

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

    // Update available
    _isAvailable = true;

    if (!_forceUpdate &&
        SatisfiedVersion.list(currentVersion, _bannedVersions)) {
      _print('Current version have to force to update');
      _forceUpdate = true;
    }

    // Current version needs to force update
    if (_forceUpdate) {
      _isForceUpdate = true;
    }

    if (!_onlyShowDialogWhenBanned ||
        (_onlyShowDialogWhenBanned && _forceUpdate)) {
      // ignore: use_build_context_synchronously
      await showDialog(
        context: _context!,
        barrierDismissible: false,
        builder: (BuildContext context) => _StatefulAlert(
            forceUpdate: _forceUpdate,
            title: _title,
            content: _content,
            forceUpdateContent: _forceUpdateContent,
            changelogs: _changelogs,
            changelogsText: _changelogsText,
            okButtonText: _okButtonText,
            laterButtonText: _laterButtonText,
            updatePlatformConfig: updatePlatformConfig!,
            currentVersion: currentVersion,
            packageInfo: packageInfo,
            failToOpenStoreError: _failToOpenStoreError),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_context != null && _checkWhenResume) {
          _initial();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  void _print(Object? object) =>
      // ignore: avoid_print
      _isDebug ? debugPrint('[Update Helper] $object') : null;

  /// Open the store
  static Future<void> openStore({
    /// Use this Url if any error occurs
    String? fallbackUrl,

    /// Print debug log
    bool debugLog = false,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();

    try {
      await openStoreImpl(
        packageInfo.packageName,
        fallbackUrl,
        (progress) {
          if (debugLog) debugPrint('[UpdateHelper.openStore] $progress');
        },
      );
    } catch (_) {
      if (fallbackUrl != null && await canLaunchUrlString(fallbackUrl)) {
        await launchUrlString(fallbackUrl);
      }
    }
  }
}

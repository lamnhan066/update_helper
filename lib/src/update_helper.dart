import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:satisfied_version/satisfied_version.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:update_helper/src/models/dialog_config.dart';
import 'package:update_helper/src/utils/open_store.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'models/update_platform_config.dart';
part 'widgets/default_dialog.dart';

class UpdateHelper {
  /// Create instance for UpdateHelper.
  static final instance = UpdateHelper._();

  UpdateHelper._();

  bool _isDebug = false;

  /// Is update available. This value is useful when you set the [onlyShowDialogWhenBanned]
  /// to `true`.
  bool get isAvailable => _isAvailable;
  bool _isAvailable = false;

  /// Is force update ([forceUpdate] is `true` or the current version is banned).
  bool get isForceUpdate => _isForceUpdate;
  bool _isForceUpdate = false;

  /// This is internal variable. Only use for testing.
  @visibleForTesting
  String packageName = '';

  /// Intitalize the package.
  Future<void> initial({
    /// Current context.
    required BuildContext context,

    /// Configuration for each platform.
    required UpdateConfig updateConfig,

    /// Force update on this version. The user can't close this dialog until it's updated.
    bool forceUpdate = false,

    /// Use `satisfied_version` package to compare with current version to force update.
    ///
    /// Ex: ["<=1.0.0"] means the app have to update if current version <= 1.0.0.
    List<String> bannedVersions = const [],

    /// Only show the update dialog when the current version is banned or
    /// [forceUpdate] is `true`.
    bool onlyShowDialogWhenBanned = false,

    /// Title of the dialog.
    String title = 'Update',

    /// Content of the dialog (No force).
    ///
    /// `%currentVersion` will be replaced with the current version.
    /// `%latestVersion` will be replaced with the latest version.
    String content = 'A new version is available!\n\n'
        'v%currentVersion → v%latestVersion\n\n'
        'Would you like to update?',

    /// OK button text.
    String okButtonText = 'OK',

    /// Later button text.
    String laterButtonText = 'Later',

    /// Content of the dialog in force mode.
    String forceUpdateContent = 'A new version is available!\n\n'
        'v%currentVersion → v%latestVersion\n\n'
        'Please update to continue using the app.',

    /// Show changelogs if `changelogs` is not empty.
    ///
    /// Changelogs:
    /// - Changelog 1
    /// - Changelog 2
    List<String> changelogs = const [],

    /// Changelogs text: 'Changelogs' -> 'Changelogs:'
    String changelogsText = 'Changelogs',

    /// Show this text if the Store cannot be opened.
    ///
    /// `%error` will be replaced with the error log.
    String failToOpenStoreError = 'Got an error when trying to open the Store, '
        'please update the app manually. '
        '\nSorry for the inconvenience.\n(Logs: %error)',

    /// Create your own dialog widget.
    ///
    /// The [DefaultUpdateHelperDialog] is used by default.
    Widget Function(BuildContext context, DialogConfig config)? dialogBuilder,

    /// Print debuglog.
    bool isDebug = false,
  }) async {
    _isDebug = isDebug;

    UpdatePlatformConfig config =
        updateConfig.defaultConfig ?? UpdatePlatformConfig();
    if (UniversalPlatform.isAndroid) {
      config = config.copyWith(updateConfig.android);
    } else if (UniversalPlatform.isMacOS) {
      config = config.copyWith(updateConfig.macos);
    } else if (UniversalPlatform.isIOS) {
      config = config.copyWith(updateConfig.ios);
    } else if (UniversalPlatform.isWeb) {
      config = config.copyWith(updateConfig.web);
    } else if (UniversalPlatform.isWindows) {
      config = config.copyWith(updateConfig.windows);
    } else if (UniversalPlatform.isLinux) {
      config = config.copyWith(updateConfig.linux);
    } else if (UniversalPlatform.isFuchsia) {
      config = config.copyWith(updateConfig.fuchsia);
    }

    if (config.latestVersion == null) {
      _print('Config from this platform is null');
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();

    final currentVersion = packageInfo.version;
    _print('current version: $currentVersion');

    if (config.latestVersion!.satisfiedWith('<=$currentVersion')) {
      _print('Current version is up to date');
      return;
    }

    // Update available.
    _isAvailable = true;

    if (!forceUpdate && SatisfiedVersion.list(currentVersion, bannedVersions)) {
      _print('Current version have to force to update');
      forceUpdate = true;
    }

    // Current version needs to force update.
    if (forceUpdate) {
      _isForceUpdate = true;
    }

    if ((!onlyShowDialogWhenBanned ||
        (onlyShowDialogWhenBanned && forceUpdate))) {
      final dialogConfig = DialogConfig(
        forceUpdate: forceUpdate,
        title: title,
        content: content,
        forceUpdateContent: forceUpdateContent,
        changelogsText: changelogsText,
        changelogs: changelogs,
        okButtonText: okButtonText,
        laterButtonText: laterButtonText,
        updatePlatformConfig: config,
        currentVersion: currentVersion,
        packageInfo: packageInfo,
        failToOpenStoreError: failToOpenStoreError,
        onOkPressed: () async {
          String packageName = packageInfo.packageName;

          // For testing
          if (_isDebug && packageName != '') {
            packageName = packageName;
          }

          try {
            await openStoreImpl(
              packageName,
              config.storeUrl,
              (debugLog) {
                _print(debugLog);
              },
            );
          } catch (e) {
            return e.toString();
          }
          return null;
        },
        onLaterPressed: () => Navigator.pop(context),
      );

      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              dialogBuilder?.call(context, dialogConfig) ??
              DefaultUpdateHelperDialog(config: dialogConfig),
        );
      }
    }
  }

  void _print(Object? object) =>
      // ignore: avoid_print
      _isDebug ? debugPrint('[Update Helper] $object') : null;

  /// Open the store.
  static Future<void> openStore({
    String? packageName,

    /// Use this Url if any error occurs.
    String? fallbackUrl,

    /// Print debug log.
    bool debugLog = false,
  }) async {
    try {
      packageName ??= (await PackageInfo.fromPlatform()).packageName;
      await openStoreImpl(
        packageName,
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

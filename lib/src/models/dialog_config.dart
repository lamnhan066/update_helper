import 'package:package_info_plus/package_info_plus.dart';

import '../update_helper.dart';

class DialogConfig {
  /// Config of the dialog.
  const DialogConfig({
    required this.forceUpdate,
    required this.title,
    required this.content,
    required this.forceUpdateContent,
    required this.changelogsText,
    required this.changelogs,
    required this.okButtonText,
    required this.laterButtonText,
    required this.updatePlatformConfig,
    required this.currentVersion,
    required this.packageInfo,
    required this.failToOpenStoreError,
    required this.onOkPressed,
  });

  /// Is forced update.
  final bool forceUpdate;

  /// Title of the dialog.
  final String title;

  /// Content of the dialog.
  final String content;

  /// Content of the forced update dialog.
  final String forceUpdateContent;

  /// List of changelogs.
  final List<String> changelogs;

  /// Title of the changelogs/
  final String changelogsText;

  /// Text of the ok button.
  final String okButtonText;

  /// Text of the later button.
  final String laterButtonText;

  /// Config of the update that you're passed.
  final UpdatePlatformConfig updatePlatformConfig;

  /// Current version of the app (in `major.minor.patch` format).
  final String currentVersion;

  /// The current package_info instance.
  final PackageInfo packageInfo;

  /// Show this error text when the store cannot be opened.
  final String failToOpenStoreError;

  /// Pass this callback to the `OK` button.
  ///
  /// If there is no issue, the string will be `null`. Otherwise, an error text
  /// is returned.
  final Future<String?> Function() onOkPressed;
}

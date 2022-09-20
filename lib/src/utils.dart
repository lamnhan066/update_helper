part of 'update_helper.dart';

class UpdatePlatformConfig {
  /// This value does not need for Android and iOS.
  ///
  /// The plugin will use url_laucher to launch this URL on other platforms.
  final String? storeUrl;

  /// The latest version of the app on this platform.
  final String? latestVersion;

  UpdatePlatformConfig({this.storeUrl, this.latestVersion});
}

/// Update configuration for each platform
class UpdateConfig {
  /// Update configuration for android
  final UpdatePlatformConfig? android;

  /// Update configuration for ios
  final UpdatePlatformConfig? ios;

  /// Update configuration for web
  final UpdatePlatformConfig? web;

  /// Update configuration for windows
  final UpdatePlatformConfig? windows;

  /// Update configuration for linux
  final UpdatePlatformConfig? linux;

  /// Update configuration for macos
  final UpdatePlatformConfig? macos;

  UpdateConfig({
    this.android,
    this.ios,
    this.web,
    this.windows,
    this.linux,
    this.macos,
  });
}

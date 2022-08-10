part of 'update_helper.dart';

class UpdatePlatformConfig {
  /// This value dont need for Android and iOS.
  ///
  /// The plugin will use url_laucher to lauch this URL on other platforms.
  final String? storeUrl;

  /// Latest version of the app of this platform.
  final String? latestVersion;

  UpdatePlatformConfig({this.storeUrl, this.latestVersion});
}

class UpdateConfig {
  final UpdatePlatformConfig? android;
  final UpdatePlatformConfig? ios;
  final UpdatePlatformConfig? web;
  final UpdatePlatformConfig? windows;
  final UpdatePlatformConfig? linux;
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

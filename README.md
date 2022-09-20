# Update Helper

Help you easier to control the update dialog. It also supports the feature that forces the app to update to continue using.

## Usage

``` dart
final latestVersion = '1.0.0';
final bannedVersions = ['0.8.0','0.9.0'];
final currentVersion = '0.9.0';

await UpdateHelper.initial(
    context: context,
    updateConfig: UpdateConfig(
    android: UpdatePlatformConfig(
        latestVersion: latestVersion,
    ),
    ),
    title: 'Cập Nhật',
    content: 'Đã có phiên bản cập nhật mới!\n\n'
        'Phiên bản hiện tại: %currentVersion\n'
        'Phiên bản mới: %latestVersion\n\n'
        'Bạn có muốn cập nhật không?',
    forceUpdate: bannedVersions.contains(currentVersion),
    forceUpdateContent: 'Đã có phiên bản cập nhật mới!\n\n'
        'Phiên bản hiện tại: %currentVersion\n'
        'Phiên bản mới: %latestVersion\n\n'
        'Bạn cần cập nhật để tiếp tục sử dụng',
);
```

You can use [satisfied_version](https://pub.dev/packages/satisfied_version) plugin to easier to control banned versions. For example:

``` dart
final latestVersion = '1.0.0';
final bannedVersions = ['<=0.9.0'];
final currentVersion = '0.9.0';

await UpdateHelper.initial(
    context: context,
    updateConfig: UpdateConfig(
    android: UpdatePlatformConfig(
        latestVersion: latestVersion,
    ),
    ),
    title: 'Cập Nhật',
    content: 'Đã có phiên bản cập nhật mới!\n\n'
        'Phiên bản hiện tại: %currentVersion\n'
        'Phiên bản mới: %latestVersion\n\n'
        'Bạn có muốn cập nhật không?',
    forceUpdate: currentVersion.isSatisfiedVersion(bannedVersions),
    forceUpdateContent: 'Đã có phiên bản cập nhật mới!\n\n'
        'Phiên bản hiện tại: %currentVersion\n'
        'Phiên bản mới: %latestVersion\n\n'
        'Bạn cần cập nhật để tiếp tục sử dụng',
);
```

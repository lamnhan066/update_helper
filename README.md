# Update Helper

Help you easier to control the update dialog. It also supports the feature that forces the app to update to continue using.

Screenshots (Left/Above: don't force to update, Right/Below: force to update and users cannot close the dialog):

<img src="https://raw.githubusercontent.com/vursin/update_helper/main/images/noforce.png" width="256"/>
<img src="https://raw.githubusercontent.com/vursin/update_helper/main/images/force.png" width="256"/>

## Usage

### Simple Way

``` dart
UpdateHelper.initial(
  context: context,
  updateConfig: UpdateConfig(
    defaultConfig: UpdatePlatformConfig(latestVersion: '3.0.0'),
  ),
  // forceUpdate: true, // Add this line if you want users to be forced to update
);
```

### Advanced

``` dart
final latestVersion = '1.0.0';
final forceUpdate = false;
final bannedVersions = ['<=0.9.0']; // <-------
final currentVersion = '0.9.0';

await UpdateHelper.initial(
    context: context,
    updateConfig: UpdateConfig(
        defaultConfig: UpdatePlatformConfig(latestVersion: latestVersion),
        android: UpdatePlatformConfig(latestVersion: latestVersion)
    ),
    title: 'Cập Nhật',
    content: 'Đã có phiên bản cập nhật mới!\n\n'
        'Phiên bản hiện tại: %currentVersion\n'
        'Phiên bản mới: %latestVersion\n\n'
        'Bạn có muốn cập nhật không?',
    forceUpdate: forceUpdate,
    bannedVersions: bannedVersions, // <--------
    forceUpdateContent: 'Đã có phiên bản cập nhật mới!\n\n'
        'Phiên bản hiện tại: %currentVersion\n'
        'Phiên bản mới: %latestVersion\n\n'
        'Bạn cần cập nhật để tiếp tục sử dụng',
    changelogs: [
        'Bugs fix and improve performances',
        'New feature: Add update dialog',
    ],
);
```

**NOTE:**

- The plugin will replace `%currentVersion` and `%latestVersion` with it's real version.
- You can use only `forceUpdate` or `bannedVersions` because `forceUpdate` will be `true` if the current version is satisfied with `bannedVersions`.
- You can read more about how to use `bannedVersions` on [satisfied_version](https://pub.dev/packages/satisfied_version) plugin.
- 
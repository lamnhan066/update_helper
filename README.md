# Update Helper

Help you easier to control the update dialog. It also supports the feature that forces the app to update to continue using.

Screenshots (Left/Above: don't force to update, Right/Below: force to update and users cannot close the dialog):

<img src="https://raw.githubusercontent.com/vursin/update_helper/main/images/noforce.png" width="256"/>
<img src="https://raw.githubusercontent.com/vursin/update_helper/main/images/force.png" width="256"/>

## Usage

**Version must be in format `major.minor.patch`**

### Simple Way

``` dart
final updateHelper = UpdateHelper.instance;
updateHelper.initial(
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
final bannedVersions = ['<=0.9.0']; // <-------

final updateHelper = UpdateHelper.instance;

updateHelper.initial(
    context: context,
    updateConfig: UpdateConfig(
        defaultConfig: UpdatePlatformConfig(latestVersion: latestVersion),
    ),
    title: 'Cập Nhật',
    content: 'Đã có phiên bản cập nhật mới!\n\n'
        'Phiên bản hiện tại: %currentVersion\n'
        'Phiên bản mới: %latestVersion\n\n'
        'Bạn có muốn cập nhật không?',
    bannedVersions: bannedVersions, // <--------
    onlyShowDialogWhenBanned: false,
    forceUpdateContent: 'Đã có phiên bản cập nhật mới!\n\n'
        'Phiên bản hiện tại: %currentVersion\n'
        'Phiên bản mới: %latestVersion\n\n'
        'Bạn cần cập nhật để tiếp tục sử dụng',
    changelogsText: 'Thay đổi',
    changelogs: [
        'Cải thiện hiệu năng', 
        'Sửa một số lỗi',
    ],
    failToOpenStoreError: 'Đã xảy ra lỗi khi mở Store để cập nhật ứng dung, '
        'bạn vui lòng cập nhật thủ công nhé!'
        '\nXin lỗi vì sự bất tiện này.\n(Logs: %error)',
);
```

When you're setting `onlyShowDialogWhenBanned` to `true`, you can check the current version has update or not by using `updateHelper.isAvailable` variable, it will be `true` if the new version is available. You have to use this value after calling `initial`.

You can also check the current version needs to force update or not by using `updateHelper.isForceUpdate`. If this value is `true`, it means the `forceUpdate` variable is `true` or the current version is is `bannedVersions`.

## **Additional**

``` dart
/// Use this method to open the store
UpdateHelper.openStore();
```

## **NOTE:**

- The plugin will replace `%currentVersion` and `%latestVersion` with it's real version.

- You can use only `forceUpdate` or `bannedVersions` because `forceUpdate` will be `true` if the current version is satisfied with `bannedVersions`.

- `onlyShowDialogWhenBanned`: only show the update dialog when the current version is banned or `forceUpdate` is `true`.

- You can read more about how to use `bannedVersions` on [satisfied_version](https://pub.dev/packages/satisfied_version) plugin.

- `changelogsText` is the changelogs text, default is 'Changelogs'. `changelogs` is a list of change log that you want to show in the new version, default is empty. The `changelogsText` and `changelogs` only show up when `changelogs` is not empty.

- Show an error log when the app can't open the store, you can modify it using the `failToOpenStoreError` parameter. The plugin will replace the `%error` with it's real error log.

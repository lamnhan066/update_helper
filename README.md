# Update Helper

Help you easier to control the update dialog. It also supports the feature that forces the app to update to continue using.

Screenshots (Left/Above: don't force to update, Right/Below: force to update and users cannot close the dialog):

## Demo

[https://pub.lamnhan.dev/update_helper](https://pub.lamnhan.dev/update_helper)

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
    title: 'Update',
    content: 'A new version is available!\n\n'
        'v%currentVersion → v%latestVersion\n\n'
        'Would you like to update?',
    bannedVersions: bannedVersions, // <--------
    onlyShowDialogWhenBanned: false,
    forceUpdateContent: 'A new version is available!\n\n'
        'v%currentVersion → v%latestVersion\n\n'
        'Please update to continue using the app.',
    changelogsText: 'Changelogs',
    changelogs: [
        'Improve performances', 
        'Minor bugfixes',
    ],
    failToOpenStoreError:'Got an error when trying to open the Store, '
        'please update the app manually. '
        '\nSorry for the inconvenience.\n(Logs: %error)',
);
```

When you're setting `onlyShowDialogWhenBanned` to `true`, you can check the current version has update or not by using `updateHelper.isAvailable` variable, it will be `true` if the new version is available. You have to use this value after calling `initial`.

You can also check the current version needs to force update or not by using `updateHelper.isForceUpdate`. If this value is `true`, it means the `forceUpdate` variable is `true` or the current version is is `bannedVersions`.

If you want to create a custom dialog, you can create it via the `dialogBuilder`:

```dart
updateHelper.initial(
    context: context,
    updateConfig: UpdateConfig(
        defaultConfig: UpdatePlatformConfig(latestVersion: latestVersion),
    ),
    dialogBuilder: (context, config) {
        return AlertDialog.adaptive(
              title: const Text('Update'),
              content: const Text(
                  'This is a custom dialog.\n\nWould you like to update?'),
              actions: [
                TextButton(
                    onPressed: config.onOkPressed, child: const Text('OK')),
                TextButton(
                  onPressed: config.onLaterPressed,
                  child: Text(
                    'Later',
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                ),
              ],
        );
    }
);
```

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

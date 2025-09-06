## 0.9.1

* Prevent users from pressing the back button to close the dialog.

## 0.9.0

* **BREAKING CHANGE:** Use package `web` to support WASM.
* **BREAKING CHANGE:** Update the default texts.
* Update the example.
* Update the README.

## 0.8.0

* **BREAKING CHANGE:** Bump the `package_info_plus` version to `^8.0.0`.
* Able to use a custom dialog via `dialogBuilder` parameter.
* **BREAKING CHANGE:** The default dialog now uses the `AlertDialog.adaptive` instead of `AlertDialog`.
* **BREAKING CHANGE:** Update some default texts to improve the UX.

## 0.7.1

* Fixes duplicated changelog.

## 0.7.0

* Bump dependencies.

## 0.6.1

* Change `package_info_plus version` to `^4.2.0`.

## 0.6.0

* Update comments.
* Update homepage URL.

## 0.5.2

* Improve CHANGELOG.

## 0.5.1

* Support version with format "major.minor.patch" better.

## 0.5.0

* Bump sdk to ">=3.0.0 <4.0.0".
* Bump dependencies.

## 0.4.1

* Add Fuchsia platform.
* Improve fallback URL behavior.
* Improve dialog UI.

## 0.4.0

* Bump dependencies.

## 0.3.0

* Bump http version to `1.0.0`.

## 0.2.0

* Update dependencies.
* Update dart sdk to `>=2.18.0 <4.0.0`.
* Update flutter min sdk to `3.3.0`.
* Update homepage URL.

## 0.1.4

* Support reloading website when updating on Web platform.

## 0.1.3

* Added `isAvailable` and `isForceUpdate` variables

## 0.1.2

* Refactored internal code
* Added `UpdateHelper.openStore()` method to open the store.

## 0.1.1

* Added `onlyShowDialogWhenBanned` parameter: only show the update dialog when the current version is banned or `forceUpdate` is `true`.

## 0.1.0

* Release to stable.

## 0.1.0-rc4

* **[BREAKING CHANGE]** Move from static function to singleton.

  * Before:
  
    ``` dart
    UpdateHelper.initial();
    ```

  * Now:

    ``` dart
    final updateHelper = UpdateHelper.instance;
    updateHelper.initial();
    ```

* Update README.

## 0.1.0-rc3

* Add `failToOpenStoreError` parameter to show the error log if the app can't open the store.
* Add class `UpdateHelperForceMock` and `UpdateHelpereMock` to improve the test.

## 0.1.0-rc2

* Update README: Update image URL.
* Update dependencies.

## 0.1.0-rc1

* Upgrade dependencies.
* Remove `in_app_review` package.
* Add example.

## 0.0.2

* Add `defaultConfig` in `UpdateConfig` to define default value for all platforms.
* Add showing changelogs feature.
* Rename title from `Update Information` to `Update`.
* Change font size from 16 to 15.
* Update README.

## 0.0.1+4

* Add `satisfied_version` plugin to control `bannedVersions`.

## 0.0.1+3

* Prevent users from pressing the back button to close the dialog.

## 0.0.1+2

* Improved public apis comments.

## 0.0.1+1

* Improved readme.

## 0.0.1

* Initial release.

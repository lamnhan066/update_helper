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

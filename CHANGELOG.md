## 0.4.0 - 5/12/22
* Add unnamed constructor to improve testing and mocking
* Fix lint warnings
* Bump packages to latest versions

## 0.3.0 - 1/13/21
* #75: Add `forceAppVersion` field to make testing easier.
* #77: Improve `canUpdate` logic so that greater local version won't prompt for an update.

## 0.2.3 - 8/24/21

* #50: Check for empty result from iOS App Store if the app does not exist in the store
## 0.2.2 - 7/5/21

* #45: Check if What's New text exists before accessing it to prevent crash.
## 0.2.1 - 6/23/21

* Optional field `releaseNotes` added to `VersionStatus`, which contains the release notes for a published app.
* Optional parameter `allowDismissal` added to `showUpdateDialog` function. When it is set to false, the plugin prevents the user from dismissing the update dialog. By default it is true.
## 0.2.0 - 3/23/21

#### Breaking changes

* `NewVersion` now only has three fields `iOSId`, `androidId`, and `iOSAppStoreCountry`. The other fields have been turned into parameters for the individual functions.

## 0.1.0 - 3/23/21

#### Breaking changes

* `VersionStatus` can no longer be directly instantiated by the user.
* Migrated to null-safety, so certain fields are now `final` or non-null, which may break your code.

#### Non-breaking changes

* `canUpdate` now checks that the local version is *smaller* than the store version, not just that it is unequal.

## 0.0.7 - 3/16/21

* Add `iOSAppStoreCountry` parameter to allow app lookup in a different country's App Store
* Bump packages to latest version
* Migrate from `package_info` to `package_info_plus`
* Clean up example project
* Document all parameters in README

## 0.0.6 - 1/15/21

* Add more granular parameters, fix Android web view and navigation bugs.

## 0.0.5 - 9/29/20

* Fix HTTPS bug on iOS. Fix null return for android version statuses. Upgrade dependencies.

## 0.0.3 - 1/13/19

* Initial release. API includes `getVersionStatus` and `showAlertIfNecessary` methods. Support for iOS and Android.

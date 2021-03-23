## 0.0.3 - 1/13/19

* Initial release. API includes `getVersionStatus` and `showAlertIfNecessary` methods. Support for iOS and Android.

## 0.0.5 - 9/29/20

* Fix HTTPS bug on iOS. Fix null return for android version statuses. Upgrade dependencies.

## 0.0.6 - 1/15/21

* Add more granular parameters, fix Android web view and navigation bugs.

## 0.0.7 - 3/16/21

* Add `iOSAppStoreCountry` parameter to allow app lookup in a different country's App Store
* Bump packages to latest version
* Migrate from `package_info` to `package_info_plus`
* Clean up example project
* Document all parameters in README

## 0.1.0 - 3/23/21

#### Breaking changes

* `VersionStatus` can no longer be directly instantiated by the user.
* Migrated to null-safety, so certain fields are now `final` or non-null, which may break your code.

#### Non-breaking changes

* `canUpdate` now checks that the local version is *smaller* than the store version, not just that it is unequal.
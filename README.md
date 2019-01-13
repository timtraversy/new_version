# New Version Plugin 🎉

A Flutter plugin that makes it possible to: 
* Check if a user has the most recent version of your app installed.
* Show the user an alert with a link to the appropriate app store page.

<img src="https://raw.githubusercontent.com/timtraversy/new_version/master/screenshots/ios.jpeg" height="400" /> <img src="https://raw.githubusercontent.com/timtraversy/new_version/master/screenshots/android.png" height="400" />
## Installation
Add new_version as [a dependency in your `pubspec.yaml` file.](https://flutter.io/using-packages/)
```
dependencies:
  new_version: ^0.0.3
```

## Usage
In `main.dart` (or wherever your app is initialized), create an instance of `NewVersion` using your current build context.
`final newVersion = NewVersion(context)`.

The plugin will automatically use your Flutter package identifier to check the app store. If your app has a differnet identifier in the Google Play Store or Apple App Store, you can overwrite this by providing values for `androidId` and/or `iOSId`.

You can use then use the plugin in two ways.

### Quickstart
Calling `showAlertIfNecessary` will check if the app can be updated, and will automatically dispaly a platform-specific alert that the user can use to go to the app store.

`newVersion.showAlertIfNecessary();`

### Advanced 😎
If you want to create a custom alert or use the app version information differently, call `getVersionStatus`. This will return a `VersionStatus` future with information about the local and app store versions of the app.
```
final status = await newVersion.getVersionStatus();
status.needsUpdate // (true)
status.localVersion // (1.2.1)
status.storeVersion // (1.2.3)
status.appStoreLink // (https://itunes.apple.com/us/app/google/id284815942?mt=8)
```

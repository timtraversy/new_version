library new_version;

import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:html/parser.dart' show parse;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

/// Information about the app's current version, and the most recent version
/// available in the Apple App Store or Google Play Store.
class VersionStatus {
  /// True if the there is a more recent version of the app in the store.
  bool canUpdate;

  /// The current version of the app.
  String localVersion;

  /// The most recent version of the app in the store.
  String storeVersion;

  /// A link to the app store page where the app can be updated.
  String appStoreLink;

  VersionStatus({this.canUpdate, this.localVersion, this.storeVersion});
}

class NewVersion {
  /// This is required to check the user's platform and display alert dialogs.
  BuildContext context;

  /// An optional value that can override the default packageName when
  /// attempting to reach the Google Play Store. This is useful if your app has
  /// a different package name in the Play Store for some reason.
  String androidId;

  /// An optional value that can override the default packageName when
  /// attempting to reach the Apple App Store. This is useful if your app has
  /// a different package name in the App Store for some reason.
  String iOSId;

  NewVersion({this.androidId, this.iOSId, @required this.context})
      : assert(context != null);

  /// This checks the version status, then displays a platform-specific alert
  /// with buttons to dismiss the update alert, or go to the app store.
  showAlertIfNecessary() async {
    VersionStatus versionStatus = await getVersionStatus();
    if (versionStatus.canUpdate) {
      showUpdateDialog(versionStatus);
    }
  }

  /// This checks the version status and returns the information. This is useful
  /// if you want to display a custom alert, or use the information in a different
  /// way.
  Future<VersionStatus> getVersionStatus() async {

    PackageInfo packageInfo;
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      print('error');
    }

    VersionStatus versionStatus = VersionStatus(
      localVersion: packageInfo.version,
    );

    /// Android info is fetched by parsing the html of the app store page.
    /// iOS info is fetched by using the iTunes lookup API, which returns a
    /// JSON document.
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
        final id = androidId ?? packageInfo.packageName;
        final url = 'https://play.google.com/store/apps/details?id=$id';
        final response = await http.get(url);
        final document = parse(response.body);
        final elements = document.getElementsByClassName('hAyfc');
        final versionElement = elements.firstWhere(
          (elm) => elm.querySelector('.BgcNfc').text == 'Current Version',
        );
        versionStatus.storeVersion =
            versionElement.querySelector('.htlgb').text;
        versionStatus.appStoreLink = url;
        break;

      case TargetPlatform.iOS:
        final id = iOSId ?? packageInfo.packageName;
        final url = 'http://itunes.apple.com/lookup?bundleId=$id';
        final response = await http.get(url);
        final jsonObj = json.decode(response.body);
        versionStatus.storeVersion = jsonObj['results'][0]['version'];
        versionStatus.appStoreLink = jsonObj['results'][0]['trackViewUrl'];
        break;

      default:
        print('This target platform is not yet supported by this package.');
    }

    versionStatus.canUpdate =
        versionStatus.storeVersion != versionStatus.localVersion;

    return versionStatus;
  }

  /// Shows the user a platform-specific alert about the app update. The user
  /// can dismiss the alert or proceed to the app store.
  void showUpdateDialog(VersionStatus versionStatus) async {
    const title = Text('Update Available');
    final content = Text(
        'You can now update this app from ${versionStatus.localVersion} to ${versionStatus.storeVersion}');
    const dismissText = Text('Maybe Later');
    final dismissAction = () => Navigator.pop(context);
    const updateText = Text('Update');
    final updateAction = () {
      _launchAppStore(versionStatus.appStoreLink);
      Navigator.pop(context);
    };

    final platform = Theme.of(context).platform;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return platform == TargetPlatform.android
            ? AlertDialog(
                title: title,
                content: content,
                actions: <Widget>[
                  FlatButton(
                    child: dismissText,
                    onPressed: dismissAction,
                  ),
                  FlatButton(
                    child: updateText,
                    onPressed: updateAction,
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: title,
                content: content,
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: dismissText,
                    onPressed: dismissAction,
                  ),
                  CupertinoDialogAction(
                    child: updateText,
                    onPressed: updateAction,
                  ),
                ],
              );
      },
    );
  }

  /// Launches the Apple App Store or Google Play Store page for the app.
  void _launchAppStore(String appStoreLink) async {
    if (await canLaunch(appStoreLink)) {
      await launch(appStoreLink, forceWebView: true);
    } else {
      throw 'Could not launch appStoreLink';
    }
  }
}

library new_version;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Information about the app's current version, and the most recent version
/// available in the Apple App Store or Google Play Store.
class VersionStatus {
  /// True if the there is a more recent version of the app in the store.
  bool get canUpdate {
    if (storeVersion == null) {
      return false;
    }
    if (localVersion != null) {
      final current = int.tryParse(localVersion!.replaceAll('.', ''));
      final store = int.tryParse(storeVersion!.replaceAll('.', ''));
      if (current != null && store != null) {
        return store > current;
      }
    }
    return storeVersion != localVersion;
  }

  /// The current version of the app.
  String? localVersion;

  /// The most recent version of the app in the store.
  String? storeVersion;

  /// A link to the app store page where the app can be updated.
  String? appStoreLink;

  VersionStatus({this.localVersion, this.storeVersion});
}

class NewVersion {
  /// This is required to check the user's platform and display alert dialogs.
  final BuildContext context;

  /// An optional value that can override the default packageName when
  /// attempting to reach the Google Play Store. This is useful if your app has
  /// a different package name in the Play Store.
  final String? androidId;

  /// An optional value that can override the default packageName when
  /// attempting to reach the Apple App Store. This is useful if your app has
  /// a different package name in the App Store.
  final String? iOSId;

  /// An optional value that can override the default callback to dismiss button.
  final VoidCallback? dismissAction;

  /// An optional value that can override the default text to alert,
  /// you can ${versionStatus.localVersion} to ${versionStatus.storeVersion}
  /// to determinate in the text a versions.
  final String? dialogText;

  /// An optional value that can override the default title of alert dialog.
  final String dialogTitle;

  /// An optional value that can override the default text of dismiss button.
  final String dismissText;

  /// An optional value that can override the default text of update button.
  final String updateText;

  /// Only affects iOS App Store lookup: The two-letter country code for the store you want to search.
  /// Provide a value here if your app is only available outside the US.
  /// For example: US. The default is US.
  /// See http://en.wikipedia.org/wiki/ ISO_3166-1_alpha-2 for a list of ISO Country Codes.
  final String? iOSAppStoreCountry;

  NewVersion({
    this.androidId,
    this.iOSId,
    required this.context,
    this.dismissAction,
    this.dismissText: 'Maybe Later',
    this.updateText: 'Update',
    this.dialogText,
    this.dialogTitle: 'Update Available',
    this.iOSAppStoreCountry,
  });

  /// This checks the version status, then displays a platform-specific alert
  /// with buttons to dismiss the update alert, or go to the app store.
  showAlertIfNecessary() async {
    final VersionStatus? versionStatus = await getVersionStatus();
    if (versionStatus != null && versionStatus.canUpdate) {
      showUpdateDialog(versionStatus);
    }
  }

  /// This checks the version status and returns the information. This is useful
  /// if you want to display a custom alert, or use the information in a different
  /// way.
  Future<VersionStatus?> getVersionStatus() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    VersionStatus versionStatus = VersionStatus(localVersion: packageInfo.version);
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
        final id = androidId ?? packageInfo.packageName;
        versionStatus = await _getAndroidStoreVersion(id, versionStatus);
        break;
      case TargetPlatform.iOS:
        final id = iOSId ?? packageInfo.packageName;
        versionStatus = await _getiOSStoreVersion(id, versionStatus);
        break;
      default:
        debugPrint('This target platform is not yet supported by this package.');
    }

    return versionStatus;
  }

  /// iOS info is fetched by using the iTunes lookup API, which returns a
  /// JSON document.
  _getiOSStoreVersion(String id, VersionStatus versionStatus) async {
    final parameters = {"bundleId": "$id"};
    if (iOSAppStoreCountry != null) {
      parameters.addAll({"country": iOSAppStoreCountry!});
    }
    var uri = Uri.https("itunes.apple.com", "/lookup", parameters);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('Can\'t find an app in the App Store with the id: $id');
      return null;
    }
    final jsonObj = json.decode(response.body);
    versionStatus.storeVersion = jsonObj['results'][0]['version'];
    versionStatus.appStoreLink = jsonObj['results'][0]['trackViewUrl'];
    return versionStatus;
  }

  /// Android info is fetched by parsing the html of the app store page.
  _getAndroidStoreVersion(String id, VersionStatus versionStatus) async {
    final uri = Uri.https("play.google.com", "/store/apps/details", {"id": "$id"});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('Can\'t find an app in the Play Store with the id: $id');
      return null;
    }
    final document = parse(response.body);
    final elements = document.getElementsByClassName('hAyfc');
    final versionElement = elements.firstWhere(
      (elm) => elm.querySelector('.BgcNfc')!.text == 'Current Version',
    );
    versionStatus.storeVersion = versionElement.querySelector('.htlgb')!.text;
    versionStatus.appStoreLink = uri.toString();
    return versionStatus;
  }

  /// Shows the user a platform-specific alert about the app update. The user
  /// can dismiss the alert or proceed to the app store.
  void showUpdateDialog(VersionStatus versionStatus) async {
    final title = Text(dialogTitle);
    final content = Text(
      this.dialogText ??
          'You can now update this app from ${versionStatus.localVersion} to ${versionStatus.storeVersion}',
    );
    final dismissText = Text(this.dismissText);
    final dismissAction =
        this.dismissAction ?? () => Navigator.of(context, rootNavigator: true).pop();
    final updateText = Text(this.updateText);
    final updateAction = () {
      _launchAppStore(versionStatus.appStoreLink!);
      Navigator.of(context, rootNavigator: true).pop();
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
                  TextButton(
                    child: dismissText,
                    onPressed: dismissAction,
                  ),
                  TextButton(
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
    debugPrint(appStoreLink);
    if (await canLaunch(appStoreLink)) {
      await launch(appStoreLink);
    } else {
      throw 'Could not launch appStoreLink';
    }
  }
}

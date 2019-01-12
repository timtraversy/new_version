library new_version;

import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:html/parser.dart' show parse;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class VersionStatus {
  bool needsUpdate;
  String localVersion;
  String storeVersion;
  String appStoreLink;
  VersionStatus({this.needsUpdate, this.localVersion, this.storeVersion});
}

class NewVersion {
  BuildContext context;
  String androidId;
  String iOSId;

  NewVersion({this.context, this.androidId, this.iOSId});

  showAlertIfNecessary() async {
    VersionStatus versionStatus = await getVersionStatus();
    if (!versionStatus.needsUpdate) {
      return;
    }
    showUpdateDialog(versionStatus.appStoreLink);
  }

  Future<VersionStatus> getVersionStatus() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    VersionStatus versionStatus = VersionStatus(
      localVersion: packageInfo.version,
    );

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

    versionStatus.needsUpdate =
        versionStatus.storeVersion != versionStatus.localVersion;

    return versionStatus;
  }

  void showUpdateDialog(String appStoreLink) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Available'),
          content: Text('Update'),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Maybe Later'),
            ),
            RaisedButton(
              onPressed: () {
                _launchAppStore(appStoreLink);
                Navigator.pop(context);
              },
              child: Text('Update', style: TextStyle(color: Colors.white),),
            )
          ],
        );
      },
    );
  }

  void _launchAppStore(String appStoreLink) async {
    if (await canLaunch(appStoreLink)) {
      await launch(appStoreLink);
    } else {
      throw 'Could not launch appStoreLink';
    }
  }
}

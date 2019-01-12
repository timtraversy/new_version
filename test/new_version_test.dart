import 'package:flutter_test/flutter_test.dart';
import 'package:new_version/new_version.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

void main() {
  const fakeGoogleLocalVersion = '0.0.1';
  const googleiOSId = 'com.google.GoogleMobile';
  const googleAndroidId = 'com.google.earth';

  test('Checking version status', () {

  });

  testWidgets('Checking version status', (WidgetTester tester) async {
    final AutomatedTestWidgetsFlutterBinding binding = tester.binding;
    binding.addTime(Duration(seconds: 10));
    Future<VersionStatus> versionStatus;
    await tester.pumpWidget(
    StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          print(Theme.of(context).platform);
          final newVersion = NewVersion(
              context: context, androidId: googleAndroidId, iOSId: googleiOSId);
          versionStatus = newVersion.getVersionStatus();
          return Container();
        },
      ),
    );
    final status = await versionStatus;
    print(status);
//    expect(calculator.addOne(2), 3);
//    expect(calculator.addOne(-7), -6);
//    expect(calculator.addOne(0), 1);
//    expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });
}

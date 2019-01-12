import 'package:flutter/material.dart';
import 'package:new_version/new_version.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    NewVersion newVersion = NewVersion(context: context);
    newVersion.showAlertIfNecessary();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('New Version Example'),
        ),
      ),
    );
  }
}

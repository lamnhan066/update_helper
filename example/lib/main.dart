import 'package:flutter/material.dart';
import 'package:update_helper/update_helper.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      UpdateHelper.initial(
        context: context,
        updateConfig: UpdateConfig(
          defaultConfig: UpdatePlatformConfig(latestVersion: '3.0.0'),
        ),
        forceUpdate: true,
        changelogs: [
          'Bugs fix and improve performances',
          'New feature: Add update dialog',
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: const Center(
        child: Text(''),
      ),
    );
  }
}

// ignore_for_file: invalid_use_of_visible_for_testing_member, avoid_print

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
  final updateHelper = UpdateHelper.instance;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // Adding testing package name, don't need this in real app
      updateHelper.packageName = 'com.vursin.othello';

      print('Show normal update dialog. Just press Later');
      await UpdateHelper.instance.initial(
        context: context,
        updateConfig: UpdateConfig(
          defaultConfig: UpdatePlatformConfig(latestVersion: '0.0.6'),
        ),
        changelogs: ['Improve performances', 'Update UI'],
        isDebug: true,
      );

      print('Don\'t show dialog because [onlyShowDialogWhenForce] is `true`'
          'but [forceUpdate] is `false`');
      if (mounted) {
        await UpdateHelper.instance.initial(
          context: context,
          updateConfig: UpdateConfig(
            defaultConfig: UpdatePlatformConfig(latestVersion: '0.0.6'),
          ),
          onlyShowDialogWhenBanned: true,
          changelogs: ['Improve performances', 'Update UI'],
          isDebug: true,
        );
      }

      print('Show dialog because [onlyShowDialogWhenForce] is `true`'
          'and [forceUpdate] is `true`');
      if (mounted) {
        await UpdateHelper.instance.initial(
          context: context,
          updateConfig: UpdateConfig(
            defaultConfig: UpdatePlatformConfig(latestVersion: '0.0.6'),
          ),
          onlyShowDialogWhenBanned: true,
          forceUpdate: true,
          isDebug: true,
        );
      }
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

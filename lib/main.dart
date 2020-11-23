import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test_app/features/presentation/pages/host_app_page.dart';
import 'package:flutter_test_app/in_app_webiew_example.screen.dart';
import 'package:flutter_test_app/camera_test.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_test_app/features/presentation/di/injection_container.dart' as di;

// import 'package:permission_handler/permission_handler.dart';

InAppLocalhostServer localhostServer = new InAppLocalhostServer();

Future main() async {
  // it should be the first line in main method
  WidgetsFlutterBinding.ensureInitialized();
  //await localhostServer.start();
  await di.init();
  await Permission.camera.request();
  await Permission.microphone.request();
//  await Permission.camera.request();
//  await Permission.storage.request();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web View',
      theme: ThemeData(
        primaryColor: Colors.green.shade800,
        accentColor: Colors.green.shade600,
      ),
      home: WebViewExample(),
    );
  }
}

Drawer myDrawer({@required BuildContext context}) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Text('flutter_inappbrowser example'),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          title: Text('InAppBrowser'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/InAppBrowser');
          },
        ),
        ListTile(
          title: Text('ChromeSafariBrowser'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/ChromeSafariBrowser');
          },
        ),
        ListTile(
          title: Text('InAppWebView'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        ListTile(
          title: Text('HeadlessInAppWebView'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/HeadlessInAppWebView');
          },
        ),
      ],
    ),
  );
}

/*class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => InAppWebViewExampleScreen(),
        }
    );
  }
}*/
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test_app/features/presentation/bloc/bloc.dart';
import 'package:flutter_test_app/features/presentation/di/injection_container.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<InAppWebViewController> _controller =
      Completer<InAppWebViewController>();
  ContextMenu contextMenu;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter WebView example'),
          // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
          actions: <Widget>[
            NavigationControls(_controller.future),
            SampleMenu(_controller.future),
          ],
        ),
        // We're using a Builder here so we have a context that is below the Scaffold
        // to allow calling Scaffold.of(context) so we can show a snackbar.
        body: Builder(builder: (BuildContext context) {
          return InAppWebView(
            // contextMenu: contextMenu,
            initialUrl: "https://www.epm.com.co/site/",
            // initialFile: "assets/index.html",
            initialHeaders: {},
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  debuggingEnabled: true,
                  useShouldOverrideUrlLoading: true,
                ),
                android: AndroidInAppWebViewOptions(
                  allowFileAccessFromFileURLs: true,
                )),
            onWebViewCreated: (InAppWebViewController controller) {
              _controller.complete(controller);
              //_onNavigationDelegateExample('microapp4');
              //loadHtmlFromAssets();
              print("onWebViewCreated");
            },
            onLoadStart: (InAppWebViewController controller, String url) {
              print("onLoadStart $url");
              setState(() {
                this.url = url;
              });
            },
            shouldOverrideUrlLoading:
                (controller, shouldOverrideUrlLoadingRequest) async {
              var url = shouldOverrideUrlLoadingRequest.url;
              var uri = Uri.parse(url);

              if (![
                "http",
                "https",
                "file",
                "chrome",
                "data",
                "javascript",
                "about"
              ].contains(uri.scheme)) {
                if (await canLaunch(url)) {
                  // Launch the App
                  await launch(
                    url,
                  );
                  // and cancel the request
                  return ShouldOverrideUrlLoadingAction.CANCEL;
                }
              }

              return ShouldOverrideUrlLoadingAction.ALLOW;
            },
            onLoadStop: (InAppWebViewController controller, String url) async {
              print("onLoadStop $url");
              setState(() {
                this.url = url;
              });
            },
            onProgressChanged:
                (InAppWebViewController controller, int progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
            onUpdateVisitedHistory: (InAppWebViewController controller,
                String url, bool androidIsReload) {
              print("onUpdateVisitedHistory $url");
              setState(() {
                this.url = url;
              });
            },
            onConsoleMessage: (controller, consoleMessage) {
              print(consoleMessage);
            },
          );
        }));
  }
}

enum MenuOptions {
  navigationDelegateMicroApp1,
  navigationDelegateMicroApp2,
  navigationDelegateMicroApp3,
  navigationDelegateMicroApp4,
  navigationDelegateMicroApp5,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);

  bool _downloading = false;
  String _dir;

  final Future<InAppWebViewController> controller;
  final CookieManager cookieManager = CookieManager();

  _initDir() async {
    if (null == _dir) {
      _dir = (await getApplicationDocumentsDirectory()).path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildBody(context);
  }

  //region BlocProvider
  BlocProvider<MicroAppBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MicroAppBloc>(),
      child: Column(
        children: <Widget>[
          FutureBuilder<InAppWebViewController>(
            future: controller,
            builder: (BuildContext context,
                AsyncSnapshot<InAppWebViewController> controller) {
              return PopupMenuButton<MenuOptions>(
                onSelected: (MenuOptions value) {
                  switch (value) {
                    case MenuOptions.navigationDelegateMicroApp1:
                      _downloadMicroApp(context, 'microapp1');
                      //_onNavigationDelegateExample(controller.data, context, 'microapp1');
                      break;
                    case MenuOptions.navigationDelegateMicroApp2:
                      _onNavigationDelegateExample(
                          controller.data, context, 'microapp2');
                      break;
                    case MenuOptions.navigationDelegateMicroApp3:
                      _onNavigationDelegateExample(
                          controller.data, context, 'microapp3');
                      break;
                    case MenuOptions.navigationDelegateMicroApp4:
                      _onNavigationDelegateExample(
                          controller.data, context, 'microapp4');
                      break;
                    case MenuOptions.navigationDelegateMicroApp5:
                      _onNavigationDelegateExample(
                          controller.data, context, 'microapp5');
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
                  PopupMenuItem<MenuOptions>(
                    value: MenuOptions.navigationDelegateMicroApp1,
                    child: Text('Download MicroApp 1'),
                  ),
                  const PopupMenuItem<MenuOptions>(
                    value: MenuOptions.navigationDelegateMicroApp2,
                    child: Text('Download MicroApp 2'),
                  ),
                  const PopupMenuItem<MenuOptions>(
                    value: MenuOptions.navigationDelegateMicroApp3,
                    child: Text('Download MicroApp 3'),
                  ),
                  const PopupMenuItem<MenuOptions>(
                    value: MenuOptions.navigationDelegateMicroApp4,
                    child: Text('Download MicroApp 4'),
                  ),
                  const PopupMenuItem<MenuOptions>(
                    value: MenuOptions.navigationDelegateMicroApp5,
                    child: Text('Download MicroApp 5'),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  //endregion

  void _downloadMicroApp(BuildContext context, String microAppId) {
    print('MICROAPP:: downloadMicroApp...');
    BlocProvider.of<MicroAppBloc>(context).add(GetUrlForMicroApp(microAppId));
  }

  void _onNavigationDelegateExample(InAppWebViewController controller,
      BuildContext context, String microAppId) async {
    _initDir();
    _downloading = false;
    await _downloadZip(microAppId);
    loadHtmlFromAssets(controller, microAppId);
  }

  Future<File> _downloadFile(String url, String fileName) async {
    print('make req:: ');
    var req = await http.Client().get(Uri.parse(url));
    print('status code response:: ' + req.statusCode.toString());
    var file = File('$_dir/$fileName');
    print('file path download::' + file.path);
    return file.writeAsBytes(req.bodyBytes);
  }

  Future<void> _downloadZip(String microAppId) async {
    //https://github.com/JCASTANO/flutter/blob/main/
    String _zipPath =
        'https://github.com/laura-gomez-c/assets_flutter_test/blob/main/$microAppId.zip?raw=true';
    String _localZipFileName = '$microAppId.zip';
    var zippedFile = await _downloadFile(_zipPath, _localZipFileName);
    await unarchiveAndSave(zippedFile);
  }

  unarchiveAndSave(var zippedFile) async {
    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      var fileName = '$_dir/${file.name}';
      print('filename: $fileName');
      if (file.isFile) {
        var outFile = File(fileName);

        print('File:: ' + outFile.path);

        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
        print('File written');
      }
    }
  }

  void loadHtmlFromAssets(
      InAppWebViewController controller, String microAppId) async {
    //Access to content
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/$microAppId/index.html';

    File file = File(filePath);
    String fileHtmlContents = await file.readAsString();

    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(fileHtmlContents));

    final uri = Uri.directory(filePath);
    final uriString = uri.toString().substring(0, uri.toString().length - 1);

    /// Remove final slash symbol
    controller.loadUrl(url: uriString);
    controller.addJavaScriptHandler(
        handlerName: 'postMessage',
        callback: (args) {
          print(args);
          // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
        });

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('position...' + position.toString());
    controller.addJavaScriptHandler(
        handlerName: 'getLocation',
        callback: (args) {
          // return data to JavaScript side!
          return position
              .toJson(); //{'latitud': position.latitude, 'longitud': position.longitude};
        });
    // await controller.loadUrl('data:text/html;base64,$contentBase64');
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<InAppWebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InAppWebViewController>(
      future: _webViewControllerFuture,
      builder: (BuildContext context,
          AsyncSnapshot<InAppWebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final InAppWebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoBack()) {
                        await controller.goBack();
                      } else {
                        // ignore: deprecated_member_use
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("No back history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoForward()) {
                        await controller.goForward();
                      } else {
                        // ignore: deprecated_member_use
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("No forward history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}

import 'dart:developer';
import 'dart:io';

import 'dart:async';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      new _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  InAppWebViewController webView;
  ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  CookieManager _cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(androidId: 1, iosId: "1", title: "Special", action: () async {
            print("Menu item Special clicked!");
            print(await webView.getSelectedText());
            await webView.clearFocus();
          })
        ],
        options: ContextMenuOptions(
            hideDefaultSystemContextMenuItems: true
        ),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webView.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid) ? contextMenuItemClicked.androidId : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: " + id.toString() + " " + contextMenuItemClicked.title);
        }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("InAppWebView")
        ),
        drawer: myDrawer(context: context),
        body: SafeArea(
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Text(
                    "CURRENT URL\n${(url.length > 50) ? url.substring(0, 50) + "..." : url}"),
              ),
              Container(
                  padding: EdgeInsets.all(10.0),
                  child: progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container()),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration:
                  BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                  child: InAppWebView(
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
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                      _onNavigationDelegateExample('microapp4');
                      //loadHtmlFromAssets();
                      print("onWebViewCreated");
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {
                      print("onLoadStart $url");
                      setState(() {
                        this.url = url;
                      });
                    },
                    shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
                      var url = shouldOverrideUrlLoadingRequest.url;
                      var uri = Uri.parse(url);

                      if (!["http", "https", "file",
                        "chrome", "data", "javascript",
                        "about"].contains(uri.scheme)) {
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
                    onProgressChanged: (InAppWebViewController controller, int progress) {
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
                    onUpdateVisitedHistory: (InAppWebViewController controller, String url, bool androidIsReload) {
                      print("onUpdateVisitedHistory $url");
                      setState(() {
                        this.url = url;
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print(consoleMessage);
                    },
                  ),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      if (webView != null) {
                        webView.goBack();
                      }
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (webView != null) {
                        webView.goForward();
                      }
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      if (webView != null) {
                        webView.reload();
                      }
                    },
                  ),
                ],
              ),
            ]))
    );
  }

  loadHtmlFromAssets() async {
    //String fileHtmlContents = await rootBundle.loadString('assets/microapp1/index.html');
    webView.loadFile(assetFilePath: 'assets/microapp4/index.html');
  }

  bool _downloading = false;
  String _dir;

  _initDir() async {
    if (null == _dir) {
      _dir = (await getApplicationDocumentsDirectory()).path;
    }
  }

  void _onNavigationDelegateExample(String microAppId) async {
    _initDir();
    _downloading = false;
    await _downloadZip(microAppId);
    loadHtmlFromDirectory(microAppId);
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
      if (file.isFile) {
        var outFile = File(fileName);

        print('File:: ' + outFile.path);

        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }
  }

  void loadHtmlFromDirectory(String microAppId) async {
    //Access to content
    String filePath = '$_dir/$microAppId/index.html';
    print('loading from dir.. filepath:: $filePath');

    File file = File(filePath);
    String fileHtmlContents = await file.readAsString();

    final String contentBase64 =
    base64Encode(const Utf8Encoder().convert(fileHtmlContents));
    final uri = Uri.directory(filePath);
    final uriString = uri.toString().substring(0, uri.toString().length - 1); /// Remove final slash symbol*/

    webView.loadUrl(url: uriString);
    // await controller.loadUrl('data:text/html;base64,$contentBase64');
  }
}
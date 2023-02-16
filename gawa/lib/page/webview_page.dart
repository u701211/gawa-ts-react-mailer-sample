import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../function/create_javascript_channels.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewPlusController controller;
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(''),
      // ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewPlus(
              serverPort: int.parse(dotenv.get('SERVER_PORT')),
              javascriptMode: JavascriptMode.unrestricted,
              debuggingEnabled: true,
              onWebViewCreated: (controller) {
                this.controller = controller;
                // テスト用
                // controller.loadUrl('https://www.google.com');

                // Auth0はhttpではエラーになる -> auth0-spa-js must run on a secure origin.
                // controller.loadUrl('http://10.0.2.2:3000/gawaApp');
                // controller.loadUrl('http://192.168.1.130:3000/gawaApp');

                // httpsは現状エラーで起動出来ず -> E/chromium(26544): [ERROR:ssl_client_socket_impl.cc(985)] handshake failed; returned -1, SSL error code 1, net_error -202
                // controller.loadUrl('https://10.0.2.2:3000/gawaApp');
                // controller.loadUrl('https://192.168.1.130:3000/gawaApp');

                // グローバルアドレスのhttpsはOK
                // controller.loadUrl('https://u701211.github.io/gawaApp');

                // 1. ローカルのアセットロードはOK ※1.と2.は同義
                controller.loadUrl(dotenv.get('SPA_LOAD_URL'));
                // 2. ローカルのアセットロードはOK ※1.と2.は同義
                // controller.loadUrl(
                //     'localhost:${int.parse(dotenv.get('SERVER_PORT'))}/${dotenv.get('SPA_LOAD_URL')}');
              },
              onPageStarted: (url) {
                setState(() {
                  loadingPercentage = 0;
                });
              },
              onProgress: (progress) {
                setState(() {
                  loadingPercentage = progress;
                });
              },
              onPageFinished: (url) {
                setState(() {
                  loadingPercentage = 100;
                });
              },
              onWebResourceError: (error) {
                debugPrint('''
Page resource エラー:
  code: ${error.errorCode}
  domain: ${error.domain}
  description: ${error.description}
  errorType: ${error.errorType}
  failingUrl: ${error.failingUrl}
            ''');
              },
              navigationDelegate: (navigation) {
                bool ok;
                if (!navigation.isForMainFrame) {
                  ok = true;
                } else {
                  final host = Uri.parse(navigation.url).host;
                  final whiteList = dotenv.get('INCLUDE_DOMAIN').split(',');
                  ok = whiteList.contains(host);
                }

                if (ok) {
                  return NavigationDecision.navigate;
                } else {
                  launchUrl(Uri.parse(navigation.url),
                      mode: LaunchMode.externalApplication);

                  return NavigationDecision.prevent;
                }
              },
              // jsからの接続チャンネルを生成
              javascriptChannels:
                  createJavascriptChannels(context, () => controller),
            ),
            if (loadingPercentage < 100)
              LinearProgressIndicator(
                value: loadingPercentage / 100.0,
              ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              controller.webViewController.goBack();
            },
            tooltip: 'back',
            child: const Icon(Icons.arrow_back),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              controller.webViewController.goForward();
            },
            tooltip: 'forward',
            child: const Icon(Icons.arrow_forward),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              controller.webViewController.reload();
            },
            tooltip: 'reload',
            child: const Icon(Icons.replay_outlined),
          ),
        ],
      ),
    );
  }
}

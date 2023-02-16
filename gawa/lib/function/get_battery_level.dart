import 'package:flutter/services.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'create_javascript_channels.dart';

JavascriptChannel getBatteryLevel(WebViewPlusController Function() controller) {
  const method = 'getBatteryLevel';
  const proxy = 'flutter_$method';

  return JavascriptChannel(
    name: proxy,
    onMessageReceived: (message) async {
      try {
        const platform = MethodChannel(method);
        final int level = await platform.invokeMethod(method);
        runJavascript(controller(), proxy, level);
      } on PlatformException catch (e) {
        runJavascript(controller(), proxy, e);
      } catch (e) {
        runJavascript(controller(), proxy, e);
      }
    },
  );
}

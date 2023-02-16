import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'get_battery_level.dart';
import 'get_qr_code.dart';

// jsからの接続チャンネルを生成
Set<JavascriptChannel> createJavascriptChannels(
    BuildContext context, WebViewPlusController Function() controller) {
  return {
    getBatteryLevel(controller),
    getQRCode(controller, context),
  };
}

// jsへのコールバック
void runJavascript<T>(
    WebViewPlusController controller, String proxy, T callbackValue) {
  controller.webViewController.runJavascript(
      "window.$proxy.callback(${callbackValue is String ? "'$callbackValue'" : callbackValue})");
}

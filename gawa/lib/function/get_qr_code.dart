import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'create_javascript_channels.dart';

JavascriptChannel getQRCode(
    WebViewPlusController Function() controller, BuildContext context) {
  const method = 'getQRCode';
  const proxy = 'flutter_$method';

  return JavascriptChannel(
    name: proxy,
    onMessageReceived: (message) async {
      try {
        MobileScannerController cameraController = MobileScannerController();

        String? code = await showGeneralDialog(
          context: context,
          barrierDismissible: false,
          transitionDuration: Duration.zero, // これを入れると遅延を入れなくて
          barrierColor: Colors.black.withOpacity(0.5),
          pageBuilder: (BuildContext context, Animation animation,
              Animation secondaryAnimation) {
            return Center(
              child: MobileScanner(
                // fit: BoxFit.contain,
                controller: cameraController,
                onDetect: (capture) {
                  final target = capture.barcodes.where(
                      (element) => element.format == BarcodeFormat.qrCode);
                  if (target.isNotEmpty) {
                    Navigator.pop(context, target.first.rawValue!);
                  }

                  // final Uint8List? image = capture.image;
                  // if (image != null) {
                  //   showDialog(
                  //     context: context,
                  //     builder: (context) => Image(image: MemoryImage(image)),
                  //   );
                  //   Future.delayed(const Duration(seconds: 5), () {
                  //     Navigator.pop(context);
                  //   });
                  // }
                },
              ),
            );
          },
        );

        runJavascript(controller(), proxy, code ?? '');
      } on PlatformException catch (e) {
        runJavascript(controller(), proxy, e);
      } catch (e) {
        runJavascript(controller(), proxy, e);
      }
    },
  );
}

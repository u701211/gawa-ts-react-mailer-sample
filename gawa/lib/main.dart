import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'page/webview_page.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const GawaApp());
}

class GawaApp extends StatelessWidget {
  const GawaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPA in GAWA アプリケーション',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const WebViewPage(),
    );
  }
}

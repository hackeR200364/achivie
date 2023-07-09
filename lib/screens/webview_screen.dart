import 'package:flutter/material.dart';

class WebViewScreen extends StatelessWidget {
  final String url;

  WebViewScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewScreen(
        url: url,
      ),
    );
  }
}

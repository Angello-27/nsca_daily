import '../widgets/app_bar_two.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreenIframe extends StatefulWidget {
  static const routeName = '/webview-iframe';

  final String? url;

  const WebViewScreenIframe({super.key, required this.url});

  @override
  State<WebViewScreenIframe> createState() => _WebViewScreenIframeState();
}

class _WebViewScreenIframeState extends State<WebViewScreenIframe> {
  InAppWebViewController? controller;
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarTwo(),
      body: InAppWebView(
        initialData: InAppWebViewInitialData(
          data: '''<html><body><iframe style="height: 100%;width:100%" src="${widget.url}" allowfullscreen></iframe></body></html>''',
          mimeType: 'text/html',
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          allowFileAccess: true,
        ),
        onWebViewCreated: (controller) {
          this.controller = controller;
        },
      ),
    );
  }
}

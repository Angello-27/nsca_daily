import '../widgets/app_bar_two.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class VimeoIframe extends StatefulWidget {
  static const routeName = '/vimeo-iframe';

  final String? url;

  const VimeoIframe({super.key, required this.url});

  @override
  State<VimeoIframe> createState() => _VimeoIframeState();
}

class _VimeoIframeState extends State<VimeoIframe> {
  InAppWebViewController? controller;
  // ignore: unused_field
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarTwo(),
      body: InAppWebView(
        initialData: InAppWebViewInitialData(
          data: '''<iframe 
              src="${widget.url}?loop=0&autoplay=0" 
              width="100%" height="100%" frameborder="0" allow="fullscreen" 
              allowfullscreen></iframe>''',
          mimeType: 'text/html',
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          allowFileAccess: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
        ),
        onWebViewCreated: (controller) {
          this.controller = controller;
        },
      ),
    );
  }
}

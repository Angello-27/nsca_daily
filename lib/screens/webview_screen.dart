// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../models/app_logo.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../constants.dart';

class WebViewScreen extends StatefulWidget {
  static const routeName = '/webview';

  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  // ignore: library_private_types_in_public_api
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _controller;
  final _controllerTwo = StreamController<AppLogo>();

  fetchMyLogo() async {
    var url = '$BASE_URL/api/app_logo';
    try {
      final response = await http.get(Uri.parse(url));
      // debugPrint(response.body);
      if (response.statusCode == 200) {
        var logo = AppLogo.fromJson(jsonDecode(response.body));
        _controllerTwo.add(logo);
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMyLogo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        elevation: 0.3,
        iconTheme: const IconThemeData(
          color: kSecondaryColor, //change your color here
        ),
        title: StreamBuilder<AppLogo>(
          stream: _controllerTwo.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              if (snapshot.error != null) {
                return const Text("Error Occured");
              } else {
                return CachedNetworkImage(
                  imageUrl: snapshot.data!.darkLogo.toString(),
                  fit: BoxFit.contain,
                  height: 27,
                );
              }
            }
          },
        ),
        actions: <Widget>[NavigationControls(webViewController: _controller)],
        backgroundColor: kBackgroundColor,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(widget.url),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          allowFileAccess: true,
          domStorageEnabled: true,
        ),
        onWebViewCreated: (controller) {
          _controller = controller;
          
          // Agregar JavaScript channel equivalente al 'Toaster'
          _controller!.addJavaScriptHandler(
            handlerName: 'Toaster',
            callback: (args) {
              if (args.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(args[0].toString())),
                );
              }
            },
          );
        },
        onProgressChanged: (controller, progress) {
          debugPrint('WebView is loading (progress : $progress%)');
        },
        onLoadStart: (controller, url) {
          debugPrint('Page started loading: ${url.toString()}');
        },
        onLoadStop: (controller, url) {
          debugPrint('Page finished loading: ${url.toString()}');
        },
        onReceivedError: (controller, request, error) {
          debugPrint('''
Page resource error:
  code: ${error.type}
  description: ${error.description}
          ''');
        },
      ),
    );
  }

  Widget favoriteButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (_controller != null) {
          final url = await _controller!.getUrl();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Favorited ${url.toString()}')));
          }
        }
      },
      child: const Icon(Icons.favorite),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController});

  final InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            if (webViewController != null && await webViewController!.canGoBack()) {
              await webViewController!.goBack();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No back history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () async {
            if (webViewController != null && await webViewController!.canGoForward()) {
              await webViewController!.goForward();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No forward history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () {
            if (webViewController != null) {
              webViewController!.reload();
            }
          },
        ),
      ],
    );
  }
}

// lib/screens/home_screen.dart
import '../constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controlador del WebView, por si necesitas acciones (reload, etc.)
  InAppWebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> refreshList() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Recargar el WebView
      if (_controller != null) {
        await _controller!.reload();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      // Error handling can be added here if needed
      setState(() {
        _isLoading = false;
      });
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshList,
      child: Stack(
        children: [
          // El WebView ocupa todo el espacio
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://www.nationalschoolchaplainassociation.org/blog'),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              allowFileAccess: true,
              domStorageEnabled: true,
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) {
              setState(() => _isLoading = false);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString();
              
              // Opcional: bloquear redirecciones fuera del dominio
              if (!url.startsWith('https://www.nationalschoolchaplainassociation.org')) {
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
          ),
          // Mientras carga, mostramos un indicador
          if (_isLoading)
            SizedBox(
              height: MediaQuery.of(context).size.height * .5,
              child: Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Si fuera necesario limpiar algo:
    super.dispose();
  }
}

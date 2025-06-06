// lib/screens/home_screen.dart
import '../constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controlador del WebView, por si necesitas acciones (reload, etc.)
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(
            Uri.parse('https://www.nationalschoolchaplainassociation.org/blog'),
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (uri) => setState(() => _isLoading = true),
              onPageFinished: (uri) => setState(() => _isLoading = false),
              onNavigationRequest: (request) {
                // Opcional: bloquear redirecciones fuera del dominio
                if (!request.url.startsWith(
                  'https://www.nationalschoolchaplainassociation.org',
                )) {
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          );
  }

  Future<void> refreshList() async {
    try {
      setState(() {
        _isLoading = true;
      });

      setState(() {
        _isLoading = false;
      });
    } catch (error) {}

    return;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshList,
      child: Stack(
        children: [
          // El WebView ocupa todo el espacio
          WebViewWidget(controller: _controller),
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

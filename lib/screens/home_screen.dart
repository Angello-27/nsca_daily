// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/theme_provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(context),
          body: RefreshIndicator(
            onRefresh: refreshList,
            color: kPrimaryColor,
            backgroundColor: AppColors.getCardColor(context),
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
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.getBackgroundColor(context).withValues(alpha: 0.8),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                        backgroundColor: AppColors.getCardColor(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Si fuera necesario limpiar algo:
    super.dispose();
  }
}

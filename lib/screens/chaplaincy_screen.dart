import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class ChaplaincyScreen extends StatefulWidget {
  static const routeName = '/chaplaincy';
  const ChaplaincyScreen({super.key});

  @override
  State<ChaplaincyScreen> createState() => _ChaplaincyScreenState();
}

class _ChaplaincyScreenState extends State<ChaplaincyScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _authToken;
  String? _chaplaincyUrl;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    await _getAuthToken();
    _setupWebView();
  }

  Future<void> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('userData');
      
      if (userData != null && userData.isNotEmpty) {
        final response = json.decode(userData);
        _authToken = response['token'];
        
        // Construir URL con token de autenticación
        _chaplaincyUrl = '$CHAPLAINCY_URL?token=$_authToken';
      } else {
        _showLoginRequiredDialog();
        return;
      }
    } catch (e) {
      debugPrint('Error obteniendo token: $e');
      _showLoginRequiredDialog();
    }
  }

  void _setupWebView() {
    if (_chaplaincyUrl == null) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..loadRequest(Uri.parse(_chaplaincyUrl!))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (uri) {
            setState(() => _isLoading = true);
            debugPrint('Cargando página de capellanía: $uri');
          },
          onPageFinished: (uri) {
            setState(() => _isLoading = false);
            debugPrint('Página de capellanía cargada: $uri');
          },
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
            debugPrint('Error en WebView: ${error.description}');
            _showErrorDialog(error.description);
          },
          onNavigationRequest: (request) {
            // Permitir navegación dentro del dominio de capellanía
            if (request.url.startsWith('http://localhost/nsca-lms/') || 
                request.url.startsWith('https://www.nscaacademy.org/')) {
              return NavigationDecision.navigate;
            }
            // Bloquear navegación externa
            return NavigationDecision.prevent;
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      );
  }

  void _handleJavaScriptMessage(String message) {
    // Manejar mensajes del JavaScript de la página de capellanía
    debugPrint('Mensaje desde JavaScript: $message');
    
    // Aquí puedes manejar diferentes tipos de mensajes
    // Por ejemplo, cuando el usuario complete una etapa
    if (message.startsWith('stage_completed:')) {
      final stageNumber = message.split(':')[1];
      _showStageCompletedDialog(stageNumber);
    } else if (message.startsWith('chaplaincy_completed')) {
      _showChaplaincyCompletedDialog();
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to log in to access the chaplain certification process.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, '/auth');
            },
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Loading Error'),
        content: Text('Could not load the chaplain certification page: $error'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _refreshWebView();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showStageCompletedDialog(String stageNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stage Completed!'),
        content: Text('You have successfully completed stage $stageNumber of the chaplain certification process.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showChaplaincyCompletedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('You have successfully completed the entire chaplain certification process.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Excellent'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshWebView() async {
    if (_chaplaincyUrl != null) {
      await _controller.loadRequest(Uri.parse(_chaplaincyUrl!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'School Chaplain Certification',
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextColor),
        actions: [
          IconButton(
            onPressed: _refreshWebView,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView principal
          if (_chaplaincyUrl != null)
            WebViewWidget(controller: _controller)
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: kPrimaryColor),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading chaplain certification process...',
                    style: TextStyle(color: kSecondaryColor),
                  ),
                ],
              ),
            ),
          
          // Indicador de carga
          if (_isLoading && _chaplaincyUrl != null)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: kPrimaryColor),
                    const SizedBox(height: 16),
                    const Text(
                      'Loading chaplain certification process...',
                      style: TextStyle(color: kTextColor),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshWebView,
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

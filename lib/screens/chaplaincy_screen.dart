import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants.dart';

class ChaplaincyScreen extends StatefulWidget {
  static const routeName = '/chaplaincy';
  const ChaplaincyScreen({super.key});

  @override
  State<ChaplaincyScreen> createState() => _ChaplaincyScreenState();
}

class _ChaplaincyScreenState extends State<ChaplaincyScreen>
    with AutomaticKeepAliveClientMixin {
  InAppWebViewController? _controller;
  bool _isLoading = true;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    // Cargar token inmediatamente para inicialización más rápida
    _initializeWebView();
    // Solicitar permisos en paralelo (no bloquear la carga)
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Solicita permisos de almacenamiento, cámara y archivos
    await [
      Permission.camera,
      Permission.photos, // Para iOS
      Permission.storage, // Para Android <= 12
      Permission.mediaLibrary, // Para Android 13+
      Permission.manageExternalStorage, // Para Android 11+
    ].request();
  }

  Future<void> _initializeWebView() async {
    await _getAuthToken();
  }

  Future<void> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('userData');

      if (userData != null && userData.isNotEmpty) {
        final response = json.decode(userData);
        _authToken = response['token'];
      } else {
        _showLoginRequiredDialog();
        return;
      }
    } catch (e) {
      debugPrint('Error obteniendo token: $e');
      _showLoginRequiredDialog();
    }
  }


  void _handleJavaScriptMessage(String message) {
    // Manejar mensajes del JavaScript de la página de capellanía
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
      builder:
          (ctx) => AlertDialog(
            title: const Text('Login Required'),
            content: const Text(
              'You need to log in to access the chaplain certification process.',
            ),
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

  void _showErrorDialog(String title, String message, {VoidCallback? onRetry}) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              if (onRetry != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onRetry();
                  },
                  child: const Text('Retry'),
                ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showStageCompletedDialog(String stageNumber) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Stage Completed!'),
            content: Text(
              'You have successfully completed stage $stageNumber of the chaplain certification process.',
            ),
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
      builder:
          (ctx) => AlertDialog(
            title: const Text('Congratulations!'),
            content: const Text(
              'You have successfully completed the entire chaplain certification process.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Excellent'),
              ),
            ],
          ),
    );
  }

  Future<void> _injectTokenIntoPage() async {
    if (_authToken == null || _controller == null) return;

    try {
      // JavaScript para inyectar el token en localStorage y sessionStorage
      final jsCode = '''
        (function() {
          // Guardar token en localStorage para que la página lo pueda usar
          localStorage.setItem('auth_token', '$_authToken');
          sessionStorage.setItem('auth_token', '$_authToken');
          
          // También agregar a window para acceso global
          window.authToken = '$_authToken';
          
          // Interceptar fetch/XMLHttpRequest para agregar headers automáticamente
          const originalFetch = window.fetch;
          window.fetch = function(url, options = {}) {
            options.headers = options.headers || {};
            options.headers['Authorization'] = 'Bearer $_authToken';
            return originalFetch(url, options);
          };
          
          const originalXHROpen = XMLHttpRequest.prototype.open;
          XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
            this.addEventListener('readystatechange', function() {
              if (this.readyState === 1) {
                this.setRequestHeader('Authorization', 'Bearer $_authToken');
              }
            });
            return originalXHROpen.apply(this, arguments);
          };
          
          console.log('🔐 Token JWT inyectado correctamente');
        })();
      ''';

      await _controller!.evaluateJavascript(source: jsCode);
    } catch (e) {
      debugPrint('❌ Error inyectando token: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Añade esto si usas AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // InAppWebView principal con soporte para file uploads
          InAppWebView(
            key: const PageStorageKey('chaplaincyWebView'),
            initialUrlRequest: URLRequest(
              url: WebUri('$BASE_URL/chaplain/stages'),
              headers:
                  _authToken != null
                      ? {
                        'Authorization': 'Bearer $_authToken',
                        'Accept':
                            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                        'User-Agent': 'NSCA-Daily-App/1.0',
                        'Cache-Control': 'no-cache',
                        'Pragma': 'no-cache',
                      }
                      : {
                        'Accept':
                            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                        'User-Agent': 'NSCA-Daily-App/1.0',
                        'Cache-Control': 'no-cache',
                        'Pragma': 'no-cache',
                      },
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              userAgent: 'NSCA-Daily-App/1.0',
              // Habilitar soporte para file uploads
              allowFileAccess: true,
              supportZoom: false,
              useOnLoadResource: true,
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
              
              debugPrint('🌐 Cargando página de capellanía: $BASE_URL/chaplain/stages');
              if (_authToken != null) {
                debugPrint('🔐 Autenticación JWT activa');
              } else {
                debugPrint('⚠️ Sin autenticación');
              }

              // Agregar JavaScript channel
              _controller!.addJavaScriptHandler(
                handlerName: 'FlutterChannel',
                callback: (args) {
                  if (args.isNotEmpty) {
                    _handleJavaScriptMessage(args[0].toString());
                  }
                },
              );
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
              if (url.toString().contains('/login') ||
                  url.toString().contains('/auth')) {
                debugPrint(
                  '⚠️ Redirigiendo al login - Token puede ser inválido',
                );
              }
            },
            onLoadStop: (controller, url) async {
              setState(() => _isLoading = false);

              if (url.toString().contains('/chaplain')) {
                debugPrint('✅ Página de capellanía cargada correctamente');
              } else if (url.toString().contains('/login') ||
                  url.toString().contains('/auth')) {
                debugPrint('❌ Error: Redirigido al login');
              }

              // Inyectar token en la página si es necesario
              if (_authToken != null) {
                _injectTokenIntoPage();
              }
            },
            onReceivedError: (controller, request, error) {
              setState(() => _isLoading = false);
              debugPrint(
                '❌ Error WebView: ${error.type} - ${error.description}',
              );
              _showErrorDialog('WebView Error', 'Error: ${error.description}');
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString();

              // Permitir navegación dentro del dominio de la aplicación
              if (url.startsWith('$BASE_URL/')) {
                return NavigationActionPolicy.ALLOW;
              }

              // Bloquear navegación externa
              debugPrint('🚫 Bloqueando navegación externa: $url');
              return NavigationActionPolicy.CANCEL;
            },
            // ¡ESTA ES LA PARTE CLAVE! Manejo de file uploads
            onCreateWindow: (controller, createWindowAction) async {
              return true;
            },
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT,
              );
            },
          ),

          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
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
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

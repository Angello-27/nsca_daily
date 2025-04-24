import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import './auth_screen.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1) Aquí guardas la lista de resultados:
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();

  // 2) Suscripción a Stream<List<ConnectivityResult>>
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();

    // 3) 'onConnectivityChanged' emite List<ConnectivityResult>
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  // 4) Ahora devuelve una lista
  Future<void> initConnectivity() async {
    List<ConnectivityResult> results;
    try {
      results = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Error al comprobar conectividad: $e');
      return;
    }
    if (!mounted) return;
    _updateConnectionStatus(results);
  }

  // 5) Recibe la lista completa
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      _connectionStatus = results;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 6) Comprueba el primer elemento para ver si hay conexión
    final bool hasConnection =
        _connectionStatus.isNotEmpty &&
        _connectionStatus.first != ConnectivityResult.none;

    return SingleChildScrollView(
      child:
          !hasConnection
              ? Center(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * .22),
                    Image.asset(
                      "assets/images/login_forget.png",
                      height: MediaQuery.of(context).size.height * .27,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('There is no Internet connection'),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('Please check your Internet connection'),
                    ),
                  ],
                ),
              )
              : Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * .22),
                  Center(
                    child: Image.asset(
                      'assets/images/login_forget.png',
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * .27,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AuthScreen.routeName);
                      },
                      color: kPrimaryColor,
                      textColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 150,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        // side: const BorderSide(color: kPrimaryColor),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

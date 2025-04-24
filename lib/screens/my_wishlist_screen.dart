import 'dart:async';
import '../providers/courses.dart';
import '../widgets/wishlist_grid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class MyWishlistScreen extends StatefulWidget {
  const MyWishlistScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyWishlistScreenState createState() => _MyWishlistScreenState();
}

class _MyWishlistScreenState extends State<MyWishlistScreen> {
  // 1) Estado: guardamos la lista de resultados
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  // 2) Suscripción a Stream<List<ConnectivityResult>>
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    // 3) onConnectivityChanged emite List<ConnectivityResult>
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  // 4) initConnectivity devuelve Future<List<ConnectivityResult>>
  Future<void> initConnectivity() async {
    List<ConnectivityResult> results;
    try {
      results = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Error comprobando conectividad: $e');
      return;
    }
    if (!mounted) return;
    _updateConnectionStatus(results);
  }

  // 5) Callback que recibe la lista completa
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
    // 6) Comprueba el primer elemento para ver estado de conexión
    final bool hasConnection =
        _connectionStatus.isNotEmpty &&
        _connectionStatus.first != ConnectivityResult.none;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'My Wishlist',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future:
                Provider.of<Courses>(context, listen: false).fetchMyWishlist(),
            builder: (ctx, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor.withOpacity(0.7),
                  ),
                );
              } else {
                if (dataSnapshot.error != null) {
                  // 7) Si no hay conexión en la lista...
                  if (!hasConnection) {
                    return Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .15,
                          ),
                          Image.asset(
                            "assets/images/no_connection.png",
                            height: MediaQuery.of(context).size.height * .35,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('There is no Internet connection'),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              'Please check your Internet connection',
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(child: Text(dataSnapshot.error.toString()));
                  }
                } else {
                  // 8) Mostrar lista cuando haya datos y conexión
                  return Consumer<Courses>(
                    builder:
                        (context, courseData, child) => AlignedGridView.count(
                          padding: const EdgeInsets.all(10.0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 1,
                          itemCount: courseData.items.length,
                          itemBuilder: (ctx, index) {
                            return WishlistGrid(
                              course: courseData.items[index],
                            );
                            // return Text(myCourseData.items[index].title);
                          },
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                        ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

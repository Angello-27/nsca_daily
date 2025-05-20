import 'dart:async';
import '../constants.dart';
import '../providers/categories.dart';
import '../widgets/sub_category_list_item.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SubCategoryScreen extends StatefulWidget {
  static const routeName = '/sub-cat';
  const SubCategoryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  // 1) Estado como lista de ConnectivityResult
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  // 2) Suscripción a Stream<List<ConnectivityResult>>
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // var _isLoading = false;

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

  // 5) Callback recibe la lista completa
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
    // 6) Determina si hay conexión mirando el primer elemento
    final bool hasConnection =
        _connectionStatus.isNotEmpty &&
        _connectionStatus.first != ConnectivityResult.none;
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final categoryId = routeArgs['category_id'] as int;
    final title = routeArgs['title'];
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(title, maxLines: 2),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 15),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: Provider.of<Categories>(
            context,
            listen: false,
          ).fetchSubCategories(categoryId),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * .5,
                child: Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor.withOpacity(0.7),
                  ),
                ),
              );
            } else if (dataSnapshot.error != null) {
              // 7) Si falla y NO hay conexión:
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
                        child: Text('Please check your Internet connection'),
                      ),
                    ],
                  ),
                );
              } else {
                // Error distinto cuando sí hay red
                return const Center(child: Text('Error Occured'));
              }
            } else {
              // 8) Datos cargados y hay conexión: tu ListView
              return Consumer<Categories>(
                builder:
                    (context, myCourseData, child) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Showing ${myCourseData.subItems.length} Sub-Categories',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: myCourseData.subItems.length,
                            itemBuilder: (ctx, index) {
                              return SubCategoryListItem(
                                id: myCourseData.subItems[index].id,
                                title: myCourseData.subItems[index].title,
                                parent: myCourseData.subItems[index].parent,
                                numberOfCourses:
                                    myCourseData
                                        .subItems[index]
                                        .numberOfCourses,
                                index: index,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
              );
            }
          },
        ),
      ),
    );
  }
}

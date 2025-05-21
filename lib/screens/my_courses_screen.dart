// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:convert';
import '../providers/my_bundles.dart';
import '../providers/my_courses.dart';
import '../widgets/my_bundle_grid.dart';
import '../widgets/my_course_grid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../constants.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  _MyCoursesScreenState createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  // 1) Estado como lista:
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  // 2) Suscripción a Stream<List<ConnectivityResult>>
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool _isLoading = true;
  dynamic bundleStatus = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_smoothScrollToTop);

    addonStatus();
    // … tus otros init (scroll, tabs, addonStatus) …
    initConnectivity();
    // 3) Suscríbete sin casts raros:
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  // 4) initConnectivity ahora maneja Future<List<ConnectivityResult>>
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

  // 5) Callback recibe la lista y la guarda:
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (!mounted) return;
    setState(() {
      _connectionStatus = results;
    });
  }

  @override
  void dispose() {
    // 1) Cancelas la suscripción a la conectividad
    _connectivitySubscription.cancel();
    // 2) Disposes de los controladores
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _scrollListener() {
    // if (fixedScroll) {
    //   _scrollController.jumpTo(0);
    // }
  }

  _smoothScrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  Future<void> addonStatus() async {
    final url = '$BASE_URL/api/addon_status?unique_identifier=course_bundle';
    try {
      final response = await http.get(Uri.parse(url));
      final status = json.decode(response.body)['status'];
      // **Comprueba que el State siga montado antes de setState**
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        bundleStatus = status;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        bundleStatus = false;
      });
      debugPrint('Error en addonStatus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 6) Comprueba el primer valor para saber si hay conexión
    final bool hasConnection =
        _connectionStatus.isNotEmpty &&
        _connectionStatus.first != ConnectivityResult.none;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
              : !hasConnection
              ? Center(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * .15),
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
              )
              : bundleStatus == true
              ? NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, value) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 10,
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: false,
                          indicatorColor: kPrimaryColor,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kPrimaryColor,
                          ),
                          unselectedLabelColor: Colors.black87,
                          dividerHeight: 0,
                          labelColor: Colors.white,
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_lesson, size: 15),
                                  Text(
                                    'My Courses',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.all_inbox, size: 15),
                                  Text(
                                    'My Bundles',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [courseView(), bundleView()],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'My Courses',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    courseView(),
                  ],
                ),
              ),
    );
  }

  Widget courseView() {
    return FutureBuilder(
      future: Provider.of<MyCourses>(context, listen: false).fetchMyCourses(),
      builder: (ctx, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * .7,
            child: Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor.withOpacity(0.7),
              ),
            ),
          );
        } else {
          if (dataSnapshot.error != null) {
            //error
            return _connectionStatus == ConnectivityResult.none
                ? Center(
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
                )
                : Center(
                  // child: Text('Error Occured'),
                  child: Text(dataSnapshot.error.toString()),
                );
          } else {
            return Consumer<MyCourses>(
              builder:
                  (context, myCourseData, child) => AlignedGridView.count(
                    padding: const EdgeInsets.all(10.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 1,
                    itemCount: myCourseData.items.length,
                    itemBuilder: (ctx, index) {
                      return MyCourseGrid(myCourse: myCourseData.items[index]);
                      // return Text(myCourseData.items[index].title);
                    },
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5.0,
                  ),
            );
          }
        }
      },
    );
  }

  Widget bundleView() {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: Provider.of<MyBundles>(context, listen: false).fetchMybundles(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor.withOpacity(0.7),
              ),
            );
          } else {
            if (dataSnapshot.error != null) {
              //error
              return _connectionStatus == ConnectivityResult.none
                  ? Center(
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
                  )
                  : Center(
                    // child: Text('Error Occured'),
                    child: Text(dataSnapshot.error.toString()),
                  );
            } else {
              return Consumer<MyBundles>(
                builder:
                    (context, myBundleData, child) => AlignedGridView.count(
                      padding: const EdgeInsets.all(10.0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      itemCount: myBundleData.bundleItems.length,
                      itemBuilder: (ctx, index) {
                        return MyBundleGrid(
                          myBundle: myBundleData.bundleItems[index],
                        );
                        // return Text(myCourseData.items[index].title);
                      },
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                    ),
              );
            }
          }
        },
      ),
    );
  }
}

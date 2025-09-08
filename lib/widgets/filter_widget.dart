// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import '../models/all_category.dart';
import '../models/category.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/misc_provider.dart';
import '../providers/courses.dart';
import '../providers/categories.dart';
import './custom_text.dart';
import './star_display_widget.dart';
import '../screens/courses_screen.dart';
import '../models/common_functions.dart';

class FilterWidget extends StatefulWidget {
  const FilterWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  var _isInit = true;
  var _isLoading = false;
  var subIndex = 0;
  var data = <AllSubCategory>[];
  String _selectedCategory = 'all';
  dynamic _selectedSubCat;
  String _selectedPrice = 'all';
  String _selectedLevel = 'all';
  String _selectedLanguage = 'all';
  String _selectedRating = 'all';

  // 1) Estado como lista
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  // 2) Suscripción a Stream<List<ConnectivityResult>>
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    // 3) onConnectivityChanged ahora emite List<ConnectivityResult>
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

  // 5) Callback que recibe la lista
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
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Categories>(context, listen: false).fetchAllCategory().then((
        _,
      ) {
        setState(() {
          _isLoading = false;
        });
      });

      Provider.of<Languages>(context).fetchLanguages().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _resetForm() {
    setState(() {
      _selectedCategory = 'all';
      _selectedSubCat = null;
      _selectedPrice = 'all';
      _selectedLevel = 'all';
      _selectedLanguage = 'all';
      _selectedRating = 'all';
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedSubCat != null) {
        await Provider.of<Courses>(context, listen: false).filterCourses(
          _selectedSubCat,
          _selectedPrice,
          _selectedLevel,
          _selectedLanguage,
          _selectedRating,
        );
      } else {
        await Provider.of<Courses>(context, listen: false).filterCourses(
          _selectedCategory,
          _selectedPrice,
          _selectedLevel,
          _selectedLanguage,
          _selectedRating,
        );
      }
      Navigator.of(context).pushNamed(
        CoursesScreen.routeName,
        arguments: {
          'category_id': null,
          'search_query': null,
          'type': CoursesPageData.Filter,
        },
      );
    } catch (error) {
      const errorMsg = 'Could not process request!';
      CommonFunctions.showErrorDialog(errorMsg, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasConnection = _hasConnection();

    // 1) Si estamos cargando INICIAL y no hay red:
    if (_isLoading && !hasConnection) {
      return _noConnectionView();
    }

    // 2) Ponemos a punto las listas de categorías y lenguajes:
    _prepareDropdownData(context);

    // 3) Si seguimos cargando (pero hay red), mostramos spinner:
    if (_isLoading) {
      return _loadingView();
    }

    // 4) Finalmente, devolvemos la UI principal:
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),
            _buildAppBar(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: _buildFilterForm(context),
            ),
          ],
        ),
      ),
    );
  }

  // Comprueba la conexión:
  bool _hasConnection() {
    return _connectionStatus.isNotEmpty &&
        _connectionStatus.first != ConnectivityResult.none;
  }

  // Pantalla cuando NO tenemos conexión:
  Widget _noConnectionView() {
    return Center(
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
    );
  }

  // Indicador de carga:
  Widget _loadingView() {
    return Center(
      child: CircularProgressIndicator(color: kPrimaryColor.withValues(alpha: 0.7)),
    );
  }

  // AppBar personalizado:
  Widget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0.5,
      title: const Text(
        'Filter Courses',
        style: TextStyle(
          fontSize: 18,
          color: kTextColor,
          fontWeight: FontWeight.w400,
        ),
      ),
      iconTheme: const IconThemeData(color: kSecondaryColor),
      backgroundColor: kBackgroundColor,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.cancel_outlined,
            color: Colors.black38,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  // Prepara las listas de dropdown una sola vez:
  void _prepareDropdownData(BuildContext ctx) {
    final catData = Provider.of<Categories>(ctx, listen: false).items;
    if (catData.isEmpty || catData.first.id != 0) {
      catData.insert(
        0,
        Category(
          id: 0,
          title: 'All Category',
          thumbnail: null,
          numberOfCourses: null,
          numberOfSubCategories: null,
        ),
      );
    }
    final langData = Provider.of<Languages>(ctx, listen: false).items;
    if (langData.isEmpty || langData.first.id != 0) {
      langData.insert(
        0,
        Language(id: 0, value: 'all', displayedValue: 'All Language'),
      );
    }
    final allCategory = Provider.of<Categories>(ctx, listen: false).allItems;
    if (allCategory.isEmpty || allCategory.first.id != 0) {
      allCategory.insert(
        0,
        AllCategory(id: 0, title: 'All Category', subCategory: data),
      );
    }
  }

  // Construye todo el formulario de filtros:
  Widget _buildFilterForm(BuildContext ctx) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(text: 'Category', fontSize: 17, colors: kTextColor),
          _buildCategoryDropdown(ctx),
          const CustomText(
            text: 'Sub Category',
            fontSize: 17,
            colors: kTextColor,
          ),
          _buildSubCategoryDropdown(ctx),
          const CustomText(text: 'Pricing', fontSize: 17, colors: kTextColor),
          _buildPriceDropdown(),
          const CustomText(text: 'Level', fontSize: 17, colors: kTextColor),
          _buildLevelDropdown(),
          const CustomText(text: 'Language', fontSize: 17, colors: kTextColor),
          _buildLanguageDropdown(),
          const CustomText(text: 'Rating', fontSize: 17, colors: kTextColor),
          _buildRatingDropdown(),
          const SizedBox(height: 10),
          _buildResetAndFilterButtons(),
        ],
      ),
    );
  }

  // Helper methods extracted from FilterWidget:

  // 1) Category dropdown
  Widget _buildCategoryDropdown(BuildContext ctx) {
    final catData = Provider.of<Categories>(ctx, listen: false).items;
    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButton<String>(
          dropdownColor: kBackgroundColor,
          value: _selectedCategory,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedSubCat = null;
              _selectedCategory = value!;
            });
          },
          items:
              catData.map((cd) {
                return DropdownMenuItem<String>(
                  value: cd.id == 0 ? 'all' : cd.id.toString(),
                  onTap: () {
                    setState(() {
                      subIndex = catData.indexOf(cd);
                    });
                  },
                  child: Text(cd.title.toString()),
                );
              }).toList(),
        ),
      ),
    );
  }

  // 2) Sub-category dropdown
  Widget _buildSubCategoryDropdown(BuildContext ctx) {
    final allCategory = Provider.of<Categories>(ctx, listen: false).allItems;
    final subCategories = allCategory[subIndex].subCategory;
    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButton<String>(
          dropdownColor: kBackgroundColor,
          value: _selectedSubCat,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          isExpanded: true,
          hint: const Text('All Sub-Category'),
          onChanged: (value) {
            setState(() {
              _selectedSubCat = value!;
            });
          },
          items:
              subCategories.map((sc) {
                return DropdownMenuItem<String>(
                  value: sc.id == 0 ? 'all' : sc.id.toString(),
                  child: Text(sc.title.toString()),
                );
              }).toList(),
        ),
      ),
    );
  }

  // 3) Price dropdown
  Widget _buildPriceDropdown() {
    final filters = PriceFilter.getPriceFilter();
    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButton<String>(
          dropdownColor: kBackgroundColor,
          value: _selectedPrice,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedPrice = value!;
            });
          },
          items:
              filters.map((pf) {
                return DropdownMenuItem<String>(
                  value: pf.id,
                  child: Text(pf.name),
                );
              }).toList(),
        ),
      ),
    );
  }

  // 4) Level dropdown
  Widget _buildLevelDropdown() {
    final levels = DifficultyLevel.getDifficultyLevel();
    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButton<String>(
          dropdownColor: kBackgroundColor,
          value: _selectedLevel,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedLevel = value!;
            });
          },
          items:
              levels.map((dl) {
                return DropdownMenuItem<String>(
                  value: dl.id,
                  child: Text(dl.name),
                );
              }).toList(),
        ),
      ),
    );
  }

  // 5) Language dropdown
  Widget _buildLanguageDropdown() {
    final langData = Provider.of<Languages>(context, listen: false).items;
    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButton<String>(
          dropdownColor: kBackgroundColor,
          value: _selectedLanguage,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedLanguage = value!;
            });
          },
          items:
              langData.map((ld) {
                return DropdownMenuItem<String>(
                  value: ld.value,
                  child: Text(ld.displayedValue.toString()),
                );
              }).toList(),
        ),
      ),
    );
  }

  // 6) Rating dropdown
  Widget _buildRatingDropdown() {
    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButton<String>(
          dropdownColor: kBackgroundColor,
          value: _selectedRating,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedRating = value!;
            });
          },
          items:
              [0, 1, 2, 3, 4, 5].map((item) {
                return DropdownMenuItem<String>(
                  value: item == 0 ? 'all' : item.toString(),
                  child:
                      item == 0
                          ? const Text('All Rating')
                          : StarDisplayWidget(
                            value: item,
                            filledStar: const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 15,
                            ),
                            unfilledStar: const Icon(
                              Icons.star,
                              color: Colors.grey,
                              size: 15,
                            ),
                          ),
                );
              }).toList(),
        ),
      ),
    );
  }

  // 7) Reset button
  Widget _resetButton() {
    return MaterialButton(
      elevation: 0.5,
      onPressed: _resetForm,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      textColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
        side: const BorderSide(color: Colors.white),
      ),
      child: const Text(
        'Reset',
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      ),
    );
  }

  // 8) Filter button
  Widget _filterButton() {
    return MaterialButton(
      elevation: 0.5,
      onPressed: _submitForm,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: kPrimaryColor,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
        side: const BorderSide(color: kPrimaryColor),
      ),
      child: const Text(
        'Filter',
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      ),
    );
  }

  Row _buildResetAndFilterButtons() {
    return Row(
      children: [
        Expanded(flex: 5, child: _resetButton()),
        const Spacer(flex: 2),
        Expanded(flex: 5, child: _filterButton()),
      ],
    );
  }
}

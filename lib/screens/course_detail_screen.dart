// ignore_for_file: deprecated_member_use, use_build_context_synchronously, prefer_const_constructors

import 'package:nsca_daily/providers/my_courses.dart';

import '../models/common_functions.dart';
import '../providers/shared_pref_helper.dart';
import '../widgets/custom_text.dart';
import '../widgets/from_vimeo_player.dart';
import '../widgets/lesson_list_item.dart';
import '../widgets/new_youtube_player.dart';
import '../widgets/star_display_widget.dart';
import '../widgets/tab_view_details.dart';
import '../widgets/util.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/provider.dart';
// import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../providers/courses.dart';
import '../widgets/app_bar_two.dart';
import '../widgets/from_network.dart';

class CourseDetailScreen extends StatefulWidget {
  static const routeName = '/course-details';
  const CourseDetailScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  var _isInit = true;
  bool _isAuth = false;
  var _isLoading = false;
  String? _authToken;
  dynamic loadedCourseDetail;
  dynamic loadedCourse;
  dynamic courseId;
  int? selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadData();
      _isInit = false;
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final token = await SharedPreferenceHelper().getAuthToken();
    _isAuth = token != null && token.isNotEmpty;

    // Obtén el ID que vino en los argumentos
    courseId = ModalRoute.of(context)!.settings.arguments as int;

    // 1) Intenta cargar el curso desde Courses
    try {
      loadedCourse = Provider.of<Courses>(
        context,
        listen: false,
      ).findById(courseId);
    } on StateError {
      // 2) Si falla (no existe en Courses), carga desde MyCourses
      loadedCourse = Provider.of<MyCourses>(
        context,
        listen: false,
      ).findById(courseId);
    }

    // 3) Luego carga los detalles vía el provider correspondiente
    final courseProvider =
        _isAuth
            ? Provider.of<Courses>(context, listen: false)
            : Provider.of<MyCourses>(context, listen: false);

    await courseProvider.fetchCourseDetailById(courseId);

    setState(() {
      loadedCourseDetail = courseProvider.getCourseDetail;
      _isLoading = false;
    });
  }

  void _launchURL(String url) async =>
      await canLaunch(url)
          ? await launch(url, forceSafariVC: false)
          : throw 'Could not launch $url';

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarTwo(),
      backgroundColor: kBackgroundColor,
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor.withOpacity(0.7),
                ),
              )
              : Consumer<Courses>(
                builder: (context, courses, child) {
                  final loadedCourseDetail = courses.getCourseDetail;
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Stack(
                            fit: StackFit.loose,
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  alignment: Alignment.center,
                                  height:
                                      MediaQuery.of(context).size.height / 3.3,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.6),
                                        BlendMode.dstATop,
                                      ),
                                      image: NetworkImage(
                                        loadedCourse!.thumbnail,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ClipOval(
                                child: InkWell(
                                  onTap: () {
                                    if (loadedCourse.courseOverviewProvider ==
                                        'vimeo') {
                                      String vimeoVideoId =
                                          loadedCourse.courseOverviewUrl!
                                              .split('/')
                                              .last;
                                      // _showVimeoModal(context, vimeoVideoId);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => FromVimeoPlayer(
                                                courseId: loadedCourse.id!,
                                                vimeoVideoId: vimeoVideoId,
                                              ),
                                        ),
                                      );
                                    } else if (loadedCourse
                                            .courseOverviewProvider ==
                                        'html5') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => PlayVideoFromNetwork(
                                                courseId: loadedCourse.id!,
                                                videoUrl:
                                                    loadedCourse
                                                        .courseOverviewUrl!,
                                              ),
                                        ),
                                      );
                                    } else {
                                      if (loadedCourse
                                          .courseOverviewProvider!
                                          .isEmpty) {
                                        CommonFunctions.showSuccessToast(
                                          'Video url not provided',
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => YoutubeVideoPlayerFlutter(
                                                  courseId: loadedCourse.id!,
                                                  videoUrl:
                                                      loadedCourse
                                                          .courseOverviewUrl!,
                                                ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: 45,
                                    height: 45,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [kDefaultShadow],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Image.asset(
                                        'assets/images/play.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -15,
                                right: 20,
                                child: SizedBox(
                                  height: 45,
                                  width: 45,
                                  child: FittedBox(
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        if (_isAuth) {
                                          var msg =
                                              loadedCourseDetail.isWishlisted;
                                          showDialog(
                                            context: context,
                                            builder:
                                                (BuildContext context) =>
                                                    buildPopupDialogWishList(
                                                      context,
                                                      loadedCourseDetail
                                                          .isWishlisted,
                                                      loadedCourse.id,
                                                      msg,
                                                    ),
                                          );
                                        } else {
                                          CommonFunctions.showSuccessToast(
                                            'Please login first',
                                          );
                                        }
                                      },
                                      tooltip: 'Wishlist',
                                      backgroundColor: kPrimaryColor,
                                      child: Icon(
                                        loadedCourseDetail.isWishlisted!
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    text: loadedCourse.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const Expanded(flex: 1, child: Text('')),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: StarDisplayWidget(
                                  value: loadedCourse.rating!.toInt(),
                                  filledStar: const Icon(
                                    Icons.star,
                                    color: kStarColor,
                                    size: 18,
                                  ),
                                  unfilledStar: const Icon(
                                    Icons.star_border,
                                    color: kStarColor,
                                    size: 18,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(
                                  '( ${loadedCourse.rating}.0 )',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: kTextColor,
                                  ),
                                ),
                              ),
                              CustomText(
                                text:
                                    '${loadedCourse.totalNumberRating}+ Rating',
                                fontSize: 11,
                                colors: kTextColor,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            right: 15,
                            left: 15,
                            top: 0,
                            bottom: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: CustomText(
                                  text: loadedCourse.price.toString(),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  colors: kTextColor,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.share,
                                  color: kSecondaryColor,
                                ),
                                tooltip: 'Share',
                                onPressed: () {
                                  // Share.share(
                                  //     loadedCourse.shareableLink.toString());
                                },
                              ),
                              MaterialButton(
                                onPressed: () async {
                                  _authToken =
                                      await SharedPreferenceHelper()
                                          .getAuthToken();
                                  if (!loadedCourseDetail.isPurchased!) {
                                    if (_authToken != null) {
                                      if (loadedCourse.isFreeCourse == '1') {
                                        // final _url = BASE_URL + '/api/enroll_free_course?course_id=$courseId&auth_token=$_authToken';
                                        Provider.of<MyCourses>(
                                              context,
                                              listen: false,
                                            )
                                            .getEnrolled(courseId)
                                            .then(
                                              (_) =>
                                                  CommonFunctions.showSuccessToast(
                                                    'Enrolled Successfully',
                                                  ),
                                            );
                                      } else {
                                        final url =
                                            '$BASE_URL/api/web_redirect_to_buy_course/$_authToken/$courseId/academybycreativeitem';
                                        _launchURL(url);
                                      }
                                    } else {
                                      CommonFunctions.showSuccessToast(
                                        'Please login first',
                                      );
                                    }
                                  }
                                },
                                color:
                                    loadedCourseDetail.isPurchased!
                                        ? kGreenPurchaseColor
                                        : kPrimaryColor,
                                textColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                splashColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  // side: BorderSide(color: kBlueColor),
                                ),
                                child: Text(
                                  loadedCourseDetail.isPurchased!
                                      ? 'Purchased'
                                      : loadedCourse.isFreeCourse == '1'
                                      ? 'Get Enroll'
                                      : 'Buy Now',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: TabBar(
                                          dividerHeight: 0,
                                          controller: _tabController,
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,
                                          indicator: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: kPrimaryColor,
                                          ),
                                          unselectedLabelColor: kTextColor,
                                          padding: const EdgeInsets.all(10),
                                          labelColor: Colors.white,
                                          tabs: const <Widget>[
                                            Tab(
                                              child: Text(
                                                "Includes",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "Outcomes",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "Requirements",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 300,
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                          left: 10,
                                          top: 0,
                                          bottom: 10,
                                        ),
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: [
                                            TabViewDetails(
                                              titleText: 'What is Included',
                                              listText:
                                                  loadedCourseDetail
                                                      .courseIncludes,
                                            ),
                                            TabViewDetails(
                                              titleText: 'What you will learn',
                                              listText:
                                                  loadedCourseDetail
                                                      .courseOutcomes,
                                            ),
                                            TabViewDetails(
                                              titleText: 'Course Requirements',
                                              listText:
                                                  loadedCourseDetail
                                                      .courseRequirements,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                                child: CustomText(
                                  text: 'Course Curriculum',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  colors: kDarkGreyColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                                child: ListView.builder(
                                  key: Key(
                                    'builder ${selected.toString()}',
                                  ), //attention
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      loadedCourseDetail.mSection!.length,
                                  itemBuilder: (ctx, index) {
                                    final section =
                                        loadedCourseDetail.mSection![index];
                                    return Card(
                                      elevation: 0.3,
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent,
                                          unselectedWidgetColor:
                                              Colors.transparent,
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.black,
                                          ),
                                        ),
                                        child: ExpansionTile(
                                          key: Key(
                                            index.toString(),
                                          ), //attention
                                          initiallyExpanded: index == selected,
                                          onExpansionChanged: ((newState) {
                                            if (newState) {
                                              setState(() {
                                                selected = index;
                                              });
                                            } else {
                                              setState(() {
                                                selected = -1;
                                              });
                                            }
                                          }), //attention
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 5.0,
                                                      ),
                                                  child: CustomText(
                                                    text: HtmlUnescape()
                                                        .convert(
                                                          section.title
                                                              .toString(),
                                                        ),
                                                    colors: kDarkGreyColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: kTimeBackColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                3,
                                                              ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 5.0,
                                                            ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: CustomText(
                                                            text:
                                                                section
                                                                    .totalDuration,
                                                            fontSize: 10,
                                                            colors: kTimeColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10.0),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color:
                                                              kLessonBackColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                3,
                                                              ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 5.0,
                                                            ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  kLessonBackColor,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    3,
                                                                  ),
                                                            ),
                                                            child: CustomText(
                                                              text:
                                                                  '${section.mLesson!.length} Lessons',
                                                              fontSize: 10,
                                                              colors:
                                                                  kDarkGreyColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      flex: 2,
                                                      child: Text(""),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (ctx, index) {
                                                return Column(
                                                  children: [
                                                    LessonListItem(
                                                      lesson:
                                                          section
                                                              .mLesson![index],
                                                      courseId:
                                                          loadedCourseDetail
                                                              .courseId!,
                                                    ),
                                                    if (index <
                                                        section
                                                                .mLesson!
                                                                .length -
                                                            1)
                                                      Divider(
                                                        height: 3,
                                                        color: Colors.grey[200],
                                                      ),
                                                  ],
                                                );
                                              },
                                              itemCount:
                                                  section.mLesson!.length,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

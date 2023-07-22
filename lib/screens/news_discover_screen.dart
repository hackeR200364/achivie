import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:achivie/models/trending_reporters_model.dart';
import 'package:achivie/models/trending_reports_model.dart';
import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/screens/top_reporters_screen.dart';
import 'package:achivie/styles.dart';
import 'package:achivie/widgets/news_bloc_profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../Utils/snackbar_utils.dart';
import '../models/categories_models.dart';
import '../models/reports_by_category_model.dart';
import '../services/keys.dart';
import '../services/shared_preferences.dart';
import '../widgets/news_discover_screen_widget.dart';
import 'news_details_screen.dart';
import 'news_screen.dart';

class NewsDiscoverScreen extends StatefulWidget {
  const NewsDiscoverScreen({Key? key}) : super(key: key);

  @override
  State<NewsDiscoverScreen> createState() => _NewsDiscoverScreenState();
}

class _NewsDiscoverScreenState extends State<NewsDiscoverScreen>
    with TickerProviderStateMixin {
  bool followed = false, saved = false, loading = false;

  final List<Ticker> _tickers = [];
  int newsSliderIndex = 0,
      newsListIndex = 0,
      topItemIndex = 0,
      listLen = 100,
      newsSelectedCategoryIndex = 0,
      pageCount = 1,
      limitCount = 10,
      totalPage = 0;
  String newsSelectedCategory = "All", token = "", uid = "", message = "";
  late TextEditingController commentController;
  late ScrollController _newsScrollController,
      _pageScrollController,
      _catScrollController;
  List<Category> categoryList = [];
  List<ReportByCat> reportsByCat = <ReportByCat>[];
  List<TrendingReport> trendingReportsList = <TrendingReport>[];
  List<TrendingReporter> reporters = [];
  DateTime? dateTime;

  @override
  void initState() {
    commentController = TextEditingController();
    _newsScrollController = ScrollController();
    _pageScrollController = ScrollController();
    _catScrollController = ScrollController();
    _pageScrollController.addListener(_updateScreenOffset);
    _newsScrollController.addListener(_updateState);

    getUsrDetails();
    super.initState();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _newsScrollController.removeListener(_updateState);
    _newsScrollController.dispose();
    _catScrollController.dispose();
    commentController.dispose();

    for (var ticker in _tickers) {
      ticker.dispose();
    }
    super.dispose();
  }

  void _updateState() => setState(() {
        topItemIndex = _getIndexInView();
      });

  void _updateScreenOffset() {
    if (_pageScrollController.position.maxScrollExtent ==
        _pageScrollController.offset) {
      log(newsSelectedCategory);
      if (pageCount < totalPage) {
        fetchTrendingReports(selectedCat: newsSelectedCategory);
      }
      // setState(() {
      //   reports.addAll(reports);
      // });
    }

    // log(_pageScrollController.offset.toString());

    // if (_pageScrollController.offset > 0 && _pageScrollController.offset < 10) {
    //   setState(() {
    //     isTopVisible = false;
    //   });
    // }
    // if (_pageScrollController.offset > 100 &&
    //     _pageScrollController.offset < 101) {
    //   setState(() {
    //     isTopVisible = true;
    //   });
    // }
    // setState(() {
    //   topItemIndex = _getIndexInView();
    //   screenOffset = _pageScrollController.offset;
    //   log(screenOffset.toString());
    // });
  }

  Future fetchTrendingReports({
    required String selectedCat,
  }) async {
    if (pageCount < totalPage) {
      pageCount++;
    }

    if (newsSelectedCategory == "All" && selectedCat == "All") {
      // log("message");

      http.Response response = await http.get(
        Uri.parse(
            "${Keys.apiReportsBaseUrl}/reports/trending/$uid?page=$pageCount&limit=$limitCount"),
        headers: {
          'content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        TrendingReports trendingReports =
            trendingReportsFromJson(response.body);
        if (trendingReports.success) {
          // log(pageCount.toString());
          // log(totalPage.toString());
          trendingReportsList.addAll(trendingReports.reports);
        } else {
          message = "No reports found";
          loading = false;
        }
      }
    }
    setState(() {});

    if (newsSelectedCategory != "All" && selectedCat != "All") {
      selectedCat = Uri.encodeComponent(selectedCat!);
      http.Response response = await http.get(
        Uri.parse(
            "${Keys.apiReportsBaseUrl}/reports/category/search/$uid?page=$pageCount&limit=$limitCount&cat=$selectedCat"),
        headers: {
          'content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final ReportsByCat allReports = reportsByCatFromJson(response.body);
        if (allReports.success) {
          log(pageCount.toString());
          log(totalPage.toString());

          setState(() {
            reportsByCat.addAll(allReports.reports);
          });
        } else {
          message = "No reports found";
          loading = false;
        }
      }
    }
    setState(() {});
  }

  int _getIndexInView() {
    double itemHeight = 10; // calculate the height of each item
    double position = _newsScrollController.position.pixels;
    int index =
        (position / itemHeight).floor() + 1; // add 1 to start from the 2nd item
    // log(index.toString());
    return index;
  }

  void getUsrDetails() async {
    token = await StorageServices.getUsrToken();
    uid = await StorageServices.getUID();
    await refresh();
    setState(() {});
  }

  Future<void> refresh() async {
    pageCount = 1;
    newsSelectedCategory = "All";
    newsSelectedCategoryIndex = 0;
    _catScrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
    setState(() {});

    http.Response trendingReportersResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reporters/trending/$uid?page=1&limit=3",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (trendingReportersResponse.statusCode == 200) {
      Map<String, dynamic> trendingReportersJson =
          jsonDecode(trendingReportersResponse.body);
      if (trendingReportersJson["success"]) {
        TrendingReporters trendingReporters =
            trendingReportersFromJson(trendingReportersResponse.body);
        reporters = trendingReporters.reporters;
      }
    }
    setState(() {});

    http.Response catResponse = await http.get(
      Uri.parse("${Keys.apiReportsBaseUrl}/categories"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (catResponse.statusCode == 200) {
      final blocAllCategories = blocAllCategoriesFromJson(catResponse.body);

      if (blocAllCategories.success) {
        categoryList = blocAllCategories.categories;
      }
    }
    setState(() {});

    await allReportsAPICall();
    setState(() {});

    // http.Response trendingResponse = await http.get(
    //   Uri.parse(
    //       "${Keys.apiReportsBaseUrl}/reports/trending/$uid?page=$pageCount&limit=$limitCount"),
    //   headers: {
    //     'content-Type': 'application/json',
    //     'authorization': 'Bearer $token',
    //   },
    // );
    //
    // if (trendingResponse.statusCode == 200) {
    //   if (jsonDecode(trendingResponse.body)["success"]) {
    //     TrendingReports trendingReports =
    //         trendingReportsFromJson(trendingResponse.body);
    //     // log(trendingReports.message);
    //     trendingReportsList = trendingReports.reports;
    //     totalPage = trendingReports.totalPage;
    //   }
    // }
  }

  Future<void> allReportsAPICall() async {
    // trendingReportsList.clear();
    reportsByCat.clear();
    pageCount = 1;

    http.Response response = await http.get(
      Uri.parse(
          "${Keys.apiReportsBaseUrl}/reports/trending/$uid?page=$pageCount&limit=$limitCount"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> allReportsJson = jsonDecode(response.body);
      if (allReportsJson["success"]) {
        TrendingReports trendingReports =
            trendingReportsFromJson(response.body);

        trendingReportsList = trendingReports.reports;
        totalPage = trendingReports.totalPage;
        // log(trendingReportsList.first.blocName);
        // setState(() {});
      } else {
        message = "No reports found";
        // loading = false;
      }
    }
    setState(() {});

    // log("${trendingReportsList.length.toString()} 87");
  }

  Future<void> allReportsByCatAPICall(String selectedCat) async {
    trendingReportsList.clear();
    reportsByCat.clear();
    selectedCat = Uri.encodeComponent(selectedCat);
    // log(selectedCat.toString());

    http.Response response = await http.get(
      Uri.parse(
          "${Keys.apiReportsBaseUrl}/reports/category/search/$uid?page=$pageCount&limit=$limitCount&cat=$selectedCat"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> reportsByCatJson = jsonDecode(response.body);
      if (reportsByCatJson["success"]) {
        ReportsByCat allReports = reportsByCatFromJson(response.body);
        reportsByCat = allReports.reports;
        totalPage = allReports.totalPage;
        setState(() {});
      } else {
        message = "No reports found";
      }
    }

    setState(() {});
  }

  Future<String> printIps() async {
    List<Map<String, dynamic>> ipList = [];

    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        var ipDetails = {
          'address': addr.address,
          'isLoopback': addr.isLoopback,
          'rawAddress': addr.rawAddress,
          'type': addr.type.name,
        };

        ipList.add(ipDetails);
      }
    }

    String ipDetails = jsonEncode(ipList);
    // print(ipDetails);

    return ipDetails;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: (reporters.isNotEmpty && categoryList.isNotEmpty)
          ? CustomScrollView(
              controller: _pageScrollController,
              slivers: [
                if (reporters.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                      ),
                      child: const DiscoverPageHeading(
                        head: "Top Reporters",
                      ),
                    ),
                  ),
                if (reporters.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: (reporters.length + 1.5) * 40,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.backgroundColour.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 10,
                                    ),
                                    child: ListView.separated(
                                      itemCount: reporters.length,
                                      itemBuilder: (topReportersContext,
                                          topReportersIndex) {
                                        return BlocDetailsRow(
                                          followers:
                                              reporters[topReportersIndex]
                                                  .followers,
                                          blocName: reporters[topReportersIndex]
                                              .blocName,
                                          blocProfilePic:
                                              reporters[topReportersIndex]
                                                  .blocProfile,
                                          followed: reporters[topReportersIndex]
                                              .followed,
                                          followedOnTap: (() {
                                            setState(() {
                                              followed = !followed;
                                            });
                                          }),
                                          onTap: (() {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (profileDetailsContext) =>
                                                    const ReporterPublicProfile(
                                                  blockUID: "",
                                                ),
                                              ),
                                            );
                                          }),
                                        );
                                      },
                                      separatorBuilder:
                                          ((topReportersSeparatorContext,
                                              topReportersSeparatorIndex) {
                                        return Container(
                                          width: MediaQuery.of(
                                                  topReportersSeparatorContext)
                                              .size
                                              .width,
                                          height: 1,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          color:
                                              AppColors.white.withOpacity(0.3),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                ShowAllBtn(
                                  onTap: (() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (topReportersScreenContext) =>
                                            const TopReportersScreen(),
                                      ),
                                    );
                                  }),
                                  head: "Show All",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (reporters.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: ShimmerChild(
                        height: 15,
                        width: MediaQuery.of(context).size.width / 2,
                        radius: 15,
                      ),
                    ),
                  ),
                if (reporters.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      height: 270,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 5,
                        top: 15,
                      ),
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 15,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColour.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          ReporterShimmer(),
                          ReporterShimmer(),
                          ReporterShimmer(),
                          Container(
                            margin: EdgeInsets.only(
                              top: 10,
                              bottom: 15,
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: 1,
                            color: AppColors.white.withOpacity(0.3),
                          ),
                          ShimmerChild(
                            height: 15,
                            width: MediaQuery.of(context).size.width / 4,
                            radius: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (categoryList.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                      ),
                      child: const DiscoverPageHeading(
                        head: "Trending Reports",
                      ),
                    ),
                  ),
                if (categoryList.isNotEmpty)
                  SliverAppBar(
                    expandedHeight: 40,
                    backgroundColor: AppColors.mainColor,
                    elevation: 0,
                    pinned: true,
                    // title: Text(
                    //   "Top News",
                    //   style: TextStyle(
                    //     color: AppColors.white,
                    //     fontSize: 15,
                    //   ),
                    // ),
                    flexibleSpace: Container(
                      // padding: EdgeInsets.only(top: 10, bottom: 10),
                      height: 60,
                      // width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: categoryList.length,
                              scrollDirection: Axis.horizontal,
                              controller: _catScrollController,
                              itemBuilder: (newsCatContext, index) {
                                return CategoryContainer(
                                  newsSelectedCategoryIndex:
                                      newsSelectedCategoryIndex,
                                  categoryList: categoryList,
                                  index: index,
                                  onTap: (() async {
                                    pageCount = 1;
                                    newsSelectedCategory =
                                        categoryList[index].reportCat;

                                    if (categoryList[index].reportCat ==
                                        "All") {
                                      allReportsAPICall();
                                      // log(trendingReportsList[index].blocId);
                                    }
                                    newsSelectedCategoryIndex = index;
                                    setState(() {});
                                    // log(categoryList[index].reportCat);
                                    HapticFeedback.heavyImpact();

                                    await allReportsByCatAPICall(
                                        categoryList[index].reportCat);
                                    // setState(() {});
                                  }),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  width: 10,
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (categoryList.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: ShimmerChild(
                        height: 15,
                        width: MediaQuery.of(context).size.width / 2,
                        radius: 15,
                      ),
                    ),
                  ),
                if (categoryList.isEmpty)
                  SliverAppBar(
                    expandedHeight: 40,
                    backgroundColor: AppColors.mainColor,
                    elevation: 0,
                    pinned: true,
                    flexibleSpace: Container(
                      height: 60,
                      margin: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: 50,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (newsCatContext, index) {
                                return Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundColour
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  width: 10,
                                );
                                //               .reportTumbImage,
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (trendingReportsList.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: trendingReportsList.length + 1,
                      (context, index) {
                        if (index < trendingReportsList.length) {
                          return ReportContainer(
                            tag: trendingReportsList[index].blocId,
                            followers: trendingReportsList[index].followers,
                            blocName: trendingReportsList[index].blocName,
                            blocProfile: trendingReportsList[index].blocProfile,
                            followed: trendingReportsList[index].followed,
                            reportCat: trendingReportsList[index].reportCat,
                            reportHeadline:
                                trendingReportsList[index].reportHeadline,
                            reportUploadTime:
                                "${DateFormat('EEEE').format(trendingReportsList[index].reportUploadTime)}, ${trendingReportsList[index].reportUploadTime.day} ${DateFormat('MMMM').format(trendingReportsList[index].reportUploadTime)} ${trendingReportsList[index].reportUploadTime.year}",
                            //"Monday, 26 September 2022",
                            reportTime:
                                "${DateFormat('EEEE').format(DateTime.fromMillisecondsSinceEpoch(int.parse(trendingReportsList[index].reportTime)))}, ${DateTime.fromMillisecondsSinceEpoch(int.parse(trendingReportsList[index].reportTime)).day} ${DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(int.parse(trendingReportsList[index].reportTime)))} ${DateTime.fromMillisecondsSinceEpoch(int.parse(trendingReportsList[index].reportTime)).year}",
                            //"Monday, 26 September 2022",,
                            // "${trendingReportsList[index].reportTime}, ${trendingReportsList[index].reportDate}",
                            reportThumbPic:
                                trendingReportsList[index].reportTumbImage,
                            liked: trendingReportsList[index].liked,
                            likeCount: trendingReportsList[index].reportLikes,
                            likeBtnOnTap: ((liked) async {
                              String usrAddress = await printIps();
                              if (trendingReportsList[index].liked) {
                                http.Response recentResponse = await http.post(
                                  Uri.parse(
                                    "${Keys.apiReportsBaseUrl}/report/like/delete/$uid/${trendingReportsList[index].reportId}",
                                  ),
                                  headers: {
                                    'content-Type': 'application/json',
                                    'authorization': 'Bearer $token',
                                  },
                                );
                                log(recentResponse.statusCode.toString());
                                if (recentResponse.statusCode == 200) {
                                  Map<String, dynamic> recentsResponseJson =
                                      jsonDecode(recentResponse.body);
                                  if (recentsResponseJson["success"]) {
                                    trendingReportsList[index].liked =
                                        recentsResponseJson["liked"];
                                    trendingReportsList[index].reportLikes =
                                        trendingReportsList[index].reportLikes -
                                            1;
                                    setState(() {});
                                    return recentsResponseJson["liked"];
                                  } else {
                                    trendingReportsList[index].liked =
                                        recentsResponseJson["success"];
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message: recentsResponseJson["message"],
                                        context: context,
                                      ),
                                    );
                                  }
                                  setState(() {});
                                } else {
                                  trendingReportsList[index].liked = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    AppSnackbar().customizedAppSnackbar(
                                      message: "Something went wrong",
                                      context: context,
                                    ),
                                  );
                                }
                                setState(() {});
                                return false;
                              } else if (!trendingReportsList[index].liked) {
                                // usrAddress = Uri.encodeComponent(usrAddress);
                                http.Response recentResponse = await http.post(
                                  Uri.parse(
                                    "${Keys.apiReportsBaseUrl}/report/like/add/$uid/${trendingReportsList[index].reportId}/${trendingReportsList[index].reportBlocId}/$usrAddress",
                                  ),
                                  headers: {
                                    'content-Type': 'application/json',
                                    'authorization': 'Bearer $token',
                                  },
                                );
                                log(recentResponse.statusCode.toString());
                                if (recentResponse.statusCode == 200) {
                                  Map<String, dynamic> recentsResponseJson =
                                      jsonDecode(recentResponse.body);
                                  if (recentsResponseJson["success"]) {
                                    trendingReportsList[index].liked =
                                        recentsResponseJson["success"];
                                    trendingReportsList[index].reportLikes =
                                        trendingReportsList[index].reportLikes +
                                            1;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message: recentsResponseJson["message"],
                                        context: context,
                                      ),
                                    );
                                    setState(() {});
                                    return true;
                                  }
                                  trendingReportsList[index].liked =
                                      recentsResponseJson["success"];
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    AppSnackbar().customizedAppSnackbar(
                                      message: recentsResponseJson["message"],
                                      context: context,
                                    ),
                                  );
                                  setState(() {});
                                  return false;
                                }
                                trendingReportsList[index].liked = false;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  AppSnackbar().customizedAppSnackbar(
                                    message: "Something went wrong",
                                    context: context,
                                  ),
                                );
                                setState(() {});
                              }
                              return false;
                            }),
                            reportOnDoubleTap: (() async {
                              String usrAddress = await printIps();
                              if (!trendingReportsList[index].liked) {
                                // usrAddress = Uri.encodeComponent(usrAddress);
                                http.Response recentResponse = await http.post(
                                  Uri.parse(
                                    "${Keys.apiReportsBaseUrl}/report/like/add/$uid/${trendingReportsList[index].reportId}/${trendingReportsList[index].reportBlocId}/$usrAddress",
                                  ),
                                  headers: {
                                    'content-Type': 'application/json',
                                    'authorization': 'Bearer $token',
                                  },
                                );
                                log(recentResponse.statusCode.toString());
                                if (recentResponse.statusCode == 200) {
                                  Map<String, dynamic> recentsResponseJson =
                                      jsonDecode(recentResponse.body);
                                  if (recentsResponseJson["success"]) {
                                    trendingReportsList[index].liked =
                                        recentsResponseJson["success"];
                                    trendingReportsList[index].reportLikes =
                                        trendingReportsList[index].reportLikes +
                                            1;
                                  } else {
                                    trendingReportsList[index].liked =
                                        recentsResponseJson["success"];
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message: recentsResponseJson["message"],
                                        context: context,
                                      ),
                                    );
                                  }
                                } else {
                                  trendingReportsList[index].liked = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    AppSnackbar().customizedAppSnackbar(
                                      message: "Something went wrong",
                                      context: context,
                                    ),
                                  );
                                }
                                setState(() {});
                              }
                            }),
                            commentCount: NumberFormat.compact()
                                .format(
                                    trendingReportsList[index].reportComments)
                                .toString(),
                            reportOnTap: (() {
                              // log(trendingReportsList[index].saved.toString());
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (newsDetailsScreenContext) =>
                                      NewsDetailsScreen(
                                    reportID:
                                        trendingReportsList[index].reportId,
                                    reportUsrID:
                                        trendingReportsList[index].reportUsrId,
                                    usrID: uid,
                                  ),
                                ),
                              );
                            }),
                            blocDetailsOnTap: (() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (profileDetailsContext) =>
                                      ReporterPublicProfile(
                                    blockUID: trendingReportsList[index].blocId,
                                  ),
                                ),
                              );
                            }),
                            commentBtnOnTap: (() {
                              showModalBottomSheet(
                                backgroundColor: AppColors.mainColor,
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                builder: (commentModelContext) =>
                                    CommentModalSheet(
                                  commentController: commentController,
                                  reporterProfilePic:
                                      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                  blocID: 'Rupam Karmakar',
                                  commentTime: '12h',
                                  comment:
                                      "commentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdf",
                                  commentModelContext: commentModelContext,
                                ),
                              );
                            }),
                            saveBtnOnTap: (() {}),
                            followedOnTap: (() async {
                              if (!trendingReportsList[index].followed) {
                                http.Response recentResponse = await http.post(
                                  Uri.parse(
                                    "${Keys.apiReportsBaseUrl}/follow",
                                  ),
                                  headers: {
                                    'content-Type': 'application/json',
                                    'authorization': 'Bearer $token',
                                  },
                                );
                                log(recentResponse.statusCode.toString());
                                if (recentResponse.statusCode == 200) {
                                  Map<String, dynamic> recentsResponseJson =
                                      jsonDecode(recentResponse.body);
                                  if (recentsResponseJson["success"]) {
                                    HapticFeedback.heavyImpact();
                                    trendingReportsList[index].followed =
                                        recentsResponseJson["followed"];
                                    trendingReportsList[index].followers =
                                        trendingReportsList[index].followers +
                                            1;
                                  } else {
                                    trendingReportsList[index].followed =
                                        recentsResponseJson["success"];
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message: recentsResponseJson["message"],
                                        context: context,
                                      ),
                                    );
                                  }
                                } else {
                                  trendingReportsList[index].followed = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    AppSnackbar().customizedAppSnackbar(
                                      message: "Something went wrong",
                                      context: context,
                                    ),
                                  );
                                }
                              }

                              setState(() {});
                            }),
                            saved: saved,
                            commented: trendingReportsList[index].commented,
                          );
                        } else if (pageCount < totalPage) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.backgroundColour,
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                if ((newsSelectedCategory == "All" &&
                        trendingReportsList.isEmpty) ||
                    (newsSelectedCategory != "All" && reportsByCat.isEmpty))
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: 1,
                      (context, index) => Container(
                        height: 530,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                        ),
                        padding: const EdgeInsets.only(
                          left: 0,
                          right: 0,
                          top: 10,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColour.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ReporterShimmer(),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 15),
                              height: 30,
                              width: MediaQuery.of(context).size.width / 4,
                              decoration: BoxDecoration(
                                // shape: shape,
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.white.withOpacity(0.08),
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                              ),
                              child: Row(
                                children: [
                                  ShimmerChild(
                                    height: 17,
                                    width:
                                        MediaQuery.of(context).size.width / 1.9,
                                    radius: 10,
                                  ),
                                  SizedBox(width: 5),
                                  Container(
                                    height: 17,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    decoration: BoxDecoration(
                                      // shape: shape,
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.backgroundColour
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 17,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    decoration: BoxDecoration(
                                      // shape: shape,
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.backgroundColour
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  ShimmerChild(
                                    height: 17,
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    radius: 10,
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    height: 17,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    decoration: BoxDecoration(
                                      // shape: shape,
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.backgroundColour
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                              ),
                              child: Row(
                                children: [
                                  ShimmerChild(
                                    height: 10,
                                    width:
                                        MediaQuery.of(context).size.width / 6,
                                    radius: 10,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  ShimmerChild(
                                    height: 10,
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    radius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                              ),
                              child: Row(
                                children: [
                                  ShimmerChild(
                                    height: 10,
                                    width:
                                        MediaQuery.of(context).size.width / 6,
                                    radius: 10,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  ShimmerChild(
                                    height: 10,
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    radius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                              ),
                              child: ShimmerChild(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                radius: 15,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 40,
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.thumb_up,
                                            color: AppColors.white
                                                .withOpacity(0.2),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          ShimmerChild(
                                            height: 15,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                8,
                                            radius: 10,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                25,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.comment,
                                            color: AppColors.white
                                                .withOpacity(0.2),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          ShimmerChild(
                                            height: 15,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                8,
                                            radius: 10,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ShimmerChild(
                                    height: 25,
                                    width:
                                        MediaQuery.of(context).size.width / 3.5,
                                    radius: 15,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (reportsByCat.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: reportsByCat.length + 1,
                      (context, index) {
                        if (index < reportsByCat.length) {
                          return ReportContainer(
                            tag: reportsByCat[index].blocId,
                            followers: reportsByCat[index].followers,
                            blocName: reportsByCat[index].blocName,
                            blocProfile: reportsByCat[index].blocProfile,
                            followed: reportsByCat[index].followed ?? false,
                            reportCat: reportsByCat[index].reportCat,
                            reportHeadline: reportsByCat[index].reportHeadline,
                            reportUploadTime:
                                "${DateFormat('EEEE').format(reportsByCat[index].reportUploadTime)}, ${reportsByCat[index].reportUploadTime.day} ${DateFormat('MMMM').format(reportsByCat[index].reportUploadTime)} ${reportsByCat[index].reportUploadTime.year}", //"Monday, 26 September 2022",
                            reportTime: "${DateFormat('EEEE').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                int.parse(reportsByCat[index].reportTime),
                              ),
                            )}, ${DateTime.fromMillisecondsSinceEpoch(
                              int.parse(reportsByCat[index].reportTime),
                            ).day} ${DateFormat('MMMM').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                int.parse(reportsByCat[index].reportTime),
                              ),
                            )} ${DateTime.fromMillisecondsSinceEpoch(
                              int.parse(reportsByCat[index].reportTime),
                            ).year}",
                            reportThumbPic: reportsByCat[index].reportTumbImage,
                            likeCount: reportsByCat[index].reportLikes,
                            commentCount: NumberFormat.compact()
                                .format(reportsByCat[index].reportComments)
                                .toString(),
                            saved: saved,
                            reportOnTap: (() {
                              log(reportsByCat[index].reportId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (newsDetailsScreenContext) =>
                                      NewsDetailsScreen(
                                    reportID: reportsByCat[index].reportId,
                                    reportUsrID:
                                        reportsByCat[index].reportUsrId,
                                    usrID: uid,
                                  ),
                                ),
                              );
                            }),
                            blocDetailsOnTap: (() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (profileDetailsContext) =>
                                      ReporterPublicProfile(
                                    blockUID: reportsByCat[index].blocId,
                                  ),
                                ),
                              );
                            }),
                            likeBtnOnTap: ((liked) async {
                              String usrAddress = await printIps();
                              if (reportsByCat[index].liked) {
                                http.Response recentResponse = await http.post(
                                  Uri.parse(
                                    "${Keys.apiReportsBaseUrl}/report/like/delete/$uid/${reportsByCat[index].reportId}",
                                  ),
                                  headers: {
                                    'content-Type': 'application/json',
                                    'authorization': 'Bearer $token',
                                  },
                                );
                                log(recentResponse.statusCode.toString());
                                if (recentResponse.statusCode == 200) {
                                  Map<String, dynamic> recentsResponseJson =
                                      jsonDecode(recentResponse.body);
                                  if (recentsResponseJson["success"]) {
                                    reportsByCat[index].liked =
                                        recentsResponseJson["liked"];
                                    reportsByCat[index].reportLikes =
                                        reportsByCat[index].reportLikes - 1;
                                    setState(() {});
                                    return recentsResponseJson["liked"];
                                  } else {
                                    reportsByCat[index].liked =
                                        recentsResponseJson["success"];
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message: recentsResponseJson["message"],
                                        context: context,
                                      ),
                                    );
                                  }
                                  setState(() {});
                                } else {
                                  reportsByCat[index].liked = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    AppSnackbar().customizedAppSnackbar(
                                      message: "Something went wrong",
                                      context: context,
                                    ),
                                  );
                                }
                                setState(() {});
                                return false;
                              } else if (!reportsByCat[index].liked) {
                                // usrAddress = Uri.encodeComponent(usrAddress);
                                http.Response recentResponse = await http.post(
                                  Uri.parse(
                                    "${Keys.apiReportsBaseUrl}/report/like/add/$uid/${reportsByCat[index].reportId}/${reportsByCat[index].reportBlocId}/$usrAddress",
                                  ),
                                  headers: {
                                    'content-Type': 'application/json',
                                    'authorization': 'Bearer $token',
                                  },
                                );
                                log(recentResponse.statusCode.toString());
                                if (recentResponse.statusCode == 200) {
                                  Map<String, dynamic> recentsResponseJson =
                                      jsonDecode(recentResponse.body);
                                  if (recentsResponseJson["success"]) {
                                    reportsByCat[index].liked =
                                        recentsResponseJson["success"];
                                    reportsByCat[index].reportLikes =
                                        reportsByCat[index].reportLikes + 1;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message: recentsResponseJson["message"],
                                        context: context,
                                      ),
                                    );
                                    setState(() {});
                                    return true;
                                  }
                                  reportsByCat[index].liked =
                                      recentsResponseJson["success"];
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    AppSnackbar().customizedAppSnackbar(
                                      message: recentsResponseJson["message"],
                                      context: context,
                                    ),
                                  );
                                  setState(() {});
                                  return false;
                                }
                                reportsByCat[index].liked = false;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  AppSnackbar().customizedAppSnackbar(
                                    message: "Something went wrong",
                                    context: context,
                                  ),
                                );
                                setState(() {});
                              }
                              return false;
                            }),
                            reportOnDoubleTap: (() async {
                              String usrAddress = await printIps();
                              if (!reportsByCat[index].liked) {
                                // usrAddress = Uri.encodeComponent(usrAddress);
                                http.Response recentResponse = await http.post(
                                  Uri.parse(
                                    "${Keys.apiReportsBaseUrl}/report/like/add/$uid/${reportsByCat[index].reportId}/${reportsByCat[index].reportBlocId}/$usrAddress",
                                  ),
                                  headers: {
                                    'content-Type': 'application/json',
                                    'authorization': 'Bearer $token',
                                  },
                                );
                                log(recentResponse.statusCode.toString());
                                if (recentResponse.statusCode == 200) {
                                  Map<String, dynamic> recentsResponseJson =
                                      jsonDecode(recentResponse.body);
                                  if (recentsResponseJson["success"]) {
                                    reportsByCat[index].liked =
                                        recentsResponseJson["success"];
                                    reportsByCat[index].reportLikes =
                                        reportsByCat[index].reportLikes + 1;
                                  } else {
                                    reportsByCat[index].liked =
                                        recentsResponseJson["success"];
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message: recentsResponseJson["message"],
                                        context: context,
                                      ),
                                    );
                                  }
                                } else {
                                  reportsByCat[index].liked = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    AppSnackbar().customizedAppSnackbar(
                                      message: "Something went wrong",
                                      context: context,
                                    ),
                                  );
                                }
                                setState(() {});
                              }
                            }),
                            commentBtnOnTap: (() {
                              showModalBottomSheet(
                                backgroundColor: AppColors.mainColor,
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                builder: (commentModelContext) =>
                                    CommentModalSheet(
                                  commentController: commentController,
                                  reporterProfilePic:
                                      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                  blocID: 'Rupam Karmakar',
                                  commentTime: '12h',
                                  comment:
                                      "commentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdf",
                                  commentModelContext: commentModelContext,
                                ),
                              );
                            }),
                            saveBtnOnTap: (() {}),
                            followedOnTap: (() async {
                              if (!reportsByCat[index].followed) {
                                http.Response recentResponse = await http.post(
                                  Uri.parse(
                                    "${Keys.apiReportsBaseUrl}/follow",
                                  ),
                                  headers: {
                                    'content-Type': 'application/json',
                                    'authorization': 'Bearer $token',
                                  },
                                );
                                log(recentResponse.statusCode.toString());
                                if (recentResponse.statusCode == 200) {
                                  Map<String, dynamic> recentsResponseJson =
                                      jsonDecode(recentResponse.body);
                                  if (recentsResponseJson["success"]) {
                                    HapticFeedback.heavyImpact();
                                    reportsByCat[index].followed =
                                        recentsResponseJson["followed"];
                                    reportsByCat[index].followers =
                                        reportsByCat[index].followers + 1;
                                  } else {
                                    reportsByCat[index].followed =
                                        recentsResponseJson["success"];
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message: recentsResponseJson["message"],
                                        context: context,
                                      ),
                                    );
                                  }
                                } else {
                                  reportsByCat[index].followed = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    AppSnackbar().customizedAppSnackbar(
                                      message: "Something went wrong",
                                      context: context,
                                    ),
                                  );
                                }
                              }

                              setState(() {});
                            }),
                            liked: reportsByCat[index].liked!,
                            commented: reportsByCat[index].commented!,
                          );
                        } else if (pageCount < totalPage) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                color: AppColors.backgroundColour,
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
              ],
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      right: 10,
                      left: 10,
                    ),
                    child: ShimmerChild(
                      height: 15,
                      width: MediaQuery.of(context).size.width / 2,
                      radius: 15,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 270,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 5,
                      top: 15,
                    ),
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 15,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColour.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        ReporterShimmer(),
                        ReporterShimmer(),
                        ReporterShimmer(),
                        Container(
                          margin: EdgeInsets.only(
                            top: 10,
                            bottom: 15,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: 1,
                          color: AppColors.white.withOpacity(0.3),
                        ),
                        ShimmerChild(
                          height: 15,
                          width: MediaQuery.of(context).size.width / 4,
                          radius: 15,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      right: 10,
                      left: 10,
                    ),
                    child: ShimmerChild(
                      height: 15,
                      width: MediaQuery.of(context).size.width / 2,
                      radius: 15,
                    ),
                  ),
                ),
                SliverAppBar(
                  expandedHeight: 40,
                  backgroundColor: AppColors.mainColor,
                  elevation: 0,
                  pinned: true,
                  flexibleSpace: Container(
                    height: 60,
                    margin: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: 50,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (newsCatContext, index) {
                              return Container(
                                width: MediaQuery.of(context).size.width / 5,
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 5,
                                  bottom: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundColour
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(
                                width: 10,
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: 50,
                    (context, index) => Container(
                      height: 530,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                      ),
                      padding: const EdgeInsets.only(
                        left: 0,
                        right: 0,
                        top: 10,
                        bottom: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColour.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ReporterShimmer(),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15),
                            height: 30,
                            width: MediaQuery.of(context).size.width / 4,
                            decoration: BoxDecoration(
                              // shape: shape,
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.white.withOpacity(0.08),
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                            ),
                            child: Row(
                              children: [
                                ShimmerChild(
                                  height: 17,
                                  width:
                                      MediaQuery.of(context).size.width / 1.9,
                                  radius: 10,
                                ),
                                SizedBox(width: 5),
                                Container(
                                  height: 17,
                                  width: MediaQuery.of(context).size.width / 4,
                                  decoration: BoxDecoration(
                                    // shape: shape,
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.backgroundColour
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 17,
                                  width: MediaQuery.of(context).size.width / 4,
                                  decoration: BoxDecoration(
                                    // shape: shape,
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.backgroundColour
                                        .withOpacity(0.4),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                ShimmerChild(
                                  height: 17,
                                  width: MediaQuery.of(context).size.width / 3,
                                  radius: 10,
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  height: 17,
                                  width: MediaQuery.of(context).size.width / 4,
                                  decoration: BoxDecoration(
                                    // shape: shape,
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.backgroundColour
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                            ),
                            child: Row(
                              children: [
                                ShimmerChild(
                                  height: 10,
                                  width: MediaQuery.of(context).size.width / 6,
                                  radius: 10,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                ShimmerChild(
                                  height: 10,
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  radius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                            ),
                            child: Row(
                              children: [
                                ShimmerChild(
                                  height: 10,
                                  width: MediaQuery.of(context).size.width / 6,
                                  radius: 10,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                ShimmerChild(
                                  height: 10,
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  radius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                            ),
                            child: ShimmerChild(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              radius: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          color:
                                              AppColors.white.withOpacity(0.2),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        ShimmerChild(
                                          height: 15,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              8,
                                          radius: 10,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          25,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.comment,
                                          color:
                                              AppColors.white.withOpacity(0.2),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        ShimmerChild(
                                          height: 15,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              8,
                                          radius: 10,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                ShimmerChild(
                                  height: 25,
                                  width:
                                      MediaQuery.of(context).size.width / 3.5,
                                  radius: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class ReporterShimmer extends StatelessWidget {
  const ReporterShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(
          top: 5,
          bottom: 5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 10,
                right: 1,
              ),
              child: ShimmerChild(
                height: 55,
                width: 55,
                radius: 55,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerChild(
                  height: 15,
                  width: MediaQuery.of(context).size.width / 3.5,
                  radius: 15,
                ),
                const SizedBox(
                  height: 7,
                ),
                ShimmerChild(
                  height: 15,
                  width: MediaQuery.of(context).size.width / 3.5,
                  radius: 15,
                ),
              ],
            ),
            const SizedBox(
              width: 15,
            ),
            ShimmerChild(
              height: 50,
              width: MediaQuery.of(context).size.width / 3,
              radius: 15,
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerChild extends StatelessWidget {
  const ShimmerChild({
    super.key,
    required this.height,
    required this.width,
    required this.radius,
    // required this.shape,
  });

  final double height, width, radius;
  // final BoxShape? shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        // shape: shape,
        borderRadius: BorderRadius.circular(radius),
        color: AppColors.white.withOpacity(0.08),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:achivie/models/all_reports_model.dart';
import 'package:achivie/models/recent_reports_model.dart';
import 'package:achivie/models/reports_by_category_model.dart';
import 'package:achivie/screens/news_details_screen.dart';
import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/screens/search_screen.dart';
import 'package:achivie/services/keys.dart';
import 'package:achivie/styles.dart';
import 'package:achivie/widgets/news_bloc_profile_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../Utils/snackbar_utils.dart';
import '../models/categories_models.dart';
import '../services/shared_preferences.dart';
import 'news_discover_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String email = 'email',
      profileType = "",
      uid = "",
      token = "",
      message = "message";
  final List<Ticker> _tickers = [];
  CarouselController carouselController = CarouselController();
  // late ScrollController _reportsCatController;
  late ScrollController _pageScrollController;
  late ScrollController _catScrollController;
  late ScrollController _recentScrollController;
  late TextEditingController commentController;
  int newsSliderIndex = 0,
      newsListIndex = 0,
      topItemIndex = 0,
      listLen = 100,
      newsSelectedCategoryIndex = 0,
      likeCount = 9999,
      pageCount = 1,
      limitCount = 5,
      totalPage = 0;

  double screenOffset = 0.0, newsOffset = 0.0;

  bool followed = false, saved = false, loading = false, isNativeLoaded = false;
  String newsSelectedCategory = "All";
  List<Report> reports = <Report>[];
  List<ReportByCat> reportsByCat = <ReportByCat>[];
  List<Category> categoryList = [];
  List<RecentReport> recentReportList = [];
  late Timer timer;
  // String timeDifference = '';
  String newsDes =
      "Crypto investors should be prepared to lose all their money, BOE governor says sdfbkd sjfbd shbcshb ckxc mzxcnidush yeihewjhfjdsk fjsdnkcv jdsfjkdsf iusdfhjsdff";
  // NativeAd? nativeAd;

  @override
  void initState() {
    // _reportsCatController = ScrollController();
    // MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
    //   testDeviceIds: ['17ED2EE7DC2A08B4FDAAEBBD1F08602C'],
    // ));
    //
    // nativeAd = NativeAd(
    //   adUnitId: "ca-app-pub-7050103229809241/9680336245",
    //   factoryId: "ReportContainer",
    //   // nativeAdOptions: NativeAdOptions(
    //   //   adChoicesPlacement: AdChoicesPlacement.bottomRightCorner,
    //   //   videoOptions: VideoOptions(
    //   //     startMuted: true,
    //   //     clickToExpandRequested: true,
    //   //   ),
    //   // ),
    //   listener: NativeAdListener(
    //     onAdLoaded: ((ad) {
    //       setState(() {
    //         isNativeLoaded = true;
    //       });
    //     }),
    //     onAdFailedToLoad: ((ad, error) {
    //       log(error.toString());
    //       log(ad.adUnitId.toString());
    //       ad.dispose();
    //     }),
    //   ),
    //   request: const AdRequest(),
    // );
    // nativeAd!.load();
    _pageScrollController = ScrollController();
    _catScrollController = ScrollController();
    _recentScrollController = ScrollController();
    _pageScrollController.addListener(_updateScreenOffset);
    commentController = TextEditingController();

    getUserDetails();
    super.initState();
  }

  @override
  void dispose() {
    _pageScrollController.removeListener(_updateScreenOffset);
    // _reportsCatController.dispose();
    _pageScrollController.dispose();
    _catScrollController.dispose();
    _recentScrollController.dispose();
    commentController.dispose();
    // nativeAd!.dispose();
    // for (var ticker in _tickers) {
    //   ticker.dispose();
    // }
    super.dispose();
  }

  void getUserDetails() async {
    email = await StorageServices.getUsrEmail();
    profileType = await StorageServices.getUsrSignInType();
    uid = await StorageServices.getUID();
    token = await StorageServices.getUsrToken();

    await refresh();
    // Future.delayed(
    //   const Duration(
    //     milliseconds: 700,
    //   ),
    //   (() {
    //
    //   }),
    // );

    // print(profileType);
  }

  void _updateScreenOffset() {
    if (_pageScrollController.position.maxScrollExtent ==
        _pageScrollController.offset) {
      if (pageCount < totalPage) {
        fetchAllReports(
          selectedCat: newsSelectedCategory,
        );
      }
      // setState(() {
      //   reports.addAll(reports);
      // });
    }
    // setState(() {
    //   topItemIndex = _getIndexInView();
    //   screenOffset = _pageScrollController.offset;
    //   log(screenOffset.toString());
    // });
  }

  Future fetchAllReports({
    String? selectedCat,
  }) async {
    if (pageCount < totalPage) {
      pageCount++;
    }
    // log(selectedCat.toString());
    if (newsSelectedCategory == "All" && selectedCat == "All") {
      http.Response response = await http.get(
        Uri.parse(
            "${Keys.apiReportsBaseUrl}/reports/all/$uid?page=$pageCount&limit=$limitCount"),
        headers: {
          'content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        AllReports allReports = allReportsFromJson(response.body);
        if (allReports.success) {
          log(pageCount.toString());
          log(totalPage.toString());
          reports.addAll(allReports.reports);
          setState(() {});
        } else {
          message = "No reports found";
          loading = false;
        }
      }
    }
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

  // void _updateNewsOffset() => setState(() {
  //       topItemIndex = _getIndexInView();
  //       newsOffset = _newsScrollController.offset;
  //     });

  // int _getIndexInView() {
  //   double itemHeight = 10; // calculate the height of each item
  //   double position = _newsScrollController.position.pixels;
  //   int index =
  //       (position / itemHeight).floor() + 1; // add 1 to start from the 2nd item
  //   // log(index.toString());
  //   return index;
  // }

  Future<void> allReportsAPICall() async {
    http.Response response = await http.get(
      Uri.parse(
          "${Keys.apiReportsBaseUrl}/reports/all/$uid?page=$pageCount&limit=$limitCount"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> allReportsJson = jsonDecode(response.body);
      if (allReportsJson["success"]) {
        AllReports allReports = allReportsFromJson(response.body);
        reports = allReports.reports;
        totalPage = allReports.totalPage;
      } else {
        message = "No reports found";
      }
    }

    setState(() {});
  }

  Future<void> allReportsByCatAPICall(String selectedCat) async {
    reports.clear();

    reportsByCat.clear();
    selectedCat = Uri.encodeComponent(selectedCat);
    log(selectedCat.toString());

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

  Future<void> refresh() async {
    pageCount = 1;
    newsSelectedCategory = "All";
    newsSelectedCategoryIndex = 0;
    _catScrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.fastLinearToSlowEaseIn,
    );
    carouselController.animateToPage(0);
    // nativeAd!.dispose();
    setState(() {});

    http.Response recentResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reports/recent/$uid?page=1&limit=5",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (recentResponse.statusCode == 200) {
      Map<String, dynamic> recentsResponseJson =
          jsonDecode(recentResponse.body);
      if (recentsResponseJson["success"]) {
        RecentsReports recentsReports =
            recentsReportsFromJson(recentResponse.body);
        recentReportList = recentsReports.reports;
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
      Map<String, dynamic> blocAllCategoriesJson = jsonDecode(catResponse.body);
      if (blocAllCategoriesJson["success"]) {
        BlocAllCategories blocAllCategories =
            blocAllCategoriesFromJson(catResponse.body);
        categoryList = blocAllCategories.categories;
      }
    }

    setState(() {});

    // log(isNativeLoaded.toString());

    await allReportsAPICall();

    // log(message);
  }
  // void _scrollListener() {
  //   if (_scrollController.offset <=
  //       _scrollController.position.minScrollExtent) {
  //     // The list is scrolled to the top
  //     setState(() {
  //       _topItemIndex = 0;
  //     });
  //   } else if (_scrollController.offset >=
  //       _scrollController.position.maxScrollExtent) {
  //     // The list is scrolled to the bottom
  //     setState(() {
  //       _topItemIndex = listLen - 1;
  //     });
  //   } else {
  //     // The list is scrolled somewhere in between
  //     setState(() {
  //       _topItemIndex = _scrollController.position..toInt();
  //     });
  //     log(_topItemIndex.toString());
  //   }
  // }

  String updateTimeDifference(DateTime dateTime) {
    final now = DateTime.now();
    // final dateTime = DateTime.parse(time);
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      final formatter = DateFormat.yMd().add_jm();
      return formatter.format(dateTime);
    }
  }

  // int getDestinationItemIndex(int rawIndex) {
  //   if (rawIndex >= _kAdIndex && isNativeLoaded) {
  //     return rawIndex - 1;
  //   }
  //   return rawIndex;
  // }

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
      child: (recentReportList.isNotEmpty ||
              categoryList.isNotEmpty ||
              reports.isNotEmpty)
          ? CustomScrollView(
              controller: _pageScrollController,
              slivers: [
                if (recentReportList.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      height: 230,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CarouselSlider(
                          carouselController: carouselController,
                          items: recentReportList.map(
                            (RecentReport e) {
                              // updateTimeDifference(e.reportUploadTime);
                              return HomeScreenCarouselItem(
                                newsHead: e.reportHeadline,
                                newsDes: e.reportDes,
                                category: e.reportCat,
                                followers: e.followers,
                                blocName: e.blocName,
                                blocProfilePic: e.blocProfile,
                                reportPic: e.reportTumbImage,
                                reportDetailsOnTap: (() {
                                  log(e.reportUploadTime.toString());
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (newsDetailsScreenContext) =>
                                          NewsDetailsScreen(
                                        reportID: e.reportId,
                                        reportUsrID: e.reportUsrId,
                                        usrID: uid,
                                      ),
                                    ),
                                  );
                                }),
                                blocDetailsProfileOnTap: (() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (profileDetailsContext) =>
                                          ReporterPublicProfile(
                                        blockUID: e.blocId,
                                      ),
                                    ),
                                  );
                                }),
                                timeDifference:
                                    updateTimeDifference(e.reportUploadTime),
                              );
                            },
                          ).toList(),
                          options: CarouselOptions(
                            padEnds: false,
                            viewportFraction: 0.94,
                            height: 230,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            // autoPlay: true,
                            disableCenter: true,
                            enlargeFactor: 0.25,
                            scrollPhysics: AppColors.scrollPhysics,
                            onPageChanged: ((index, reason) {
                              setState(() {
                                newsSliderIndex = index;
                              });
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (recentReportList.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      height: 280,
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
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (recentReportCtx, recentReportIdx) {
                          return Container(
                            width: MediaQuery.of(context).size.width - 40,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.backgroundColour.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 15,
                                        right: 20,
                                        top: 25,
                                      ),
                                      height: 30,
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      decoration: BoxDecoration(
                                        // shape: shape,
                                        borderRadius: BorderRadius.circular(10),
                                        color:
                                            AppColors.white.withOpacity(0.08),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
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
                                        height: 17,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.9,
                                        radius: 10,
                                      ),
                                      SizedBox(width: 5),
                                      Container(
                                        height: 17,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4,
                                        decoration: BoxDecoration(
                                          // shape: shape,
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                            MediaQuery.of(context).size.width /
                                                4,
                                        decoration: BoxDecoration(
                                          // shape: shape,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.backgroundColour
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      ShimmerChild(
                                        height: 17,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        radius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                  ),
                                  child: ShimmerChild(
                                    height: 10,
                                    width: MediaQuery.of(context).size.width,
                                    radius: 10,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                  ),
                                  child: ShimmerChild(
                                    height: 10,
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    radius: 10,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              left: 10,
                                              right: 1,
                                            ),
                                            child: ShimmerChild(
                                              height: 40,
                                              width: 40,
                                              radius: 55,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ShimmerChild(
                                                height: 15,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.5,
                                                radius: 15,
                                              ),
                                              const SizedBox(
                                                height: 7,
                                              ),
                                              ShimmerChild(
                                                height: 10,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4.5,
                                                radius: 15,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      ShimmerChild(
                                        height: 15,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        radius: 10,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (recentReportCtx, recentReportIdx) {
                          return SizedBox(
                            width: 15,
                          );
                        },
                        itemCount: 20,
                      ),
                    ),
                  ),
                if (categoryList.isNotEmpty)
                  SliverAppBar(
                    expandedHeight: 40,
                    backgroundColor: AppColors.mainColor,
                    elevation: 0,
                    pinned: true,
                    flexibleSpace: Container(
                      // padding: EdgeInsets.only(top: 10, bottom: 10),
                      height: 45,
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
                                  onTap: (() {
                                    // log(newsCategory[index].category);
                                    pageCount = 1;
                                    newsSelectedCategory =
                                        categoryList[index].reportCat;
                                    if (categoryList[index].reportCat ==
                                        "All") {
                                      allReportsAPICall();
                                    }
                                    newsSelectedCategoryIndex = index;
                                    setState(() {});
                                    allReportsByCatAPICall(
                                        categoryList[index].reportCat);
                                    // log(categoryList[newsSelectedCategoryIndex]
                                    //     .reportCat);
                                    // setState(() {});
                                    HapticFeedback.heavyImpact();
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
                        ],
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
                if (reports.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: reports.length + 1,
                      (context, index) {
                        if (index < reports.length) {
                          return ReportContainer(
                            followers: reports[index].followers,
                            blocName: reports[index].blocName,
                            blocProfile: reports[index].blocProfile,
                            followed: reports[index].followed ?? false,
                            reportCat: reports[index].reportCat,
                            reportHeadline: reports[index].reportHeadline,
                            reportUploadTime:
                                "${DateFormat('EEEE').format(reports[index].reportUploadTime)}, ${reports[index].reportUploadTime.day} ${DateFormat('MMMM').format(reports[index].reportUploadTime)} ${reports[index].reportUploadTime.year}", //"Monday, 26 September 2022",
                            reportTime: "${DateFormat('EEEE').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                int.parse(reports[index].reportTime),
                              ),
                            )}, ${DateTime.fromMillisecondsSinceEpoch(
                              int.parse(reports[index].reportTime),
                            ).day} ${DateFormat('MMMM').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                int.parse(reports[index].reportTime),
                              ),
                            )} ${DateTime.fromMillisecondsSinceEpoch(
                              int.parse(reports[index].reportTime),
                            ).year}",
                            reportThumbPic: reports[index].reportTumbImage,
                            commentCount: NumberFormat.compact()
                                .format(reports[index].reportComments)
                                .toString(),
                            saved: saved,
                            reportOnTap: (() {
                              log(reports[index].reportId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (newsDetailsScreenContext) =>
                                      NewsDetailsScreen(
                                    reportID: reports[index].reportId,
                                    reportUsrID: reports[index].reportUsrId,
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
                                    blockUID: reports[index].blocId,
                                  ),
                                ),
                              );
                            }),
                            likeCount: reports[index].reportLikes,
                            liked: reports[index].liked,
                            likeBtnOnTap: ((liked) async {
                              String usrAddress = await printIps();
                              if (reports[index].liked) {
                                return false;
                              } else if (!reports[index].liked) {
                                // usrAddress = Uri.encodeComponent(usrAddress);
                                http.Response recentResponse = await http.post(
                                  Uri.parse(
                                    "${Keys.apiReportsBaseUrl}/report/like/add/$uid/${reports[index].reportId}/${reports[index].reportBlocId}/$usrAddress",
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
                                    reports[index].liked =
                                        recentsResponseJson["success"];
                                    reports[index].reportLikes =
                                        reports[index].reportLikes + 1;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message: recentsResponseJson["message"],
                                        context: context,
                                      ),
                                    );
                                    setState(() {});
                                    return true;
                                  }
                                  reports[index].liked =
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
                                reports[index].liked = false;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  AppSnackbar().customizedAppSnackbar(
                                    message: "Something went wrong",
                                    context: context,
                                  ),
                                );
                                setState(() {});
                                return false;
                              }
                            }),
                            reportOnDoubleTap: (() async {
                              String usrAddress = await printIps();
                              if (reports[index].liked) {
                              } else if (!reports[index].liked) {
                                // usrAddress = Uri.encodeComponent(usrAddress);
                                http.Response recentResponse = await http.post(
                                  Uri.parse(
                                    "${Keys.apiReportsBaseUrl}/report/like/add/$uid/${reports[index].reportId}/${reports[index].reportBlocId}/$usrAddress",
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
                                    reports[index].liked =
                                        recentsResponseJson["success"];
                                    reports[index].reportLikes =
                                        reports[index].reportLikes + 1;
                                  } else {
                                    reports[index].liked =
                                        recentsResponseJson["success"];
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message: recentsResponseJson["message"],
                                        context: context,
                                      ),
                                    );
                                  }
                                } else {
                                  reports[index].liked = false;
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
                            followedOnTap: (() {}),
                            commented: reports[index].commented!,
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
                if ((reports.isEmpty && newsSelectedCategory == "All") ||
                    (reportsByCat.isEmpty && newsSelectedCategory != "All"))
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
                              if (reportsByCat[index].liked!) {
                                return false;
                              } else {
                                return true;
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
                            followedOnTap: (() {}),
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
                  child: Container(
                    height: 280,
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
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (recentReportCtx, recentReportIdx) {
                        return Container(
                          width: MediaQuery.of(context).size.width - 40,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColour.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 15,
                                      right: 20,
                                      top: 25,
                                    ),
                                    height: 30,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    decoration: BoxDecoration(
                                      // shape: shape,
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.white.withOpacity(0.08),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
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
                                      height: 17,
                                      width: MediaQuery.of(context).size.width /
                                          1.9,
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
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                ),
                                child: ShimmerChild(
                                  height: 10,
                                  width: MediaQuery.of(context).size.width,
                                  radius: 10,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                ),
                                child: ShimmerChild(
                                  height: 10,
                                  width: MediaQuery.of(context).size.width / 2,
                                  radius: 10,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            left: 10,
                                            right: 1,
                                          ),
                                          child: ShimmerChild(
                                            height: 40,
                                            width: 40,
                                            radius: 55,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ShimmerChild(
                                              height: 15,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3.5,
                                              radius: 15,
                                            ),
                                            const SizedBox(
                                              height: 7,
                                            ),
                                            ShimmerChild(
                                              height: 10,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4.5,
                                              radius: 15,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    ShimmerChild(
                                      height: 15,
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      radius: 10,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (recentReportCtx, recentReportIdx) {
                        return SizedBox(
                          width: 15,
                        );
                      },
                      itemCount: 20,
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

class CategoryContainer extends StatelessWidget {
  const CategoryContainer({
    super.key,
    required this.newsSelectedCategoryIndex,
    required this.categoryList,
    required this.index,
    required this.onTap,
  });

  final int newsSelectedCategoryIndex, index;
  final List<Category> categoryList;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        padding: EdgeInsets.only(
          left: (index == newsSelectedCategoryIndex) ? 25 : 20,
          right: (index == newsSelectedCategoryIndex) ? 25 : 20,
          top: 5,
          bottom: 5,
        ),
        decoration: BoxDecoration(
          color: (index == newsSelectedCategoryIndex)
              ? AppColors.backgroundColour
              : AppColors.backgroundColour.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          // border: const Border.fromBorderSide(
          //   BorderSide(
          //     width: 0.7,
          //     color: AppColors.white,
          //   ),
          // ),
        ),
        duration: const Duration(milliseconds: 250),
        child: Center(
          child: Text(
            categoryList[index].reportCat,
            style: TextStyle(
              color: AppColors.white,
              fontSize: (index == newsSelectedCategoryIndex) ? 14 : 12,
              fontWeight: (index == newsSelectedCategoryIndex)
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class ReportContainer extends StatelessWidget {
  const ReportContainer({
    super.key,
    required this.followers,
    required this.likeCount,
    required this.blocName,
    required this.blocProfile,
    required this.reportCat,
    required this.reportHeadline,
    required this.reportUploadTime,
    required this.reportTime,
    required this.reportThumbPic,
    required this.commentCount,
    required this.reportOnTap,
    required this.blocDetailsOnTap,
    required this.likeBtnOnTap,
    required this.commentBtnOnTap,
    required this.saveBtnOnTap,
    required this.followed,
    required this.followedOnTap,
    required this.saved,
    required this.liked,
    required this.commented,
    this.reportOnDoubleTap,
  });

  final int followers, likeCount;
  final bool followed, saved, liked, commented;
  final String blocName,
      blocProfile,
      reportCat,
      reportHeadline,
      reportUploadTime,
      reportTime,
      reportThumbPic,
      commentCount;

  final VoidCallback reportOnTap,
      blocDetailsOnTap,
      commentBtnOnTap,
      saveBtnOnTap,
      followedOnTap;

  final VoidCallback? reportOnDoubleTap;

  final Future<bool?> Function(bool)? likeBtnOnTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: reportOnTap,
          onDoubleTap: reportOnDoubleTap,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                BlocDetailsRow(
                  followers: followers,
                  blocName: blocName,
                  blocProfilePic: blocProfile,
                  followed: followed,
                  followedOnTap: followedOnTap,
                  onTap: blocDetailsOnTap,
                ),
                const SizedBox(
                  height: 25,
                ),
                ReportDetailsColumn(
                  category: reportCat,
                  reportHeading: reportHeadline,
                  reportUploadTime: reportUploadTime,
                  reportTime: reportTime,
                  reportThumbPic: reportThumbPic,
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReportLikeBtn(
                            isLiked: liked,
                            likeCount: likeCount,
                            onTap: likeBtnOnTap,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ReactBtn(
                            head: commentCount,
                            icon: Icons.comment_outlined,
                            onPressed: commentBtnOnTap,
                          ),
                        ],
                      ),
                      ReportSaveBtn(
                        saved: saved,
                        onTap: saveBtnOnTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const ReportsDivider(),
      ],
    );
  }
}

class ReportsDivider extends StatelessWidget {
  const ReportsDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      width: MediaQuery.of(context).size.width,
      height: 1,
      decoration: BoxDecoration(
        color: AppColors.backgroundColour.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class HomeScreenCarouselItem extends StatelessWidget {
  const HomeScreenCarouselItem({
    super.key,
    required this.newsDes,
    required this.reportPic,
    required this.category,
    required this.newsHead,
    required this.blocName,
    required this.blocProfilePic,
    required this.reportDetailsOnTap,
    required this.blocDetailsProfileOnTap,
    required this.followers,
    required this.timeDifference,
  });

  final String newsDes, reportPic, category, newsHead, blocName, blocProfilePic;
  final VoidCallback reportDetailsOnTap, blocDetailsProfileOnTap;
  final int followers;
  final String timeDifference;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                reportPic,
              ),
            ),
          ),
        ),
        Positioned(
          child: GestureDetector(
            onTap: reportDetailsOnTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.transparent,
                    AppColors.mainColor.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 15,
              left: 15,
              right: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                HomeScreenCarouselCat(
                  head: category,
                ),
                SizedBox(
                  height: 15,
                ),
                Column(
                  children: [
                    HomeScreenCarouselReportDetails(
                      newsHead: newsHead,
                      newsDes: newsDes,
                      onTap: reportDetailsOnTap,
                    ),
                    HomeScreenCarouselReportBlocDetails(
                      blocName: blocName,
                      followers: followers,
                      blocProfilePic: blocProfilePic,
                      onTap: blocDetailsProfileOnTap,
                      timeDifference: timeDifference,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HomeScreenCarouselReportBlocDetails extends StatelessWidget {
  const HomeScreenCarouselReportBlocDetails({
    super.key,
    required this.onTap,
    required this.blocProfilePic,
    required this.blocName,
    this.followers,
    this.timeDifference,
  });

  final VoidCallback onTap;
  final String blocProfilePic, blocName;
  final int? followers;
  final String? timeDifference;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ReportBlockNameRow(
            blockName: blocName,
            blockProfilePic: blocProfilePic,
            followers: followers,
          ),
          Text(
            timeDifference!,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreenCarouselReportDetails extends StatelessWidget {
  const HomeScreenCarouselReportDetails({
    super.key,
    required this.newsDes,
    required this.onTap,
    required this.newsHead,
  });

  final String newsHead, newsDes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeScreenCarouselReportHead(
            head: newsHead,
          ),
          const SizedBox(
            height: 10,
          ),
          if (newsDes.length < MediaQuery.of(context).size.width / 3)
            HomeScreenCarouselReportDes(
              newsDes: newsDes,
            ),
          if (newsDes.length > MediaQuery.of(context).size.width / 3)
            HomeScreenCarouselReportDes(
              newsDes:
                  "${newsDes.substring(0, MediaQuery.of(context).size.width ~/ 4)} ...Read More",
            ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}

class HomeScreenCarouselReportDes extends StatelessWidget {
  const HomeScreenCarouselReportDes({
    super.key,
    required this.newsDes,
  });

  final String newsDes;

  @override
  Widget build(BuildContext context) {
    return Text(
      newsDes,
      style: TextStyle(
        color: AppColors.white.withOpacity(0.8),
        fontSize: 12,
        overflow: TextOverflow.clip,
      ),
    );
  }
}

class HomeScreenCarouselReportHead extends StatelessWidget {
  const HomeScreenCarouselReportHead({
    super.key,
    required this.head,
  });

  final String head;

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(r'(?:#|@)\w+');
    // final mentionRegex = RegExp(r'\@\w+');
    final List<TextSpan> spans = [];

    head.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final String? matchedText = match.group(0);

        spans.add(
          TextSpan(
            text: matchedText,
            style: matchedText!.startsWith("#")
                ? TextStyle(
                    color: AppColors.mentionTextDark,
                    // fontWeight: FontWeight.w500,
                    fontSize: 14,
                  )
                : matchedText.startsWith("@")
                    ? TextStyle(
                        color: AppColors.mentionText,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 2)
                    : TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (searchPageCtx) => SearchScreen(
                      initialIndex: matchedText.startsWith("#")
                          ? 0
                          : matchedText.startsWith("@")
                              ? 1
                              : 0,
                      query: matchedText.startsWith("#")
                          ? matchedText
                          : matchedText.startsWith("@")
                              ? matchedText.substring(1)
                              : null,
                    ),
                  ),
                );
              },
          ),
        );

        return matchedText!;
      },
      onNonMatch: (String nonMatch) {
        spans.add(
          TextSpan(
            text: nonMatch,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

        return nonMatch;
      },
    );

    // head.splitMapJoin(
    //   mentionRegex,
    //   onMatch: (Match match) {
    //     final String? matchedText = match.group(0);
    //
    //     spans.add(
    //       TextSpan(
    //         text: matchedText,
    //         style: TextStyle(
    //           color: AppColors.mainColor2,
    //           fontWeight: FontWeight.w500,
    //           fontSize: 15,
    //         ),
    //         recognizer: TapGestureRecognizer()
    //           ..onTap = (() {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (searchPageCtx) => SearchScreen(
    //                   initialIndex: 1,
    //                   query: matchedText!.substring(1),
    //                 ),
    //               ),
    //             );
    //           }),
    //       ),
    //     );
    //     return matchedText!;
    //   },
    // );

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.justify,
    );
  }
}

class HomeScreenCarouselCat extends StatelessWidget {
  const HomeScreenCarouselCat({
    super.key,
    required this.head,
  });

  final String head;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 25,
        right: 25,
        top: 10,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColour.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        head,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ReactBtn extends StatelessWidget {
  const ReactBtn({
    super.key,
    required this.icon,
    required this.head,
    required this.onPressed,
  });

  final String head;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: 25,
            ),
            SizedBox(
              width: 5,
            ),
            Center(
              child: Text(
                head,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

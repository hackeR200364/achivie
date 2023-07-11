import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:achivie/models/reporters_search_model.dart';
import 'package:achivie/models/top_reports_model.dart';
import 'package:achivie/models/top_reports_search_model.dart';
import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/services/shared_preferences.dart';
import 'package:achivie/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/news_category_model.dart';
import '../models/trending_reporters_model.dart';
import '../services/keys.dart';
import '../widgets/email_us_screen_widgets.dart';
import '../widgets/news_bloc_profile_widgets.dart';
import 'news_screen.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({
    super.key,
    this.initialIndex,
    this.query,
  });
  final int? initialIndex;
  final String? query;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  List<NewsCategoryModel> newsCategory = <NewsCategoryModel>[
    NewsCategoryModel(
      category: "All",
      index: 0,
    ),
    NewsCategoryModel(
      category: "Health",
      index: 1,
    ),
    NewsCategoryModel(
      category: "Technology",
      index: 2,
    ),
    NewsCategoryModel(
      category: "Finance",
      index: 3,
    ),
    NewsCategoryModel(
      category: "Arts",
      index: 4,
    ),
    NewsCategoryModel(
      category: "Sports",
      index: 5,
    ),
  ];
  late TextEditingController _searchController;
  late TextEditingController commentController;
  late TabController _tabController;
  late ScrollController _pageScrollController;
  bool followed = false, saved = false, loading = false, backPressed = false;
  int likeCount = 1000000,
      _hintIndex = 0,
      pageCount = 1,
      pageCountSearch = 1,
      limitCount = 10,
      totalPage = 0,
      totalPageSearch = 0;
  Timer? timer;
  List<Report> reports = <Report>[];
  List<TopReportSearch> searchReports = <TopReportSearch>[];
  List<Reporter> searchReporters = <Reporter>[];
  List<TrendingReporter> reporters = [];
  String uid = "", token = "";

  @override
  void initState() {
    _pageScrollController = ScrollController();
    _pageScrollController.addListener(_updateScreenOffset);
    _searchController = TextEditingController(
      text: widget.query,
    );

    _searchController.addListener(_onTextChanged);
    commentController = TextEditingController();
    _tabController = TabController(
      initialIndex: widget.initialIndex ?? 0,
      length: 3,
      vsync: this,
    );
    getUsrDetails();
    _startTimer();

    super.initState();
  }

  @override
  void dispose() {
    _pageScrollController.removeListener(_updateScreenOffset);
    _searchController.dispose();
    timer?.cancel();
    // controllerToIncreasingCurve.dispose();
    // controllerToDecreasingCurve.dispose();
    super.dispose();
  }

  void _updateScreenOffset() {
    if (_pageScrollController.position.maxScrollExtent ==
        _pageScrollController.offset) {
      // if (pageCount < totalPage) {
      //   setState(() {
      //     fetchTopReports();
      //   });
      // }

      if (_searchController.text.trim().isEmpty) {
        log("top fetch");

        if (pageCount < totalPage) {
          fetchTopReports();
        }
      }
      if (_searchController.text.trim().isNotEmpty) {
        if (pageCountSearch < totalPageSearch) {
          log("search fetch");
          fetchTopReportsSearch();
        }
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

  Future fetchTopReportsSearch() async {
    pageCountSearch++;

    String query = _searchController.text.trim();

    if (query.startsWith("#")) {
      query = Uri.encodeComponent(query);
    }
    setState(() {});

    http.Response topSearchResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reports/top/search/$uid?page=$pageCountSearch&limit=$limitCount&q=$query",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (topSearchResponse.statusCode == 200) {
      Map<String, dynamic> topSearchResponseJson =
          jsonDecode(topSearchResponse.body);
      if (topSearchResponseJson["success"]) {
        TopReportsSearch topSearchReports =
            topReportsSearchFromJson(topSearchResponse.body);
        searchReports.addAll(topSearchReports.reports);
        // totalPageSearch = topSearchReports.totalPage;
      }
    }

    setState(() {});
  }

  Future fetchTopReports() async {
    pageCount++;
    log(pageCount.toString());
    http.Response topReportsResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reports/top/$uid?page=$pageCount&limit=$limitCount",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (topReportsResponse.statusCode == 200) {
      Map<String, dynamic> topSearchResponseJson =
          jsonDecode(topReportsResponse.body);
      if (topSearchResponseJson["success"]) {
        TopReports topReports = topReportsFromJson(topReportsResponse.body);
        reports.addAll(topReports.reports);
        // totalPage = topReports.totalPage;
      }
    }

    setState(() {});
  }

  void _onTextChanged() {
    // Update the value in real-time
    // String updatedValue = _searchController.text.toUpperCase();
    _searchController.value = _searchController.value.copyWith(
      text: _searchController.text.trim(),
      selection:
          TextSelection.collapsed(offset: _searchController.text.trim().length),
    );

    // log(_searchController.text.trim());
  }

  void _startTimer() {
    if (timer != null && timer!.isActive) return;
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _hintIndex = (_hintIndex + 1) % newsCategory.length;
      });
    });
  }

  void getUsrDetails() async {
    uid = await StorageServices.getUID();
    token = await StorageServices.getUsrToken();
    // log(_tabController.index.toString());
    setState(() {});

    if (widget.query == null) {
      refreshTopReports();
      refreshReporters();
    }

    if (widget.query != null) {
      refreshTopReportsSearch(widget.query!);
      refreshReportersSearch(widget.query!);
    }

    // if (_tabController.index == 1 && widget.query == null) {
    // }

    // if (_tabController.index == 1 && widget.query != null) {
    // }

    setState(() {});

    // if (_tabController.index == 0 && query.isNotEmpty) {
    //   refreshTopReportsSearch();
    // }
  }

  Future<void> refreshTopReports() async {
    pageCount = 1;
    _searchController.clear();
    searchReports.clear();
    loading = true;
    totalPage = 0;
    setState(() {});

    http.Response topResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reports/top/$uid?page=$pageCount&limit=$limitCount",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (topResponse.statusCode == 200) {
      Map<String, dynamic> topResponseJson = jsonDecode(topResponse.body);
      if (topResponseJson["success"]) {
        TopReports topReports = topReportsFromJson(topResponse.body);
        reports = topReports.reports;
        totalPage = topReports.totalPage;
      }
    }

    loading = false;
    setState(() {});
    // log(reports.toString());
    // setState(() {});
  }

  Future<void> refreshTopReportsSearch(String query) async {
    pageCountSearch = 1;
    totalPageSearch = 0;
    loading = true;
    reports.clear();

    if (query.startsWith("#")) {
      query = Uri.encodeComponent(query);
    }
    setState(() {});

    http.Response topSearchResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reports/top/search/$uid?page=$pageCountSearch&limit=$limitCount&q=$query",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (topSearchResponse.statusCode == 200) {
      Map<String, dynamic> topSearchResponseJson =
          jsonDecode(topSearchResponse.body);
      if (topSearchResponseJson["success"]) {
        TopReportsSearch topSearchReports =
            topReportsSearchFromJson(topSearchResponse.body);
        searchReports = topSearchReports.reports;
        totalPageSearch = topSearchReports.totalPage;
      }
    }
    loading = false;
    setState(() {});
  }

  Future<void> refreshReporters() async {
    pageCount = 1;
    _searchController.clear();
    searchReporters.clear();
    loading = true;
    setState(() {});

    http.Response trendingReportersResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reporters/trending/$uid?page=$pageCount&limit=$limitCount",
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
  }

  Future<void> refreshReportersSearch(String query) async {
    pageCountSearch = 1;
    totalPageSearch = 0;
    loading = true;
    reporters.clear();
    // setState(() {});

    // if (query.startsWith("@")) {
    //   query = Uri.encodeComponent(query);
    // }
    setState(() {});

    http.Response topSearchResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reporters/search/$uid?page=$pageCountSearch&limit=$limitCount&q=$query",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (topSearchResponse.statusCode == 200) {
      Map<String, dynamic> topSearchResponseJson =
          jsonDecode(topSearchResponse.body);
      // log(topSearchResponse.toString());
      if (topSearchResponseJson["success"]) {
        SearchReporters topSearchReports =
            searchReportersFromJson(topSearchResponse.body);
        searchReporters = topSearchReports.reports;
        totalPageSearch = topSearchReports.totalPage;
        // log(topSe.toString());
      }
    }
    loading = false;
    setState(() {});
  }

  Future<void> refreshAllReports() async {
    log("refreshing");
  }

  @override
  Widget build(BuildContext context) {
    // log(_searchController.text);
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      // appBar: AppBar(
      //   backgroundColor: AppColors.transparent,
      //   elevation: 0,
      //   leading: CustomAppBarLeading(
      //     onPressed: (() {
      //       Navigator.pop(context);
      //       // print(isPlaying);
      //     }),
      //     icon: Icons.arrow_back_ios_rounded,
      //   ),
      //   title: GlassmorphicContainer(
      //     width: double.infinity,
      //     height: 41,
      //     borderRadius: 40,
      //     linearGradient: AppColors.customGlassIconButtonGradient,
      //     border: 2,
      //     blur: 4,
      //     borderGradient: AppColors.customGlassIconButtonBorderGradient,
      //     child: Center(
      //       child: Text(
      //         "Discover Blocs",
      //         style: AppColors.subHeadingTextStyle,
      //       ),
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: CustomScrollView(
          // controller: _pageScrollController,
          slivers: [
            SliverAppBar(
              leading: Container(),
              backgroundColor: AppColors.mainColor,
              elevation: 0,
              pinned: true,
              flexibleSpace: Container(
                width: MediaQuery.of(context).size.width,
                height: 40,
                margin: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomAppBarLeading(
                      onPressed: (() {
                        backPressed = true;
                        // controllerToDecreasingCurve.forward();
                        Navigator.pop(context);
                        // print(isPlaying);
                      }),
                      icon: Icons.arrow_back_ios_rounded,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 100,
                        ),
                        child: TextFormField(
                          textInputAction: TextInputAction.search,
                          textCapitalization: TextCapitalization.sentences,
                          scrollPhysics: AppColors.scrollPhysics,
                          decoration: InputDecoration(
                            errorStyle: const TextStyle(
                              overflow: TextOverflow.clip,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.white.withOpacity(0.6),
                            ),
                            prefixStyle: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                            hintText:
                                " Search ${newsCategory[_hintIndex].category}",
                            hintStyle: TextStyle(
                              color: AppColors.white.withOpacity(0.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 1,
                                color: AppColors.white,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 1,
                                color: AppColors.white,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            contentPadding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _searchController,
                          keyboardType: TextInputType.text,
                          cursorColor: AppColors.white,
                          style: const TextStyle(
                            color: AppColors.white,
                          ),
                          onFieldSubmitted: ((String inputQuery) {
                            if (inputQuery.isNotEmpty &&
                                _tabController.index == 0) {
                              refreshTopReportsSearch(
                                  _searchController.text.trim());
                            }

                            if (inputQuery.isEmpty &&
                                _tabController.index == 0) {
                              // loading = false;
                              refreshReporters();
                              // setState(() {});
                            }
                          }),
                          onChanged: ((String inputQuery) {
                            // log(inputQuery);
                            if (inputQuery.isNotEmpty &&
                                _tabController.index == 0) {
                              refreshTopReportsSearch(
                                  _searchController.text.trim());
                            }

                            if (inputQuery.isEmpty &&
                                _tabController.index == 0) {
                              // loading = false;
                              refreshTopReports();
                              // setState(() {});
                            }

                            if (inputQuery.isEmpty &&
                                _tabController.index == 1) {
                              // loading = false;
                              refreshReporters();
                              // setState(() {});
                            }

                            if (inputQuery.isNotEmpty &&
                                _tabController.index == 1) {
                              refreshReportersSearch(inputQuery);
                              // setState(() {});
                            }

                            // log(inputQuery);
                            // setState(() {});
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverAppBar(
              leading: Container(),
              backgroundColor: AppColors.mainColor,
              elevation: 0,
              pinned: true,
              flexibleSpace: Container(
                width: MediaQuery.of(context).size.width,
                height: 35,
                margin: const EdgeInsets.only(
                  top: 10,
                ),
                child: TabBar(
                  enableFeedback: true,
                  splashBorderRadius: BorderRadius.circular(50),
                  splashFactory: NoSplash.splashFactory,
                  physics: AppColors.scrollPhysics,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: BoxDecoration(
                    color: AppColors.backgroundColour,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  labelColor: AppColors.white,
                  labelStyle: const TextStyle(
                    // color: AppColors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelColor: AppColors.backgroundColour,
                  controller: _tabController,
                  tabs: const [
                    CustomSearchNewsTabBar(
                      label: "Top Reports",
                    ),
                    CustomSearchNewsTabBar(
                      label: "Reporters",
                    ),
                    CustomSearchNewsTabBar(
                      label: "All Reports",
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  RefreshIndicator(
                    onRefresh: refreshTopReports,
                    child: ListView.builder(
                      controller: _pageScrollController,
                      itemCount: (_searchController.text.trim().isNotEmpty)
                          ? searchReports.length + 1
                          : reports.length + 1,
                      itemBuilder: ((topNewsContext, topNewsIndex) {
                        if ((_searchController.text.trim().isNotEmpty &&
                                topNewsIndex < searchReports.length) ||
                            (_searchController.text.trim().isEmpty &&
                                topNewsIndex < reports.length)) {
                          return (_searchController.text.isNotEmpty ||
                                  searchReports.isNotEmpty)
                              ? ReportContainer(
                                  followers:
                                      searchReports[topNewsIndex].followers,
                                  likeCount:
                                      searchReports[topNewsIndex].reportLikes,
                                  blocName:
                                      searchReports[topNewsIndex].blocName,
                                  blocProfile:
                                      searchReports[topNewsIndex].blocProfile,
                                  reportCat:
                                      searchReports[topNewsIndex].reportCat,
                                  reportHeadline: searchReports[topNewsIndex]
                                      .reportHeadline,
                                  reportUploadTime:
                                      "${DateFormat('EEEE').format(searchReports[topNewsIndex].reportUploadTime)}, ${searchReports[topNewsIndex].reportUploadTime.day} ${DateFormat('MMMM').format(searchReports[topNewsIndex].reportUploadTime)} ${searchReports[topNewsIndex].reportUploadTime.year}",
                                  //"Monday, 26 September 2022",
                                  reportTime: "${DateFormat('EEEE').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(searchReports[topNewsIndex]
                                          .reportTime),
                                    ),
                                  )}, ${DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(
                                        searchReports[topNewsIndex].reportTime),
                                  ).day} ${DateFormat('MMMM').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(searchReports[topNewsIndex]
                                          .reportTime),
                                    ),
                                  )} ${DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(
                                        searchReports[topNewsIndex].reportTime),
                                  ).year}",
                                  reportThumbPic: searchReports[topNewsIndex]
                                      .reportTumbImage,
                                  commentCount: NumberFormat.compact()
                                      .format(searchReports[topNewsIndex]
                                          .reportComments)
                                      .toString(),
                                  reportOnTap: (() {}),
                                  blocDetailsOnTap: (() {}),
                                  likeBtnOnTap: ((liked) async {
                                    return true;
                                  }),
                                  commentBtnOnTap: (() {}),
                                  saveBtnOnTap: (() {}),
                                  followed:
                                      searchReports[topNewsIndex].followed,
                                  followedOnTap: (() {}),
                                  saved: searchReports[topNewsIndex].saved,
                                  liked: searchReports[topNewsIndex].liked,
                                  commented:
                                      searchReports[topNewsIndex].commented,
                                )
                              : (_searchController.text.isEmpty &&
                                      reports.isNotEmpty)
                                  ? ReportContainer(
                                      followers:
                                          reports[topNewsIndex].followers,
                                      likeCount:
                                          reports[topNewsIndex].reportLikes,
                                      blocName: reports[topNewsIndex].blocName,
                                      blocProfile:
                                          reports[topNewsIndex].blocProfile,
                                      reportCat:
                                          reports[topNewsIndex].reportCat,
                                      reportHeadline:
                                          reports[topNewsIndex].reportHeadline,
                                      reportUploadTime:
                                          "${DateFormat('EEEE').format(reports[topNewsIndex].reportUploadTime)}, ${reports[topNewsIndex].reportUploadTime.day} ${DateFormat('MMMM').format(reports[topNewsIndex].reportUploadTime)} ${reports[topNewsIndex].reportUploadTime.year}",
                                      //"Monday, 26 September 2022",
                                      reportTime: "${DateFormat('EEEE').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(
                                              reports[topNewsIndex].reportTime),
                                        ),
                                      )}, ${DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(
                                            reports[topNewsIndex].reportTime),
                                      ).day} ${DateFormat('MMMM').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(
                                              reports[topNewsIndex].reportTime),
                                        ),
                                      )} ${DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(
                                            reports[topNewsIndex].reportTime),
                                      ).year}",
                                      reportThumbPic:
                                          reports[topNewsIndex].reportTumbImage,
                                      commentCount: NumberFormat.compact()
                                          .format(reports[topNewsIndex]
                                              .reportComments)
                                          .toString(),
                                      reportOnTap: (() {}),
                                      blocDetailsOnTap: (() {}),
                                      likeBtnOnTap: ((liked) async {
                                        return true;
                                      }),
                                      commentBtnOnTap: (() {}),
                                      saveBtnOnTap: (() {}),
                                      followed: reports[topNewsIndex].followed,
                                      followedOnTap: (() {}),
                                      saved: reports[topNewsIndex].saved,
                                      liked: reports[topNewsIndex].liked,
                                      commented:
                                          reports[topNewsIndex].commented,
                                    )
                                  : (searchReports.isEmpty &&
                                          _searchController.text
                                              .trim()
                                              .isNotEmpty)
                                      ? Text(
                                          "No reports found",
                                          style: TextStyle(
                                            color: AppColors.white
                                                .withOpacity(0.7),
                                          ),
                                        )
                                      : Container();
                        } else if ((_searchController.text.trim().isEmpty &&
                                (pageCount < totalPage)) ||
                            (_searchController.text.trim().isNotEmpty &&
                                (pageCountSearch < totalPageSearch))) {
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
                      }),
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: refreshReporters,
                    child: ListView.separated(
                      itemCount: (_searchController.text.trim().isNotEmpty)
                          ? searchReporters.length
                          : reporters.length,
                      itemBuilder: ((topReportersContext, topReportersIndex) {
                        if ((_searchController.text.trim().isNotEmpty &&
                                topReportersIndex < searchReporters.length) ||
                            (_searchController.text.trim().isEmpty &&
                                topReportersIndex < reporters.length)) {
                          return (_searchController.text.isNotEmpty ||
                                  searchReporters.isNotEmpty)
                              ? Container(
                                  margin: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                  ),
                                  child: BlocDetailsRow(
                                    followers:
                                        searchReporters[topReportersIndex]
                                            .followers,
                                    blocName: searchReporters[topReportersIndex]
                                        .blocName,
                                    blocProfilePic:
                                        searchReporters[topReportersIndex]
                                            .blocProfile,
                                    radius: 30,
                                    followed: searchReporters[topReportersIndex]
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
                                              ReporterPublicProfile(
                                            blockUID: searchReporters[
                                                    topReportersIndex]
                                                .blocId,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                )
                              : (_searchController.text.isEmpty &&
                                      reporters.isNotEmpty)
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                      ),
                                      child: BlocDetailsRow(
                                        followers: reporters[topReportersIndex]
                                            .followers,
                                        blocName: reporters[topReportersIndex]
                                            .blocName,
                                        blocProfilePic:
                                            reporters[topReportersIndex]
                                                .blocProfile,
                                        radius: 30,
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
                                              builder:
                                                  (profileDetailsContext) =>
                                                      ReporterPublicProfile(
                                                blockUID:
                                                    reporters[topReportersIndex]
                                                        .blocId,
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    )
                                  : (searchReporters.isEmpty &&
                                          _searchController.text
                                              .trim()
                                              .isNotEmpty)
                                      ? Text(
                                          "No reports found",
                                          style: TextStyle(
                                            color: AppColors.white
                                                .withOpacity(0.7),
                                          ),
                                        )
                                      : Container();
                        } else if ((_searchController.text.trim().isEmpty &&
                                (pageCount < totalPage)) ||
                            (_searchController.text.trim().isNotEmpty &&
                                (pageCountSearch < totalPageSearch))) {
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
                      }),
                      separatorBuilder:
                          ((topNewsSeparatorContext, topNewsSeparatorIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          child: const ReportsDivider(),
                        );
                      }),
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: refreshAllReports,
                    child: ListView.builder(
                      itemBuilder: ((topNewsContext, topNewsIndex) {
                        return ReportContainer(
                          followers: 10000,
                          likeCount: 1000000,
                          blocName: "blocName",
                          blocProfile:
                              "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                          reportCat: "reportCat",
                          reportHeadline: "reportHeadline",
                          reportUploadTime: "reportUploadTime",
                          reportTime: "reportTime",
                          reportThumbPic:
                              "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                          commentCount:
                              NumberFormat.compact().format(90010).toString(),
                          reportOnTap: (() {}),
                          blocDetailsOnTap: (() {}),
                          likeBtnOnTap: ((liked) async {
                            return true;
                          }),
                          commentBtnOnTap: (() {}),
                          saveBtnOnTap: (() {}),
                          followed: followed,
                          followedOnTap: (() {}),
                          saved: saved,
                          liked: false,
                          commented: false,
                        );
                      }),
                      itemCount: 10,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomSearchNewsTabBar extends StatelessWidget {
  const CustomSearchNewsTabBar({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.backgroundColour,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(
          label,
        ),
      ),
    );
  }
}

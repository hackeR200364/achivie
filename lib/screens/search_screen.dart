import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:achivie/models/all_reports_by_search_model.dart';
import 'package:achivie/models/all_reports_model.dart';
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
      limitCount = 2,
      totalPageTopReports = 0,
      totalPageReporters = 0,
      totalPageAllReports = 0,
      totalPageSearch = 0;
  Timer? timer;
  List<TopReport> reports = <TopReport>[];
  List<TopReportSearch> searchReports = <TopReportSearch>[];
  List<Reporter> searchReporters = <Reporter>[];
  List<TrendingReporter> reporters = [];
  List<ReportAllBySearch> allReportsBySearch = [];
  List<Report> allReports = [];
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

      if (_searchController.text.trim().isEmpty && _tabController.index == 0) {
        if (pageCount < totalPageTopReports) {
          fetchTopReports();
          log("message");
        }
      }
      if (_searchController.text.trim().isNotEmpty &&
          _tabController.index == 0) {
        if (pageCountSearch < totalPageSearch) {
          fetchTopReportsSearch();
        }
      }

      if (_searchController.text.trim().isEmpty && _tabController.index == 1) {
        if (pageCount < totalPageReporters) {
          fetchReporters();
        }
      }
      if (_searchController.text.trim().isNotEmpty &&
          _tabController.index == 1) {
        if (pageCountSearch < totalPageSearch) {
          fetchReportersSearch();
        }
      }

      if (_searchController.text.trim().isEmpty && _tabController.index == 2) {
        if (pageCount < totalPageAllReports) {
          fetchAllReports();
        }
      }
      if (_searchController.text.trim().isNotEmpty &&
          _tabController.index == 2) {
        if (pageCountSearch < totalPageSearch) {
          fetchAllReportsSearch();
        }
      }
    }
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
    // log(pageCount.toString());

    http.Response trendingReportsResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reports/top/$uid?page=$pageCount&limit=$limitCount",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (trendingReportsResponse.statusCode == 200) {
      Map<String, dynamic> topResponseJson =
          jsonDecode(trendingReportsResponse.body);
      if (topResponseJson["success"]) {
        TopReports topReports =
            topReportsFromJson(trendingReportsResponse.body);
        reports.addAll(topReports.reports);
        // totalPage = topReports.totalPage;
      }
    }

    setState(() {});
  }

  Future fetchReportersSearch() async {
    pageCountSearch++;

    _searchController.text = Uri.encodeComponent(_searchController.text.trim());
    setState(() {});

    http.Response topSearchResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reporters/search/$uid?page=$pageCountSearch&limit=$limitCount&q=${_searchController.text.trim()}",
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
        searchReporters.addAll(topSearchReports.reports);
        // totalPageSearch = topSearchReports.totalPage;
        // log(topSe.toString());
      }
    }
    loading = false;
    setState(() {});
  }

  Future fetchReporters() async {
    pageCount++;
    log(pageCount.toString());
    http.Response topReportersResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reporters/trending/$uid?page=$pageCount&limit=$limitCount",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (topReportersResponse.statusCode == 200) {
      Map<String, dynamic> trendingReportersJson =
          jsonDecode(topReportersResponse.body);
      if (trendingReportersJson["success"]) {
        TrendingReporters trendingReporters =
            trendingReportersFromJson(topReportersResponse.body);
        reporters.addAll(trendingReporters.reporters);
      }
    }

    setState(() {});
  }

  Future fetchAllReportsSearch() async {
    pageCountSearch++;

    _searchController.text = Uri.encodeComponent(_searchController.text.trim());
    setState(() {});

    http.Response allReportsSearchResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reporters/search/$uid?page=$pageCountSearch&limit=$limitCount&q=${_searchController.text.trim()}",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (allReportsSearchResponse.statusCode == 200) {
      Map<String, dynamic> allSearchResponseJson =
          jsonDecode(allReportsSearchResponse.body);
      // log(topSearchResponse.toString());
      if (allSearchResponseJson["success"]) {
        ReportsAllBySearch allSearchReports =
            reportsAllBySearchFromJson(allReportsSearchResponse.body);
        allReportsBySearch.addAll(allSearchReports.reports);
        // totalPageSearch = allSearchReports.totalPage;
        // log(topSe.toString());
      }
    }

    loading = false;
    setState(() {});
  }

  Future fetchAllReports() async {
    pageCount++;
    log(pageCount.toString());

    http.Response topResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reports/all/$uid?page=$pageCount&limit=$limitCount",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (topResponse.statusCode == 200) {
      Map<String, dynamic> topResponseJson = jsonDecode(topResponse.body);
      if (topResponseJson["success"]) {
        AllReports allReportsRes = allReportsFromJson(topResponse.body);
        allReports.addAll(allReportsRes.reports);
        // totalPage = allReportsRes.totalPage;
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
      refreshAllReports();
    }

    if (widget.query != null) {
      refreshTopReportsSearch(widget.query!);
      refreshReportersSearch(widget.query!);
      refreshAllReportsSearch(widget.query!);
    }
    setState(() {});
  }

  Future<void> refreshTopReports() async {
    pageCount = 1;
    _searchController.clear();
    searchReports.clear();
    loading = true;
    totalPageTopReports = 0;
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
        totalPageTopReports = topReports.totalPage;
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
    totalPageReporters = 0;
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
        totalPageReporters = trendingReporters.totalPage;
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
    query = Uri.encodeComponent(query);
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
    pageCount = 1;
    _searchController.clear();
    allReports.clear();
    loading = true;
    totalPageAllReports = 0;
    setState(() {});

    http.Response topResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reports/all/$uid?page=$pageCount&limit=$limitCount",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (topResponse.statusCode == 200) {
      Map<String, dynamic> topResponseJson = jsonDecode(topResponse.body);
      if (topResponseJson["success"]) {
        AllReports allReportsRes = allReportsFromJson(topResponse.body);
        allReports = allReportsRes.reports;
        totalPageAllReports = allReportsRes.totalPage;
      }
    }

    loading = false;
    setState(() {});
  }

  Future<void> refreshAllReportsSearch(String query) async {
    pageCountSearch = 1;
    totalPageSearch = 0;
    loading = true;
    allReportsBySearch.clear();
    // setState(() {});

    // if (query.startsWith("@")) {
    //   query = Uri.encodeComponent(query);
    // }
    query = Uri.encodeComponent(query);
    setState(() {});

    http.Response topSearchResponse = await http.get(
      Uri.parse(
        "${Keys.apiReportsBaseUrl}/reports/all/search/$uid?page=$pageCountSearch&limit=$limitCount&q=$query",
      ),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (topSearchResponse.statusCode == 200) {
      Map<String, dynamic> allSearchResponseJson =
          jsonDecode(topSearchResponse.body);
      // log(topSearchResponse.toString());
      if (allSearchResponseJson["success"]) {
        ReportsAllBySearch allSearchReports =
            reportsAllBySearchFromJson(topSearchResponse.body);
        allReportsBySearch = allSearchReports.reports;
        totalPageSearch = allSearchReports.totalPage;
        // log(topSe.toString());
      }
    }
    loading = false;
    setState(() {});
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

                            if (inputQuery.isEmpty &&
                                _tabController.index == 2) {
                              // loading = false;
                              refreshAllReports();
                              // setState(() {});
                            }

                            if (inputQuery.isNotEmpty &&
                                _tabController.index == 2) {
                              refreshAllReportsSearch(inputQuery);
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
                  onTap: ((index) {
                    _pageScrollController.animateTo(
                      _pageScrollController.position.minScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastLinearToSlowEaseIn,
                    );
                  }),
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
                                (pageCount < totalPageTopReports)) ||
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
                      controller: _pageScrollController,
                      itemCount: (_searchController.text.trim().isNotEmpty)
                          ? searchReporters.length + 1
                          : reporters.length + 1,
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
                                (pageCount < totalPageReporters)) ||
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
                      controller: _pageScrollController,
                      itemCount: (_searchController.text.trim().isNotEmpty)
                          ? allReportsBySearch.length + 1
                          : allReports.length + 1,
                      itemBuilder: ((allNewsContext, allNewsIndex) {
                        if ((_searchController.text.trim().isNotEmpty &&
                                allNewsIndex < allReportsBySearch.length) ||
                            (_searchController.text.trim().isEmpty &&
                                allNewsIndex < allReports.length)) {
                          // log(pageCount.toString());
                          return (_searchController.text.isNotEmpty ||
                                  allReportsBySearch.isNotEmpty)
                              ? ReportContainer(
                                  followers: allReportsBySearch[allNewsIndex]
                                      .followers,
                                  likeCount: allReportsBySearch[allNewsIndex]
                                      .reportLikes,
                                  blocName:
                                      allReportsBySearch[allNewsIndex].blocName,
                                  blocProfile: allReportsBySearch[allNewsIndex]
                                      .blocProfile,
                                  reportCat: allReportsBySearch[allNewsIndex]
                                      .reportCat,
                                  reportHeadline:
                                      allReportsBySearch[allNewsIndex]
                                          .reportHeadline,
                                  reportUploadTime:
                                      "${DateFormat('EEEE').format(allReportsBySearch[allNewsIndex].reportUploadTime)}, ${allReportsBySearch[allNewsIndex].reportUploadTime.day} ${DateFormat('MMMM').format(allReportsBySearch[allNewsIndex].reportUploadTime)} ${allReportsBySearch[allNewsIndex].reportUploadTime.year}",
                                  //"Monday, 26 September 2022",
                                  reportTime: "${DateFormat('EEEE').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(allReportsBySearch[allNewsIndex]
                                          .reportTime),
                                    ),
                                  )}, ${DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(allReportsBySearch[allNewsIndex]
                                        .reportTime),
                                  ).day} ${DateFormat('MMMM').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(allReportsBySearch[allNewsIndex]
                                          .reportTime),
                                    ),
                                  )} ${DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(allReportsBySearch[allNewsIndex]
                                        .reportTime),
                                  ).year}",
                                  reportThumbPic:
                                      allReportsBySearch[allNewsIndex]
                                          .reportTumbImage,
                                  commentCount: NumberFormat.compact()
                                      .format(allReportsBySearch[allNewsIndex]
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
                                      allReportsBySearch[allNewsIndex].followed,
                                  followedOnTap: (() {}),
                                  saved: allReportsBySearch[allNewsIndex].saved,
                                  liked: allReportsBySearch[allNewsIndex].liked,
                                  commented: allReportsBySearch[allNewsIndex]
                                      .commented,
                                )
                              : (_searchController.text.isEmpty &&
                                      allReports.isNotEmpty)
                                  ? ReportContainer(
                                      followers:
                                          allReports[allNewsIndex].followers,
                                      likeCount:
                                          allReports[allNewsIndex].reportLikes,
                                      blocName:
                                          allReports[allNewsIndex].blocName,
                                      blocProfile:
                                          allReports[allNewsIndex].blocProfile,
                                      reportCat:
                                          allReports[allNewsIndex].reportCat,
                                      reportHeadline: allReports[allNewsIndex]
                                          .reportHeadline,
                                      reportUploadTime:
                                          "${DateFormat('EEEE').format(allReports[allNewsIndex].reportUploadTime)}, ${allReports[allNewsIndex].reportUploadTime.day} ${DateFormat('MMMM').format(allReports[allNewsIndex].reportUploadTime)} ${allReports[allNewsIndex].reportUploadTime.year}",
                                      //"Monday, 26 September 2022",
                                      reportTime: "${DateFormat('EEEE').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(allReports[allNewsIndex]
                                              .reportTime),
                                        ),
                                      )}, ${DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(allReports[allNewsIndex]
                                            .reportTime),
                                      ).day} ${DateFormat('MMMM').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(allReports[allNewsIndex]
                                              .reportTime),
                                        ),
                                      )} ${DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(allReports[allNewsIndex]
                                            .reportTime),
                                      ).year}",
                                      reportThumbPic: allReports[allNewsIndex]
                                          .reportTumbImage,
                                      commentCount: NumberFormat.compact()
                                          .format(allReports[allNewsIndex]
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
                                          allReports[allNewsIndex].followed,
                                      followedOnTap: (() {}),
                                      saved: allReports[allNewsIndex].saved,
                                      liked: allReports[allNewsIndex].liked,
                                      commented:
                                          allReports[allNewsIndex].commented,
                                    )
                                  : (allReportsBySearch.isEmpty &&
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
                                (pageCount < totalPageAllReports)) ||
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

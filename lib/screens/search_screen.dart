import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:achivie/models/top_reports_model.dart';
import 'package:achivie/providers/news_searching_provider.dart';
import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/services/shared_preferences.dart';
import 'package:achivie/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/news_category_model.dart';
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
  int? initialIndex;
  String? query;

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
  bool followed = false, saved = false;
  int likeCount = 1000000, _hintIndex = 0, pageCount = 1, limitCount = 10;
  Timer? timer;
  List<Report> reports = <Report>[];
  String uid = "", token = "", query = "";

  @override
  void initState() {
    _searchController = TextEditingController(
      text: widget.query,
    );
    // _searchController.addListener(_onTextChanged);
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
    _searchController.dispose();
    timer?.cancel();
    super.dispose();
  }

  // void _onTextChanged() {
  //   // Update the value in real-time
  //   // String updatedValue = _searchController.text.toUpperCase();
  //   _searchController.value = _searchController.value.copyWith(
  //     text: _searchController.text.trim(),
  //     selection:
  //         TextSelection.collapsed(offset: _searchController.text.trim().length),
  //   );
  //
  //   // log(_searchController.text.trim());
  // }

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

    if (_tabController.index == 0 && query.isEmpty) {
      refreshTopReports();
    }

    if (_tabController.index == 0 && query.isNotEmpty) {
      refreshTopReportsSearch();
    }
  }

  Future<void> refreshTopReports() async {
    pageCount = 1;
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
      }
    }
    setState(() {});
    // log(reports.toString());
    // setState(() {});
  }

  Future<void> refreshTopReportsSearch() async {
    pageCount = 1;
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
      }
    }
    setState(() {});
    // log(reports.toString());
    // setState(() {});
  }

  Future<void> refreshReporters() async {
    log("refreshing");
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
                        Navigator.pop(context);
                        // print(isPlaying);
                      }),
                      icon: Icons.arrow_back_ios_rounded,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Consumer<NewsSearchingProvider>(
                        builder: (newsSearchingContext, newsSearchingProvider,
                            newsSearchingChild) {
                          return AnimatedContainer(
                            duration: Duration(
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
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _searchController,
                              keyboardType: TextInputType.text,
                              cursorColor: AppColors.white,
                              style: const TextStyle(
                                color: AppColors.white,
                              ),
                              onFieldSubmitted: ((String inputQuery) {
                                // log(query);
                                // newsSearchingProvider.queryFunc(query);
                                setState(() {
                                  query = inputQuery;
                                });
                              }),
                              onChanged: ((String inputQuery) {
                                // log(query);
                                // newsSearchingProvider.queryFunc(query);
                                setState(() {
                                  query = inputQuery;
                                });
                              }),
                            ),
                          );
                        },
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
                    onRefresh: (query.isEmpty)
                        ? refreshTopReports
                        : refreshTopReportsSearch,
                    child: ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: ((topNewsContext, topNewsIndex) {
                        return ReportContainer(
                          followers: reports[topNewsIndex].followers,
                          likeCount: reports[topNewsIndex].reportLikes,
                          blocName: reports[topNewsIndex].blocName,
                          blocProfile: reports[topNewsIndex].blocProfile,
                          reportCat: reports[topNewsIndex].reportCat,
                          reportHeadline: reports[topNewsIndex].reportHeadline,
                          reportUploadTime:
                              "${DateFormat('EEEE').format(reports[topNewsIndex].reportUploadTime)}, ${reports[topNewsIndex].reportUploadTime.day} ${DateFormat('MMMM').format(reports[topNewsIndex].reportUploadTime)} ${reports[topNewsIndex].reportUploadTime.year}", //"Monday, 26 September 2022",
                          reportTime: "${DateFormat('EEEE').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              int.parse(reports[topNewsIndex].reportTime),
                            ),
                          )}, ${DateTime.fromMillisecondsSinceEpoch(
                            int.parse(reports[topNewsIndex].reportTime),
                          ).day} ${DateFormat('MMMM').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              int.parse(reports[topNewsIndex].reportTime),
                            ),
                          )} ${DateTime.fromMillisecondsSinceEpoch(
                            int.parse(reports[topNewsIndex].reportTime),
                          ).year}",
                          reportThumbPic: reports[topNewsIndex].reportTumbImage,
                          commentCount: NumberFormat.compact()
                              .format(reports[topNewsIndex].reportComments)
                              .toString(),
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
                        );
                      }),
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: refreshReporters,
                    child: ListView.separated(
                      itemBuilder: ((topNewsContext, topNewsIndex) {
                        return Container(
                          margin: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: BlocDetailsRow(
                            followers: 10000,
                            blocName: "Rupam Karmakar",
                            blocProfilePic:
                                "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                            radius: 30,
                            followed: followed,
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
                          ),
                        );
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
                      itemCount: 10,
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

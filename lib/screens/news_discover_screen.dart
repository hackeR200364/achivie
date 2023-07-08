import 'dart:convert';
import 'dart:developer';

import 'package:achivie/models/trending_reports_model.dart';
import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/screens/top_reporters_screen.dart';
import 'package:achivie/styles.dart';
import 'package:achivie/widgets/news_bloc_profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/categories_models.dart';
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

class _NewsDiscoverScreenState extends State<NewsDiscoverScreen> {
  final List<Ticker> _tickers = [];
  bool followed = false, saved = false, loading = false;
  int newsSliderIndex = 0,
      newsListIndex = 0,
      topItemIndex = 0,
      listLen = 100,
      newsSelectedCategoryIndex = 0,
      likeCount = 9999,
      pageCount = 1,
      limitCount = 2,
      totalPage = 0;
  String newsSelectedCategory = "All", token = "", uid = "", message = "";
  late TextEditingController commentController;
  late ScrollController _newsScrollController;
  late ScrollController _pageScrollController;
  List<Category> categoryList = [];
  List<TrendingReport> trendingReportsList = [];
  DateTime? dateTime;

  @override
  void initState() {
    commentController = TextEditingController();
    _newsScrollController = ScrollController();
    _pageScrollController = ScrollController();
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
      if (pageCount < totalPage) {
        fetchTrendingReports();
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

  Future fetchTrendingReports() async {
    if (pageCount < totalPage) {
      pageCount++;
    }
    http.Response response = await http.get(
      Uri.parse(
          "${Keys.apiReportsBaseUrl}/reports/trending/$uid?page=$pageCount&limit=$limitCount"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      TrendingReports trendingReports = trendingReportsFromJson(response.body);
      if (trendingReports.success) {
        log(pageCount.toString());
        log(totalPage.toString());
        setState(() {
          trendingReportsList.addAll(trendingReports.reports);
        });
      } else {
        message = "No reports found";
        loading = false;
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

    pageCount = 1;
    setState(() {});

    http.Response trendingResponse = await http.get(
      Uri.parse(
          "${Keys.apiReportsBaseUrl}/reports/trending/$uid?page=$pageCount&limit=$limitCount"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (trendingResponse.statusCode == 200) {
      if (jsonDecode(trendingResponse.body)["success"]) {
        TrendingReports trendingReports =
            trendingReportsFromJson(trendingResponse.body);
        // log(trendingReports.message);
        trendingReportsList = trendingReports.reports;
        totalPage = trendingReports.totalPage;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: (categoryList.isNotEmpty || trendingReportsList.isNotEmpty)
          ? CustomScrollView(
              controller: _pageScrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                    ),
                    child: const DiscoverPageHeading(
                      head: "Trending Reporters",
                    ),
                  ),
                ),
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
                          height: 220,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColour.withOpacity(0.2),
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
                                    itemBuilder: (topReportersContext,
                                        topReportersIndex) {
                                      return BlocDetailsRow(
                                        followers: 10000,
                                        blocName: "Rupam Karmakar",
                                        blocProfilePic:
                                            "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
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
                                        color: AppColors.white.withOpacity(0.3),
                                      );
                                    }),
                                    itemCount: 3,
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
                            itemBuilder: (newsCatContext, index) {
                              return GestureDetector(
                                onTap: (() {
                                  // log(newsCategory[index].category);
                                  setState(() {
                                    newsSelectedCategory =
                                        categoryList[index].reportCat;
                                    newsSelectedCategoryIndex = index;
                                  });
                                }),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (index == newsSelectedCategoryIndex)
                                        ? AppColors.backgroundColour
                                        : AppColors.backgroundColour
                                            .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: const Border.fromBorderSide(
                                      BorderSide(
                                        width: 0.7,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      categoryList[index].reportCat,
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
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
                    childCount: trendingReportsList.length + 1,
                    (context, index) {
                      if (index < trendingReportsList.length) {
                        return GestureDetector(
                          onTap: (() {
                            log(trendingReportsList[index].saved.toString());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (newsDetailsScreenContext) =>
                                    NewsDetailsScreen(
                                  reportID: trendingReportsList[index].reportId,
                                  reportUsrID:
                                      trendingReportsList[index].reportUsrId,
                                  usrID: uid,
                                ),
                              ),
                            );
                          }),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 10,
                            ),
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 15,
                              bottom: 15,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.backgroundColour.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                BlocDetailsRow(
                                  followers:
                                      trendingReportsList[index].followers,
                                  blocName: trendingReportsList[index].blocName,
                                  blocProfilePic:
                                      trendingReportsList[index].blocProfile,
                                  followed: trendingReportsList[index].followed,
                                  followedOnTap: (() {}),
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
                                const SizedBox(
                                  height: 25,
                                ),
                                ReportDetailsColumn(
                                  category:
                                      trendingReportsList[index].reportCat,
                                  reportHeading:
                                      trendingReportsList[index].reportHeadline,
                                  reportUploadTime:
                                      "${DateFormat('EEEE').format(trendingReportsList[index].reportUploadTime)}, ${trendingReportsList[index].reportUploadTime.day} ${DateFormat('MMMM').format(trendingReportsList[index].reportUploadTime)} ${trendingReportsList[index].reportUploadTime.year}",
                                  //"Monday, 26 September 2022",
                                  reportTime:
                                      "${DateFormat('EEEE').format(DateTime.fromMillisecondsSinceEpoch(int.parse(trendingReportsList[index].reportTime)))}, ${DateTime.fromMillisecondsSinceEpoch(int.parse(trendingReportsList[index].reportTime)).day} ${DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(int.parse(trendingReportsList[index].reportTime)))} ${DateTime.fromMillisecondsSinceEpoch(int.parse(trendingReportsList[index].reportTime)).year}",
                                  //"Monday, 26 September 2022",,
                                  // "${trendingReportsList[index].reportTime}, ${trendingReportsList[index].reportDate}",
                                  reportThumbPic: trendingReportsList[index]
                                      .reportTumbImage,
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ReportLikeBtn(
                                            isLiked: trendingReportsList[index]
                                                .liked,
                                            likeCount:
                                                trendingReportsList[index]
                                                    .reportLikes,
                                            onTap: ((liked) async {
                                              return false;
                                            }),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          ReactBtn(
                                            head: NumberFormat.compact()
                                                .format(
                                                    trendingReportsList[index]
                                                        .reportComments)
                                                .toString(),
                                            icon: (trendingReportsList[index]
                                                    .commented)
                                                ? Icons.comment
                                                : Icons.comment_outlined,
                                            onPressed: (() {
                                              showModalBottomSheet(
                                                backgroundColor:
                                                    AppColors.mainColor,
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                                builder:
                                                    (commentModelContext) =>
                                                        CommentModalSheet(
                                                  commentController:
                                                      commentController,
                                                  reporterProfilePic:
                                                      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                                  blocID: 'Rupam Karmakar',
                                                  commentTime: '12h',
                                                  comment:
                                                      "commentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdf",
                                                  commentModelContext:
                                                      commentModelContext,
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                      ReportSaveBtn(
                                        saved: trendingReportsList[index].saved,
                                        onTap: (() {}),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                color: AppColors.backgroundColour,
              ),
            ),
    );
  }
}

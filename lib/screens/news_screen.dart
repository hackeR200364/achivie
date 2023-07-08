import 'dart:developer';

import 'package:achivie/models/all_reports_model.dart';
import 'package:achivie/screens/news_details_screen.dart';
import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/services/keys.dart';
import 'package:achivie/styles.dart';
import 'package:achivie/widgets/news_bloc_profile_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  late TextEditingController commentController;
  int newsSliderIndex = 0,
      newsListIndex = 0,
      topItemIndex = 0,
      listLen = 100,
      newsSelectedCategoryIndex = 0,
      likeCount = 9999,
      pageCount = 1,
      limitCount = 2,
      totalPage = 0;

  double screenOffset = 0.0, newsOffset = 0.0;

  bool followed = false, saved = false, loading = false;
  String newsSelectedCategory = "All";
  List<Report> reports = <Report>[];
  List<Category> categoryList = [];
  String newsDes =
      "Crypto investors should be prepared to lose all their money, BOE governor says sdfbkd sjfbd shbcshb ckxc mzxcnidush yeihewjhfjdsk fjsdnkcv jdsfjkdsf iusdfhjsdff";

  @override
  void initState() {
    // _reportsCatController = ScrollController();
    _pageScrollController = ScrollController();

    _pageScrollController.addListener(_updateScreenOffset);
    // _pageScrollController.addListener(_updateNewsOffset);
    commentController = TextEditingController();
    getUserDetails();
    // refresh();
    super.initState();
  }

  @override
  void dispose() {
    _pageScrollController.removeListener(_updateScreenOffset);
    // _reportsCatController.dispose();
    _pageScrollController.dispose();
    commentController.dispose();
    for (var ticker in _tickers) {
      ticker.dispose();
    }
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
        fetchAllReports();
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

  Future fetchAllReports() async {
    if (pageCount < totalPage) {
      pageCount++;
    }
    http.Response response = await http.get(
      Uri.parse(
          "${Keys.apiReportsBaseUrl}/reports/all/$uid?page=$pageCount&limit=$limitCount"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final AllReports allReports = allReportsFromJson(response.body);
      if (allReports.success) {
        log(pageCount.toString());
        log(totalPage.toString());

        setState(() {
          reports.addAll(allReports.reports);
        });
      } else {
        message = "No reports found";
        loading = false;
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

  Future<void> refresh() async {
    pageCount = 1;
    loading = false;
    setState(() {});
    http.Response response = await http.get(
      Uri.parse(
          "${Keys.apiReportsBaseUrl}/reports/all/$uid?page=$pageCount&limit=$limitCount"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final AllReports allReports = allReportsFromJson(response.body);
      if (allReports.success) {
        reports = allReports.reports;
        totalPage = allReports.totalPage;
      } else {
        message = "No reports found";
      }
    }

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

    loading = false;
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: (categoryList.isNotEmpty || reports.isNotEmpty)
          ? CustomScrollView(
              controller: _pageScrollController,
              slivers: [
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
                        items: [
                          HomeScreenCarouselItem(
                            newsHead:
                                "cbsdhys csdbch isdhulighc biusryiuew iusdgtfyiubhw iufgtwebndfew usdhgcjkkjc kjhxc",
                            newsDes: newsDes,
                            category: "Finance",
                            followers: 100000,
                            blocName: "Rupam Karmakar",
                            blocProfilePic:
                                "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                            reportPic:
                                "https://images.unsplash.com/photo-1567769082922-a02edac05807?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80",
                            reportDetailsOnTap: (() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (newsDetailsScreenContext) =>
                                      NewsDetailsScreen(
                                    reportID: "",
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
                                    blockUID: "",
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
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
                      margin: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
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
                                      color:
                                          (index == newsSelectedCategoryIndex)
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
                          return GestureDetector(
                            onTap: (() {
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
                                    followers: reports[index].followers,
                                    blocName: reports[index].blocName,
                                    blocProfilePic: reports[index].blocProfile,
                                    followed: reports[index].followed ?? false,
                                    followedOnTap: (() {}),
                                    onTap: (() {
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
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  ReportDetailsColumn(
                                    category: reports[index].reportCat,
                                    reportHeading:
                                        reports[index].reportHeadline,
                                    reportUploadTime:
                                        "${DateFormat('EEEE').format(reports[index].reportUploadTime)}, ${reports[index].reportUploadTime.day} ${DateFormat('MMMM').format(reports[index].reportUploadTime)} ${reports[index].reportUploadTime.year}", //"Monday, 26 September 2022",
                                    reportTime:
                                        "${reports[index].reportTime}, ${reports[index].reportDate}",
                                    reportThumbPic:
                                        reports[index].reportTumbImage,
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
                                              likeCount:
                                                  reports[index].reportLikes,
                                              onTap: ((liked) async {
                                                if (reports[index].liked!) {
                                                } else {}
                                              }),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            ReactBtn(
                                              head: NumberFormat.compact()
                                                  .format(reports[index]
                                                      .reportComments)
                                                  .toString(),
                                              icon: Icons.comment_outlined,
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
                                          saved: saved,
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
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.backgroundColour,
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                if (reports.isEmpty)
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
  });

  final String newsDes, reportPic, category, newsHead, blocName, blocProfilePic;
  final VoidCallback reportDetailsOnTap, blocDetailsProfileOnTap;
  final int followers;

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
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundColour.withOpacity(0.6),
              borderRadius: BorderRadius.circular(15),
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
  });

  final VoidCallback onTap;
  final String blocProfilePic, blocName;
  final int? followers;

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
            "10 minutes ago",
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
    return Text(
      head,
      style: TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
        fontSize: 17,
        overflow: TextOverflow.clip,
      ),
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
        left: 15,
        right: 15,
        top: 5,
        bottom: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        head,
        style: TextStyle(
          color: AppColors.backgroundColour,
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

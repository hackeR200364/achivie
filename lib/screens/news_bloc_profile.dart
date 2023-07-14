import 'dart:convert';
import 'dart:developer';

import 'package:achivie/models/bloc_all_reports_model.dart';
import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/screens/search_screen.dart';
import 'package:achivie/services/keys.dart';
import 'package:achivie/services/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../Utils/snackbar_utils.dart';
import '../models/news_category_model.dart';
import '../styles.dart';
import '../widgets/news_bloc_profile_widgets.dart';
import 'news_details_screen.dart';
import 'news_screen.dart';

class NewsBlocProfile extends StatefulWidget {
  NewsBlocProfile({
    Key? key,
    required this.hasBloc,
  }) : super(key: key);

  bool hasBloc;

  @override
  State<NewsBlocProfile> createState() => _NewsBlocProfileState();
}

class _NewsBlocProfileState extends State<NewsBlocProfile>
    with TickerProviderStateMixin {
  final List<Ticker> _tickers = [];
  late ScrollController _newsScrollController;
  late ScrollController _pageScrollController;
  late TextEditingController commentController;
  int newsSliderIndex = 0,
      newsListIndex = 0,
      topItemIndex = 0,
      listLen = 100,
      newsSelectedCategoryIndex = 0,
      likeCount = 9999,
      pageCount = 1,
      limitCount = 5;

  bool _isScrollingDown = false,
      followed = false,
      saved = false,
      isDown = false,
      isLoading = false;

  String newsSelectedCategory = "Followed",
      usrProfilePic =
          "https://i0.wp.com/www.gosfordpark-coventry.org.uk/wp-content/uploads/blank-avatar.png?ssl=1",
      uid = "",
      usrDes = "",
      blocID = "",
      token = "";
  List<NewsCategoryModel> newsCategory = <NewsCategoryModel>[
    NewsCategoryModel(
      category: "My Reports",
      index: 0,
    ),
    NewsCategoryModel(
      category: "Top Reports",
      index: 1,
    ),
    NewsCategoryModel(
      category: "Liked Reports",
      index: 2,
    ),
  ];
  String newsDes =
      "Crypto investors should be prepared to lose all their money, BOE governor says sdfbkd sjfbd shbcshb ckxc mzxcnidush yeihewjhfjdsk fjsdnkcv jdsfjkdsf iusdfhjsdff";
  Map<String, dynamic>? blocDetails, blocAllReportsError;
  BlocAllReports? blocAllReports;
  late TabController _tabController;

  @override
  void initState() {
    _newsScrollController = ScrollController();
    _pageScrollController = ScrollController();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    // _newsScrollController.addListener(_updateState);
    commentController = TextEditingController();
    getUsrDetails();
    super.initState();
  }

  @override
  void dispose() {
    // _newsScrollController.removeListener(_updateState);
    _newsScrollController.dispose();
    _pageScrollController.dispose();
    commentController.dispose();
    for (var ticker in _tickers) {
      ticker.dispose();
    }
    super.dispose();
  }

  // void _updateState() => setState(() {});
  //
  // int _getIndexInView() {
  //   double itemHeight = 10; // calculate the height of each item
  //   double position = _newsScrollController.position.pixels;
  //   int index =
  //       (position / itemHeight).floor() + 1; // add 1 to start from the 2nd item
  //   // log(index.toString());
  //   return index;
  // }

  Future<void> getBlocDetails(
    String blocID,
    String uid,
    String token,
  ) async {
    log(token);
    http.Response response = await http.get(
      Uri.parse("${Keys.apiReportsBaseUrl}/bloc/details/$blocID/$uid/$uid"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    // log(response.statusCode.toString());
    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = await json.decode(response.body);

      if (responseJson["success"]) {
        blocDetails = responseJson;
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackbar().customizedAppSnackbar(
            message: responseJson[Keys.message],
            context: context,
          ),
        );
      }
      // log(responseJson.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar().customizedAppSnackbar(
          message: "Something went wrong",
          context: context,
        ),
      );
    }
  }

  Future<void> getReports(
    String blocID,
    String uid,
    String token,
    int pageCount,
    int limitCount,
  ) async {
    http.Response response = await http.get(
      Uri.parse(
          "${Keys.apiReportsBaseUrl}/reports/bloc/all/$blocID/$uid?page=$pageCount&limit=$limitCount"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      blocAllReports = blocAllReportsFromJson(response.body);
      if (blocAllReports!.success) {
        setState(() {});
      } else {
        blocAllReportsError = await json.decode(response.body);
        setState(() {});
      }
    }
  }

  void getUsrDetails() async {
    widget.hasBloc = true;
    isLoading = true;
    setState(() {});
    if (widget.hasBloc) {
      uid = await StorageServices.getUID();
      blocID = (await StorageServices.getBlocID())!;
      token = await StorageServices.getUsrToken();

      // log(token);
      await getBlocDetails(blocID, uid, token);
      await getReports(blocID, uid, token, pageCount, limitCount);

      isLoading = false;
      setState(() {});
      // log(usrProfilePic);
    } else {
      uid = await StorageServices.getUID();
      usrDes = await StorageServices.getUsrDescription();
      newsSelectedCategoryIndex = 1;
      setState(() {});
    }
  }

  Future<void> refresh() async {
    await getBlocDetails(blocID, uid, token);
    await getReports(blocID, uid, token, pageCount, limitCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: (widget.hasBloc && blocDetails != null && blocAllReports != null) ||
              (!widget.hasBloc)
          ? CustomScrollView(
              controller: _pageScrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 5,
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundImage: NetworkImage(
                                  (widget.hasBloc)
                                      ? blocDetails!["details"]["blocProfile"]
                                      : "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                ),
                              ),
                              if (widget.hasBloc)
                                IfHasBlocProfile(
                                  newsCount: blocDetails!["details"]
                                      ["reportsCount"],
                                  followersCount: blocDetails!["details"]
                                      ["followers"],
                                  followingCount:
                                      blocDetails!["details"]["following"] ?? 0,
                                ),
                              if (!widget.hasBloc)
                                IfNoBlocProfile(uid: uid, usrDes: usrDes),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (widget.hasBloc)
                          IfHasBlocProfileDetails(
                            blocUID: blocDetails!["details"]["blocID"],
                            blocDes: blocDetails!["details"]["blocDes"],
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
                          label: "My Reports",
                        ),
                        CustomSearchNewsTabBar(
                          label: "Top Reports",
                        ),
                        CustomSearchNewsTabBar(
                          label: "Liked Reports",
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => GestureDetector(
                      onTap: (() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (newsDetailsScreenContext) =>
                                const NewsDetailsScreen(
                              reportID: "",
                            ),
                          ),
                        );
                      }),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 15,
                          bottom: 15,
                        ),
                        child: Column(
                          children: [
                            if (newsSelectedCategoryIndex != 0)
                              BlocDetailsRow(
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
                                blocName: 'Rupam Karmakar',
                                blocProfilePic:
                                    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                followed: true,
                                followedOnTap: (() {}),
                              ),
                            if (newsSelectedCategoryIndex != 0)
                              const SizedBox(
                                height: 25,
                              ),
                            ReportDetailsColumn(
                              category:
                                  blocAllReports!.reports[index].reportCat,
                              reportHeading:
                                  blocAllReports!.reports[index].reportHeadline,
                              reportUploadTime:
                                  "${DateFormat('EEEE').format(blocAllReports!.reports[index].reportUploadTime)}, ${blocAllReports!.reports[index].reportUploadTime.day} ${DateFormat('MMMM').format(blocAllReports!.reports[index].reportUploadTime)} ${blocAllReports!.reports[index].reportUploadTime.year}", //"Monday, 26 September 2022",
                              reportTime:
                                  "${blocAllReports!.reports[index].reportTime}, ${blocAllReports!.reports[index].reportDate}",
                              reportThumbPic: blocAllReports!
                                  .reports[index].reportTumbImage,
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ReportLikeBtn(
                                        likeCount: blocAllReports!
                                            .reports[index].reportLikes,
                                        onTap: ((liked) async {
                                          log(liked.toString());
                                          return false;
                                        }),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ReactBtn(
                                        head: NumberFormat.compact()
                                            .format(blocAllReports!
                                                .reports[index].reportComments)
                                            .toString(),
                                        icon: Icons.comment_outlined,
                                        onPressed: (() {
                                          showModalBottomSheet(
                                            backgroundColor:
                                                AppColors.mainColor,
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
                                    saved: true,
                                    onTap: (() {}),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

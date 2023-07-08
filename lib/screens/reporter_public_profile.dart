import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';

import '../models/news_category_model.dart';
import '../services/shared_preferences.dart';
import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';
import '../widgets/news_bloc_profile_widgets.dart';
import 'news_details_screen.dart';
import 'news_screen.dart';

class ReporterPublicProfile extends StatefulWidget {
  const ReporterPublicProfile({
    Key? key,
    required this.blockUID,
  }) : super(key: key);

  final String blockUID;

  @override
  State<ReporterPublicProfile> createState() => _ReporterPublicProfileState();
}

class _ReporterPublicProfileState extends State<ReporterPublicProfile> {
  String email = 'email', profileType = "", uid = "", token = "";
  final List<Ticker> _tickers = [];
  late ScrollController _newsScrollController;
  late ScrollController _pageScrollController;
  late TextEditingController commentController;
  int newsSliderIndex = 0,
      newsListIndex = 0,
      topItemIndex = 0,
      listLen = 100,
      newsSelectedCategoryIndex = 0,
      likeCount = 9999;

  // bool _isScrollingDown = false, followed = false, saved = false;
  String newsSelectedCategory = "All",
      usrProfilePic =
          "https://i0.wp.com/www.gosfordpark-coventry.org.uk/wp-content/uploads/blank-avatar.png?ssl=1";
  List<NewsCategoryModel> newsCategory = <NewsCategoryModel>[
    NewsCategoryModel(
      category: "Top News",
      index: 0,
    ),
    NewsCategoryModel(
      category: "All News",
      index: 1,
    ),
    NewsCategoryModel(
      category: "Liked News",
      index: 2,
    ),
  ];
  String newsDes =
      "Crypto investors should be prepared to lose all their money, BOE governor says sdfbkd sjfbd shbcshb ckxc mzxcnidush yeihewjhfjdsk fjsdnkcv jdsfjkdsf iusdfhjsdff";

  @override
  void initState() {
    _newsScrollController = ScrollController();
    _pageScrollController = ScrollController(keepScrollOffset: false);
    _newsScrollController.addListener(_updateState);
    commentController = TextEditingController();
    getUsrDetails();
    super.initState();
  }

  @override
  void dispose() {
    _newsScrollController.removeListener(_updateState);
    _newsScrollController.dispose();
    _pageScrollController.dispose();
    commentController.dispose();
    for (var ticker in _tickers) {
      ticker.dispose();
    }
    super.dispose();
  }

  void _updateState() => setState(() {
        topItemIndex = _getIndexInView();
      });

  int _getIndexInView() {
    double itemHeight = 10; // calculate the height of each item
    double position = _newsScrollController.position.pixels;
    int index =
        (position / itemHeight).floor() + 1; // add 1 to start from the 2nd item
    // log(index.toString());
    return index;
  }

  void getUsrDetails() async {
    usrProfilePic = await StorageServices.getUsrProfilePic();
    setState(() {});
    log(usrProfilePic);
  }

  Future<void> refresh() async {
    log("refreshing");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: CustomAppBarLeading(
          onPressed: (() {
            Navigator.pop(context);
            // print(isPlaying);
          }),
          icon: Icons.arrow_back_ios_new,
        ),
        title: GlassmorphicContainer(
          width: double.infinity,
          height: 41,
          borderRadius: 40,
          linearGradient: AppColors.customGlassIconButtonGradient,
          border: 2,
          blur: 4,
          borderGradient: AppColors.customGlassIconButtonBorderGradient,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            // height: 41 / 2.3,
            child: Center(
              child: Text(
                "Reporter Profile",
                style: AppColors.headingTextStyle,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FullScreenWidget(
                          backgroundColor: AppColors.blackLow.withOpacity(0.3),
                          disposeLevel: DisposeLevel.Low,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                              usrProfilePic,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              BlocDetails(
                                counts: 100,
                                head: "News",
                              ),
                              BlocDetails(
                                counts: 1000000000000343234,
                                head: "Followers",
                              ),
                              BlocDetails(
                                counts: 1034235340,
                                head: "Following",
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "blockUID",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              "blockDes",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            SliverAppBar(
              backgroundColor: AppColors.mainColor,
              elevation: 0,
              pinned: true,
              leading: Container(),
              expandedHeight: 40,
              flexibleSpace: Container(
                width: MediaQuery.of(context).size.width,
                height: 40,
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: ListView.separated(
                  itemCount: newsCategory.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (newsCatContext, index) {
                    return GestureDetector(
                      onTap: (() {
                        // log(newsCategory[index].category);
                        setState(() {
                          newsSelectedCategory = newsCategory[index].category;
                          newsSelectedCategoryIndex = index;
                        });
                      }),
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        decoration: BoxDecoration(
                          color: (index == newsSelectedCategoryIndex)
                              ? AppColors.backgroundColour
                              : AppColors.backgroundColour.withOpacity(0.5),
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
                            newsCategory[index].category,
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
                      (BuildContext newsCatContext, int newsCatIndex) {
                    return SizedBox(
                      width: 15,
                    );
                  },
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
                      top: 10,
                    ),
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 15,
                      bottom: 15,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColour.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        BlocDetailsRow(
                          followers: 1000000,
                          blocName: "Rupam Karmakar",
                          blocProfilePic:
                              "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                          followed: false,
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
                        const ReportDetailsColumn(
                          category: "Finance",
                          reportHeading:
                              "Bitcoin Price and Ethereum Consolidate Despite Broader US Dollar Rally",
                          reportUploadTime: "Monday, 26 September 2022",
                          reportThumbPic:
                              "https://images.unsplash.com/photo-1567769082922-a02edac05807?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80",
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ReportLikeBtn(
                                    likeCount: likeCount,
                                    onTap: ((liked) async {
                                      return false;
                                    }),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ReactBtn(
                                    head: NumberFormat.compact()
                                        .format(10000000)
                                        .toString(),
                                    icon: Icons.comment_outlined,
                                    onPressed: (() {
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
                                          commentModelContext:
                                              commentModelContext,
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              ReportSaveBtn(
                                saved: false,
                                onTap: (() {}),
                              ),
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
        ),
      ),
    );
  }
}

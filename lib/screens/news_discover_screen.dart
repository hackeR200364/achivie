import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/screens/top_reporters_screen.dart';
import 'package:achivie/styles.dart';
import 'package:achivie/widgets/news_bloc_profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/categories_models.dart';
import '../models/news_category_model.dart';
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
  bool followed = false, saved = false;
  int newsSliderIndex = 0,
      newsListIndex = 0,
      topItemIndex = 0,
      listLen = 100,
      newsSelectedCategoryIndex = 0,
      likeCount = 9999;
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
  String newsSelectedCategory = "All", token = "";
  late TextEditingController commentController;
  late ScrollController _newsScrollController;
  late ScrollController _pageScrollController;
  List<Category> categoryList = [];

  @override
  void initState() {
    commentController = TextEditingController();
    _newsScrollController = ScrollController();
    _pageScrollController = ScrollController(keepScrollOffset: false);
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
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        controller: _pageScrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DiscoverPageHeading(
                    head: "Top Reporters",
                  ),
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
                              itemBuilder:
                                  (topReportersContext, topReportersIndex) {
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
                              separatorBuilder: ((topReportersSeparatorContext,
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
                bottom: 5,
              ),
              child: const DiscoverPageHeading(
                head: "Trending News",
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
                      separatorBuilder: (BuildContext context, int index) {
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
              (context, index) => GestureDetector(
                onTap: (() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (newsDetailsScreenContext) =>
                          const NewsDetailsScreen(
                        contentID: "",
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
                        followed: followed,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        blocUID: 'Rupam Karmakar',
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

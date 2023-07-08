import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/categories_models.dart';
import '../models/news_category_model.dart';
import '../services/keys.dart';
import '../services/shared_preferences.dart';
import '../styles.dart';
import '../widgets/news_bloc_profile_widgets.dart';
import 'news_details_screen.dart';
import 'news_screen.dart';

class NewsSavedScreen extends StatefulWidget {
  const NewsSavedScreen({Key? key}) : super(key: key);

  @override
  State<NewsSavedScreen> createState() => _NewsSavedScreenState();
}

class _NewsSavedScreenState extends State<NewsSavedScreen> {
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

  int newsSelectedCategoryIndex = 0, likeCount = 9999;
  String newsSelectedCategory = "All", token = "";
  bool followed = false, saved = false;
  late TextEditingController commentController;
  List<Category> categoryList = [];

  @override
  void initState() {
    commentController = TextEditingController();
    getUsrDetails();
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();

    super.dispose();
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
        slivers: [
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

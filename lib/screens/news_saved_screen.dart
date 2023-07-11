import 'package:flutter/material.dart';

import '../models/categories_models.dart';
import '../models/news_category_model.dart';
import '../services/shared_preferences.dart';
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
    // http.Response catResponse = await http.get(
    //   Uri.parse("${Keys.apiReportsBaseUrl}/categories"),
    //   headers: {
    //     'content-Type': 'application/json',
    //     'authorization': 'Bearer $token',
    //   },
    // );
    //
    // if (catResponse.statusCode == 200) {
    //   final blocAllCategories = blocAllCategoriesFromJson(catResponse.body);
    //
    //   if (blocAllCategories.success) {
    //     categoryList = blocAllCategories.categories;
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        slivers: [
          // SliverAppBar(
          //   expandedHeight: 40,
          //   backgroundColor: AppColors.mainColor,
          //   elevation: 0,
          //   pinned: true,
          //   flexibleSpace: Container(
          //     // padding: EdgeInsets.only(top: 10, bottom: 10),
          //     height: 45,
          //     // width: MediaQuery.of(context).size.width,
          //     margin: EdgeInsets.only(
          //       left: 10,
          //       right: 10,
          //     ),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         SizedBox(
          //           height: 10,
          //         ),
          //         Expanded(
          //           child: ListView.separated(
          //             itemCount: categoryList.length,
          //             scrollDirection: Axis.horizontal,
          //             itemBuilder: (newsCatContext, index) {
          //               return CategoryContainer(
          //                 newsSelectedCategoryIndex: newsSelectedCategoryIndex,
          //                 categoryList: categoryList,
          //                 index: index,
          //                 onTap: (() {
          //                   // log(newsCategory[index].category);
          //                   setState(() {
          //                     newsSelectedCategory =
          //                         categoryList[index].reportCat;
          //                     newsSelectedCategoryIndex = index;
          //                   });
          //                 }),
          //               );
          //             },
          //             separatorBuilder: (BuildContext context, int index) {
          //               return SizedBox(
          //                 width: 10,
          //               );
          //             },
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ReportContainer(
                followers: 100000,
                likeCount: likeCount,
                blocName: "blocName",
                blocProfile:
                    "https://images.unsplash.com/photo-1567769082922-a02edac05807?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80",
                reportCat: "Test",
                reportHeadline: "reportHeadline",
                reportUploadTime: "DateTime.now().hour",
                reportTime: "DateTime.now().hour",
                reportThumbPic:
                    "https://images.unsplash.com/photo-1567769082922-a02edac05807?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80",
                commentCount: "100",
                reportOnTap: (() {}),
                blocDetailsOnTap: (() {}),
                likeBtnOnTap: ((liked) async {}),
                commentBtnOnTap: (() {}),
                saveBtnOnTap: (() {}),
                followed: followed,
                followedOnTap: (() {}),
                saved: saved,
                liked: false,
                commented: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

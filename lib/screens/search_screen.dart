import 'dart:async';
import 'dart:developer';

import 'package:achivie/providers/news_searching_provider.dart';
import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Utils/custom_text_field_utils.dart';
import '../models/news_category_model.dart';
import '../widgets/email_us_screen_widgets.dart';
import '../widgets/news_bloc_profile_widgets.dart';
import 'news_details_screen.dart';
import 'news_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

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
  int likeCount = 1000000, _hintIndex = 0;
  Timer? timer;

  @override
  void initState() {
    _searchController = TextEditingController();
    commentController = TextEditingController();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    timer?.cancel();

    super.dispose();
  }

  void _startTimer() {
    if (timer != null && timer!.isActive) return;
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _hintIndex = (_hintIndex + 1) % newsCategory.length;
      });
    });
  }

  Future<void> refresh() async {
    log("refreshing");
  }

  @override
  Widget build(BuildContext context) {
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
        child: RefreshIndicator(
          onRefresh: refresh,
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
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                onFieldSubmitted: ((String query) {
                                  // log(query);
                                  newsSearchingProvider.queryFunc(query);
                                }),
                                onChanged: ((String query) {
                                  log(query);
                                  newsSearchingProvider.queryFunc(query);
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
                        label: "Top News",
                      ),
                      CustomSearchNewsTabBar(
                        label: "Accounts",
                      ),
                      CustomSearchNewsTabBar(
                        label: "All News",
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: Consumer<NewsSearchingProvider>(
                  builder:
                      (newsSearchCtx, newsSearchProvider, newsSearchChild) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        ListView.separated(
                          itemBuilder: ((topNewsContext, topNewsIndex) {
                            return GestureDetector(
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
                                  top: 2,
                                ),
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 15,
                                  bottom: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundColour
                                      .withOpacity(0.2),
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
                                    ReportDetailsColumn(
                                      category: "Finance",
                                      reportHeading:
                                          "Bitcoin Price and Ethereum Consolidate Despite Broader US Dollar Rally ${newsSearchProvider.query}",
                                      reportUploadTime:
                                          "Monday, 26 September 2022",
                                      reportThumbPic:
                                          "https://images.unsplash.com/photo-1567769082922-a02edac05807?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80",
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
                                                            Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height -
                                                              50,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: 15,
                                                                  left: 15,
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    CustomAppBarLeading(
                                                                      onPressed:
                                                                          (() {
                                                                        Navigator.pop(
                                                                            commentModelContext);
                                                                        // print(isPlaying);
                                                                      }),
                                                                      icon: Icons
                                                                          .arrow_back_ios_new,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    const Text(
                                                                      "Comments",
                                                                      style:
                                                                          TextStyle(
                                                                        color: AppColors
                                                                            .white,
                                                                        fontSize:
                                                                            16,
                                                                        letterSpacing:
                                                                            2,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 70,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child:
                                                                    CustomTextField(
                                                                  controller:
                                                                      commentController,
                                                                  hintText:
                                                                      "Comment as blockUID",
                                                                  keyboard:
                                                                      TextInputType
                                                                          .text,
                                                                  isPassField:
                                                                      false,
                                                                  isEmailField:
                                                                      false,
                                                                  isPassConfirmField:
                                                                      false,
                                                                  icon: Icons
                                                                      .comment,
                                                                ),
                                                              ),
                                                              Container(
                                                                height: (MediaQuery.of(context)
                                                                            .viewInsets
                                                                            .bottom <
                                                                        200)
                                                                    ? MediaQuery.of(context)
                                                                            .size
                                                                            .height -
                                                                        210
                                                                    : MediaQuery.of(context)
                                                                            .viewInsets
                                                                            .bottom -
                                                                        70,
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: 15,
                                                                  bottom: 10,
                                                                ),
                                                                child: ListView
                                                                    .separated(
                                                                  itemCount: 10,
                                                                  reverse: true,
                                                                  itemBuilder:
                                                                      ((commentsModalContext,
                                                                          commentsModalIndex) {
                                                                    return Container(
                                                                      width: MediaQuery.of(
                                                                              commentModelContext)
                                                                          .size
                                                                          .width,
                                                                      margin: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          const CircleAvatar(
                                                                            radius:
                                                                                25,
                                                                            backgroundImage:
                                                                                NetworkImage(
                                                                              "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 10),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      "blocUID $commentsModalIndex ",
                                                                                      style: const TextStyle(
                                                                                        color: AppColors.white,
                                                                                        fontSize: 13,
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 6,
                                                                                    ),
                                                                                    Text(
                                                                                      "1h",
                                                                                      style: TextStyle(
                                                                                        color: AppColors.white.withOpacity(0.6),
                                                                                        fontSize: 12,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                const Text(
                                                                                  "comment",
                                                                                  style: TextStyle(
                                                                                    color: AppColors.white,
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }),
                                                                  separatorBuilder:
                                                                      ((_,
                                                                          separatedModalIndex) {
                                                                    return const SizedBox(
                                                                      height:
                                                                          16,
                                                                    );
                                                                  }),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
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
                          }),
                          separatorBuilder: ((topNewsSeparatorContext,
                              topNewsSeparatorIndex) {
                            return const SizedBox(
                              height: 20,
                            );
                          }),
                          itemCount: 10,
                        ),
                        ListView.separated(
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
                          separatorBuilder: ((topNewsSeparatorContext,
                              topNewsSeparatorIndex) {
                            return const SizedBox(
                              height: 10,
                            );
                          }),
                          itemCount: 10,
                        ),
                        ListView.separated(
                          itemBuilder: ((topNewsContext, topNewsIndex) {
                            return GestureDetector(
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
                                  top: 2,
                                ),
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 15,
                                  bottom: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundColour
                                      .withOpacity(0.2),
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
                                      reportUploadTime:
                                          "Monday, 26 September 2022",
                                      reportThumbPic:
                                          "https://images.unsplash.com/photo-1567769082922-a02edac05807?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80",
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
                                                            Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height -
                                                              50,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: 15,
                                                                  left: 15,
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    CustomAppBarLeading(
                                                                      onPressed:
                                                                          (() {
                                                                        Navigator.pop(
                                                                            commentModelContext);
                                                                        // print(isPlaying);
                                                                      }),
                                                                      icon: Icons
                                                                          .arrow_back_ios_new,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    const Text(
                                                                      "Comments",
                                                                      style:
                                                                          TextStyle(
                                                                        color: AppColors
                                                                            .white,
                                                                        fontSize:
                                                                            16,
                                                                        letterSpacing:
                                                                            2,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 70,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child:
                                                                    CustomTextField(
                                                                  controller:
                                                                      commentController,
                                                                  hintText:
                                                                      "Comment as blockUID",
                                                                  keyboard:
                                                                      TextInputType
                                                                          .text,
                                                                  isPassField:
                                                                      false,
                                                                  isEmailField:
                                                                      false,
                                                                  isPassConfirmField:
                                                                      false,
                                                                  icon: Icons
                                                                      .comment,
                                                                ),
                                                              ),
                                                              Container(
                                                                height: (MediaQuery.of(context)
                                                                            .viewInsets
                                                                            .bottom <
                                                                        200)
                                                                    ? MediaQuery.of(context)
                                                                            .size
                                                                            .height -
                                                                        210
                                                                    : MediaQuery.of(context)
                                                                            .viewInsets
                                                                            .bottom -
                                                                        70,
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: 15,
                                                                  bottom: 10,
                                                                ),
                                                                child: ListView
                                                                    .separated(
                                                                  itemCount: 10,
                                                                  reverse: true,
                                                                  itemBuilder:
                                                                      ((commentsModalContext,
                                                                          commentsModalIndex) {
                                                                    return Container(
                                                                      width: MediaQuery.of(
                                                                              commentModelContext)
                                                                          .size
                                                                          .width,
                                                                      margin: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          const CircleAvatar(
                                                                            radius:
                                                                                25,
                                                                            backgroundImage:
                                                                                NetworkImage(
                                                                              "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 10),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      "blocUID $commentsModalIndex ",
                                                                                      style: const TextStyle(
                                                                                        color: AppColors.white,
                                                                                        fontSize: 13,
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 6,
                                                                                    ),
                                                                                    Text(
                                                                                      "1h",
                                                                                      style: TextStyle(
                                                                                        color: AppColors.white.withOpacity(0.6),
                                                                                        fontSize: 12,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                const Text(
                                                                                  "comment",
                                                                                  style: TextStyle(
                                                                                    color: AppColors.white,
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }),
                                                                  separatorBuilder:
                                                                      ((_,
                                                                          separatedModalIndex) {
                                                                    return const SizedBox(
                                                                      height:
                                                                          16,
                                                                    );
                                                                  }),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
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
                          }),
                          separatorBuilder: ((topNewsSeparatorContext,
                              topNewsSeparatorIndex) {
                            return const SizedBox(
                              height: 20,
                            );
                          }),
                          itemCount: 10,
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
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

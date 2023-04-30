import 'dart:developer';

import 'package:achivie/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

import '../Utils/custom_text_field_utils.dart';
import '../widgets/email_us_screen_widgets.dart';
import 'news_details_screen.dart';
import 'news_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late TextEditingController commentController;
  late TabController _tabController;
  bool followed = false, saved = false;
  int likeCount = 1000000;

  @override
  void initState() {
    _searchController = TextEditingController();
    commentController = TextEditingController();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 15, left: 10),
                  child: CustomAppBarLeading(
                    onPressed: (() {
                      Navigator.pop(context);
                      // print(isPlaying);
                    }),
                    icon: Icons.arrow_back_ios_rounded,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 15,
                      right: 15,
                      bottom: 10,
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
                        hintText: "Please what you want to search",
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
                      onFieldSubmitted: ((String query) {
                        log(query);
                      }),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 35,
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
                  CustomSearchNewsabBar(
                    label: "Top News",
                  ),
                  CustomSearchNewsabBar(
                    label: "Accounts",
                  ),
                  CustomSearchNewsabBar(
                    label: "All News",
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: TabBarView(
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
                                  NewsDetailsScreen(
                                contentID: "",
                              ),
                            ),
                          );
                        }),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          padding: EdgeInsets.only(
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 25,
                                        backgroundImage: NetworkImage(
                                          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.5,
                                        child: Text(
                                          "Rupam Karma jkdsncdsj kncdnmzcnkar ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.white
                                                .withOpacity(0.8),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: (() {
                                      setState(() {
                                        followed = !followed;
                                      });
                                    }),
                                    child: AnimatedContainer(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      decoration: BoxDecoration(
                                        color: (followed == true)
                                            ? AppColors.red
                                            : AppColors.backgroundColour,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      duration: Duration(milliseconds: 400),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              (followed == true)
                                                  ? Icons.sentiment_dissatisfied
                                                  : Icons
                                                      .emoji_emotions_outlined,
                                              color: AppColors.white,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              (followed == true)
                                                  ? "Unfollow"
                                                  : "Follow",
                                              style: TextStyle(
                                                color: AppColors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                      left: 15,
                                      right: 15,
                                      top: 5,
                                      bottom: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.backgroundColour,
                                      ),
                                    ),
                                    child: Text(
                                      "Finance",
                                      style: TextStyle(
                                        color: AppColors.backgroundColour,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    "Bitcoin Price and Ethereum Consolidate Despite Broader US Dollar Rally",
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    "Monday, 26 September 2022",
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.4),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          "https://images.unsplash.com/photo-1567769082922-a02edac05807?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        LikeButton(
                                          onTap: ((liked) async {
                                            if (likeCount < 100000)
                                              return false;
                                          }),
                                          likeCount: likeCount,
                                          isLiked: true,
                                          circleColor: const CircleColor(
                                            start: AppColors.gold,
                                            end: AppColors.orange,
                                          ),
                                          bubblesColor: BubblesColor(
                                            dotPrimaryColor: AppColors.gold,
                                            dotSecondaryColor: AppColors.orange,
                                          ),
                                          countBuilder: (int? count,
                                              bool isLiked, String text) {
                                            var color = isLiked
                                                ? AppColors.gold
                                                : AppColors.white;
                                            Widget result;
                                            if (count == 0) {
                                              result = Text(
                                                "Like",
                                                style: TextStyle(color: color),
                                              );
                                            } else {
                                              result = Text(
                                                NumberFormat.compact()
                                                    .format(count),
                                                style: TextStyle(color: color),
                                              );
                                            }
                                            return result;
                                          },
                                          likeCountAnimationType:
                                              likeCount < 1000
                                                  ? LikeCountAnimationType.part
                                                  : LikeCountAnimationType.none,
                                          likeCountPadding:
                                              const EdgeInsets.only(left: 5.0),
                                          likeBuilder: (bool isLiked) {
                                            return Icon(
                                              isLiked
                                                  ? Icons.thumb_up
                                                  : Icons.thumb_up_off_alt,
                                              color: isLiked
                                                  ? AppColors.goldDark
                                                  : AppColors.white,
                                              size: 25,
                                            );
                                          },
                                        ),
                                        // ReactBtn(
                                        //   head: NumberFormat.compact()
                                        //       .format(10000000)
                                        //       .toString(),
                                        //   icon: Icons.thumb_up_off_alt,
                                        //   onPressed: (() {}),
                                        // ),
                                        SizedBox(
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
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                              ),
                                              builder: (commentModelContext) =>
                                                  Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    50,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
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
                                                                onPressed: (() {
                                                                  Navigator.pop(
                                                                      commentModelContext);
                                                                  // print(isPlaying);
                                                                }),
                                                                icon: Icons
                                                                    .arrow_back_ios_new,
                                                              ),
                                                              SizedBox(
                                                                width: 15,
                                                              ),
                                                              Text(
                                                                "Comments",
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  fontSize: 16,
                                                                  letterSpacing:
                                                                      2,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
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
                                                            isPassField: false,
                                                            isEmailField: false,
                                                            isPassConfirmField:
                                                                false,
                                                            icon: Icons.comment,
                                                          ),
                                                        ),
                                                        Container(
                                                          height: (MediaQuery.of(
                                                                          context)
                                                                      .viewInsets
                                                                      .bottom <
                                                                  200)
                                                              ? MediaQuery.of(
                                                                          commentModelContext)
                                                                      .size
                                                                      .height -
                                                                  200
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .viewInsets
                                                                      .bottom -
                                                                  70,
                                                          margin:
                                                              EdgeInsets.only(
                                                            top: 15,
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
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            15),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
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
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              10),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "blocUID $commentsModalIndex ",
                                                                                style: TextStyle(
                                                                                  color: AppColors.white,
                                                                                  fontSize: 13,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
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
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            "comment",
                                                                            style:
                                                                                TextStyle(
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
                                                            separatorBuilder: ((_,
                                                                separatedModalIndex) {
                                                              return SizedBox(
                                                                height: 16,
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
                                    // ReactBtn(
                                    //   head: NumberFormat.compact()
                                    //       .format(10000000)
                                    //       .toString(),
                                    //   icon: Icons.send_outlined,
                                    //   onPressed: (() {}),
                                    // ),
                                    GestureDetector(
                                      onTap: (() {
                                        setState(() {
                                          saved = !saved;
                                        });
                                      }),
                                      child: AnimatedContainer(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        decoration: BoxDecoration(
                                          color: (saved == true)
                                              ? AppColors.white
                                                  .withOpacity(0.35)
                                              : AppColors.white
                                                  .withOpacity(0.25),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        duration: Duration(milliseconds: 500),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              (saved == true)
                                                  ? Icons.bookmark
                                                  : Icons
                                                      .bookmark_border_outlined,
                                              color: AppColors.white,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Center(
                                              child: Text(
                                                (saved == true)
                                                    ? "Saved"
                                                    : "Save",
                                                style: TextStyle(
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    separatorBuilder:
                        ((topNewsSeparatorContext, topNewsSeparatorIndex) {
                      return SizedBox(
                        height: 20,
                      );
                    }),
                    itemCount: 10,
                  ),
                  ListView.separated(
                    itemBuilder: ((topNewsContext, topNewsIndex) {
                      return Container(
                        width: MediaQuery.of(topNewsContext).size.width,
                        margin: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 12,
                          right: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Rupam Karmajksdf sdfsd dsncdsjkncdnmzcnkar",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              AppColors.white.withOpacity(0.8),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "${NumberFormat.compact().format(10000000).toString()} Followers",
                                        style: TextStyle(
                                          color:
                                              AppColors.white.withOpacity(0.4),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: (() {
                                setState(() {
                                  followed = !followed;
                                });
                              }),
                              child: AnimatedContainer(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                width: MediaQuery.of(context).size.width / 3.5,
                                decoration: BoxDecoration(
                                  color: (followed == true)
                                      ? AppColors.red
                                      : AppColors.backgroundColour,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                duration: Duration(milliseconds: 400),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        (followed == true)
                                            ? Icons.sentiment_dissatisfied
                                            : Icons.emoji_emotions_outlined,
                                        color: AppColors.white,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        (followed == true)
                                            ? "Unfollow"
                                            : "Follow",
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                    separatorBuilder:
                        ((topNewsSeparatorContext, topNewsSeparatorIndex) {
                      return SizedBox(
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
                                  NewsDetailsScreen(
                                contentID: "",
                              ),
                            ),
                          );
                        }),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          padding: EdgeInsets.only(
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 25,
                                        backgroundImage: NetworkImage(
                                          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.5,
                                        child: Text(
                                          "Rupam Karma jkdsncdsj kncdnmzcnkar ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.white
                                                .withOpacity(0.8),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: (() {
                                      setState(() {
                                        followed = !followed;
                                      });
                                    }),
                                    child: AnimatedContainer(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      decoration: BoxDecoration(
                                        color: (followed == true)
                                            ? AppColors.red
                                            : AppColors.backgroundColour,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      duration: Duration(milliseconds: 400),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              (followed == true)
                                                  ? Icons.sentiment_dissatisfied
                                                  : Icons
                                                      .emoji_emotions_outlined,
                                              color: AppColors.white,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              (followed == true)
                                                  ? "Unfollow"
                                                  : "Follow",
                                              style: TextStyle(
                                                color: AppColors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                      left: 15,
                                      right: 15,
                                      top: 5,
                                      bottom: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.backgroundColour,
                                      ),
                                    ),
                                    child: Text(
                                      "Finance",
                                      style: TextStyle(
                                        color: AppColors.backgroundColour,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    "Bitcoin Price and Ethereum Consolidate Despite Broader US Dollar Rally",
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    "Monday, 26 September 2022",
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.4),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          "https://images.unsplash.com/photo-1567769082922-a02edac05807?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        LikeButton(
                                          onTap: ((liked) async {
                                            if (likeCount < 100000)
                                              return false;
                                          }),
                                          likeCount: likeCount,
                                          isLiked: true,
                                          circleColor: const CircleColor(
                                            start: AppColors.gold,
                                            end: AppColors.orange,
                                          ),
                                          bubblesColor: BubblesColor(
                                            dotPrimaryColor: AppColors.gold,
                                            dotSecondaryColor: AppColors.orange,
                                          ),
                                          countBuilder: (int? count,
                                              bool isLiked, String text) {
                                            var color = isLiked
                                                ? AppColors.gold
                                                : AppColors.white;
                                            Widget result;
                                            if (count == 0) {
                                              result = Text(
                                                "Like",
                                                style: TextStyle(color: color),
                                              );
                                            } else {
                                              result = Text(
                                                NumberFormat.compact()
                                                    .format(count),
                                                style: TextStyle(color: color),
                                              );
                                            }
                                            return result;
                                          },
                                          likeCountAnimationType:
                                              likeCount < 1000
                                                  ? LikeCountAnimationType.part
                                                  : LikeCountAnimationType.none,
                                          likeCountPadding:
                                              const EdgeInsets.only(left: 5.0),
                                          likeBuilder: (bool isLiked) {
                                            return Icon(
                                              isLiked
                                                  ? Icons.thumb_up
                                                  : Icons.thumb_up_off_alt,
                                              color: isLiked
                                                  ? AppColors.goldDark
                                                  : AppColors.white,
                                              size: 25,
                                            );
                                          },
                                        ),
                                        // ReactBtn(
                                        //   head: NumberFormat.compact()
                                        //       .format(10000000)
                                        //       .toString(),
                                        //   icon: Icons.thumb_up_off_alt,
                                        //   onPressed: (() {}),
                                        // ),
                                        SizedBox(
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
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                              ),
                                              builder: (commentModelContext) =>
                                                  Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    50,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
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
                                                                onPressed: (() {
                                                                  Navigator.pop(
                                                                      commentModelContext);
                                                                  // print(isPlaying);
                                                                }),
                                                                icon: Icons
                                                                    .arrow_back_ios_new,
                                                              ),
                                                              SizedBox(
                                                                width: 15,
                                                              ),
                                                              Text(
                                                                "Comments",
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  fontSize: 16,
                                                                  letterSpacing:
                                                                      2,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
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
                                                            isPassField: false,
                                                            isEmailField: false,
                                                            isPassConfirmField:
                                                                false,
                                                            icon: Icons.comment,
                                                          ),
                                                        ),
                                                        Container(
                                                          height: (MediaQuery.of(
                                                                          context)
                                                                      .viewInsets
                                                                      .bottom <
                                                                  200)
                                                              ? MediaQuery.of(
                                                                          commentModelContext)
                                                                      .size
                                                                      .height -
                                                                  200
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .viewInsets
                                                                      .bottom -
                                                                  70,
                                                          margin:
                                                              EdgeInsets.only(
                                                            top: 15,
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
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            15),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
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
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              10),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "blocUID $commentsModalIndex ",
                                                                                style: TextStyle(
                                                                                  color: AppColors.white,
                                                                                  fontSize: 13,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
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
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            "comment",
                                                                            style:
                                                                                TextStyle(
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
                                                            separatorBuilder: ((_,
                                                                separatedModalIndex) {
                                                              return SizedBox(
                                                                height: 16,
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
                                    // ReactBtn(
                                    //   head: NumberFormat.compact()
                                    //       .format(10000000)
                                    //       .toString(),
                                    //   icon: Icons.send_outlined,
                                    //   onPressed: (() {}),
                                    // ),
                                    GestureDetector(
                                      onTap: (() {
                                        setState(() {
                                          saved = !saved;
                                        });
                                      }),
                                      child: AnimatedContainer(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        decoration: BoxDecoration(
                                          color: (saved == true)
                                              ? AppColors.white
                                                  .withOpacity(0.35)
                                              : AppColors.white
                                                  .withOpacity(0.25),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        duration: Duration(milliseconds: 500),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              (saved == true)
                                                  ? Icons.bookmark
                                                  : Icons
                                                      .bookmark_border_outlined,
                                              color: AppColors.white,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Center(
                                              child: Text(
                                                (saved == true)
                                                    ? "Saved"
                                                    : "Save",
                                                style: TextStyle(
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    separatorBuilder:
                        ((topNewsSeparatorContext, topNewsSeparatorIndex) {
                      return SizedBox(
                        height: 20,
                      );
                    }),
                    itemCount: 10,
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

class CustomSearchNewsabBar extends StatelessWidget {
  const CustomSearchNewsabBar({
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

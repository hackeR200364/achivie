import 'dart:developer';

import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/services/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

import '../Utils/custom_text_field_utils.dart';
import '../models/news_category_model.dart';
import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';
import 'news_details_screen.dart';
import 'news_screen.dart';

class NewsBlocProfile extends StatefulWidget {
  const NewsBlocProfile({Key? key}) : super(key: key);

  @override
  State<NewsBlocProfile> createState() => _NewsBlocProfileState();
}

class _NewsBlocProfileState extends State<NewsBlocProfile>
    with TickerProviderStateMixin {
  final List<Ticker> _tickers = [];
  late ScrollController _newsScrollController;
  late ScrollController _pageScrollController;
  late TextEditingController commentController;
  late TabController _tabController;
  int newsSliderIndex = 0,
      newsListIndex = 0,
      topItemIndex = 0,
      listLen = 100,
      newsSelectedCategoryIndex = 0,
      likeCount = 9999;

  bool _isScrollingDown = false, followed = false, saved = false;
  String newsSelectedCategory = "All",
      usrProfilePic =
          "https://i0.wp.com/www.gosfordpark-coventry.org.uk/wp-content/uploads/blank-avatar.png?ssl=1";
  List<NewsCategoryModel> newsCategory = <NewsCategoryModel>[
    NewsCategoryModel(
      category: "My News",
      index: 0,
    ),
    NewsCategoryModel(
      category: "Followed",
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
    _tabController = TabController(length: 3, vsync: this);
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
    return RefreshIndicator(
      onRefresh: refresh,
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
            top: 15,
            left: 10,
            right: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isScrollingDown && topItemIndex <= 2)
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FullScreenWidget(
                            backgroundColor:
                                AppColors.blackLow.withOpacity(0.3),
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
              Container(
                width: MediaQuery.of(context).size.width,
                height: 35,
                margin: const EdgeInsets.only(
                  bottom: 10,
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
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: (topItemIndex > -10)
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                  controller: _newsScrollController,
                  itemCount: 100,
                  shrinkWrap: true,
                  itemBuilder: (newsListContext, index) {
                    // log(index.toString());
                    if (_newsScrollController.position.userScrollDirection ==
                        ScrollDirection.reverse) {
                      Future.delayed(
                        Duration.zero,
                        (() {
                          setState(() {
                            _isScrollingDown = true;
                          });
                        }),
                      );
                    }
                    if (_newsScrollController.position.userScrollDirection ==
                        ScrollDirection.forward) {
                      Future.delayed(
                        Duration.zero,
                        (() {
                          setState(() {
                            _isScrollingDown = false;
                          });
                        }),
                      );
                    }

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
                            if (newsSelectedCategoryIndex != 0)
                              GestureDetector(
                                onTap: (() {
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
                                child: Row(
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.7,
                                          child: Text(
                                            "Rupam Karma jkdsncdsj kncdnmzcnkar $newsSelectedCategory",
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
                                            MediaQuery.of(context).size.width /
                                                3,
                                        decoration: BoxDecoration(
                                          color: (followed == true)
                                              ? AppColors.red
                                              : AppColors.backgroundColour,
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                                    ? Icons
                                                        .sentiment_dissatisfied
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
                              ),
                            if (newsSelectedCategoryIndex != 0)
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
                                          if (likeCount < 100000) return false;
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
                                        countBuilder: (int? count, bool isLiked,
                                            String text) {
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
                                        likeCountAnimationType: likeCount < 1000
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
                                                              style: TextStyle(
                                                                color: AppColors
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
                                                        child: CustomTextField(
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
                                                        margin: EdgeInsets.only(
                                                          top: 15,
                                                        ),
                                                        child:
                                                            ListView.separated(
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
                                                                    radius: 25,
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
                                                                          CrossAxisAlignment
                                                                              .start,
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
                                                                            color:
                                                                                AppColors.white,
                                                                            fontSize:
                                                                                13,
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
                                          MediaQuery.of(context).size.width / 3,
                                      decoration: BoxDecoration(
                                        color: (saved == true)
                                            ? AppColors.white.withOpacity(0.35)
                                            : AppColors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(10),
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
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 16,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlocDetails extends StatelessWidget {
  const BlocDetails({
    super.key,
    required this.head,
    required this.counts,
  });

  final int counts;
  final String head;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          NumberFormat.compact().format(counts),
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          head,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

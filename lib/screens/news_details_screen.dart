import 'package:achivie/screens/image_preview_screen.dart';
import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';
import 'news_screen.dart';

class NewsDetailsScreen extends StatefulWidget {
  const NewsDetailsScreen({
    Key? key,
    required this.contentID,
  }) : super(key: key);

  final String contentID;

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  int likeCount = 10000;
  bool saved = false, followed = false, commentPressed = false;
  late TextEditingController commentController;

  @override
  void initState() {
    commentController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
                  "News Details",
                  style: AppColors.headingTextStyle,
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: 65,
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                countBuilder: (int? count, bool isLiked, String text) {
                  var color = isLiked ? AppColors.gold : AppColors.white;
                  Widget result;
                  if (count == 0) {
                    result = Text(
                      "Like",
                      style: TextStyle(color: color),
                    );
                  } else {
                    result = Text(
                      NumberFormat.compact().format(count),
                      style: TextStyle(color: color),
                    );
                  }
                  return result;
                },
                likeCountAnimationType: likeCount < 1000
                    ? LikeCountAnimationType.part
                    : LikeCountAnimationType.none,
                likeCountPadding: const EdgeInsets.only(left: 5.0),
                likeBuilder: (bool isLiked) {
                  return Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                    color: isLiked ? AppColors.goldDark : AppColors.white,
                    size: 25,
                  );
                },
              ),
              ReactBtn(
                head: NumberFormat.compact().format(10000000).toString(),
                icon: Icons.comment_outlined,
                onPressed: (() {
                  showModalBottomSheet(
                    backgroundColor: AppColors.mainColor,
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    builder: (commentModelContext) => Container(
                      height:
                          MediaQuery.of(commentModelContext).size.height - 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 15,
                                left: 15,
                              ),
                              child: Row(
                                children: [
                                  CustomAppBarLeading(
                                    onPressed: (() {
                                      Navigator.pop(commentModelContext);
                                      // print(isPlaying);
                                    }),
                                    icon: Icons.arrow_back_ios_new,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Comments",
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: 10,
                                reverse: true,
                                itemBuilder: ((commentsModalContext,
                                    commentsModalIndex) {
                                  return Container(
                                    width: MediaQuery.of(commentModelContext)
                                        .size
                                        .width,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const CircleAvatar(
                                          radius: 25,
                                          backgroundImage: NetworkImage(
                                            "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Column(
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
                                                      color: AppColors.white
                                                          .withOpacity(0.6),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
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
                                separatorBuilder: ((_, separatedModalIndex) {
                                  return SizedBox(
                                    height: 16,
                                  );
                                }),
                              ),
                            ),
                            SizedBox(
                              height: 70,
                              width:
                                  MediaQuery.of(commentModelContext).size.width,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  left: 15,
                                  right: 15,
                                  bottom: 10,
                                ),
                                child: TextFormField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  scrollPhysics: AppColors.scrollPhysics,
                                  decoration: InputDecoration(
                                    errorStyle: const TextStyle(
                                      overflow: TextOverflow.clip,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.comment,
                                      color: AppColors.white,
                                    ),
                                    prefixStyle: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                    ),
                                    hintText: "Comment as blocUID",
                                    hintStyle: TextStyle(
                                      color: AppColors.white.withOpacity(0.5),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: (() {
                                        if (commentController.text
                                            .trim()
                                            .isNotEmpty) {
                                          Navigator.pop(commentModelContext);
                                        }
                                      }),
                                      icon: const Icon(
                                        Icons.send,
                                        color: AppColors.white,
                                      ),
                                      splashRadius: 20,
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
                                  controller: commentController,
                                  keyboardType: TextInputType.text,
                                  cursorColor: AppColors.white,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              GestureDetector(
                onTap: (() {
                  setState(() {
                    saved = !saved;
                  });
                }),
                child: AnimatedContainer(
                  width: MediaQuery.of(context).size.width / 2.5,
                  duration: Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    color: (saved == true)
                        ? AppColors.white.withOpacity(0.35)
                        : AppColors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        (saved == true)
                            ? Icons.bookmark
                            : Icons.bookmark_border_outlined,
                        color: AppColors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Center(
                        child: Text(
                          (saved == true) ? "Saved" : "Save",
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            width: 8,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Rupam Karmajkdsncdsjkncdnmzcnkar",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white.withOpacity(0.8),
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${NumberFormat.compact().format(10000000).toString()} Followers",
                                  style: TextStyle(
                                    color: AppColors.white.withOpacity(0.4),
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
                            horizontal: 16,
                            vertical: 8,
                          ),
                          width: MediaQuery.of(context).size.width / 3,
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
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                  (followed == true) ? "Unfollow" : "Follow",
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
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
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
                  height: 8,
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
                  height: 8,
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
                  height: 24,
                ),
                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CarouselSlider(
                    items: [
                      GestureDetector(
                        onTap: (() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (imagePreviewContext) =>
                                  ImagePreviewScreen(
                                imageURL:
                                    "https://images.unsplash.com/photo-1567769082922-a02edac05807?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2340&q=80",
                              ),
                            ),
                          );
                        }),
                        child: Container(
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
                      ),
                      GestureDetector(
                        onTap: (() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (imagePreviewContext) =>
                                  ImagePreviewScreen(
                                imageURL:
                                    "https://images.pexels.com/photos/16523717/pexels-photo-16523717.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
                              ),
                            ),
                          );
                        }),
                        child: Hero(
                          tag:
                              "https://images.pexels.com/photos/16523717/pexels-photo-16523717.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
                          child: Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  "https://images.pexels.com/photos/16523717/pexels-photo-16523717.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    options: CarouselOptions(
                      viewportFraction: 0.85,
                      height: 250,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      // autoPlay: true,
                      scrollPhysics: AppColors.scrollPhysics,
                      onPageChanged: ((index, reason) {
                        setState(() {
                          // newsSliderIndex = index;
                        });
                      }),
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  "Disclaimer: The Industry Talk section features insights by crypto industry players and is not a part of the editorial content of Cryptonews.com. Shiba Inu has dropped by 6.4% in the past 24 hours. SHIB’s 24-hour dip adds to the intense bearish pressure that has seen it lose 19% of its value over the past month. At the time of writing, SHIB was trading at \$0.00001124 Shiba Inu seems to be affected by the bearish sentiment pushing its price to lower lows. During the past 24 hours, SHIB has recorded \$433 million in trading volumes, with its market cap dropping slightly to \$6.63 billion.",
                  style: TextStyle(
                    color: AppColors.white,
                    height: 2,
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

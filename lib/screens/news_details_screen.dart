import 'package:achivie/screens/image_preview_screen.dart';
import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/widgets/news_bloc_profile_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';

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
            left: 10,
            right: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReportLikeBtn(
                likeCount: likeCount,
                onTap: ((liked) async {
                  if (likeCount < 100000) return false;
                }),
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
                    builder: (commentModelContext) => CommentModalSheet(
                      commentController: commentController,
                      reporterProfilePic:
                          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                      blocUID: 'Rupam Karmakar',
                      commentTime: '12h',
                      comment:
                          "commentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdf",
                      commentModelContext: commentModelContext,
                    ),
                  );
                }),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: (() {
                    setState(() {
                      saved = !saved;
                    });
                  }),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    margin: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
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
                BlocDetailsRow(
                  radius: 25,
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

class CommentModalSheet extends StatelessWidget {
  const CommentModalSheet({
    super.key,
    required this.commentController,
    required this.reporterProfilePic,
    required this.blocUID,
    required this.commentTime,
    required this.comment,
    required this.commentModelContext,
  });

  final TextEditingController commentController;
  final BuildContext commentModelContext;
  final String reporterProfilePic, blocUID, commentTime, comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(commentModelContext).size.height - 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.mainColor,
            elevation: 0,
            pinned: true,
            leading: SizedBox(),
            expandedHeight: 60,
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(
                top: 15,
                left: 15,
              ),
              child: CommentTopRow(
                commentModelContext: commentModelContext,
              ),
            ),
          ),
          SliverAppBar(
            backgroundColor: AppColors.mainColor,
            elevation: 0,
            pinned: true,
            leading: SizedBox(),
            // expandedHeight: 100,
            flexibleSpace: Container(
              height: 65,
              margin: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: CommentTextField(
                commentController: commentController,
                commentModelContext: commentModelContext,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: 10,
              (context, index) => ReportCommentList(
                commentModelContext: commentModelContext,
                reporterProfilePic: reporterProfilePic,
                blocUID: blocUID,
                commentTime: commentTime,
                comment: comment,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportCommentList extends StatelessWidget {
  const ReportCommentList({
    super.key,
    required this.commentModelContext,
    required this.reporterProfilePic,
    required this.blocUID,
    required this.commentTime,
    required this.comment,
  });

  final BuildContext commentModelContext;
  final String reporterProfilePic, blocUID, commentTime, comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(commentModelContext).size.width,
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 10,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  reporterProfilePic,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommentBlocDetailsTimeRow(
                      blocUID: blocUID,
                      commentTime: commentTime,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CommentDetails(
                      comment: comment,
                    ),
                  ],
                ),
              )
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 1,
            margin: EdgeInsets.only(
              top: 10,
              bottom: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentDetails extends StatelessWidget {
  const CommentDetails({
    super.key,
    required this.comment,
  });

  final String comment;

  @override
  Widget build(BuildContext context) {
    return Text(
      comment,
      style: TextStyle(
        color: AppColors.white,
        fontSize: 13,
      ),
    );
  }
}

class CommentBlocDetailsTimeRow extends StatelessWidget {
  const CommentBlocDetailsTimeRow({
    super.key,
    required this.blocUID,
    required this.commentTime,
  });

  final String blocUID, commentTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          blocUID,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 6,
        ),
        Text(
          commentTime,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class CommentTopRow extends StatelessWidget {
  const CommentTopRow({
    super.key,
    required this.commentModelContext,
  });

  final BuildContext commentModelContext;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class CommentTextField extends StatelessWidget {
  const CommentTextField({
    super.key,
    required this.commentController,
    required this.commentModelContext,
  });

  final TextEditingController commentController;
  final BuildContext commentModelContext;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
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
            if (commentController.text.trim().isNotEmpty) {
              Navigator.pop(commentModelContext);
            }
          }),
          icon: Center(
            child: const Icon(
              Icons.send,
              color: AppColors.white,
            ),
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: commentController,
      keyboardType: TextInputType.text,
      cursorColor: AppColors.white,
      style: const TextStyle(
        color: AppColors.white,
      ),
    );
  }
}

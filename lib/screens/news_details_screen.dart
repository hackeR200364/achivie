import 'dart:convert';

import 'package:achivie/models/report_details_model.dart';
import 'package:achivie/screens/image_preview_screen.dart';
import 'package:achivie/screens/reporter_public_profile.dart';
import 'package:achivie/screens/search_screen.dart';
import 'package:achivie/widgets/news_bloc_profile_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../services/keys.dart';
import '../services/shared_preferences.dart';
import '../styles.dart';
import '../widgets/email_us_screen_widgets.dart';
import 'news_screen.dart';

class NewsDetailsScreen extends StatefulWidget {
  const NewsDetailsScreen({
    Key? key,
    required this.reportID,
    this.reportUsrID,
    this.usrID,
  }) : super(key: key);

  final String? reportID, reportUsrID, usrID;

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  int likeCount = 10000;
  bool liked = false,
      saved = false,
      followed = false,
      commented = false,
      commentPressed = false,
      loading = false;
  late TextEditingController commentController;
  String token = "", message = "";
  ReportDetails? reportDetails;
  DateTime? dateTime;

  @override
  void initState() {
    commentController = TextEditingController();
    getUserDetails();
    super.initState();
  }

  Future<void> refresh() async {
    loading = false;
    setState(() {});
    http.Response response = await http.get(
      Uri.parse(
          "${Keys.apiReportsBaseUrl}/report/details/${widget.reportUsrID}/${widget.reportID}/${widget.usrID}"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> resJson = jsonDecode(response.body);
      if (resJson["success"]) {
        reportDetails = reportDetailsFromJson(response.body);
        // log(reportDetails.toString());
        dateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(reportDetails!.details.reportTime),
        );
        // log(dateTime.toString());
      } else {
        message = reportDetails!.message;
      }
    } else {
      message = "${response.statusCode}: Something went wrong";
    }

    setState(() {});
  }

  void getUserDetails() async {
    token = await StorageServices.getUsrToken();
    setState(() {});

    await refresh();
    // Future.delayed(
    //   const Duration(
    //     milliseconds: 700,
    //   ),
    //   (() {
    //
    //   }),
    // );

    // print(profileType);
  }

  @override
  Widget build(BuildContext context) {
    return (reportDetails == null)
        ? const Scaffold(
            backgroundColor: AppColors.mainColor,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.backgroundColour,
              ),
            ),
          )
        : Scaffold(
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ReportLikeBtn(
                          likeCount: reportDetails!.details.reportLikes,
                          isLiked: reportDetails!.liked,
                          onTap: ((liked) async {
                            // if (likeCount < 100000)
                            return false;
                          }),
                        ),
                        ReactBtn(
                          head: NumberFormat.compact()
                              .format(reportDetails!.details.reportComments)
                              .toString(),
                          icon: (reportDetails!.commented)
                              ? Icons.comment
                              : Icons.comment_outlined,
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
                              builder: (commentModelContext) =>
                                  CommentModalSheet(
                                commentController: commentController,
                                reporterProfilePic:
                                    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                                blocID: 'Rupam Karmakar',
                                commentTime: '12h',
                                comment:
                                    "commentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdfcommentdfvxc dfg dfdfgdfg dkasdjh kjsdfghsef uiadsfyhiuejsf ksdjfuhuisfkjsd kidsuyfuisfb kadjsfhyuoisdf",
                                commentModelContext: commentModelContext,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
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
                          color: (reportDetails!.saved == true)
                              ? AppColors.white.withOpacity(0.35)
                              : AppColors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              (reportDetails!.saved == true)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border_outlined,
                              color: AppColors.white,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Center(
                              child: Text(
                                (reportDetails!.saved == true)
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
                    ),
                  ),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: refresh,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocDetailsRow(
                        radius: 25,
                        followers: reportDetails!.details.followers,
                        blocName: reportDetails!.details.blocName,
                        blocProfilePic: reportDetails!.details.blocProfile,
                        followed: reportDetails!.followed,
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
                          reportDetails!.details.reportCat,
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
                      ReportDetailsHead(
                        reportHeadline: reportDetails!.details.reportHeadline,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      ReportUploadedTimeText(
                        reportTime:
                            "${DateFormat('EEEE').format(reportDetails!.details.reportUploadTime)}, ${reportDetails!.details.reportUploadTime.day} ${DateFormat('MMMM').format(reportDetails!.details.reportUploadTime)} ${reportDetails!.details.reportUploadTime.year}", //"Monday, 26 September 2022",
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ReportTimeText(
                        reportTime:
                            "${DateFormat('EEEE').format(dateTime!)}, ${dateTime!.day} ${DateFormat('MMMM').format(dateTime!)} ${dateTime!.year}", //"Monday, 26 September 2022",,
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CarouselSlider(
                          items: reportDetails!.details.reportImages
                              .map(
                                (e) => GestureDetector(
                                  onTap: (() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (imagePreviewContext) =>
                                            ImagePreviewScreen(
                                          imageURL: e,
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
                                          e,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
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
                      ReportDetailsDes(
                        reportDes: reportDetails!.details.reportDes,
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

class ReportDetailsDes extends StatelessWidget {
  ReportDetailsDes({
    super.key,
    required this.reportDes,
  });

  String reportDes;

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(r'(#[\w]+)|(https?:\/\/[\w.\/?=]+)');
    final List<TextSpan> spans = [];

    reportDes.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final matchedText = match.group(0);
        spans.add(
          TextSpan(
            text: matchedText,
            style: matchedText!.startsWith("#")
                ? const TextStyle(
                    color: AppColors.mentionTextDark,
                    fontSize: 14,
                  )
                : (matchedText.startsWith("https") ||
                        matchedText.startsWith("http"))
                    ? const TextStyle(
                        color: AppColors.mentionText,
                        fontSize: 14,
                      )
                    : const TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
            recognizer: TapGestureRecognizer()
              ..onTap = (() async {
                if (matchedText.startsWith("#")) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (searchPageCtx) => SearchScreen(
                        query: matchedText,
                      ),
                    ),
                  );
                }

                if (matchedText.startsWith("https") ||
                    matchedText.startsWith("http")) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (webPageCtx) => WebViewScreen(url: matchedText),
                  //   ),
                  // );

                  if (await canLaunchUrlString(matchedText)) {
                    await launchUrlString(matchedText);
                  }
                }
              }),
          ),
        );
        return matchedText;
      },
      onNonMatch: (String nonMatch) {
        spans.add(
          TextSpan(
            text: nonMatch,
            style: TextStyle(
              color: AppColors.white,
              height: 2,
            ),
          ),
        );

        return nonMatch;
      },
    );
    reportDes = reportDes.replaceAllMapped(
      RegExp(r'\\u\{([\dA-Fa-f ]+)\}'),
      (match) => String.fromCharCode(
        int.parse(match.group(1)!, radix: 16),
      ),
    );
    return RichText(
      text: TextSpan(
        children: spans,
      ),
    );
  }
}

class ReportDetailsHead extends StatelessWidget {
  const ReportDetailsHead({
    super.key,
    required this.reportHeadline,
  });

  final String reportHeadline;

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(r'(?:#|@)\w+');
    // final mentionRegex = RegExp(r'\@\w+');
    final List<TextSpan> spans = [];

    reportHeadline.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final String? matchedText = match.group(0);
        spans.add(
          TextSpan(
            text: matchedText,
            style: matchedText!.startsWith("#")
                ? TextStyle(
                    color: AppColors.mentionTextDark,
                    // fontWeight: FontWeight.w500,
                    fontSize: 14,
                  )
                : matchedText.startsWith("@")
                    ? TextStyle(
                        color: AppColors.mentionText,
                        // fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )
                    : TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (searchPageCtx) => SearchScreen(
                      initialIndex: matchedText.startsWith("#")
                          ? 0
                          : matchedText.startsWith("@")
                              ? 1
                              : 0,
                      query: matchedText.startsWith("#")
                          ? matchedText
                          : matchedText.startsWith("@")
                              ? matchedText.substring(1)
                              : null,
                    ),
                  ),
                );
              },
          ),
        );

        return matchedText!;
      },
      onNonMatch: (String nonMatch) {
        spans.add(
          TextSpan(
            text: nonMatch,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

        return nonMatch;
      },
    );

    // head.splitMapJoin(
    //   mentionRegex,
    //   onMatch: (Match match) {
    //     final String? matchedText = match.group(0);
    //
    //     spans.add(
    //       TextSpan(
    //         text: matchedText,
    //         style: TextStyle(
    //           color: AppColors.mainColor2,
    //           fontWeight: FontWeight.w500,
    //           fontSize: 15,
    //         ),
    //         recognizer: TapGestureRecognizer()
    //           ..onTap = (() {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (searchPageCtx) => SearchScreen(
    //                   initialIndex: 1,
    //                   query: matchedText!.substring(1),
    //                 ),
    //               ),
    //             );
    //           }),
    //       ),
    //     );
    //     return matchedText!;
    //   },
    // );

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

class CommentModalSheet extends StatelessWidget {
  const CommentModalSheet({
    super.key,
    required this.commentController,
    required this.reporterProfilePic,
    required this.blocID,
    required this.commentTime,
    required this.comment,
    required this.commentModelContext,
  });

  final TextEditingController commentController;
  final BuildContext commentModelContext;
  final String reporterProfilePic, blocID, commentTime, comment;

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
                blocUID: blocID,
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

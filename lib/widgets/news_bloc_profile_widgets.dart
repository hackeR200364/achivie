import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

import '../screens/search_screen.dart';
import '../styles.dart';

class IfHasBlocProfileDetails extends StatelessWidget {
  const IfHasBlocProfileDetails({
    super.key,
    required this.blocUID,
    required this.blocDes,
  });

  final String blocUID, blocDes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            blocUID,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(
              blocDes,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IfNoBlocProfile extends StatelessWidget {
  const IfNoBlocProfile({
    super.key,
    required this.uid,
    required this.usrDes,
  });

  final String uid;
  final String usrDes;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              uid,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              usrDes,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IfHasBlocProfile extends StatelessWidget {
  const IfHasBlocProfile({
    super.key,
    this.newsCount,
    this.followersCount,
    this.followingCount,
  });

  final int? newsCount, followersCount, followingCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: BlocDetails(
                counts: newsCount ?? 0,
                head: "News",
              ),
            ),
            Expanded(
              child: BlocDetails(
                counts: followersCount ?? 0,
                head: "Followers",
              ),
            ),
            Expanded(
              child: BlocDetails(
                counts: followingCount ?? 0,
                head: "Following",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryListContainer extends StatelessWidget {
  const CategoryListContainer({
    super.key,
    required this.newsSelectedCategoryIndex,
    // required this.newsCategory,
    required this.onTap,
    required this.hasBloc,
    required this.index,
    required this.category,
  });

  final int newsSelectedCategoryIndex, index;
  // final List<NewsCategoryModel> newsCategory;
  final VoidCallback onTap;
  final bool hasBloc;
  final String category;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: (!hasBloc && index == 0)
          ? Container()
          : Container(
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
                  category,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
    );
  }
}

class CreateBlocBtn extends StatelessWidget {
  const CreateBlocBtn({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
            // right: 0,
            ),
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        height: 40,
        width: 130,
        decoration: BoxDecoration(
          color: AppColors.backgroundColour.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: const Border.fromBorderSide(
            BorderSide(
              width: 0.7,
              color: AppColors.white,
            ),
          ),
        ),
        child: const Center(
          child: Text(
            "Create Your Bloc",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class BlocDetailsRow extends StatelessWidget {
  const BlocDetailsRow({
    super.key,
    required this.blocName,
    required this.blocProfilePic,
    required this.followed,
    required this.followedOnTap,
    required this.onTap,
    this.followers,
    this.radius,
  });

  final String blocName, blocProfilePic;
  final int? followers;
  final bool followed;
  final VoidCallback followedOnTap, onTap;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ReportBlockNameRow(
              blockName: blocName,
              blockProfilePic: blocProfilePic,
              followers: followers,
              radius: radius,
            ),
            const SizedBox(
              width: 5,
            ),
            FollowedBtn(
              onTap: followedOnTap,
              followed: followed,
            ),
          ],
        ),
      ),
    );
  }
}

class ReportDetailsColumn extends StatelessWidget {
  const ReportDetailsColumn({
    super.key,
    required this.category,
    required this.reportHeading,
    required this.reportUploadTime,
    this.reportTime,
    required this.reportThumbPic,
  });

  final String category, reportHeading, reportUploadTime, reportThumbPic;
  final String? reportTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportNewsCat(
          category: category,
        ),
        const SizedBox(
          height: 15,
        ),
        ReportHeadText(
          head: reportHeading,
        ),
        const SizedBox(
          height: 15,
        ),
        ReportUploadedTimeText(
          reportTime: reportUploadTime,
        ),
        if (reportTime != null)
          const SizedBox(
            height: 5,
          ),
        if (reportTime != null)
          ReportTimeText(
            reportTime: reportTime!,
          ),
        const SizedBox(
          height: 15,
        ),
        ReportPic(
          reportPic: reportThumbPic,
        ),
      ],
    );
  }
}

class ReportSaveBtn extends StatelessWidget {
  const ReportSaveBtn({
    super.key,
    required this.saved,
    required this.onTap,
  });

  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        width: MediaQuery.of(context).size.width / 3,
        decoration: BoxDecoration(
          color: (saved == true)
              ? AppColors.white.withOpacity(0.35)
              : AppColors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(milliseconds: 500),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              (saved == true) ? Icons.bookmark : Icons.bookmark_border_outlined,
              color: AppColors.white,
            ),
            const SizedBox(
              width: 5,
            ),
            Center(
              child: Text(
                (saved == true) ? "Saved" : "Save",
                style: const TextStyle(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportLikeBtn extends StatelessWidget {
  ReportLikeBtn({
    super.key,
    required this.likeCount,
    required this.onTap,
    this.isLiked,
  });

  final int likeCount;
  bool? isLiked = false;
  final Future<bool?> Function(bool)? onTap;

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      onTap: onTap,
      likeCount: likeCount,
      isLiked: isLiked,
      circleColor: const CircleColor(
        start: AppColors.gold,
        end: AppColors.orange,
      ),
      bubblesColor: const BubblesColor(
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
    );
  }
}

class ReportPic extends StatelessWidget {
  const ReportPic({
    super.key,
    required this.reportPic,
  });

  final String reportPic;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            reportPic,
          ),
        ),
      ),
    );
  }
}

class ReportUploadedTimeText extends StatelessWidget {
  const ReportUploadedTimeText({
    super.key,
    required this.reportTime,
  });

  final String reportTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Uploaded on: ",
          style: TextStyle(
            color: AppColors.white.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          reportTime,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.4),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ReportTimeText extends StatelessWidget {
  const ReportTimeText({
    super.key,
    required this.reportTime,
  });

  final String reportTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Report on: ",
          style: TextStyle(
            color: AppColors.white.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          reportTime,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.4),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ReportHeadText extends StatelessWidget {
  const ReportHeadText({
    super.key,
    required this.head,
  });

  final String head;

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(r'(?:#|@)\w+');
    // final mentionRegex = RegExp(r'\@\w+');
    final List<TextSpan> spans = [];

    head.splitMapJoin(
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
                      query: matchedText,
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

class ReportNewsCat extends StatelessWidget {
  const ReportNewsCat({
    super.key,
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        category,
        style: const TextStyle(
          color: AppColors.backgroundColour,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class FollowedBtn extends StatefulWidget {
  const FollowedBtn({
    super.key,
    required this.onTap,
    required this.followed,
  });

  final VoidCallback onTap;
  final bool followed;

  @override
  State<FollowedBtn> createState() => _FollowedBtnState();
}

class _FollowedBtnState extends State<FollowedBtn> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        width: MediaQuery.of(context).size.width / 3,
        decoration: BoxDecoration(
          color: (widget.followed == true)
              ? AppColors.red
              : AppColors.backgroundColour,
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(milliseconds: 400),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                (widget.followed == true)
                    ? Icons.sentiment_dissatisfied
                    : Icons.emoji_emotions_outlined,
                color: AppColors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                (widget.followed == true) ? "Unfollow" : "Follow",
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportBlockNameRow extends StatelessWidget {
  const ReportBlockNameRow({
    super.key,
    required this.blockName,
    required this.blockProfilePic,
    this.followers,
    this.radius,
  });

  final String blockName, blockProfilePic;
  final int? followers;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: radius ?? 20,
                backgroundImage: NetworkImage(
                  blockProfilePic,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: ReportUserNameText(
                  blockName: blockName,
                  followers: followers,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportUserNameText extends StatelessWidget {
  const ReportUserNameText({
    super.key,
    required this.blockName,
    this.followers,
  });

  final String blockName;
  final int? followers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$blockName",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            overflow: TextOverflow.visible,
          ),
        ),
        if (followers != null && followers! > 0)
          Container(
            margin: EdgeInsets.only(top: 2),
            child: Text(
              "${NumberFormat.compact().format(followers)} followers",
              style: TextStyle(
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
          ),
      ],
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          NumberFormat.compact().format(counts),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          head,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

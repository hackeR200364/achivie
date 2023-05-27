import 'package:achivie/screens/news_details_screen.dart';
import 'package:achivie/styles.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../widgets/email_us_screen_widgets.dart';

class NewsNotificationScreen extends StatelessWidget {
  const NewsNotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: CustomAppBarLeading(
          onPressed: (() {
            Navigator.pop(context); // print(isPlaying);
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
          child: Center(
            child: Text(
              "Notifications",
              style: AppColors.subHeadingTextStyle,
            ),
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 15,
          right: 15,
        ),
        child: ListView.separated(
          itemCount: 20,
          physics: AppColors.scrollPhysics,
          itemBuilder: ((notifyItemContext, notifyItemIndex) {
            return GestureDetector(
              onTap: (() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (newsDetailsScreen) => NewsDetailsScreen(
                      contentID: "",
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
                        width: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(
                          "sducfah asdhyfgvhjad asdhuyfgayh iuefgasdhf laghsdf",
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                    width: MediaQuery.of(notifyItemContext).size.width / 11,
                    child: Image.network(
                      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80",
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            );
          }),
          separatorBuilder: ((notifySeparatorContext, notifySeparatorIndex) {
            return Container(
              width: MediaQuery.of(notifySeparatorContext).size.width,
              height: 20,
            );
          }),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:task_app/Utils/auth_text_field_utils.dart';
import 'package:task_app/Utils/snackbar_utils.dart';

import '../styles.dart';

class EmailUSScreen extends StatefulWidget {
  const EmailUSScreen({Key? key}) : super(key: key);

  @override
  State<EmailUSScreen> createState() => _EmailUSScreenState();
}

class _EmailUSScreenState extends State<EmailUSScreen> {
  late TextEditingController _bodyController;
  late TextEditingController _subjectController;

  @override
  void initState() {
    _bodyController = TextEditingController();
    _subjectController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundColour,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: Image.asset(
                "assets/motivational-pics/email-us-bg.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              child: Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.mainColor.withOpacity(0.7),
                      AppColors.transparent,
                      AppColors.mainColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: size.height / 6,
              child: GlassmorphicContainer(
                margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.5,
                borderRadius: 20,
                linearGradient: LinearGradient(
                  colors: [
                    AppColors.white.withOpacity(0.1),
                    AppColors.white.withOpacity(0.3),
                  ],
                ),
                border: 2,
                blur: 4,
                borderGradient: LinearGradient(
                  colors: [
                    AppColors.white.withOpacity(0.3),
                    AppColors.white.withOpacity(0.5),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Please enter your query",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: size.height / 30,
                    ),
                    Column(
                      children: [
                        AuthTextField(
                          controller: _subjectController,
                          hintText: "Subject",
                          keyboard: TextInputType.text,
                          isPassField: false,
                          isEmailField: false,
                          isPassConfirmField: false,
                          icon: Icons.subject,
                        ),
                        AuthTextField(
                          maxLen: ((size.height / 100).toInt() < 2)
                              ? 2
                              : (size.height / 100).toInt(),
                          minLen: 1,
                          controller: _bodyController,
                          hintText: "Body",
                          keyboard: TextInputType.multiline,
                          isPassField: false,
                          isEmailField: false,
                          isPassConfirmField: false,
                          icon: Icons.description,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        InkWell(
                          onTap: (() async {
                            if (_subjectController.text.isNotEmpty &&
                                _bodyController.text.isNotEmpty) {
                              Email email = Email(
                                subject: _subjectController.text.trim(),
                                body: _bodyController.text.trim(),
                                recipients: [
                                  "rupamkarmakar1238@gmail.com",
                                ],
                              );

                              await FlutterEmailSender.send(email);
                              ScaffoldMessenger.of(context).showSnackBar(
                                AppSnackbar().customizedAppSnackbar(
                                  message: "Email sent successfully",
                                  context: context,
                                ),
                              );
                            } else {
                              print((size.height / 100).toInt());
                              ScaffoldMessenger.of(context).showSnackBar(
                                AppSnackbar().customizedAppSnackbar(
                                  message: "Please fill the fields properly",
                                  context: context,
                                ),
                              );
                            }
                          }),
                          child: GlassmorphicContainer(
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: 50,
                            borderRadius: 20,
                            linearGradient: LinearGradient(
                              colors: [
                                AppColors.backgroundColour.withOpacity(0.3),
                                AppColors.backgroundColour.withOpacity(0.5),
                              ],
                            ),
                            border: 2,
                            blur: 4,
                            borderGradient: LinearGradient(
                              colors: [
                                AppColors.white.withOpacity(0.3),
                                AppColors.white.withOpacity(0.5),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Send Email",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 15,
              left: 20,
              child: GlassmorphicContainer(
                width: 40,
                height: 40,
                borderRadius: 25,
                linearGradient: LinearGradient(
                  colors: [
                    AppColors.white.withOpacity(0.1),
                    AppColors.white.withOpacity(0.3),
                  ],
                ),
                border: 2,
                blur: 4,
                borderGradient: LinearGradient(
                  colors: [
                    AppColors.white.withOpacity(0.3),
                    AppColors.white.withOpacity(0.5),
                  ],
                ),
                child: IconButton(
                  onPressed: (() {
                    ZoomDrawer.of(context)!.toggle();
                  }),
                  icon: Icon(
                    Icons.menu,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

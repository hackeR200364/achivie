import 'dart:async';
import 'dart:io';

import 'package:achivie/screens/sign_screen.dart';
import 'package:achivie/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Utils/snackbar_utils.dart';
import '../providers/app_providers.dart';
import '../widgets/email_us_screen_widgets.dart';

class ReportUploadScreen extends StatefulWidget {
  const ReportUploadScreen({Key? key}) : super(key: key);

  @override
  State<ReportUploadScreen> createState() => _ReportUploadScreenState();
}

class _ReportUploadScreenState extends State<ReportUploadScreen> {
  late TextEditingController _reportNameController,
      _reportDesController,
      _reportLocationController,
      _reportDateController;
  final ImagePicker imagePicker = ImagePicker();
  List<File> pickedImages = [];
  XFile? thumbnail;
  bool isThumb = false,
      locationTapped = false,
      headLineTapped = false,
      desTapped = false,
      isCustomDate = false;

  DateTime? dateTime;
  DateTime? newDate;
  TimeOfDay? newTime;

  @override
  void initState() {
    _reportNameController = TextEditingController();
    _reportDesController = TextEditingController();
    _reportLocationController = TextEditingController();
    _reportDateController = TextEditingController(
        text:
            "Date: ${DateFormat("dd/MM/yyyy").format(DateTime.now())}, Time: ${DateFormat.Hm().format(DateTime.now())}");
    super.initState();
  }

  @override
  void dispose() {
    _reportNameController.dispose();
    _reportDesController.dispose();
    _reportLocationController.dispose();
    _reportDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Center(
            child: Text(
              "Upload New Report",
              style: AppColors.subHeadingTextStyle,
            ),
          ),
        ),
        actions: [
          Center(
            child: Consumer<AllAppProviders>(
              builder: ((allAppProvidersContext, allAppProvidersProvider,
                  allAppProvidersChild) {
                return GestureDetector(
                  onTap: (() {
                    if (pickedImages.isNotEmpty &&
                        pickedImages.length > 1 &&
                        thumbnail != null) {
                      if (_reportNameController.text.trim().isNotEmpty &&
                          _reportDesController.text.trim().isNotEmpty &&
                          _reportDateController.text.trim().isNotEmpty &&
                          _reportLocationController.text.trim().isNotEmpty) {
                        if (newDate != null && newTime != null) {
                        } else {
                          ScaffoldMessenger.of(allAppProvidersContext)
                              .showSnackBar(
                            AppSnackbar().customizedAppSnackbar(
                              message: "Please select the date properly",
                              context: allAppProvidersContext,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(allAppProvidersContext)
                            .showSnackBar(
                          AppSnackbar().customizedAppSnackbar(
                            message: "Please enter your report details",
                            context: allAppProvidersContext,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(allAppProvidersContext).showSnackBar(
                        AppSnackbar().customizedAppSnackbar(
                          message: "Please select your report pictures",
                          context: allAppProvidersContext,
                        ),
                      );
                    }
                  }),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: 41,
                    margin: EdgeInsets.only(
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColour,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        "Post",
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          if (pickedImages.isEmpty)
            SliverToBoxAdapter(
              child: UploadBigBtn(
                onTap: (() async {
                  List<XFile> pickedImagesOnTap =
                      await imagePicker.pickMultiImage();
                  setState(() {
                    pickedImages = pickedImagesOnTap
                        .map(
                          (e) => File(e.path),
                        )
                        .toList();
                  });
                }),
                headTitle: "Upload Images",
                suggTitle:
                    "Don't select more than 10 pictures\nIt will decrease your rank",
              ),
            ),
          if (pickedImages.isNotEmpty)
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (pickedImagesContext, pickedImagesIndex) {
                  return Container(
                    margin: EdgeInsets.only(
                      left: 2.5,
                      right: 2.5,
                      top: 2.5,
                      bottom: 2.5,
                    ),
                    decoration: BoxDecoration(),
                    child: Image.file(
                      pickedImages[pickedImagesIndex],
                      fit: BoxFit.cover,
                    ),
                  );
                },
                childCount: pickedImages.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,

                // maxCrossAxisExtent: 100.0,
                // mainAxisSpacing: 10.0,
                // crossAxisSpacing: 10.0,
              ),
            ),
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: (thumbnail != null)
                  ? Stack(
                      children: [
                        GestureDetector(
                          onTap: (() {}),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            margin: EdgeInsets.only(
                              top: 10,
                              left: 10,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(
                                  File(thumbnail!.path),
                                ),
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: IconButton(
                            onPressed: (() {
                              thumbnail = null;
                              isThumb = false;
                              setState(() {});
                            }),
                            icon: Icon(
                              Icons.delete,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    )
                  : UploadBigBtn(
                      headTitle: "Upload Your Thumbnail",
                      suggTitle:
                          "You can upload your custom thumbnail\nIt will help bring more likes",
                      onTap: (() async {
                        thumbnail = await imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (thumbnail == null) return;
                        setState(() {});
                      }),
                    ),
            ),
          ),
          if (pickedImages.isNotEmpty || thumbnail != null)
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: (() {
                  setState(() {
                    isThumb = !isThumb;
                    if (isThumb) {
                      thumbnail = XFile(pickedImages[0].path);
                    } else {
                      thumbnail = null;
                    }
                  });
                }),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(
                    top: 15,
                    bottom: 15,
                    left: 10,
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Use the first picture as thumbnail",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: isThumb,
                          onChanged: ((checked) {
                            setState(() {
                              isThumb = !isThumb;
                              if (isThumb) {
                                thumbnail = XFile(pickedImages[0].path);
                              } else {
                                thumbnail = null;
                              }
                            });
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: (() {
                setState(() {
                  isCustomDate = !isCustomDate;
                  if (isCustomDate) {
                    thumbnail = XFile(pickedImages[0].path);
                  } else {
                    thumbnail = null;
                  }
                });
              }),
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(
                  top: (pickedImages.isNotEmpty || thumbnail != null) ? 0 : 20,
                  bottom: 15,
                  left: 10,
                  right: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Use custom date for your report",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: isCustomDate,
                        onChanged: ((checked) async {
                          if (checked) {
                            newDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(DateTime.now().year + 1),
                            ).whenComplete(() async {
                              newTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: DateTime.now().hour,
                                  minute: DateTime.now().minute,
                                ),
                              );
                            });
                            _reportDateController.text =
                                "Date: ${DateFormat("dd/MM/yyyy").format(newDate!)}, Time: ${DateFormat.Hm().format(
                              DateTime(
                                newDate!.year,
                                newDate!.month,
                                newDate!.day,
                                newTime!.hour,
                                newTime!.minute,
                              ),
                            )}";
                          } else {
                            _reportDateController.text =
                                "Date: ${DateFormat("dd/MM/yyyy").format(DateTime.now())}, Time: ${DateFormat.Hm().format(DateTime.now())}";
                          }
                          isCustomDate = !isCustomDate;
                          setState(() {});
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isCustomDate)
            SliverToBoxAdapter(
              child: AuthNameTextField(
                controller: _reportDateController,
                hintText: "Report Date & Time",
                icon: Icons.date_range,
                readOnly: true,
              ),
            ),
          SliverToBoxAdapter(
            child: AuthNameTextField(
              controller: _reportNameController,
              hintText: "Report Headline",
              icon: Icons.newspaper,
              desField: true,
              maxWords: 50,
            ),
          ),
          if (desTapped)
            const SliverToBoxAdapter(
              child: SuggestionContainer(
                sugg:
                    "Suggestion: Describe the incident. Don't use any AI generated content. It will decrease the ranking ability",
              ),
            ),
          SliverToBoxAdapter(
            child: AuthNameTextField(
              controller: _reportDesController,
              hintText: "Report Description",
              icon: Icons.description,
              desField: true,
              maxWords: 1000,
              maxLines: 5,
              onTap: (() {
                setState(() {
                  desTapped = true;
                });
                Timer(
                  const Duration(seconds: 7),
                  (() {
                    setState(() {
                      desTapped = false;
                    });
                  }),
                );
              }),
            ),
          ),
          if (locationTapped)
            const SliverToBoxAdapter(
              child: SuggestionContainer(
                sugg:
                    "Suggestion: Write your location like in this format, Nearby Place, Street, Place, State, PIN",
              ),
            ),
          SliverToBoxAdapter(
            child: AuthNameTextField(
              controller: _reportLocationController,
              hintText: "Report location",
              icon: Icons.location_on,
              onTap: (() {
                setState(() {
                  locationTapped = true;
                });
                Timer(
                  const Duration(seconds: 7),
                  (() {
                    setState(() {
                      locationTapped = false;
                    });
                  }),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestionContainer extends StatelessWidget {
  const SuggestionContainer({
    super.key,
    required this.sugg,
  });

  final String sugg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
      ),
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 15,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColour.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          sugg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class UploadBigBtn extends StatelessWidget {
  const UploadBigBtn({
    super.key,
    required this.headTitle,
    required this.suggTitle,
    required this.onTap,
  });

  final String headTitle, suggTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width,
        height: 150,
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 5,
        ),
        borderRadius: 15,
        linearGradient: AppColors.customGlassIconButtonGradient,
        border: 1.5,
        blur: 4,
        borderGradient: AppColors.customGlassIconButtonBorderGradient,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  headTitle,
                  style: AppColors.subHeadingTextStyle,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                suggTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

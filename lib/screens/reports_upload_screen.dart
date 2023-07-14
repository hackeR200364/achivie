import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:achivie/models/categories_models.dart';
import 'package:achivie/models/hashtags_model.dart';
import 'package:achivie/screens/sign_screen.dart';
import 'package:achivie/services/keys.dart';
import 'package:achivie/styles.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:multi_trigger_autocomplete/multi_trigger_autocomplete.dart';
import 'package:provider/provider.dart';

import '../Utils/snackbar_utils.dart';
import '../providers/app_providers.dart';
import '../services/shared_preferences.dart';
import '../widgets/email_us_screen_widgets.dart';

class RestrictedTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove any characters that are not alphabetic letters
    final formattedText = newValue.text.replaceAll(RegExp(r'[^a-zA-Z]'), '');

    // Return the formatted text
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class LocationTextInputFormatter extends TextInputFormatter {
  final RegExp _allowedRegex = RegExp(r'^[a-zA-Z,]*$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final formattedText = newValue.text.replaceAll(RegExp(r'[^a-zA-Z,]'), '');
    final words = formattedText.split(',');
    final limitedWords = words.take(3);
    final limitedText = limitedWords.join(',');

    return TextEditingValue(
      text: limitedText,
      selection: newValue.selection.copyWith(
        baseOffset: limitedText.length,
        extentOffset: limitedText.length,
      ),
    );
  }
}

class SingleWordTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove any whitespace from the beginning or end of the input
    final trimmedValue = newValue.text.trim();

    // Check if the input contains any whitespace
    final hasWhitespace = trimmedValue.contains(RegExp(r'\s'));

    if (hasWhitespace) {
      // If input contains whitespace, replace it with an empty string
      final formattedText = trimmedValue.replaceAll(RegExp(r'\s'), '');
      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    // Return the original value if there are no changes needed
    return newValue;
  }
}

class ReportUploadScreen extends StatefulWidget {
  const ReportUploadScreen({Key? key}) : super(key: key);

  @override
  State<ReportUploadScreen> createState() => _ReportUploadScreenState();
}

class _ReportUploadScreenState extends State<ReportUploadScreen> {
  int pageCount = 1, limitCount = 10;

  late TextEditingController _reportCatController,
      _reportNameController,
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
      isCustomDate = false,
      isCatTapped = false,
      desHashtagDetect = false,
      nameHashtagDetect = false;

  String token = "";

  // DateTime? dateTime;
  DateTime? newDate;
  TimeOfDay? newTime;
  List<Category> categories = [];
  List<Hashtag> hashtagsLocal = [];
  late FocusNode nameFocusNode;

  @override
  void initState() {
    _reportCatController = TextEditingController();
    _reportNameController = TextEditingController();
    _reportDesController = TextEditingController();
    _reportLocationController = TextEditingController();
    _reportDateController = TextEditingController(
        text:
            "Date: ${DateFormat("dd/MM/yyyy").format(DateTime.now())}, Time: ${DateFormat.Hm().format(DateTime.now())}");
    nameFocusNode = FocusNode();
    getUsrDetails();
    super.initState();
  }

  @override
  void dispose() {
    _reportCatController.dispose();
    _reportNameController.dispose();
    _reportDesController.dispose();
    _reportLocationController.dispose();
    _reportDateController.dispose();
    super.dispose();
  }

  void getUsrDetails() async {
    token = await StorageServices.getUsrToken();
    setState(() {});
  }

  Future<List<Category>> fetchCategories(String query) async {
    // String token = await StorageServices.getUsrToken();

    http.Response response = await http.get(
      Uri.parse(
          "${Keys.apiReportsBaseUrl}/categories?page=$pageCount&limit=$limitCount"),
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      log(response.statusCode.toString());
      final blocAllCategories = blocAllCategoriesFromJson(response.body);
      if (blocAllCategories.success) {
        if (query.isNotEmpty) {
          return blocAllCategories.categories
              .where((item) => item.reportCat.startsWith(query))
              .toList();
        } else {
          return blocAllCategories.categories;
        }
      } else {
        throw Exception('Failed to fetch hashtags');
      }
    } else {
      throw Exception('Failed to fetch hashtags');
    }
  }

  Future<List<Hashtag>> fetchHashtags(String query) async {
    // String token = await StorageServices.getUsrToken();

    var uri = Uri.parse(
        "${Keys.apiReportsBaseUrl}/hashtags/autocomplete?q=${Uri.encodeComponent(query)}&page=$pageCount&limit=$limitCount");

    http.Response response = await http.get(
      uri,
      headers: {
        'content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Hashtags hashtags = hashtagsFromJson(response.body);
      if (hashtags.success) {
        log(hashtags.message);
        return hashtags.hashtags;
      } else {
        throw Exception('Failed to fetch hashtags 1');
      }
    } else {
      log(response.statusCode.toString());
      throw Exception('Failed to fetch hashtags');
    }
  }

  String replaceText(String currentText, String newText) => currentText
      .replaceAllMapped(RegExp(r'(#\w+)(?!.*#\w+)'), (match) => newText);

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Scaffold(
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
                "Upload Report",
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
                    onTap: (allAppProvidersProvider.isLoading)
                        ?
                        // null
                        (() {
                            allAppProvidersProvider.isLoadingFunc(false);
                          })
                        : (() async {
                            if (pickedImages.isNotEmpty &&
                                pickedImages.length > 1 &&
                                thumbnail != null) {
                              if (_reportNameController.text.trim().isNotEmpty &&
                                  _reportDesController.text.trim().isNotEmpty &&
                                  _reportDateController.text
                                      .trim()
                                      .isNotEmpty &&
                                  _reportLocationController.text
                                      .trim()
                                      .isNotEmpty) {
                                newDate = DateTime.now();
                                newTime = TimeOfDay(
                                  hour: newDate!.hour,
                                  minute: newDate!.minute,
                                );
                                if (newDate != null && newTime != null) {
                                  allAppProvidersProvider.isLoadingFunc(true);
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  if (isCustomDate) {
                                    newDate = DateTime(
                                      newDate!.year,
                                      newDate!.month,
                                      newDate!.day,
                                      newTime!.hour,
                                      newTime!.minute,
                                    );
                                  } else {
                                    newDate = DateTime.now();
                                  }

                                  http.MultipartFile? multipartImagesFile;
                                  var request = http.MultipartRequest(
                                    'POST',
                                    Uri.parse(
                                      "${Keys.apiReportsBaseUrl}/report/add",
                                    ),
                                  );

                                  // for (var i = 0; i < pickedImages.length; i++) {
                                  //   var imageFile = pickedImages[i];
                                  //   var stream =
                                  //       http.ByteStream(imageFile.openRead());
                                  //   var length = await imageFile.length();
                                  //
                                  //   multipartImagesFile = http.MultipartFile(
                                  //     'reportImages',
                                  //     stream,
                                  //     length,
                                  //     filename: imageFile.path,
                                  //   );
                                  // }

                                  for (var file in pickedImages) {
                                    var multipartFile =
                                        await http.MultipartFile.fromPath(
                                            "reportImages", file.path);
                                    request.files.add(multipartFile);
                                  }

                                  var fileStream = http.ByteStream(
                                    thumbnail!.openRead(),
                                  );

                                  var thumbLength = await thumbnail!.length();

                                  var multipartThumbFile = http.MultipartFile(
                                    "reportTumbImage",
                                    fileStream,
                                    thumbLength,
                                    filename: thumbnail!.path.split('/').last,
                                  );

                                  request.fields["reportCat"] =
                                      _reportCatController.text.trim();

                                  request.fields["reportHeadline"] =
                                      _reportNameController.text.trim();

                                  request.fields["reportDes"] =
                                      _reportDesController.text.trim();

                                  request.fields["reportLocation"] =
                                      _reportLocationController.text.trim();

                                  request.fields["reportDate"] = newDate!
                                      .millisecondsSinceEpoch
                                      .toString();

                                  request.fields["reportTime"] = newDate!
                                      .millisecondsSinceEpoch
                                      .toString();

                                  request.fields["reportBlocID"] =
                                      (await StorageServices.getBlocID())!;

                                  request.fields["reportUsrID"] =
                                      (await StorageServices.getUID());

                                  // request.files.add(multipartImagesFile!);
                                  request.files.add(multipartThumbFile);

                                  http.StreamedResponse streamedResponse =
                                      await request.send();

                                  http.Response response =
                                      await http.Response.fromStream(
                                          streamedResponse);

                                  log(response.body.toString());

                                  Map<String, dynamic> responseJson =
                                      await json.decode(response.body);

                                  if (response.statusCode == 200) {
                                    if (responseJson["success"]) {
                                      ScaffoldMessenger.of(
                                              allAppProvidersContext)
                                          .showSnackBar(
                                        AppSnackbar().customizedAppSnackbar(
                                          message: responseJson["message"],
                                          context: allAppProvidersContext,
                                        ),
                                      );
                                      allAppProvidersProvider
                                          .isLoadingFunc(false);

                                      Navigator.pop(context);
                                    } else {
                                      allAppProvidersProvider
                                          .isLoadingFunc(false);

                                      ScaffoldMessenger.of(
                                              allAppProvidersContext)
                                          .showSnackBar(
                                        AppSnackbar().customizedAppSnackbar(
                                          message: responseJson["message"],
                                          context: allAppProvidersContext,
                                        ),
                                      );
                                    }
                                  } else {
                                    allAppProvidersProvider
                                        .isLoadingFunc(false);

                                    ScaffoldMessenger.of(allAppProvidersContext)
                                        .showSnackBar(
                                      AppSnackbar().customizedAppSnackbar(
                                        message: response.statusCode.toString(),
                                        context: allAppProvidersContext,
                                      ),
                                    );
                                  }
                                } else {
                                  allAppProvidersProvider.isLoadingFunc(false);

                                  ScaffoldMessenger.of(allAppProvidersContext)
                                      .showSnackBar(
                                    AppSnackbar().customizedAppSnackbar(
                                      message:
                                          "Please select the date properly",
                                      context: allAppProvidersContext,
                                    ),
                                  );
                                }
                              } else {
                                allAppProvidersProvider.isLoadingFunc(false);

                                ScaffoldMessenger.of(allAppProvidersContext)
                                    .showSnackBar(
                                  AppSnackbar().customizedAppSnackbar(
                                    message: "Please enter your report details",
                                    context: allAppProvidersContext,
                                  ),
                                );
                              }
                            } else {
                              allAppProvidersProvider.isLoadingFunc(false);

                              ScaffoldMessenger.of(allAppProvidersContext)
                                  .showSnackBar(
                                AppSnackbar().customizedAppSnackbar(
                                  message: "Please select your report pictures",
                                  context: allAppProvidersContext,
                                ),
                              );
                            }
                            allAppProvidersProvider.isLoadingFunc(false);
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
                        child: (allAppProvidersProvider.isLoading)
                            ? Center(
                                child: Lottie.asset(
                                  "assets/loading-animation.json",
                                  width: double.infinity,
                                  height: 50,
                                ),
                              )
                            : Text(
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
                        await imagePicker.pickMultiImage(
                      imageQuality: 70,
                    );
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
                      "Don't select more than 6 pictures\nIt will decrease your rank",
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
                              height: 250,
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
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.mainColor.withOpacity(0.7),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                ),
                              ),
                              child: IconButton(
                                onPressed: (() {
                                  thumbnail = null;
                                  isThumb = false;
                                  setState(() {});
                                }),
                                icon: Icon(
                                  Icons.delete,
                                  color: AppColors.white,
                                  size: 30,
                                ),
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
                    top:
                        (pickedImages.isNotEmpty || thumbnail != null) ? 0 : 20,
                    bottom: 15,
                    left: 10,
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Use custom date for your report",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            "(Else it will take the current time)",
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
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
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 15,
                  right: 15,
                  bottom: 10,
                ),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    counterText: "",
                    // suffixText: (widget.desField != null && widget.desField == true)
                    //     ? "${allAppProvider.desPosition.toString()}/${widget.maxWords}"
                    //     : "",
                    prefixIcon: Icon(
                      Icons.category,
                      color: AppColors.white,
                    ),
                    prefixStyle: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                    hintText: "Category",
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
                  onChanged: ((text) async {
                    categories = await fetchCategories(text.trim());
                    isCatTapped = true;
                    setState(() {});
                  }),
                  inputFormatters: [
                    FilteringTextInputFormatter.singleLineFormatter,
                    SingleWordTextInputFormatter(),
                    RestrictedTextInputFormatter(),
                  ],
                  controller: _reportCatController,
                  keyboardType: TextInputType.name,
                  cursorColor: AppColors.white,
                  style: const TextStyle(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Visibility(
                visible: isCatTapped,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 23),
                        child: Text(
                          "Categories",
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    AnimatedContainer(
                      width: MediaQuery.of(context).size.width,
                      height: (categories.length * 55) > 200
                          ? 200
                          : categories.length * 55,
                      margin: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 5,
                      ),
                      duration: Duration(
                        milliseconds: 600,
                      ),
                      child: ListView.separated(
                        itemBuilder: (catListContext, catListIndex) {
                          return GestureDetector(
                            onTap: (() {
                              _reportCatController.text =
                                  categories[catListIndex].reportCat;
                              isCatTapped = false;
                              _reportCatController.selection =
                                  TextSelection.collapsed(
                                offset: _reportCatController.text.length,
                              );
                              setState(() {});
                            }),
                            child: Container(
                              margin: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.backgroundColour.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              width: MediaQuery.of(catListContext).size.width,
                              height: 50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    categories[catListIndex].reportCat,
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 5,
                          );
                        },
                        itemCount: categories.length,
                      ),
                    ),
                    if (categories.isNotEmpty)
                      SizedBox(
                        height: 2,
                      ),
                    if (categories.isNotEmpty)
                      Center(
                        child: Text(
                          "If you cannot found proper category, just type it",
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    if (categories.isEmpty)
                      Center(
                        child: Text(
                          "There are no categories according to your report category\nIf your are confident about it just type it",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // if (nameHashtagDetect)
            // if (desTapped)
            //   const SliverToBoxAdapter(
            //     child: SuggestionContainer(
            //       sugg:
            //           "Suggestion: Describe the incident. Don't use any AI generated content. It will decrease the ranking ability",
            //     ),
            //   ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 15,
                  right: 15,
                  bottom: 10,
                ),
                child: DetectableTextField(
                  textCapitalization: TextCapitalization.sentences,
                  detectionRegExp: detectionRegExp(url: false)!,
                  controller: _reportNameController,
                  keyboardType: TextInputType.multiline,
                  basicStyle: const TextStyle(
                    color: AppColors.white,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    suffixText: "",
                    prefixIcon: const Icon(
                      Icons.newspaper,
                      color: AppColors.white,
                    ),
                    prefixStyle: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                    hintText: "Headline",
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
                      top: 10,
                      bottom: 10,
                    ),
                  ),
                  decoratedStyle: TextStyle(
                    color: AppColors.backgroundColour,
                  ),
                  maxLines: 2,
                  minLines: 1,
                  maxLength: 50,
                  onDetectionTyped: ((text) async {
                    log(text);
                    nameHashtagDetect = true;
                    // hashtags = await fetchHashtags(text);

                    var uri = Uri.parse(
                        "${Keys.apiReportsBaseUrl}/hashtags/autocomplete?q=${Uri.encodeComponent(text)}&page=$pageCount&limit=$limitCount");

                    http.Response response = await http.get(
                      Uri.parse(
                          "${Keys.apiReportsBaseUrl}/hashtags/autocomplete?q=${Uri.encodeComponent(text.trim())}&page=$pageCount&limit=$limitCount"),
                      headers: {
                        'content-Type': 'application/json',
                        'authorization': 'Bearer $token',
                      },
                    );

                    if (response.statusCode == 200) {
                      log(response.body.toString());
                      final resJson = jsonDecode(response.body);
                      log(resJson["message"].toString());
                      if (resJson["success"]) {
                        Hashtags hashtags = hashtagsFromJson(response.body);

                        log(hashtags.message);
                        hashtagsLocal = hashtags.hashtags;
                      } else {
                        hashtagsLocal.clear();
                      }
                    }
                    setState(() {});
                  }),
                  onDetectionFinished: (() {
                    nameHashtagDetect = false;
                    hashtagsLocal.clear();
                    setState(() {});
                  }),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Visibility(
                visible: nameHashtagDetect,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hashtagsLocal.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 23),
                        child: Text(
                          "Hashtags",
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    AnimatedContainer(
                      width: MediaQuery.of(context).size.width,
                      height: (hashtagsLocal.length * 55) > 200
                          ? 200
                          : hashtagsLocal.length * 55,
                      margin: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 5,
                      ),
                      duration: Duration(
                        milliseconds: 300,
                      ),
                      child: ListView.separated(
                        itemBuilder: (hashtagListContext, hashtagListIndex) {
                          return GestureDetector(
                            onTap: (() {
                              // _reportNameController.text =
                              //     _reportNameController.text.replaceAll(
                              //   RegExp(r'(#\w+)(?=\b)'),
                              //   hashtagsLocal[hashtagListIndex],
                              // );

                              String currentText = _reportNameController.text;
                              RegExp regex =
                                  RegExp(r'(?<=\s|^)(#\w+)\b(?!.*#\w+\b)');
                              String newText = currentText.replaceFirst(regex,
                                  hashtagsLocal[hashtagListIndex].hashtag);
                              _reportNameController.text = "$newText ";

                              // String currentText = _reportNameController.text;
                              // final List<String> words = currentText.split(' ');
                              // String newText = "";
                              // int lastIndex = -1;
                              // for (int i = words.length - 1; i >= 0; i--) {
                              //   if (words[i].startsWith('#')) {
                              //     lastIndex = i;
                              //     break;
                              //   }
                              // }
                              // if (lastIndex != -1) {
                              //   String word = words[lastIndex];
                              //   newText = currentText.replaceRange(
                              //     currentText.lastIndexOf(word),
                              //     currentText.lastIndexOf(word) + word.length,
                              //     hashtagsLocal[hashtagListIndex],
                              //   );
                              //   _reportNameController.text = newText;
                              // }
                              // _reportNameController.text = newText;

                              _reportNameController.selection =
                                  TextSelection.collapsed(
                                offset: _reportNameController.text.length,
                              );

                              setState(() {});

                              // _reportNameController.value = TextEditingValue(
                              //   text: _reportNameController.text,
                              //   selection: TextSelection.collapsed(
                              //     offset: (cursorPosition.toInt() +
                              //             hashtagsLocal[hashtagListIndex]
                              //                 .length -
                              //             match.group(0)!.length)
                              //         .toInt(),
                              //   ),
                              // ),
                            }),
                            child: Container(
                              margin: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.backgroundColour.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              width:
                                  MediaQuery.of(hashtagListContext).size.width,
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    hashtagsLocal[hashtagListIndex].hashtag,
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Times used: ",
                                        style: TextStyle(
                                          color:
                                              AppColors.white.withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        NumberFormat.compact().format(
                                            hashtagsLocal[hashtagListIndex]
                                                .timesUsed),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color:
                                              AppColors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 5,
                          );
                        },
                        itemCount: hashtagsLocal.length,
                      ),
                    ),
                    if (hashtagsLocal.isNotEmpty)
                      SizedBox(
                        height: 2,
                      ),
                    Center(
                      child: Text(
                        "If you can't find proper hashtag, just type it",
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 15,
                  right: 15,
                  bottom: 10,
                ),
                child: DetectableTextField(
                  focusNode: nameFocusNode,
                  textCapitalization: TextCapitalization.sentences,
                  detectionRegExp: detectionRegExp(atSign: false)!,
                  controller: _reportDesController,
                  keyboardType: TextInputType.multiline,
                  basicStyle: TextStyle(
                    color: AppColors.white,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    suffixText: "",
                    prefixIcon: Icon(
                      Icons.description,
                      color: AppColors.white,
                    ),
                    prefixStyle: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                    hintText: "Description",
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
                      top: 10,
                      bottom: 10,
                    ),
                  ),
                  decoratedStyle: TextStyle(
                    color: AppColors.backgroundColour,
                  ),
                  maxLines: 15,
                  minLines: 1,
                  maxLength: 1000,
                  onDetectionTyped: ((text) async {
                    if (text.trim().startsWith('#')) {
                      // log(text);
                      desHashtagDetect = true;
                      hashtagsLocal = await fetchHashtags(text);
                      setState(() {});
                    }

                    if (text.trim().startsWith('@')) {}
                  }),
                  onDetectionFinished: (() {
                    desHashtagDetect = false;

                    setState(() {});
                  }),
                ),
              ),
            ),

            // if (desHashtagDetect)
            //   SliverToBoxAdapter(
            //     child: Consumer<AllAppProviders>(
            //       builder: (allAppContext, allAppProvider, allAppChild) {
            //         return Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             if (hashtagsLocal.isNotEmpty)
            //               Padding(
            //                 padding: const EdgeInsets.only(left: 23),
            //                 child: Text(
            //                   "Hashtags",
            //                   style: TextStyle(
            //                     color: AppColors.white.withOpacity(0.5),
            //                   ),
            //                 ),
            //               ),
            //             AnimatedContainer(
            //               width: MediaQuery.of(context).size.width,
            //               height: hashtagsLocal.length * 40,
            //               margin: EdgeInsets.only(
            //                 left: 15,
            //                 right: 15,
            //                 top: 5,
            //               ),
            //               duration: Duration(
            //                 milliseconds: 600,
            //               ),
            //               child: ListView.separated(
            //                 itemBuilder: (hashtagListContext, hashtagListIndex) {
            //                   return Container(
            //                     margin: const EdgeInsets.only(
            //                       left: 10,
            //                       right: 10,
            //                     ),
            //                     padding: EdgeInsets.symmetric(horizontal: 10),
            //                     decoration: BoxDecoration(
            //                       color:
            //                           AppColors.backgroundColour.withOpacity(0.4),
            //                       borderRadius: BorderRadius.circular(15),
            //                     ),
            //                     width:
            //                         MediaQuery.of(hashtagListContext).size.width,
            //                     height: 40,
            //                     child: Column(
            //                       mainAxisAlignment: MainAxisAlignment.center,
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         Text(
            //                           hashtagsLocal[hashtagListIndex],
            //                           style: TextStyle(
            //                             color: AppColors.white.withOpacity(0.8),
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   );
            //                 },
            //                 separatorBuilder: (BuildContext context, int index) {
            //                   return SizedBox(
            //                     width: MediaQuery.of(context).size.width,
            //                     height: 1.5,
            //                   );
            //                 },
            //                 itemCount: hashtagsLocal.length,
            //               ),
            //             ),
            //             if (hashtagsLocal.isNotEmpty)
            //               SizedBox(
            //                 height: 2,
            //               ),
            //             if (hashtagsLocal.isNotEmpty)
            //               Center(
            //                 child: Text(
            //                   "If you cannot found proper category, just type it",
            //                   style: TextStyle(
            //                     color: AppColors.white.withOpacity(0.5),
            //                   ),
            //                 ),
            //               ),
            //             if (hashtagsLocal.isEmpty)
            //               Center(
            //                 child: Text(
            //                   "There are no categories according to your report category\nIf your are confident about it just type it",
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(
            //                     color: AppColors.white.withOpacity(0.5),
            //                   ),
            //                 ),
            //               ),
            //           ],
            //         );
            //       },
            //     ),
            //   ),
            // if (locationTapped)
            //   const SliverToBoxAdapter(
            //     child: SuggestionContainer(
            //       sugg:
            //           "Suggestion: Write your location like in this format, Nearby Place, Street, Place, State, PIN",
            //     ),
            //   ),
            SliverToBoxAdapter(
              child: AuthNameTextField(
                // inputFormatter: [
                //   LocationTextInputFormatter(),
                // ],
                controller: _reportLocationController,
                hintText: "location",
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

import 'dart:developer';
import 'dart:io';

import 'package:achivie/services/shared_preferences.dart';
import 'package:achivie/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Utils/snackbar_utils.dart';
import '../providers/app_providers.dart';
import '../widgets/email_us_screen_widgets.dart';

class NewsBlocCreationScreen extends StatefulWidget {
  const NewsBlocCreationScreen({Key? key}) : super(key: key);

  @override
  State<NewsBlocCreationScreen> createState() => _NewsBlocCreationScreenState();
}

class _NewsBlocCreationScreenState extends State<NewsBlocCreationScreen> {
  bool signUpPressed = false;
  File? selectedImage;
  bool selected = false;
  String usrName = "",
      uid = "",
      usrEmail = "",
      streetName = "Street",
      subLocalityName = "Sub-Locality",
      cityName = "City",
      countryName = "Country",
      countryCode = "Country Code",
      pin = "PIN Code";
  String? phoneNumber;
  String? _currentAddress;
  Position? _currentPosition;
  List<Placemark> screenPlaceMark = [];
  List<SimCard>? simCards;
  late TextEditingController _blocNameController, _blockDesController;

  @override
  void initState() {
    _blocNameController = TextEditingController();
    _blockDesController = TextEditingController();
    getUsrDetails();
    super.initState();
  }

  void getUsrDetails() async {
    usrName = await StorageServices.getUsrName();
    uid = await StorageServices.getUID();
    usrEmail = await StorageServices.getUsrEmail();
    await getUserLocation();
    await _handlePhonePermission();
    simCards = await MobileNumber.getSimCards;
    setState(() {});
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();
    if (!serviceEnabled) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Geolocator.openLocationSettings();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      openAppSettings();
    }
    return true;
  }

  Future<void> getUserLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
      });
      await _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      log(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placeMarks) {
      Placemark place = placeMarks[0];
      log(placeMarks.toString());
      setState(() {
        screenPlaceMark = placeMarks;
        streetName = place.street!;
        subLocalityName = place.subLocality!;
        cityName = place.locality!;
        countryName = place.country!;
        countryCode = place.isoCountryCode!;
        pin = place.postalCode!;
        log(subLocalityName);
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _handlePhonePermission() async {
    if (await Permission.phone.isGranted) {
      return;
    } else if (await Permission.phone.isRestricted) {
      Permission.phone.request();
    } else if (await Permission.phone.isDenied) {
      Permission.phone.request();
    } else if (await Permission.phone.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
              "Create Bloc",
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
                    if (selectedImage != null) {
                      if (_blocNameController.text.trim().isNotEmpty &&
                          _blockDesController.text.trim().isNotEmpty) {
                        if (streetName != "Street" &&
                            subLocalityName != "Sub-Locality" &&
                            cityName != "City" &&
                            countryName != "Country" &&
                            countryCode != "Country Code" &&
                            pin != "PIN Code") {
                          if (phoneNumber != null && phoneNumber!.isNotEmpty) {
                          } else {
                            ScaffoldMessenger.of(allAppProvidersContext)
                                .showSnackBar(
                              AppSnackbar().customizedAppSnackbar(
                                message: "Please select your phone number",
                                context: allAppProvidersContext,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(allAppProvidersContext)
                              .showSnackBar(
                            AppSnackbar().customizedAppSnackbar(
                              message:
                                  "Your address is not properly fetched.\nTry again later.",
                              context: allAppProvidersContext,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(allAppProvidersContext)
                            .showSnackBar(
                          AppSnackbar().customizedAppSnackbar(
                            message: "Please enter bloc details",
                            context: allAppProvidersContext,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(allAppProvidersContext).showSnackBar(
                        AppSnackbar().customizedAppSnackbar(
                          message: "Please select your bloc profile picture",
                          context: allAppProvidersContext,
                        ),
                      );
                    }
                  }),
                  child: Container(
                    width: size.width / 3,
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
                        "Create",
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
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          margin: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              SizedBox(
                width: size.width,
                height: (selectedImage == null) ? 50 : 130,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (selected == true && selectedImage != null)
                      GestureDetector(
                        onTap: (() async {
                          try {
                            final image = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (image == null) return;

                            final imageTemp = File(image.path);
                            selectedImage = imageTemp;
                            setState(() {});
                          } on PlatformException catch (e) {
                            log(e.toString());
                          }
                        }),
                        child: (selectedImage != null)
                            ? CircleAvatar(
                                backgroundImage: FileImage(
                                  selectedImage!,
                                ),
                                radius: 55,
                              )
                            : Container(),
                      ),
                    if (selected == false && selectedImage == null)
                      Consumer<AllAppProviders>(
                        builder: (allAppContext, allAppProvider, allAppChild) {
                          return SizedBox(
                            width: size.width - 20,
                            height: 50,
                            child: TextFormField(
                              onTap: (() async {
                                try {
                                  final image = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (image == null) return;

                                  final imageTemp = File(image.path);
                                  selectedImage = imageTemp;
                                  selected = true;
                                  signUpPressed = false;

                                  setState(() {});
                                } on PlatformException catch (e) {
                                  log(e.toString());
                                }
                              }),
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                counterText: "",
                                prefixIcon: Icon(
                                  Icons.image,
                                  color: AppColors.white,
                                ),
                                prefixStyle: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                                hintText: "Choose Profile Picture",
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
                              readOnly: true,
                              cursorColor: AppColors.white,
                              style: const TextStyle(
                                color: AppColors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    if (signUpPressed == true)
                      SizedBox(
                        width: size.width,
                        child: Center(
                          child: Text(
                            "Please select your profile picture.",
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 15,
                              letterSpacing: 1,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                      ),
                    if (selectedImage != null)
                      SizedBox(
                        width: size.width / 1.7,
                        height: 130,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            UsrDetailsField(
                              size: size,
                              usrName: usrName,
                              icon: Icons.person,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            UsrDetailsField(
                              size: size,
                              usrName: uid,
                              icon: Icons.verified_user,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            UsrDetailsField(
                              size: size,
                              usrName: usrEmail,
                              icon: Icons.email,
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              BlocDetailsField(
                desField: false,
                maxWords: 20,
                icon: Icons.badge,
                hintText: 'Enter Your Bloc Name',
                controller: _blocNameController,
              ),
              BlocDetailsField(
                desField: true,
                maxWords: 100,
                icon: Icons.co_present,
                hintText: 'Enter Your Bloc Description',
                controller: _blockDesController,
              ),
              Stack(
                children: [
                  if (screenPlaceMark.isNotEmpty)
                    Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: size.width,
                          height: 70,
                          child: Row(
                            children: [
                              AddressField(
                                head: "Street",
                                val: streetName,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              AddressField(
                                head: "Sub-Locality",
                                val: subLocalityName,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: size.width,
                          height: 70,
                          child: Row(
                            children: [
                              AddressField(
                                head: "City",
                                val: cityName,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              AddressField(
                                head: "Country",
                                val: countryName,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: size.width,
                          height: 70,
                          child: Row(
                            children: [
                              AddressField(
                                head: "Country Code",
                                val: countryCode,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              AddressField(
                                head: "PIN Code",
                                val: (cityName.length > 3)
                                    ? "${cityName[0].toUpperCase()}${cityName[1].toUpperCase()}${cityName[2].toUpperCase()} - $pin"
                                    : pin,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  if (screenPlaceMark.isEmpty)
                    Container(
                      height: 263,
                      width: size.width,
                      decoration: BoxDecoration(
                        color: AppColors.mainColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                ],
              ),
              SizedBox(
                width: size.width,
                height: 70,
                child: Row(
                  children: [
                    AddressField(
                      head: "Phone No.",
                      val: (phoneNumber != null)
                          ? phoneNumber!
                          : "Select Phone Number",
                      onTap: (() {
                        showModalBottomSheet(
                          isDismissible: false,
                          isScrollControlled: true,
                          useSafeArea: true,
                          useRootNavigator: true,
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(16),
                              topLeft: Radius.circular(16),
                            ),
                          ),
                          builder: ((modalContext) {
                            return Container(
                              height: simCards!.length * 100,
                              width: size.width,
                              padding: EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mainColor,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  topLeft: Radius.circular(15),
                                ),
                              ),
                              child: ListView.separated(
                                itemBuilder: ((numbersCtx, numbersIndex) {
                                  String simName =
                                      simCards![numbersIndex].displayName!;

                                  simName = simCards![numbersIndex]
                                      .displayName!
                                      .replaceFirst(
                                          simCards![numbersIndex]
                                              .displayName![0],
                                          simCards![numbersIndex]
                                              .displayName![0]
                                              .toUpperCase());
                                  return GestureDetector(
                                    onTap: (() {
                                      Navigator.pop(
                                        modalContext,
                                        "+${simCards![numbersIndex].countryPhonePrefix!}${simCards![numbersIndex].number!}",
                                      );
                                    }),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      padding: EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundColour
                                            .withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  "https://img.freepik.com/premium-vector/3d-handset-icon-minimalist-style-phone-call-vector-illustration-isolated-white-background_653154-62.jpg",
                                                  scale: 3,
                                                ),
                                                backgroundColor:
                                                    AppColors.white,
                                                foregroundColor:
                                                    AppColors.white,
                                                radius: 25,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "SIM: ${simCards![numbersIndex].slotIndex! + 1} - $simName",
                                                        style: TextStyle(
                                                          color:
                                                              AppColors.white,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    "+${simCards![numbersIndex].countryPhonePrefix!}${simCards![numbersIndex].number!}",
                                                    style: TextStyle(
                                                      color: AppColors.white
                                                          .withOpacity(0.7),
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                separatorBuilder:
                                    ((numbersSepCtx, numbersSepIndex) {
                                  return SizedBox(
                                    height: 10,
                                  );
                                }),
                                itemCount: simCards!.length,
                              ),
                            );
                          }),
                        ).then((value) {
                          setState(() {
                            phoneNumber = value;
                          });
                        });
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddressField extends StatelessWidget {
  const AddressField({
    super.key,
    required this.head,
    required this.val,
    this.onTap,
  });

  final String head, val;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: Text(
              head,
              style: TextStyle(
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 0,
              ),
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: AppColors.white,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      val,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlocDetailsField extends StatefulWidget {
  const BlocDetailsField({
    super.key,
    required this.desField,
    required this.maxWords,
    required this.icon,
    required this.hintText,
    required this.controller,
  });

  final String hintText;
  final int maxWords;
  final IconData icon;
  final TextEditingController controller;
  final bool desField;

  @override
  State<BlocDetailsField> createState() => _BlocDetailsFieldState();
}

class _BlocDetailsFieldState extends State<BlocDetailsField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
        bottom: 5,
      ),
      child: Consumer<AllAppProviders>(
        builder: (allAppContext, allAppProvider, allAppChild) {
          return TextFormField(
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              counterText: "",
              suffixText: (widget.desField == true)
                  ? "${allAppProvider.desPosition.toString()}/${widget.maxWords}"
                  : "",
              prefixIcon: Icon(
                widget.icon,
                color: AppColors.white,
              ),
              prefixStyle: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
              hintText: widget.hintText,
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
            onChanged: ((text) {
              if (widget.desField == true) {
                allAppProvider.desLengthFunc(text.trim().length);
              }
            }),
            maxLength: widget.maxWords,
            maxLines: (widget.desField == true) ? 2 : null,
            minLines: 1,
            controller: widget.controller,
            keyboardType: (widget.desField == true)
                ? TextInputType.multiline
                : TextInputType.name,
            cursorColor: AppColors.white,
            style: const TextStyle(
              color: AppColors.white,
            ),
          );
        },
      ),
    );
  }
}

class UsrDetailsField extends StatelessWidget {
  const UsrDetailsField({
    super.key,
    required this.size,
    required this.usrName,
    required this.icon,
  });

  final Size size;
  final String usrName;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          counterText: "",
          prefixIcon: Icon(
            icon,
            color: AppColors.white,
          ),
          prefixStyle: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
          hintText: usrName,
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
        readOnly: true,
        cursorColor: AppColors.white,
        style: const TextStyle(
          color: AppColors.white,
        ),
      ),
    );
  }
}

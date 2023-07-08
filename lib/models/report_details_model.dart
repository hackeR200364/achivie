// To parse this JSON data, do
//
//     final reportDetails = reportDetailsFromJson(jsonString);

import 'dart:convert';

ReportDetails reportDetailsFromJson(String str) =>
    ReportDetails.fromJson(json.decode(str));

String reportDetailsToJson(ReportDetails data) => json.encode(data.toJson());

class ReportDetails {
  bool success;
  String message;
  bool liked;
  bool commented;
  bool followed;
  bool saved;
  Detaiils details;

  ReportDetails({
    required this.success,
    required this.message,
    required this.liked,
    required this.commented,
    required this.followed,
    required this.saved,
    required this.details,
  });

  factory ReportDetails.fromJson(Map<String, dynamic> json) => ReportDetails(
        success: json["success"],
        message: json["message"],
        liked: json["liked"],
        commented: json["commented"],
        followed: json["followed"],
        saved: json["saved"],
        details: Detaiils.fromJson(json["detaiils"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "liked": liked,
        "commented": commented,
        "followed": followed,
        "saved": saved,
        "detaiils": details.toJson(),
      };
}

class Detaiils {
  String reportId;
  List<String> reportImages;
  String reportTumbImage;
  String reportDate;
  String reportTime;
  DateTime reportUploadTime;
  String reportHeadline;
  String reportDes;
  String reportCat;
  String reportHashtags;
  String reportLocation;
  int reportLikes;
  int reportComments;
  int reportSaved;
  String reportBlocId;
  String reportUsrId;
  String usrName;
  String usrId;
  String usrEmail;
  String blocId;
  String blocName;
  String blocDes;
  int followers;
  int reportsCount;
  String usrPhoneNo;
  String blocProfile;
  double blocLat;
  double blocLong;

  Detaiils({
    required this.reportId,
    required this.reportImages,
    required this.reportTumbImage,
    required this.reportDate,
    required this.reportTime,
    required this.reportUploadTime,
    required this.reportHeadline,
    required this.reportDes,
    required this.reportCat,
    required this.reportHashtags,
    required this.reportLocation,
    required this.reportLikes,
    required this.reportComments,
    required this.reportSaved,
    required this.reportBlocId,
    required this.reportUsrId,
    required this.usrName,
    required this.usrId,
    required this.usrEmail,
    required this.blocId,
    required this.blocName,
    required this.blocDes,
    required this.followers,
    required this.reportsCount,
    required this.usrPhoneNo,
    required this.blocProfile,
    required this.blocLat,
    required this.blocLong,
  });

  factory Detaiils.fromJson(Map<String, dynamic> json) => Detaiils(
        reportId: json["reportID"],
        reportImages: List<String>.from(json["reportImages"].map((x) => x)),
        reportTumbImage: json["reportTumbImage"],
        reportDate: json["reportDate"],
        reportTime: json["reportTime"],
        reportUploadTime: DateTime.parse(json["reportUploadTime"]),
        reportHeadline: json["reportHeadline"],
        reportDes: json["reportDes"],
        reportCat: json["reportCat"],
        reportHashtags: json["reportHashtags"],
        reportLocation: json["reportLocation"],
        reportLikes: json["reportLikes"],
        reportComments: json["reportComments"],
        reportSaved: json["reportSaved"],
        reportBlocId: json["reportBlocID"],
        reportUsrId: json["reportUsrID"],
        usrName: json["usrName"],
        usrId: json["usrID"],
        usrEmail: json["usrEmail"],
        blocId: json["blocID"],
        blocName: json["blocName"],
        blocDes: json["blocDes"],
        followers: json["followers"],
        reportsCount: json["reportsCount"],
        usrPhoneNo: json["usrPhoneNo"],
        blocProfile: json["blocProfile"],
        blocLat: json["blocLat"]?.toDouble(),
        blocLong: json["blocLong"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "reportID": reportId,
        "reportImages": List<String>.from(reportImages.map((x) => x)),
        "reportTumbImage": reportTumbImage,
        "reportDate": reportDate,
        "reportTime": reportTime,
        "reportUploadTime": reportUploadTime.toIso8601String(),
        "reportHeadline": reportHeadline,
        "reportDes": reportDes,
        "reportCat": reportCat,
        "reportHashtags": reportHashtags,
        "reportLocation": reportLocation,
        "reportLikes": reportLikes,
        "reportComments": reportComments,
        "reportSaved": reportSaved,
        "reportBlocID": reportBlocId,
        "reportUsrID": reportUsrId,
        "usrName": usrName,
        "usrID": usrId,
        "usrEmail": usrEmail,
        "blocID": blocId,
        "blocName": blocName,
        "blocDes": blocDes,
        "followers": followers,
        "reportsCount": reportsCount,
        "usrPhoneNo": usrPhoneNo,
        "blocProfile": blocProfile,
        "blocLat": blocLat,
        "blocLong": blocLong,
      };
}

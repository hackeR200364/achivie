// To parse this JSON data, do
//
//     final blocAllReports = blocAllReportsFromJson(jsonString);

import 'dart:convert';

BlocAllReports blocAllReportsFromJson(String str) =>
    BlocAllReports.fromJson(json.decode(str));

String blocAllReportsToJson(BlocAllReports data) => json.encode(data.toJson());

class BlocAllReports {
  bool success;
  bool followed;
  List<Report> reports;
  int totalPage;

  BlocAllReports({
    required this.success,
    required this.followed,
    required this.reports,
    required this.totalPage,
  });

  factory BlocAllReports.fromJson(Map<String, dynamic> json) => BlocAllReports(
        success: json["success"],
        followed: json["followed"],
        reports:
            List<Report>.from(json["reports"].map((x) => Report.fromJson(x))),
        totalPage: json["totalPage"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "followed": followed,
        "reports": List<dynamic>.from(reports.map((x) => x.toJson())),
        "totalPage": totalPage,
      };
}

class Report {
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
  bool liked;
  bool commented;
  bool saved;

  Report({
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
    required this.liked,
    required this.commented,
    required this.saved,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
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
        liked: json["liked"] ?? false,
        commented: json["commented"] ?? false,
        saved: json["saved"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "reportID": reportId,
        "reportImages": List<dynamic>.from(reportImages.map((x) => x)),
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
        "liked": liked,
        "commented": commented,
        "saved": saved,
      };
}

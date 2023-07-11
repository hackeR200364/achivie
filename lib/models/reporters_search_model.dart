// To parse this JSON data, do
//
//     final searchReporters = searchReportersFromJson(jsonString);

import 'dart:convert';

SearchReporters searchReportersFromJson(String str) =>
    SearchReporters.fromJson(json.decode(str));

String searchReportersToJson(SearchReporters data) =>
    json.encode(data.toJson());

class SearchReporters {
  bool success;
  String message;
  int totalPage;
  List<Reporter> reports;

  SearchReporters({
    required this.success,
    required this.message,
    required this.totalPage,
    required this.reports,
  });

  factory SearchReporters.fromJson(Map<String, dynamic> json) =>
      SearchReporters(
        success: json["success"],
        message: json["message"],
        totalPage: json["totalPage"],
        reports: List<Reporter>.from(
            json["reports"].map((x) => Reporter.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "totalPage": totalPage,
        "reports": List<dynamic>.from(reports.map((x) => x.toJson())),
      };
}

class Reporter {
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
  bool followed;

  Reporter({
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
    required this.followed,
  });

  factory Reporter.fromJson(Map<String, dynamic> json) => Reporter(
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
        followed: json["followed"],
      );

  Map<String, dynamic> toJson() => {
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
        "followed": followed,
      };
}

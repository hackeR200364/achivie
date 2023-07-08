// To parse this JSON data, do
//
//     final trendingReporters = trendingReportersFromJson(jsonString);

import 'dart:convert';

TrendingReporters trendingReportersFromJson(String str) =>
    TrendingReporters.fromJson(json.decode(str));

String trendingReportersToJson(TrendingReporters data) =>
    json.encode(data.toJson());

class TrendingReporters {
  bool success;
  String message;
  int totalPage;
  List<TrendingReporter> reporters;

  TrendingReporters({
    required this.success,
    required this.message,
    required this.totalPage,
    required this.reporters,
  });

  factory TrendingReporters.fromJson(Map<String, dynamic> json) =>
      TrendingReporters(
        success: json["success"],
        message: json["message"],
        totalPage: json["totalPage"],
        reporters: List<TrendingReporter>.from(
            json["reporters"].map((x) => TrendingReporter.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "totalPage": totalPage,
        "reporters": List<dynamic>.from(reporters.map((x) => x.toJson())),
      };
}

class TrendingReporter {
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
  int numReports;
  int numBlocs;
  bool followed;

  TrendingReporter({
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
    required this.numReports,
    required this.numBlocs,
    required this.followed,
  });

  factory TrendingReporter.fromJson(Map<String, dynamic> json) =>
      TrendingReporter(
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
        numReports: json["num_reports"],
        numBlocs: json["num_blocs"],
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
        "num_reports": numReports,
        "num_blocs": numBlocs,
        "followed": followed,
      };
}

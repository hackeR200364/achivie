// To parse this JSON data, do
//
//     final mentions = mentionsFromJson(jsonString);

import 'dart:convert';

Mentions mentionsFromJson(String str) => Mentions.fromJson(json.decode(str));

String mentionsToJson(Mentions data) => json.encode(data.toJson());

class Mentions {
  bool success;
  String message;
  int totalPage;
  List<Reporter> reporters;

  Mentions({
    required this.success,
    required this.message,
    required this.totalPage,
    required this.reporters,
  });

  factory Mentions.fromJson(Map<String, dynamic> json) => Mentions(
        success: json["success"],
        message: json["message"],
        totalPage: json["totalPage"],
        reporters: List<Reporter>.from(
            json["reporters"].map((x) => Reporter.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "totalPage": totalPage,
        "reporters": List<dynamic>.from(reporters.map((x) => x.toJson())),
      };
}

class Reporter {
  String blocId;
  String blocName;
  int followers;
  String blocProfile;

  Reporter({
    required this.blocId,
    required this.blocName,
    required this.followers,
    required this.blocProfile,
  });

  factory Reporter.fromJson(Map<String, dynamic> json) => Reporter(
        blocId: json["blocID"],
        blocName: json["blocName"],
        followers: json["followers"],
        blocProfile: json["blocProfile"],
      );

  Map<String, dynamic> toJson() => {
        "blocID": blocId,
        "blocName": blocName,
        "followers": followers,
        "blocProfile": blocProfile,
      };
}

// To parse this JSON data, do
//
//     final hashtags = hashtagsFromJson(jsonString);

import 'dart:convert';

Hashtags hashtagsFromJson(String str) => Hashtags.fromJson(json.decode(str));

String hashtagsToJson(Hashtags data) => json.encode(data.toJson());

class Hashtags {
  bool success;
  String message;
  int totalPage;
  List<Hashtag> hashtags;

  Hashtags({
    required this.success,
    required this.message,
    required this.totalPage,
    required this.hashtags,
  });

  factory Hashtags.fromJson(Map<String, dynamic> json) => Hashtags(
        success: json["success"],
        message: json["message"],
        totalPage: json["totalPage"] ?? 0,
        hashtags: List<Hashtag>.from(
            json["hashtags"].map((x) => Hashtag.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "totalPage": totalPage,
        "hashtags": List<dynamic>.from(hashtags.map((x) => x.toJson())),
      };
}

class Hashtag {
  String hashtag;
  int timesUsed;

  Hashtag({
    required this.hashtag,
    required this.timesUsed,
  });

  factory Hashtag.fromJson(Map<String, dynamic> json) => Hashtag(
        hashtag: json["hashtag"],
        timesUsed: json["timesUsed"],
      );

  Map<String, dynamic> toJson() => {
        "hashtag": hashtag,
        "timesUsed": timesUsed,
      };
}

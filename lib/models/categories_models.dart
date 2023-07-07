// To parse this JSON data, do
//
//     final blocAllCategories = blocAllCategoriesFromJson(jsonString);

import 'dart:convert';

BlocAllCategories blocAllCategoriesFromJson(String str) =>
    BlocAllCategories.fromJson(json.decode(str));

String blocAllCategoriesToJson(BlocAllCategories data) =>
    json.encode(data.toJson());

class BlocAllCategories {
  bool success;
  String message;
  List<Category> categories;

  BlocAllCategories({
    required this.success,
    required this.message,
    required this.categories,
  });

  factory BlocAllCategories.fromJson(Map<String, dynamic> json) =>
      BlocAllCategories(
        success: json["success"],
        message: json["message"],
        categories: List<Category>.from(
            json["categories"].map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
      };
}

class Category {
  String reportCat;

  Category({
    required this.reportCat,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        reportCat: json["reportCat"],
      );

  Map<String, dynamic> toJson() => {
        "reportCat": reportCat,
      };
}

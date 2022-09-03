import 'dart:io';

import 'package:flutter/material.dart';
//
// class Categories {
//   Categories({
//     this.isSubCategoriesExist,
//     this.id,
//     this.name,
//     this.image,
//     this.createdBy,
//     this.updatedBy,
//     this.updatedOn,
//     this.isVisible,
//     this.storeId,
//   });
//
//   bool isSubCategoriesExist;
//   int id;
//   String name;
//   String image;
//   int createdBy;
//   dynamic updatedBy;
//   dynamic updatedOn;
//   bool isVisible;
//   int storeId;
//
//   factory Categories.fromJson(Map<String, dynamic> json) => Categories(
//     isSubCategoriesExist: json["isSubCategoriesExist"],
//     id: json["id"],
//     name: json["name"],
//     image: json["image"],
//     createdBy: json["createdBy"],
//     updatedBy: json["updatedBy"],
//     updatedOn: json["updatedOn"],
//     isVisible: json["isVisible"],
//     storeId: json["storeId"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "isSubCategoriesExist": isSubCategoriesExist,
//     "id": id,
//     "name": name,
//     "image": image,
//     "createdBy": createdBy,
//     "updatedBy": updatedBy,
//     "updatedOn": updatedOn,
//     "isVisible": isVisible,
//     "storeId": storeId,
//   };
// }


// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

class Categories {
  static List<Categories> listCategoriesFromJson(String str) => List<Categories>.from(json.decode(str).map((x) => Categories.fromJson(x)));
  static String listCategoriesToJson(List<Categories> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static Categories CategoriesFromJson(String str) => Categories.fromJson(json.decode(str));
  static String CategoriesToJson(Categories data) => json.encode(data.toJson());
  Categories({
    this.isSubCategoriesExist,
    this.id,
    this.name,
    this.image,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.storeId,
    this.restaurantId,
    this.restaurant,
    this.startTime,
    this.endTime,
    this.totalOrders,
    this.categoryId
  });

  bool isSubCategoriesExist;
  int id;
  int categoryId;
  String name;
  String image;
  int createdBy;
  DateTime createdOn;
  int updatedBy;
  DateTime updatedOn;
  bool isVisible;
  int storeId;
  dynamic restaurantId;
  dynamic restaurant;
  String startTime;
  String endTime;
  int totalOrders;

  factory Categories.fromJson(Map<String, dynamic> json) => Categories(
    isSubCategoriesExist: json["isSubCategoriesExist"],
    id: json["id"],
    name: json["name"],
    image: json["image"],
    categoryId: json["categoryId"]!=null?json["categoryId"]:0,
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
    updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"],
    restaurantId: json["restaurantId"],
    restaurant: json["restaurant"],
    startTime: json["startTime"] == null ? null : json["startTime"],
    endTime: json["endTime"] == null ? null : json["endTime"],
    totalOrders: json["totalOrder"] == null ? null : json["totalOrder"],
  );

  Map<String, dynamic> toJson() => {
    "isSubCategoriesExist": isSubCategoriesExist,
    "id": id,
    "name": name,
    "image": image,
    "createdBy": createdBy == null ? null : createdBy,
    "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    "updatedBy": updatedBy == null ? null : updatedBy,
    "updatedOn": updatedOn == null ? null : updatedOn.toIso8601String(),
    "isVisible": isVisible == null ? null : isVisible,
    "storeId": storeId,
    "restaurantId": restaurantId,
    "restaurant": restaurant,
    "startTime": startTime == null ? null : startTime,
    "endTime": endTime == null ? null : endTime,
  };
}



//class Categories{
//  int id;
//  String name;
//  String imageUrl;
//  bool isSubcategory;
//
//  Categories({this.id, this.name, this.imageUrl, this.isSubcategory});
//
//  Map<String,dynamic> toMap()=>{
//    "id":id,
//    "name":name,
//    "image":imageUrl,
//    "isSubCategoriesExist":isSubcategory,
//  };
//  Categories.fromMap(Map<dynamic,dynamic> data){
//    id=data['id'];
//    name=data['name'];
//    imageUrl=data['image'];
//    isSubcategory=data['isSubCategoriesExist'];
//  }
//}
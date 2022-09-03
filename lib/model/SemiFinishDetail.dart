// To parse this JSON data, do
//
//     final semiFinishedDetail = semiFinishedDetailFromJson(jsonString);

import 'dart:convert';
import 'SemiFinishItems.dart';



class SemiFinishedDetail {
  static List<SemiFinishedDetail> semiFinishedDetailListFromJson(String str) => List<SemiFinishedDetail>.from(json.decode(str).map((x) => SemiFinishedDetail.fromJson(x)));
  static String semiFinishedDetailListToJson(List<SemiFinishedDetail> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static SemiFinishedDetail semiFinishedDetailFromJson(String str) => SemiFinishedDetail.fromJson(json.decode(str));
  static String semiFinishedDetailToJson(SemiFinishedDetail data) => json.encode(data.toJson());
  static String updateSemiFinishedDetailToJson(SemiFinishedDetail data) => json.encode(data.updateToJson());

  SemiFinishedDetail({
    this.id,
    this.unit,
    this.quantity,
    this.expiryDate,
    this.addedDate,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.semiFinishedItemId,
    this.storeId,
    this.semiFinishedItem,
    this.wastageQuantity
  });

  int id;
  int unit;
  var quantity;
  DateTime expiryDate;
  DateTime addedDate;
  int createdBy;
  DateTime createdOn;
  dynamic updatedBy;
  dynamic updatedOn;
  bool isVisible;
  int semiFinishedItemId;
  int storeId;
  SemiFinishItems semiFinishedItem;
  double wastageQuantity;



factory SemiFinishedDetail.fromJson(Map<String, dynamic> json) => SemiFinishedDetail(
    id: json["id"] == null ? null : json["id"],
    unit: json["unit"] == null ? null : json["unit"],
    quantity: json["quantity"] == null ? null : json["quantity"],
    expiryDate: json["expireDuration"] == null ? null : DateTime.parse(json["ExpireDuration"]),
    addedDate: json["addedDate"] == null ? null : DateTime.parse(json["addedDate"]),
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    semiFinishedItemId: json["semiFinishedItemId"] == null ? null : json["semiFinishedItemId"],
    storeId: json["storeId"] == null ? null : json["storeId"],
    semiFinishedItem: json["semiFinishedItem"] == null ? null : SemiFinishItems.fromJson(json["semiFinishedItem"]),
    wastageQuantity: json["wastageQuantity"] == null ? null : json["wastageQuantity"],


);

  Map<String, dynamic> toJson() => {
   // "id": id == null ? null : id,
   "Unit": unit == null ? null : unit,
    "Quantity": quantity == null ? null : quantity,
    "ExpiryDate": expiryDate == null ? null : expiryDate.toIso8601String(),
    "AddedDate": addedDate == null ? null : addedDate.toIso8601String(),
    // "createdBy": createdBy == null ? null : createdBy,
    // "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    // "updatedBy": updatedBy,
    // "updatedOn": updatedOn,
    "isVisible": isVisible == null ? true : isVisible,
    "SemiFinishedItemId": semiFinishedItemId == null ? null : semiFinishedItemId,
    "StoreId": storeId == null ? null : storeId,
    "WastageQuantity": wastageQuantity == null ? 0.0 : wastageQuantity,


  };
  Map<String, dynamic> updateToJson() => {
     "id": id == null ? null : id,
    "Unit": unit == null ? null : unit,
    "Quantity": quantity == null ? null : quantity,
    "ExpiryDate": expiryDate == null ? null : expiryDate.toIso8601String(),
    "AddedDate": addedDate == null ? null : addedDate.toIso8601String(),
    // "createdBy": createdBy == null ? null : createdBy,
    // "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    // "updatedBy": updatedBy,
    // "updatedOn": updatedOn,
    "isVisible": isVisible == null ? true : isVisible,
    "SemiFinishedItemId": semiFinishedItemId == null ? null : semiFinishedItemId,
    "StoreId": storeId == null ? null : storeId,
    "WastageQuantity": wastageQuantity == null ? 0.0 : wastageQuantity,

  };
}

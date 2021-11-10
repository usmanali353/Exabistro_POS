
import 'dart:convert';

class ItemBrand {
  static List<ItemBrand> itemBrandListFromJson(String str) => List<ItemBrand>.from(json.decode(str).map((x) => ItemBrand.fromJson(x)));
  static String itemBrandListToJson(List<ItemBrand> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static ItemBrand itemBrandFromJson(String str) => ItemBrand.fromJson(json.decode(str));
  static String itemBrandToJson(ItemBrand data) => json.encode(data.toJson());
  static String updateItemBrandToJson(ItemBrand data) => json.encode(data.updateToJson());
  ItemBrand({
    this.id,
    this.brandName,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.storeId
  });

  int id;
  String brandName;
  int storeId;
  int createdBy;
  DateTime createdOn;
  int updatedBy;
  DateTime updatedOn;
  bool isVisible;

  factory ItemBrand.fromJson(Map<String, dynamic> json) => ItemBrand(
    id: json["id"] == null ? null : json["id"],
    brandName: json["brandName"] == null ? null : json["brandName"],
    storeId: json["storeId"] == null ? null : json["storeId"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
    updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
  );

  Map<String, dynamic> toJson() => {
    "StoreId": storeId == null ? null : storeId,
    "BrandName": brandName == null ? null : brandName,
    // "createdBy": createdBy == null ? null : createdBy,
    // "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    // "updatedBy": updatedBy == null ? null : updatedBy,
    // "updatedOn": updatedOn == null ? null : updatedOn.toIso8601String(),
    "isVisible": isVisible == null ? null : isVisible,
  };
  Map<String, dynamic> updateToJson() => {
    "id": id,
    "StoreId":storeId,
    "BrandName": brandName,
    // "createdBy": createdBy,
    // "updatedBy": updatedBy,
    // "updatedOn": updatedOn,
    "isVisible": isVisible,
  };
}
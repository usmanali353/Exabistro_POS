import 'dart:convert';

import 'SemiFinishDetail.dart';
import 'Sizes.dart';
import 'StockItems.dart';



class SemiFinishItems {
  static List<SemiFinishItems> semiFinishItemsListFromJson(String str) => List<SemiFinishItems>.from(json.decode(str).map((x) => SemiFinishItems.fromJson(x)));
  static SemiFinishItems semiFinishItemsFromJson(String str) => SemiFinishItems.fromJson(json.decode(str));
  static String semiFinishItemsToJson(SemiFinishItems data) => json.encode(data.toJson());
  static String updateSemiFinishItemsToJson(SemiFinishItems data) => json.encode(data.updateToJson());
  SemiFinishItems({
    this.id,
    this.itemName,
    this.totalQuantity,
    this.storeId,
    this.semiFinishedItemIngredients,
   // this.semiFinishedDetail,
    this.createdBy,
    this.createdOn,
    this.isVisible,
    this.unit,
    this.expiryDate
  });
  int id;
  String itemName;
  double totalQuantity;
  int storeId;
  List<SemiFinishedItemIngredient> semiFinishedItemIngredients;
  //List<SemiFinishedDetail> semiFinishedDetail;
  int createdBy;
  DateTime createdOn;
  bool isVisible;
  int unit;
  DateTime expiryDate;

  factory SemiFinishItems.fromJson(Map<String, dynamic> json) => SemiFinishItems(
    id: json["id"] == null ? null : json["id"],
    itemName: json["itemName"] == null ? null : json["itemName"],
    totalQuantity: json["totalQuantity"] == null ? null : json["totalQuantity"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"] == null ? null : json["storeId"],
    unit: json["unit"] == null ? null : json["unit"],
    expiryDate: json["expiryDate"] == null ? null : DateTime.parse(json["expiryDate"]),

    //  semiFinishedDetail: json["semiFinishedItemDetails"] == null ? null : List<SemiFinishedDetail>.from(json["semiFinishedItemDetails"].map((x) => SemiFinishedDetail.fromJson(x))),

  );

  Map<String, dynamic> toJson() => {
    "ItemName": itemName == null ? null : itemName,
    "TotalQuantity": totalQuantity == null ? null : totalQuantity,
    "StoreId": storeId == null ? null : storeId,
    "SemiFinishedItemIngredients": semiFinishedItemIngredients == null ? null : List<dynamic>.from(semiFinishedItemIngredients.map((x) => x.toJson())),
    "createdBy": createdBy == null ? 1 : createdBy,
    "createdOn": createdOn == null ? DateTime.now().toIso8601String() : createdOn.toIso8601String(),
    "unit": unit == null ? null : unit,

  };
  Map<String, dynamic> updateToJson() => {
    "Id":id,
    "ItemName": itemName == null ? null : itemName,
    "TotalQuantity": totalQuantity == null ? null : totalQuantity,
    "StoreId": storeId == null ? null : storeId,
    "SemiFinishedItemIngredients": semiFinishedItemIngredients == null ? null : List<dynamic>.from(semiFinishedItemIngredients.map((x) => x.toJson())),
    "unit": unit == null ? null : unit,

  };
}

class SemiFinishedItemIngredient {

 static List<SemiFinishedItemIngredient> semiFinishedIngredientsFromJson(String str) => List<SemiFinishedItemIngredient>.from(json.decode(str).map((x) => SemiFinishedItemIngredient.fromJson(x)));
 static SemiFinishedItemIngredient semiFinishedItemIngredientFromJson(String str) => SemiFinishedItemIngredient.fromJson(json.decode(str));
 static String semiFinishedItemIngredientToJson(SemiFinishedItemIngredient data) => json.encode(data.toJson());
 static String updateSemiFinishedItemIngredientToJson(SemiFinishedItemIngredient data) => json.encode(data.updateToJson());
 static String singleSemiFinishedItemIngredientToJson(SemiFinishedItemIngredient data) => json.encode(data.AddSingle());

  SemiFinishedItemIngredient({
    this.stockItem,
    this.semiFinishedItem,
    this.id,
    this.quantity,
    this.unit,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.sizeId,
    this.stockItemId,
    this.semiFinishedItemId,
  });
 StockItems stockItem;
 dynamic semiFinishedItem;
 int id;
 double quantity;
 int unit;
 int createdBy;
 DateTime createdOn;
 int updatedBy;
 DateTime updatedOn;
 bool isVisible;
 int sizeId;
 int stockItemId;
 int semiFinishedItemId;

 factory SemiFinishedItemIngredient.fromJson(Map<String, dynamic> json) => SemiFinishedItemIngredient(
   stockItem: json["stockItem"] == null ? null : StockItems.fromJson(json["stockItem"]),
   //semiFinishedItem: json["semiFinishedItem"],
   id: json["id"] == null ? null : json["id"],
   quantity: json["quantity"] == null ? null : json["quantity"],
   unit: json["unit"] == null ? null : json["unit"],
   createdBy: json["createdBy"] == null ? null : json["createdBy"],
   createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
   updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
   updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
   isVisible: json["isVisible"] == null ? null : json["isVisible"],
   sizeId: json["sizeId"] == null ? null : json["sizeId"],
   stockItemId: json["stockItemId"] == null ? null : json["stockItemId"],
   //semiFinishedItemId: json["semiFinishedItemId"] == null ? null : json["semiFinishedItemId"],
 );

  Map<String, dynamic> toJson() => {
    "Quantity": quantity == null ? null : quantity,
    "Unit": unit == null ? null : unit,
    "SizeId": sizeId == null ? null : sizeId,
    "StockItemId": stockItemId == null ? null : stockItemId,
  //  "SemiFinishedItemId": semiFinishedItemId == null ? null : semiFinishedItemId,
  };
 Map<String, dynamic> AddSingle() => {
   "Quantity": quantity == null ? null : quantity,
   "Unit": unit == null ? null : unit,
   "SizeId": sizeId == null ? null : sizeId,
   "StockItemId": stockItemId == null ? null : stockItemId,
   "SemiFinishedItemId": semiFinishedItemId == null ? null : semiFinishedItemId,
 };
  Map<String, dynamic> updateToJson() => {
    "Id":id,
    "Quantity": quantity == null ? null : quantity,
    "Unit": unit == null ? null : unit,
    "SizeId": sizeId == null ? null : sizeId,
    "StockItemId": stockItemId == null ? null : stockItemId,
    "SemiFinishedItemId": semiFinishedItemId == null ? null : semiFinishedItemId,
  };
}


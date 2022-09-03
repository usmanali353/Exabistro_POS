import 'dart:convert';
import 'SemiFinishItems.dart';

class SemiFinishedInProduct {
 static List<SemiFinishedInProduct> semiFinishedInProductListFromJson(String str) => List<SemiFinishedInProduct>.from(json.decode(str).map((x) => SemiFinishedInProduct.fromJson(x)));
 static String semiFinishedInProductListToJson(List<SemiFinishedInProduct> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
 static SemiFinishedInProduct semiFinishedInProductFromJson(String str) => SemiFinishedInProduct.fromJson(json.decode(str));
 static String semiFinishedInProductToJson(SemiFinishedInProduct data) => json.encode(data.toJson());
 static String updateSemiFinishedInProductToJson(SemiFinishedInProduct data) => json.encode(data.updateToJson());

 SemiFinishedInProduct({
    this.semiFinishedItem,
    this.product,
    this.id,
    this.quantity,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.semiFinishedItemsId,
    this.productId,
    this.sizeId,
    this.size,
    this.unit
  });

  SemiFinishItems semiFinishedItem;
  dynamic product;
  int id;
  var quantity;
  int createdBy;
  DateTime createdOn;
  int updatedBy;
  DateTime updatedOn;
  bool isVisible;
  int semiFinishedItemsId;
  int productId;
  int sizeId;
  Size size;
  int unit;


 factory SemiFinishedInProduct.fromJson(Map<String, dynamic> json) => SemiFinishedInProduct(
    semiFinishedItem: json["semiFinishedItem"] == null ? null : SemiFinishItems.fromJson(json["semiFinishedItem"]),
    product: json["product"],
    id: json["id"] == null ? null : json["id"],
    quantity: json["quantity"] == null ? null : json["quantity"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
    updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    semiFinishedItemsId: json["semiFinishedItemsId"] == null ? null : json["semiFinishedItemsId"],
    productId: json["productId"] == null ? null : json["productId"],
    size: json["size"] == null ? null : Size.fromJson(json["size"]),
   unit: json["unit"]

 );

  Map<String, dynamic> toJson() => {
    "quantity": quantity == null ? null : quantity,
    // "createdBy": createdBy == null ? 1 : createdBy,
    // "createdOn": createdOn == null ? DateTime.now().toIso8601String() : createdOn.toIso8601String(),
    "isVisible": isVisible == null ? null : isVisible,
    "semiFinishedItemsId": semiFinishedItemsId == null ? null : semiFinishedItemsId,
    "productId": productId == null ? null : productId,
    "SizeId": sizeId == null ? null : sizeId,
    "Unit": unit==null?0:unit

  };
 Map<String, dynamic> updateToJson() => {
   "id": id == null ? null : id,
   "quantity": quantity == null ? null : quantity,
   // "createdBy": createdBy == null ? null : createdBy,
   // "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
   // "updatedBy": updatedBy == null ? null : updatedBy,
   // "updatedOn": updatedOn == null ? null : updatedOn.toIso8601String(),
   "isVisible": isVisible == null ? null : isVisible,
   "semiFinishedItemsId": semiFinishedItemsId == null ? null : semiFinishedItemsId,
   "productId": productId == null ? null : productId,
   "SizeId":sizeId,
   "Unit": unit==null?0:unit

 };
}
class Size {
  Size({
    this.id,
    this.name,
  });

  int id;
  String name;
  factory Size.fromJson(Map<String, dynamic> json) => Size(
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
  );
}
// class SemiFinishedItem {
//   SemiFinishedItem({
//     this.store,
//     this.semiFinishedItemIngredients,
//     this.id,
//     this.itemName,
//     this.totalQuantity,
//     this.createdBy,
//     this.createdOn,
//     this.updatedBy,
//     this.updatedOn,
//     this.isVisible,
//     this.storeId,
//   });
//
//   dynamic store;
//   List<SemiFinishedItemIngredient> semiFinishedItemIngredients;
//   int id;
//   String itemName;
//   int totalQuantity;
//   int createdBy;
//   DateTime createdOn;
//   int updatedBy;
//   DateTime updatedOn;
//   bool isVisible;
//   int storeId;
//
//   factory SemiFinishedItem.fromJson(Map<String, dynamic> json) => SemiFinishedItem(
//     store: json["store"],
//     semiFinishedItemIngredients: json["semiFinishedItemIngredients"] == null ? null : List<SemiFinishedItemIngredient>.from(json["semiFinishedItemIngredients"].map((x) => SemiFinishedItemIngredient.fromJson(x))),
//     id: json["id"] == null ? null : json["id"],
//     itemName: json["itemName"] == null ? null : json["itemName"],
//     totalQuantity: json["totalQuantity"] == null ? null : json["totalQuantity"],
//     createdBy: json["createdBy"] == null ? null : json["createdBy"],
//     createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
//     updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
//     updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
//     isVisible: json["isVisible"] == null ? null : json["isVisible"],
//     storeId: json["storeId"] == null ? null : json["storeId"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "store": store,
//     "semiFinishedItemIngredients": semiFinishedItemIngredients == null ? null : List<dynamic>.from(semiFinishedItemIngredients.map((x) => x.toJson())),
//     "id": id == null ? null : id,
//     "itemName": itemName == null ? null : itemName,
//     "totalQuantity": totalQuantity == null ? null : totalQuantity,
//     "createdBy": createdBy == null ? null : createdBy,
//     "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
//     "updatedBy": updatedBy == null ? null : updatedBy,
//     "updatedOn": updatedOn == null ? null : updatedOn.toIso8601String(),
//     "isVisible": isVisible == null ? null : isVisible,
//     "storeId": storeId == null ? null : storeId,
//   };
// }
//
// class SemiFinishedItemIngredient {
//   SemiFinishedItemIngredient({
//     this.size,
//     this.stockItem,
//     this.id,
//     this.quantity,
//     this.unit,
//     this.createdBy,
//     this.createdOn,
//     this.updatedBy,
//     this.updatedOn,
//     this.isVisible,
//     this.sizeId,
//     this.stockItemId,
//     this.semiFinishedItemId,
//   });
//
//   dynamic size;
//   dynamic stockItem;
//   int id;
//   int quantity;
//   int unit;
//   int createdBy;
//   DateTime createdOn;
//   int updatedBy;
//   DateTime updatedOn;
//   bool isVisible;
//   int sizeId;
//   int stockItemId;
//   int semiFinishedItemId;
//
//   factory SemiFinishedItemIngredient.fromJson(Map<String, dynamic> json) => SemiFinishedItemIngredient(
//     size: json["size"],
//     stockItem: json["stockItem"],
//     id: json["id"] == null ? null : json["id"],
//     quantity: json["quantity"] == null ? null : json["quantity"],
//     unit: json["unit"] == null ? null : json["unit"],
//     createdBy: json["createdBy"] == null ? null : json["createdBy"],
//     createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
//     updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
//     updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
//     isVisible: json["isVisible"] == null ? null : json["isVisible"],
//     sizeId: json["sizeId"] == null ? null : json["sizeId"],
//     stockItemId: json["stockItemId"] == null ? null : json["stockItemId"],
//     semiFinishedItemId: json["semiFinishedItemId"] == null ? null : json["semiFinishedItemId"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "size": size,
//     "stockItem": stockItem,
//     "id": id == null ? null : id,
//     "quantity": quantity == null ? null : quantity,
//     "unit": unit == null ? null : unit,
//     "createdBy": createdBy == null ? null : createdBy,
//     "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
//     "updatedBy": updatedBy == null ? null : updatedBy,
//     "updatedOn": updatedOn == null ? null : updatedOn.toIso8601String(),
//     "isVisible": isVisible == null ? null : isVisible,
//     "sizeId": sizeId == null ? null : sizeId,
//     "stockItemId": stockItemId == null ? null : stockItemId,
//     "semiFinishedItemId": semiFinishedItemId == null ? null : semiFinishedItemId,
//   };
// }


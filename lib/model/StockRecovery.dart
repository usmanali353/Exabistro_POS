import 'dart:convert';



class StockRecovery {
 static List<StockRecovery> stockRecoveryListFromJson(String str) => List<StockRecovery>.from(json.decode(str).map((x) => StockRecovery.fromJson(x)));
 static StockRecovery stockRecoveryFromJson(String str) => StockRecovery.fromJson(json.decode(str));
 static String stockRecoveryToJson(StockRecovery data) => json.encode(data.toJson());
 static String updateStockRecoveryToJson(StockRecovery data) => json.encode(data.updatetoJson());

//   StockRecovery({
//     this.stockItemDetails,
//     this.id,
//     this.comment,
//     this.createdBy,
//     this.createdOn,
//     this.updatedBy,
//     this.updatedOn,
//     this.stockItemDetailsId,
//   });
//
//   StockItemDetails stockItemDetails;
//   int id;
//   String comment;
//   int createdBy;
//   DateTime createdOn;
//   dynamic updatedBy;
//   dynamic updatedOn;
//   int stockItemDetailsId;
//
//   factory StockRecovery.fromJson(Map<String, dynamic> json) => StockRecovery(
//     stockItemDetails: json["stockItemDetails"] == null ? null : StockItemDetails.fromJson(json["stockItemDetails"]),
//     id: json["id"] == null ? null : json["id"],
//     comment: json["comment"] == null ? null : json["comment"],
//     createdBy: json["createdBy"] == null ? null : json["createdBy"],
//     createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
//     updatedBy: json["updatedBy"],
//     updatedOn: json["updatedOn"],
//    // stockItemDetailsId: json["stockItemDetailsId"] == null ? null : json["stockItemDetailsId"],
//   );
//
//   Map<String, dynamic> toJson() => {
//    //
//     // "stockItemDetails": stockItemDetails == null ? null : stockItemDetails.toJson(),
//    // "id": id == null ? null : id,
//     "comment": comment == null ? null : comment,
//     "createdBy": createdBy == null ? null : createdBy,
//     "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
//     "updatedBy": updatedBy,
//     "updatedOn": updatedOn,
//     "stockItemDetailsId": stockItemDetailsId == null ? null : stockItemDetailsId,
//   };
//  Map<String, dynamic> updatetoJson() => {
//    //
//    // "stockItemDetails": stockItemDetails == null ? null : stockItemDetails.toJson(),
//     "id": id == null ? null : id,
//    "comment": comment == null ? null : comment,
//    "createdBy": createdBy == null ? null : createdBy,
//    "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
//    "updatedBy": updatedBy,
//    "updatedOn": updatedOn,
//    "stockItemDetailsId": stockItemDetailsId == null ? null : stockItemDetailsId,
//  };
// }
//
// class StockItemDetails {
//   StockItemDetails({
//     this.stockItem,
//     this.dailySession,
//     this.vendor,
//     this.id,
//     this.costPrice,
//     this.unit,
//     this.quantity,
//     this.createdBy,
//     this.createdOn,
//     this.updatedBy,
//     this.updatedOn,
//     this.isVisible,
//     this.stockItemId,
//     this.dailySessionNo,
//     this.vendorId,
//   });
//
//   StockItems stockItem;
//   dynamic dailySession;
//   dynamic vendor;
//   int id;
//   int costPrice;
//   int unit;
//   int quantity;
//   int createdBy;
//   DateTime createdOn;
//   dynamic updatedBy;
//   dynamic updatedOn;
//   bool isVisible;
//   int stockItemId;
//   int dailySessionNo;
//   int vendorId;
//
//   factory StockItemDetails.fromJson(Map<String, dynamic> json) => StockItemDetails(
//     stockItem: json["stockItem"] == null ? null : StockItems.fromJson(json["stockItem"]),
//     dailySession: json["dailySession"],
//     vendor: json["vendor"],
//     id: json["id"] == null ? null : json["id"],
//     costPrice: json["costPrice"] == null ? null : json["costPrice"],
//     unit: json["unit"] == null ? null : json["unit"],
//     quantity: json["quantity"] == null ? null : json["quantity"],
//     createdBy: json["createdBy"] == null ? null : json["createdBy"],
//     createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
//     updatedBy: json["updatedBy"],
//     updatedOn: json["updatedOn"],
//     isVisible: json["isVisible"] == null ? null : json["isVisible"],
//     stockItemId: json["stockItemId"] == null ? null : json["stockItemId"],
//     dailySessionNo: json["dailySessionNo"] == null ? null : json["dailySessionNo"],
//     vendorId: json["vendorId"] == null ? null : json["vendorId"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "stockItem": stockItem == null ? null : stockItem.toJson(),
//     "dailySession": dailySession,
//     "vendor": vendor,
//     "id": id == null ? null : id,
//     "costPrice": costPrice == null ? null : costPrice,
//     "unit": unit == null ? null : unit,
//     "quantity": quantity == null ? null : quantity,
//     "createdBy": createdBy == null ? null : createdBy,
//     "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
//     "updatedBy": updatedBy,
//     "updatedOn": updatedOn,
//     "isVisible": isVisible == null ? null : isVisible,
//     "stockItemId": stockItemId == null ? null : stockItemId,
//     "dailySessionNo": dailySessionNo == null ? null : dailySessionNo,
//     "vendorId": vendorId == null ? null : vendorId,
//   };
// }
// To parse this JSON data, do
//
//     final stockRecovery = stockRecoveryFromJson(jsonString);

  StockRecovery({
  this.stockItemDetails,
  this.id,
  this.comment,
  this.isVisible,
  this.createdBy,
  this.createdOn,
  this.updatedBy,
  this.updatedOn,
  this.stockItemDetailsId,
  });

  StockItemDetails stockItemDetails;
  int id;
  String comment;
  bool isVisible;
  int createdBy;
  DateTime createdOn;
  dynamic updatedBy;
  dynamic updatedOn;
  int stockItemDetailsId;

  factory StockRecovery.fromJson(Map<String, dynamic> json) => StockRecovery(
  stockItemDetails: json["stockItemDetails"] == null ? null : StockItemDetails.fromJson(json["stockItemDetails"]),
  id: json["id"] == null ? null : json["id"],
  comment: json["comment"] == null ? null : json["comment"],
  isVisible: json["isVisible"] == null ? null : json["isVisible"],
  createdBy: json["createdBy"] == null ? null : json["createdBy"],
  createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
  updatedBy: json["updatedBy"],
  updatedOn: json["updatedOn"],
  stockItemDetailsId: json["stockItemDetailsId"] == null ? null : json["stockItemDetailsId"],
  );

  Map<String, dynamic> toJson() => {
  "stockItemDetails": stockItemDetails == null ? null : stockItemDetails.toJson(),
  "comment": comment == null ? null : comment,
  "isVisible": isVisible == null ? null : isVisible,
  "createdBy": createdBy == null ? null : createdBy,
  "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
  "updatedBy": updatedBy,
  "updatedOn": updatedOn,
  "stockItemDetailsId": stockItemDetailsId == null ? null : stockItemDetailsId,
  };
  Map<String, dynamic> updatetoJson() => {
   // "stockItemDetails": stockItemDetails == null ? null : stockItemDetails.toJson(),
    "id": id == null ? null : id,
   "comment": comment == null ? null : comment,
   "createdBy": createdBy == null ? null : createdBy,
   "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
   "updatedBy": updatedBy,
   "updatedOn": updatedOn,
   "stockItemDetailsId": stockItemDetailsId == null ? null : stockItemDetailsId,
 };
  }

  class StockItemDetails {
  StockItemDetails({
  this.stockItem,
  this.dailySession,
  this.vendor,
  this.id,
  this.costPrice,
  this.unit,
  this.quantity,
  this.createdBy,
  this.createdOn,
  this.updatedBy,
  this.updatedOn,
  this.isVisible,
  this.stockItemId,
  this.dailySessionNo,
  this.vendorId,
  });

  StockItem stockItem;
  dynamic dailySession;
  dynamic vendor;
  int id;
  double costPrice;
  int unit;
  double quantity;
  int createdBy;
  DateTime createdOn;
  dynamic updatedBy;
  dynamic updatedOn;
  bool isVisible;
  int stockItemId;
  int dailySessionNo;
  int vendorId;

  factory StockItemDetails.fromJson(Map<String, dynamic> json) => StockItemDetails(
  stockItem: json["stockItem"] == null ? null : StockItem.fromJson(json["stockItem"]),
  dailySession: json["dailySession"],
  vendor: json["vendor"],
  id: json["id"] == null ? null : json["id"],
  costPrice: json["costPrice"] == null ? null : json["costPrice"],
  unit: json["unit"] == null ? null : json["unit"],
  quantity: json["quantity"] == null ? null : json["quantity"],
  createdBy: json["createdBy"] == null ? null : json["createdBy"],
  createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
  updatedBy: json["updatedBy"],
  updatedOn: json["updatedOn"],
  isVisible: json["isVisible"] == null ? null : json["isVisible"],
  stockItemId: json["stockItemId"] == null ? null : json["stockItemId"],
  dailySessionNo: json["dailySessionNo"] == null ? null : json["dailySessionNo"],
  vendorId: json["vendorId"] == null ? null : json["vendorId"],
  );

  Map<String, dynamic> toJson() => {
  "stockItem": stockItem == null ? null : stockItem.toJson(),
  "dailySession": dailySession,
  "vendor": vendor,
  "id": id == null ? null : id,
  "costPrice": costPrice == null ? null : costPrice,
  "unit": unit == null ? null : unit,
  "quantity": quantity == null ? null : quantity,
  "createdBy": createdBy == null ? null : createdBy,
  "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
  "updatedBy": updatedBy,
  "updatedOn": updatedOn,
  "isVisible": isVisible == null ? null : isVisible,
  "stockItemId": stockItemId == null ? null : stockItemId,
  "dailySessionNo": dailySessionNo == null ? null : dailySessionNo,
  "vendorId": vendorId == null ? null : vendorId,
  };
  }

  class StockItem {
  StockItem({
  this.store,
  this.restaurant,
  this.stockItemDetails,
  this.productIngredients,
  this.additionalItems,
  this.purchaseOrderItems,
  this.id,
  this.name,
  this.totalStockQty,
  this.totalPrice,
  this.unit,
  this.minQuantity,
  this.maxQuantity,
  this.createdBy,
  this.createdOn,
  this.updatedBy,
  this.updatedOn,
  this.isVisible,
  this.storeId,
  this.restaurantId,
  });

  dynamic store;
  dynamic restaurant;
  List<dynamic> stockItemDetails;
  dynamic productIngredients;
  dynamic additionalItems;
  dynamic purchaseOrderItems;
  int id;
  String name;
  double totalStockQty;
  double totalPrice;
  int unit;
  double minQuantity;
  double maxQuantity;
  int createdBy;
  DateTime createdOn;
  int updatedBy;
  DateTime updatedOn;
  bool isVisible;
  int storeId;
  dynamic restaurantId;

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
  store: json["store"],
  restaurant: json["restaurant"],
  stockItemDetails: json["stockItemDetails"] == null ? null : List<dynamic>.from(json["stockItemDetails"].map((x) => x)),
  productIngredients: json["productIngredients"],
  additionalItems: json["additionalItems"],
  purchaseOrderItems: json["purchaseOrderItems"],
  id: json["id"] == null ? null : json["id"],
  name: json["name"] == null ? null : json["name"],
  totalStockQty: json["totalStockQty"] == null ? null : json["totalStockQty"],
  totalPrice: json["totalPrice"] == null ? null : json["totalPrice"],
  unit: json["unit"] == null ? null : json["unit"],
  minQuantity: json["minQuantity"] == null ? null : json["minQuantity"],
  maxQuantity: json["maxQuantity"] == null ? null : json["maxQuantity"],
  createdBy: json["createdBy"] == null ? null : json["createdBy"],
  createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
  updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
  updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
  isVisible: json["isVisible"] == null ? null : json["isVisible"],
  storeId: json["storeId"] == null ? null : json["storeId"],
  restaurantId: json["restaurantId"],
  );

  Map<String, dynamic> toJson() => {
  "store": store,
  "restaurant": restaurant,
  "stockItemDetails": stockItemDetails == null ? null : List<dynamic>.from(stockItemDetails.map((x) => x)),
  "productIngredients": productIngredients,
  "additionalItems": additionalItems,
  "purchaseOrderItems": purchaseOrderItems,
  "id": id == null ? null : id,
  "name": name == null ? null : name,
  "totalStockQty": totalStockQty == null ? null : totalStockQty,
  "totalPrice": totalPrice == null ? null : totalPrice,
  "unit": unit == null ? null : unit,
  "minQuantity": minQuantity == null ? null : minQuantity,
  "maxQuantity": maxQuantity == null ? null : maxQuantity,
  "createdBy": createdBy == null ? null : createdBy,
  "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
  "updatedBy": updatedBy == null ? null : updatedBy,
  "updatedOn": updatedOn == null ? null : updatedOn.toIso8601String(),
  "isVisible": isVisible == null ? null : isVisible,
  "storeId": storeId == null ? null : storeId,
  "restaurantId": restaurantId,
  };
  }


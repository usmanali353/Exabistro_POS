import 'dart:convert';

import 'StockVendors.dart';


class StockItems {
 static List<StockItems> StockItemsListFromJson(String str) => List<StockItems>.from(json.decode(str).map((x) => StockItems.fromJson(x)));
 static List<StockItems> StockItemsDetailsListFromJson(String str) => List<StockItems>.from(json.decode(str).map((x) => StockItems.DetailsfromJson(x)));
 static List<StockItems> StockItemsListOfNotificationFromJson(String str) => List<StockItems>.from(json.decode(str).map((x) => StockItems.fromJsonForNotification(x)));
 static String StockItemsListToJson(List<StockItems> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
 static StockItems StockItemsFromJson(String str) => StockItems.fromJson(json.decode(str));
 static String StockItemsToJson(StockItems data) => json.encode(data.toJson());
 static String UpdatestockItemsToJson(StockItems data) => json.encode(data.toMap());
 static String addStockItemsDetailToJson(StockItems data) => json.encode(data.stockDetailsToJson());
 static String updatestockItemsDetailToJson(StockItems data) => json.encode(data.updateStockDetailsToJson());

  StockItems({
    this.newQuantity,
    this.newCostPrice,
    this.stockDetailId,
    this.dailySession,
    this.stockDetailUnit,
    this.stockDetailQuantity,
    this.stockDetailCostPrice,
    this.vendorId,
    this.vendorName,
    this.stockItemDetails,
    this.id,
    this.name,
    this.totalStockQty,
    this.totalPrice,
    this.unit,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.storeId,
    this.restaurantId,
    this.restaurant,
    this.stockItemId,
    this.itemStockVendors,
    this.purchaseOrderItemId,
    this.purchasedQuantity,
    this.minQuantity,
    this.maxQuantity,
    this.expiryDate,
    this.isSauce,this.brandId,
    this.wasteQuantityPerUnitItem,
    this.isWastePercentageHigh,
    this.wastedQuantity,
    this.wastedItemPercentage
  });

 double newQuantity;
 double newCostPrice;
 int stockDetailId;
 int dailySession;
 int stockDetailUnit;
 double stockDetailQuantity;
 double stockDetailCostPrice;
 int vendorId;
 var vendorName;
 List<dynamic> stockItemDetails;
 int id;
 String name;
 double totalStockQty;
 double totalPrice;
 int unit;
 int createdBy;
 DateTime createdOn;
 dynamic updatedBy;
 dynamic updatedOn;
 bool isVisible;
 int storeId;
 dynamic restaurantId;
 dynamic restaurant;
 int stockItemId;
 List<StockVendors> itemStockVendors;
 int purchaseOrderItemId;
 double purchasedQuantity;
 double minQuantity ;
 double maxQuantity ;
 DateTime expiryDate;
 bool isSauce;
 int brandId;
 double wasteQuantityPerUnitItem;
 bool isWastePercentageHigh;
 double wastedQuantity;
 double wastedItemPercentage;


 factory StockItems.fromJson(Map<String, dynamic> json) => StockItems(
    newQuantity: json["newQuantity"] == null ? null : json["newQuantity"],
    newCostPrice: json["newCostPrice"] == null ? null : json["newCostPrice"],
    stockDetailId: json["stockDetailId"] == null ? null : json["stockDetailId"],
    dailySession: json["dailySession"] == null ? null : json["dailySession"],
    stockDetailUnit: json["stockDetailUnit"] == null ? null : json["stockDetailUnit"],
    stockDetailQuantity: json["stockDetailQuantity"] == null ? null : json["stockDetailQuantity"],
    stockDetailCostPrice: json["stockDetailCostPrice"] == null ? null : json["stockDetailCostPrice"],
    vendorId: json["vendorId"] == null ? null : json["vendorId"],
    vendorName: json["vendorName"] == null ? null : json["vendorName"],
    stockItemDetails: json["stockItemDetails"] == null ? null : List<dynamic>.from(json["stockItemDetails"].map((x) => x)),
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    totalStockQty: json["totalStockQty"] == null ? null : json["totalStockQty"],
    totalPrice: json["totalPrice"] == null ? null : json["totalPrice"],
    unit: json["unit"] == null ? null : json["unit"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"] == null ? null : json["storeId"],
    restaurantId: json["restaurantId"],
    restaurant: json["restaurant"],
    purchaseOrderItemId: json['purchaseOrderItemId'] ==null?null:json['purchaseOrderItemId'],
    purchasedQuantity: json['PurchasedQuantity'] ==null?null:json['PurchasedQuantity'],
      minQuantity: json['minQuantity'] ==null?null:json['minQuantity'],
      maxQuantity: json['maxQuantity'] ==null?null:json['maxQuantity'],
     wasteQuantityPerUnitItem: json['wasteQuantityPerUnitItem'] ==null?null:json['wasteQuantityPerUnitItem'],
   isSauce: json["isSauce"] == null ? null : json["isSauce"],

 );
 factory StockItems.DetailsfromJson(Map<String, dynamic> json) => StockItems(
   vendorName: json["vendorName"] == null ? null : json["vendorName"],
   stockDetailId: json["id"] == null ? null : json["id"],
   stockDetailCostPrice: json["costPrice"] == null ? null : json["costPrice"],
   unit: json["unit"] == null ? null : json["unit"],
   stockDetailQuantity: json["quantity"] == null ? null : json["quantity"],
   createdBy: json["createdBy"] == null ? null : json["createdBy"],
   createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
   updatedBy: json["updatedBy"],
   updatedOn: json["updatedOn"],
   isVisible: json["isVisible"] == null ? null : json["isVisible"],
   stockItemId: json["stockItemId"] == null ? null : json["stockItemId"],
   dailySession: json["dailySessionNo"] == null ? null : json["dailySessionNo"],
   vendorId: json["vendorId"] == null ? null : json["vendorId"],
     purchaseOrderItemId: json['purchaseOrderItemId'] ==null?null:json['purchaseOrderItemId'],
     purchasedQuantity: json['purchasedQuantity'] ==null?null:json['purchasedQuantity'],
   expiryDate: json["expiryDate"] == null ? null : DateTime.parse(json["expiryDate"]),
   brandId: json["itemBrandId"],
   isWastePercentageHigh: json["isWastePercentageHigh"] == null ? null : json["isWastePercentageHigh"],
   wastedQuantity: json["wastedQuantity"] == null ? null : json["wastedQuantity"].toDouble(),
   wastedItemPercentage: json["wastedItemPercentage"] == null ? null : json["wastedItemPercentage"].toDouble(),


 );
 factory StockItems.fromJsonForNotification(Map<String, dynamic> json) => StockItems(
   id: json["Id"] == null ? null : json["Id"],
   name: json["Name"] == null ? null : json["Name"],
   totalStockQty: json["TotalStockQty"] == null ? null : json["TotalStockQty"],
   totalPrice: json["TotalPrice"] == null ? null : json["TotalPrice"],
   unit: json["Unit"] == null ? null : json["Unit"],
   minQuantity: json["MinQuantity"] == null ? null : json["MinQuantity"],
   maxQuantity: json["MaxQuantity"] == null ? null : json["MaxQuantity"],
   isSauce: json["isSauce"] == null ? null : json["isSauce"],
   createdBy: json["CreatedBy"] == null ? null : json["CreatedBy"],
   createdOn: json["CreatedOn"] == null ? null : DateTime.parse(json["CreatedOn"]),
   updatedBy: json["UpdatedBy"],
   updatedOn: json["UpdatedOn"],
   isVisible: json["IsVisible"] == null ? null : json["IsVisible"],
   storeId: json["StoreId"] == null ? null : json["StoreId"],
 );

  Map<String, dynamic> toJson() => {
    // "NewQuantity": newQuantity == null ? null : newQuantity,
    // "NewCostPrice": newCostPrice == null ? null : newCostPrice,
   // "stockDetailId": stockDetailId == null ? null : stockDetailId,
   //  "DailySession": dailySession == null ? null : dailySession,
   //  "VendorId": vendorId == null ? null : vendorId,
    "Name": name == null ? null : name,
    "TotalStockQty": totalStockQty == null ? null : totalStockQty,
     "TotalPrice": totalPrice == null ? null : totalPrice,
    "Unit": unit == null ? null : unit,
    "IsVisible": isVisible == null ? true : isVisible,
    "StoreId": storeId == null ? null : storeId,
    //"StockDetailUnit":unit==null?null:unit,
   // "ItemStockVendors": itemStockVendors == null ? null : List<dynamic>.from(itemStockVendors.map((x) => x.toJson())),
    "MinQuantity":minQuantity == null?null :minQuantity,
    "MaxQuantity":maxQuantity == null?null :maxQuantity,
    "WasteQuantityPerUnitItem":wasteQuantityPerUnitItem,
    "IsSauce":isSauce
   // "purchaseOrderItemId": purchaseOrderItemId == null ? 1:purchaseOrderItemId,


  };

 Map<String, dynamic> toMap() => {
    "id": id,
   // "NewQuantity": newQuantity == null ? null : newQuantity,
   // "NewCostPrice": newCostPrice == null ? null : newCostPrice,
  // "stockDetailId": stockDetailId == null ? null : stockDetailId,
  //  "DailySession": dailySession == null ? null : dailySession,
  //  "VendorId": vendorId == null ? null : vendorId,
    "Name": name == null ? null : name,
    "TotalStockQty": totalStockQty == null ? null : totalStockQty,
    "TotalPrice": totalPrice == null ? null : totalPrice,
  // "Unit": unit == null ? null : unit,
    "IsVisible": isVisible == null ? true : isVisible,
    "StoreId": storeId == null ? null : storeId,
    "MinQuantity":minQuantity == null?null :minQuantity,
    "MaxQuantity":maxQuantity == null?null :maxQuantity,
   "WasteQuantityPerUnitItem":wasteQuantityPerUnitItem,
   "IsSauce":isSauce
   //"StockDetailUnit":stockDetailUnit==null?null:stockDetailUnit,
  // "purchaseOrderItemId": purchaseOrderItemId == null ? 1:purchaseOrderItemId,

 };
 Map<String, dynamic> stockDetailsToJson() => {
   "id":id,
   "NewQuantity": newQuantity == null ? null : newQuantity,
   "NewCostPrice": newCostPrice == null ? null : newCostPrice,
  // "StockItemId": stockItemId == null ? null : stockItemId,
   "DailySession": dailySession == null ? null : dailySession,
   "VendorId": vendorId == null ? null : vendorId,
   //"StockDetailCostPrice":stockDetailCostPrice==null?null:stockDetailCostPrice,
  // "Name": name == null ? null : name,
   // "TotalStockQty": totalStockQty == null ? null : totalStockQty,
   // "TotalPrice": totalPrice == null ? null : totalPrice,
   // "Unit": unit == null ? null : unit,
   "IsVisible": isVisible == null ? true : isVisible,
   "StoreId": storeId == null ? null : storeId,
   "PurchasedQuantity": purchasedQuantity==null?null:purchasedQuantity,
   "PurchaseOrderItemId": purchaseOrderItemId == null ? null:purchaseOrderItemId,
   "ExpiryDate":expiryDate==null?DateTime.now().add(Duration(days: 30)):expiryDate.toIso8601String(),
    "ItemBrandId": brandId
   // "StockDetailUnit":stockDetailUnit==null?null:stockDetailUnit,


 };
 Map<String, dynamic> updateStockDetailsToJson() => {
   "id":id,
   "StockDetailId":stockDetailId,
   // "NewQuantity": newQuantity == null ? null : newQuantity,
   // "NewCostPrice": newCostPrice == null ? null : newCostPrice,
  // "StockItemId": stockItemId == null ? null : stockItemId,
   "StockDetailQuantity":stockDetailQuantity==null?null:stockDetailQuantity,
   "DailySession": dailySession == null ? null : dailySession,
  /// "VendorId": vendorId == null ? null : vendorId,
   "StockDetailCostPrice":stockDetailCostPrice==null?null:stockDetailCostPrice,
  // "Name": name == null ? null : name,
   // "TotalStockQty": totalStockQty == null ? null : totalStockQty,
   // "TotalPrice": totalPrice == null ? null : totalPrice,
   // "Unit": unit == null ? null : unit,
   "IsVisible": isVisible == null ? true : isVisible,
   "StoreId": storeId == null ? null : storeId,
   //"StockDetailUnit":stockDetailUnit==null?null:stockDetailUnit,
   "PurchasedQuantity": purchasedQuantity==null?null:purchasedQuantity,
   "PurchaseOrderItemId": purchaseOrderItemId == null ? null:purchaseOrderItemId,
   "ExpiryDate":expiryDate==null?DateTime.now().add(Duration(days: 30)):expiryDate.toIso8601String(),
   "MinQuantity":minQuantity == null?null :minQuantity,
   "MaxQuantity":maxQuantity == null?null :maxQuantity,

 };
}

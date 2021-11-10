import 'dart:convert';
import 'ItemBrand.dart';
import 'StockVendors.dart';



class PurchaseOrder {
 static List<PurchaseOrder> purchaseOrderListFromJson(String str) => List<PurchaseOrder>.from(json.decode(str).map((x) => PurchaseOrder.fromJson(x)));
 static String purchaseOrderListToJson(List<PurchaseOrder> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
 static PurchaseOrder purchaseOrderFromJson(String str) => PurchaseOrder.fromJson(json.decode(str));
 static String purchaseOrderToJson(PurchaseOrder data) => json.encode(data.toJson());
 static String updatePurchaseOrderToJson(PurchaseOrder data) => json.encode(data.updatetoJson());

 PurchaseOrder({
 this.purchaseOrderItems,
 this.id,
 this.isVisible,
 this.createdBy,
 this.createdOn,
 this.updatedBy,
 this.updatedOn,
 this.storesId,
  this.expectedDeliveryDate,
  this.actualDeliveryDate,
  this.leadDeliveryDate,
  this.itemStockVendorId,
  this.itemStockVendor,
  this.deliveryStatus
 });

 List<PurchaseOrderItem> purchaseOrderItems;
 int id;
 bool isVisible;
 int createdBy;
 DateTime createdOn;
 dynamic updatedBy;
 dynamic updatedOn;
 int storesId;
 DateTime expectedDeliveryDate;
 DateTime actualDeliveryDate;
 var leadDeliveryDate;
 int itemStockVendorId;
 StockVendors itemStockVendor;
 String deliveryStatus;


 factory PurchaseOrder.fromJson(Map<String, dynamic> json) => PurchaseOrder(
 purchaseOrderItems: json["purchaseOrderItems"] == null ? null : List<PurchaseOrderItem>.from(json["purchaseOrderItems"].map((x) => PurchaseOrderItem.fromJson(x))),
  itemStockVendor: json["itemStockVendor"] == null ? null : StockVendors.fromJson(json["itemStockVendor"]),
  id: json["id"] == null ? null : json["id"],
 isVisible: json["isVisible"] == null ? null : json["isVisible"],
 createdBy: json["createdBy"] == null ? null : json["createdBy"],
 createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
 updatedBy: json["updatedBy"],
 updatedOn: json["updatedOn"],
 storesId: json["storesId"] == null ? null : json["storesId"],
  expectedDeliveryDate: json["expectedDeliveryDate"] == null ? null : DateTime.parse(json["expectedDeliveryDate"]),
  actualDeliveryDate: json["actualDeliveryDate"] == null ? null : DateTime.parse(json["actualDeliveryDate"]),
  leadDeliveryDate: json["leadDeliveryDate"] == null ? null : json["leadDeliveryDate"],
  deliveryStatus: json["deliveryStatus"] == null ? null : json["deliveryStatus"],


 );

 Map<String, dynamic> toJson() => {
 "purchaseOrderItems": purchaseOrderItems == null ? null : List<dynamic>.from(purchaseOrderItems.map((x) => x.toJson())),
 //"id": id == null ? null : id,
 "isVisible": isVisible == null ? null : isVisible,
 "createdBy": createdBy == null ? null : createdBy,
 "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
 "updatedBy": updatedBy,
 "updatedOn": updatedOn,
 "StoreId": storesId == null ? null : storesId,
 "ItemStockVendorId":itemStockVendorId,
 };
 Map<String, dynamic> updatetoJson() => {
  "purchaseOrderItems": purchaseOrderItems == null ? null : List<dynamic>.from(purchaseOrderItems.map((x) => x.toJson())),
  //"id": id == null ? null : id,
  "isVisible": isVisible == null ? null : isVisible,
  "createdBy": createdBy == null ? null : createdBy,
  "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
  "updatedBy": updatedBy,
  "updatedOn": updatedOn,
  "StoreId": storesId == null ? null : storesId,
 };
 }

//  class PurchaseOrderItem {
//  PurchaseOrderItem({
//  this.stockItems,
//  this.vendor,
//  this.id,
//  this.itemQuantity,
//  this.unit,
//  this.isVisible,
//  this.createdBy,
//  this.createdOn,
//  this.updatedBy,
//  this.updatedOn,
//  this.stockItemsId,
//  this.purchaseOrderId,
//  this.vendorId,
//  });
//
//  StockItems stockItems;
//  dynamic vendor;
//  int id;
//  int itemQuantity;
//  int unit;
//  bool isVisible;
//  int createdBy;
//  DateTime createdOn;
//  dynamic updatedBy;
//  dynamic updatedOn;
//  int stockItemsId;
//  int purchaseOrderId;
//  int vendorId;
//
//  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) => PurchaseOrderItem(
//  stockItems: json["stockItems"] == null ? null : StockItems.fromJson(json["stockItems"]),
//  vendor: json["vendor"],
//  id: json["id"] == null ? null : json["id"],
//  itemQuantity: json["itemQuantity"] == null ? null : json["itemQuantity"],
//  unit: json["unit"] == null ? null : json["unit"],
//  isVisible: json["isVisible"] == null ? null : json["isVisible"],
//  createdBy: json["createdBy"] == null ? null : json["createdBy"],
//  createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
//  updatedBy: json["updatedBy"],
//  updatedOn: json["updatedOn"],
//  stockItemsId: json["stockItemsId"] == null ? null : json["stockItemsId"],
//  purchaseOrderId: json["purchaseOrderId"] == null ? null : json["purchaseOrderId"],
//  vendorId: json["vendorId"] == null ? null : json["vendorId"],
//  );
//
//  Map<String, dynamic> toJson() => {
//  // "stockItems": stockItems == null ? null : stockItems.toJson(),
//  // "vendor": vendor,
//  // "id": id == null ? null : id,
//  "itemQuantity": itemQuantity == null ? null : itemQuantity,
//  "unit": unit == null ? null : unit,
//  "isVisible": isVisible == null ? null : isVisible,
//  "createdBy": createdBy == null ? null : createdBy,
//  "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
//  "updatedBy": updatedBy,
//  "updatedOn": updatedOn,
//  "stockItemsId": stockItemsId == null ? null : stockItemsId,
// // "purchaseOrderId": purchaseOrderId == null ? null : purchaseOrderId,
//  "vendorId": vendorId == null ? null : vendorId,
//  };
//  }
class PurchaseOrderItem {
 PurchaseOrderItem({
  this.id,
  this.itemQuantity,
  this.unit,
  this.stockItemsId,
  this.vendorId,
  this.purchaseOrderId,
  this.isVisible,
  this.createdBy,
  this.createdOn,
  this.updatedBy,
  this.updatedOn,
  this.stockItemName,
  this.vendorName,
  this.vendorPhone,
  this.vendorEmail,
  this.totalItems,
  this.remainingQuantity,
  this.totalDeliverdQuantity,
  this.brandId,
  this.itemBrand
 });

 int id;
 int itemQuantity;
 int unit;
 int stockItemsId;
 int vendorId;
 int purchaseOrderId;
 bool isVisible;
 int createdBy;
 DateTime createdOn;
 dynamic updatedBy;
 dynamic updatedOn;
 String stockItemName;
 String vendorName;
 dynamic vendorPhone;
 String vendorEmail;
 int totalItems;
 var remainingQuantity;
 var totalDeliverdQuantity;
 var brandId;
 ItemBrand itemBrand;

 factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) => PurchaseOrderItem(
  id: json["id"] == null ? null : json["id"],
  itemQuantity: json["itemQuantity"] == null ? null : json["itemQuantity"],
  unit: json["unit"] == null ? null : json["unit"],
  stockItemsId: json["stockItemsId"] == null ? null : json["stockItemsId"],
  vendorId: json["vendorId"] == null ? null : json["vendorId"],
  purchaseOrderId: json["purchaseOrderId"] == null ? null : json["purchaseOrderId"],
  isVisible: json["isVisible"] == null ? null : json["isVisible"],
  createdBy: json["createdBy"] == null ? null : json["createdBy"],
  createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
  updatedBy: json["updatedBy"],
  updatedOn: json["updatedOn"],
  stockItemName: json["stockName"] == null ? null : json["stockName"],
  vendorName: json["vendorName"] == null ? null : json["vendorName"],
  vendorPhone: json["vendorPhone"],
  vendorEmail: json["vendorEmail"] == null ? null : json["vendorEmail"],
  totalItems: json["totalItems"] == null ? null : json["totalItems"],
  remainingQuantity: json["remainingQuantity"] == null ? null : json["remainingQuantity"],
  totalDeliverdQuantity: json["totalDeliverdQuantity"] == null ? null : json["totalDeliverdQuantity"],
  brandId: json["itemBrandId"],
  itemBrand: json["itemBrand"] == null ? null : ItemBrand.fromJson(json["itemBrand"]),

 );
 Map<String, dynamic> toJson() => {
  // "stockItems": stockItems == null ? null : stockItems.toJson(),
  // "vendor": vendor,
  // "id": id == null ? null : id,
  "itemQuantity": itemQuantity == null ? null : itemQuantity,
  "Unit": unit == null ? null : unit,
  "isVisible": isVisible == null ? null : isVisible,
  "createdBy": createdBy == null ? null : createdBy,
  "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
  "updatedBy": updatedBy,
  "updatedOn": updatedOn,
  "stockItemsId": stockItemsId == null ? null : stockItemsId,
  "ItemBrandId": brandId
  // "DeliveryDate":DateTime.now(),
// "purchaseOrderId": purchaseOrderId == null ? null : purchaseOrderId,
 /// "vendorId": vendorId == null ? null : vendorId,
 };
 // Map<String, dynamic> toJson() => {
 //  "id": id == null ? null : id,
 //  "itemQuantity": itemQuantity == null ? null : itemQuantity,
 //  "unit": unit == null ? null : unit,
 //  "stockItemsId": stockItemsId == null ? null : stockItemsId,
 //  "vendorId": vendorId == null ? null : vendorId,
 //  "purchaseOrderId": purchaseOrderId == null ? null : purchaseOrderId,
 //  "isVisible": isVisible == null ? null : isVisible,
 //  "createdBy": createdBy == null ? null : createdBy,
 //  "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
 //  "updatedBy": updatedBy,
 //  "updatedOn": updatedOn,
 //  "stockItemName": stockItemName == null ? null : stockItemName,
 //  "vendorName": vendorName == null ? null : vendorName,
 //  "vendorPhone": vendorPhone,
 //  "vendorEmail": vendorEmail == null ? null : vendorEmail,
 //  "totalItems": totalItems == null ? null : totalItems,
 // };
}

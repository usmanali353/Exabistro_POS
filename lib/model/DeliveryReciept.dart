import 'dart:convert';

class DeliveryReceipt {

 static List<DeliveryReceipt> deliveryReceiptListFromJson(String str) => List<DeliveryReceipt>.from(json.decode(str).map((x) => DeliveryReceipt.fromJson(x)));
 static DeliveryReceipt deliveryReceiptFromJson(String str) => DeliveryReceipt.fromJson(json.decode(str));
 static String deliveryReceiptToJson(DeliveryReceipt data) => json.encode(data.toJson());

  DeliveryReceipt({
    this.purchaseOrderItem,
    this.id,
    this.deliveredQuantity,
    this.deliveryDate,
    this.price,
    this.createdBy,
    this.createdOn,
    this.purchaseOrderItemId,
    this.cleaningQuantity,
    this.dailySessionId,
    this.expiryDate,
    this.brandId
  });

  dynamic purchaseOrderItem;
  int id;
  var deliveredQuantity;
  DateTime deliveryDate;
  var price;
  int createdBy;
  DateTime createdOn;
  int purchaseOrderItemId;
  var cleaningQuantity;
  int dailySessionId;
  DateTime expiryDate;
   var brandId;
  factory DeliveryReceipt.fromJson(Map<String, dynamic> json) => DeliveryReceipt(
    purchaseOrderItem: json["purchaseOrderItem"],
    id: json["id"] == null ? null : json["id"],
    deliveredQuantity: json["deliveredQuantity"] == null ? null : json["deliveredQuantity"],
    deliveryDate: json["deliveryDate"] == null ? null : DateTime.parse(json["deliveryDate"]),
    price: json["price"] == null ? null : json["price"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    purchaseOrderItemId: json["purchaseOrderItemId"] == null ? null : json["purchaseOrderItemId"],
  );

  Map<String, dynamic> toJson() => {
    "DeliveredQuantity": deliveredQuantity == null ? null : deliveredQuantity,
    "DeliveryDate": deliveryDate == null ? null : deliveryDate.toIso8601String(),
    "Price": price == null ? null : price,
    "CreatedBy": createdBy == null ? null : createdBy,
    "CreatedOn": createdOn == null ? null : createdOn.toIso8601String(),
    "PurchaseOrderItemId": purchaseOrderItemId == null ? null : purchaseOrderItemId,
    "ExpiryDate": expiryDate == null ? null : expiryDate.toIso8601String(),
    "DailySessionId":dailySessionId,
    "CleaningQuantity":cleaningQuantity==null?null:cleaningQuantity,
    "BrandId":brandId

  };
  Map<String, dynamic> updateToJson() => {
    "Id": id == null ? null : id,
    "DeliveredQuantity": deliveredQuantity == null ? null : deliveredQuantity,
    "DeliveryDate": deliveryDate == null ? null : deliveryDate.toIso8601String(),
    "Price": price == null ? null : price,
    "CreatedBy": createdBy == null ? null : createdBy,
    "CreatedOn": createdOn == null ? null : createdOn.toIso8601String(),
    "PurchaseOrderItemId": purchaseOrderItemId == null ? null : purchaseOrderItemId,
    "ExpiryDate": expiryDate == null ? null : expiryDate.toIso8601String(),
    "DailySessionId":dailySessionId,
    "CleaningQuantity":cleaningQuantity==null?null:cleaningQuantity,
    "BrandId":brandId
  };
}

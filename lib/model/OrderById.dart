// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';



class OrderById {
 static OrderById OrderFromJson(String str) => OrderById.fromJson(json.decode(str));

 static String OrderToJson(OrderById data) => json.encode(data.toJson());
  OrderById({
    this.orderItems,
    this.id,
    this.dailySessionNo,
    this.salesNo,
    this.grossTotal,
    this.adjustment,
    this.netTotal,
    this.cashPay,
    this.balance,
    this.comment,
    this.orderType,
    this.orderStatus,
    this.paymentType,
    this.paymentOptions,
    this.separateEvenlyNo,
    this.isCashPaid,
    this.isVisible,
    this.driverId,
    this.driverAddress,
    this.driverLongitude,
    this.driverLatitude,
    this.deliveryAddress,
    this.deliveryLongitude,
    this.deliveryLatitude,
    this.estimatedPrepareTime,
    this.actualPrepareTime,
    this.estimatedDeliveryTime,
    this.actualDriverDepartureTime,
    this.actualDeliveryTime,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.storeId,
    this.restaurantId,
    this.customerId,
    this.employeeId,
    this.employee,
    this.tableId,
    this.table,
    this.orderChairs,
    this.ordersFeedBack,
    this.usersDeviceTokens,
    this.orderPayments,
  });

  List<OrderItem> orderItems;
  var id;
  var dailySessionNo;
  var salesNo;
  var grossTotal;
  dynamic adjustment;
  dynamic netTotal;
  dynamic cashPay;
  dynamic balance;
  String comment;
  var orderType;
  var orderStatus;
  var paymentType;
  var paymentOptions;
  dynamic separateEvenlyNo;
  bool isCashPaid;
  bool isVisible;
  dynamic driverId;
  dynamic driverAddress;
  dynamic driverLongitude;
  dynamic driverLatitude;
  dynamic deliveryAddress;
  dynamic deliveryLongitude;
  dynamic deliveryLatitude;
  dynamic estimatedPrepareTime;
  dynamic actualPrepareTime;
  dynamic estimatedDeliveryTime;
  dynamic actualDriverDepartureTime;
  dynamic actualDeliveryTime;
  var createdBy;
  DateTime createdOn;
  var updatedBy;
  DateTime updatedOn;
  var storeId;
  var restaurantId;
  var customerId;
  dynamic employeeId;
  dynamic employee;
  dynamic tableId;
  dynamic table;
  List<dynamic> orderChairs;
  List<dynamic> ordersFeedBack;
  List<dynamic> usersDeviceTokens;
  List<dynamic> orderPayments;

  factory OrderById.fromJson(Map<String, dynamic> json) => OrderById(
    orderItems: json["orderItems"] == null ? null : List<OrderItem>.from(json["orderItems"].map((x) => OrderItem.fromJson(x))),
    id: json["id"] == null ? null : json["id"],
    dailySessionNo: json["dailySessionNo"] == null ? null : json["dailySessionNo"],
    salesNo: json["salesNo"] == null ? null : json["salesNo"],
    grossTotal: json["grossTotal"] == null ? null : json["grossTotal"],
    adjustment: json["adjustment"],
    netTotal: json["netTotal"],
    cashPay: json["cashPay"],
    balance: json["balance"],
    comment: json["comment"] == null ? null : json["comment"],
    orderType: json["orderType"] == null ? null : json["orderType"],
    orderStatus: json["orderStatus"] == null ? null : json["orderStatus"],
    paymentType: json["paymentType"] == null ? null : json["paymentType"],
    paymentOptions: json["paymentOptions"] == null ? null : json["paymentOptions"],
    separateEvenlyNo: json["separateEvenlyNo"],
    isCashPaid: json["isCashPaid"] == null ? null : json["isCashPaid"],
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    driverId: json["driverId"],
    driverAddress: json["driverAddress"],
    driverLongitude: json["driverLongitude"],
    driverLatitude: json["driverLatitude"],
    deliveryAddress: json["deliveryAddress"],
    deliveryLongitude: json["deliveryLongitude"],
    deliveryLatitude: json["deliveryLatitude"],
    estimatedPrepareTime: json["estimatedPrepareTime"],
    actualPrepareTime: json["actualPrepareTime"],
    estimatedDeliveryTime: json["estimatedDeliveryTime"],
    actualDriverDepartureTime: json["actualDriverDepartureTime"],
    actualDeliveryTime: json["actualDeliveryTime"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
    updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    storeId: json["storeId"] == null ? null : json["storeId"],
    restaurantId: json["restaurantId"] == null ? null : json["restaurantId"],
    customerId: json["customerId"] == null ? null : json["customerId"],
    employeeId: json["employeeId"],
    employee: json["employee"],
    tableId: json["tableId"],
    table: json["table"],
    orderChairs: json["orderChairs"] == null ? null : List<dynamic>.from(json["orderChairs"].map((x) => x)),
    ordersFeedBack: json["ordersFeedBack"] == null ? null : List<dynamic>.from(json["ordersFeedBack"].map((x) => x)),
    usersDeviceTokens: json["usersDeviceTokens"] == null ? null : List<dynamic>.from(json["usersDeviceTokens"].map((x) => x)),
    orderPayments: json["orderPayments"] == null ? null : List<dynamic>.from(json["orderPayments"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "orderItems": orderItems == null ? null : List<dynamic>.from(orderItems.map((x) => x.toJson())),
    "id": id == null ? null : id,
    "dailySessionNo": dailySessionNo == null ? null : dailySessionNo,
    "salesNo": salesNo == null ? null : salesNo,
    "grossTotal": grossTotal == null ? null : grossTotal,
    "adjustment": adjustment,
    "NetTotal": netTotal,
    "cashPay": cashPay,
    "balance": balance,
    "comment": comment == null ? null : comment,
    "orderType": orderType == null ? null : orderType,
    "orderStatus": orderStatus == null ? null : orderStatus,
    "paymentType": paymentType == null ? null : paymentType,
    "paymentOptions": paymentOptions == null ? null : paymentOptions,
    "separateEvenlyNo": separateEvenlyNo,
    "isCashPaid": isCashPaid == null ? null : isCashPaid,
    "isVisible": isVisible == null ? null : isVisible,
    "driverId": driverId,
    "driverAddress": driverAddress,
    "driverLongitude": driverLongitude,
    "driverLatitude": driverLatitude,
    "deliveryAddress": deliveryAddress,
    "deliveryLongitude": deliveryLongitude,
    "deliveryLatitude": deliveryLatitude,
    "estimatedPrepareTime": estimatedPrepareTime,
    "actualPrepareTime": actualPrepareTime,
    "estimatedDeliveryTime": estimatedDeliveryTime,
    "actualDriverDepartureTime": actualDriverDepartureTime,
    "actualDeliveryTime": actualDeliveryTime,
    "createdBy": createdBy == null ? null : createdBy,
    "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    "updatedBy": updatedBy == null ? null : updatedBy,
    "updatedOn": updatedOn == null ? null : updatedOn.toIso8601String(),
    "storeId": storeId == null ? null : storeId,
    "restaurantId": restaurantId == null ? null : restaurantId,
    "customerId": customerId == null ? null : customerId,
    "employeeId": employeeId,
    "employee": employee,
    "tableId": tableId,
    "table": table,
    "orderChairs": orderChairs == null ? null : List<dynamic>.from(orderChairs.map((x) => x)),
    "ordersFeedBack": ordersFeedBack == null ? null : List<dynamic>.from(ordersFeedBack.map((x) => x)),
    "usersDeviceTokens": usersDeviceTokens == null ? null : List<dynamic>.from(usersDeviceTokens.map((x) => x)),
    "orderPayments": orderPayments == null ? null : List<dynamic>.from(orderPayments.map((x) => x)),
  };
}

class OrderItem {
  static List<OrderItem> listOrderitemFromJson(String str) => List<OrderItem>.from(json.decode(str).map((x) => OrderItem.fromJson(x)));

  static String listOrderitemToJson(List<OrderItem> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static OrderItem OrderitemByIdFromJson(String str) => OrderItem.fromJson(json.decode(str));

  static String OrderitemByIdToJson(OrderItem data) => json.encode(data.toJson());
  OrderItem({
    this.sizeName,
    this.orderItemsToppings,
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.totalPrice,
    this.salesType,
    this.haveTopping,
    this.isDeal,
    this.orderItemStatus,
    this.sizeId,
    this.orderId,
    this.productId,
    this.discountId,
    this.discount,
    this.dealId,
    this.discountedPrice,
    this.chairId,
    this.chair,
  });

  String sizeName;
  List<OrderItemsTopping> orderItemsToppings;
  var id;
  String name;
  double price;
  var quantity;
  double totalPrice;
  var salesType;
  bool haveTopping;
  bool isDeal;
  var orderItemStatus;
  int sizeId;
  var orderId;
  int productId;
  dynamic discountId;
  dynamic discount;
  dynamic dealId;
  double discountedPrice;
  dynamic chairId;
  dynamic chair;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
   // sizeName: json["sizeName"] == null ? null : json["sizeName"],
    orderItemsToppings: json["orderItemsToppings"] == null ? null : List<OrderItemsTopping>.from(json["orderItemsToppings"].map((x) => OrderItemsTopping.fromJson(x))),
  //  id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    price: json["price"] == null ? null : json["price"],
    quantity: json["quantity"] == null ? null : json["quantity"],
    totalPrice: json["totalPrice"] == null ? null : json["totalPrice"],
    salesType: json["salesType"] == null ? null : json["salesType"],
    haveTopping: json["haveTopping"] == null ? null : json["haveTopping"],
    isDeal: json["isDeal"] == null ? null : json["isDeal"],
    orderItemStatus: json["orderItemStatus"] == null ? null : json["orderItemStatus"],
    sizeId: json["sizeId"] == null ? null : json["sizeId"],
   // orderId: json["orderId"] == null ? null : json["orderId"],
    productId: json["productId"] == null ? null : json["productId"],
    discountId: json["discountId"],
    discount: json["discount"],
    dealId: json["dealId"],
    discountedPrice: json["discountedPrice"] == null ? null : json["discountedPrice"],
    chairId: json["chairId"],
  );

  Map<String, dynamic> toJson() => {
   // "sizeName": sizeName == null ? null : sizeName,
    "orderitemstoppings": orderItemsToppings == null ? null : List<dynamic>.from(orderItemsToppings.map((x) => x.toJson())),
   // "id": id == null ? null : id,
    "name": name == null ? null : name,
    "price": price == null ? null : price,
    "quantity": quantity == null ? null : quantity,
    "totalprice": totalPrice == null ? null : totalPrice,
   // "salesType": salesType == null ? null : salesType,
    "havetopping": haveTopping == null ? null : haveTopping,
    "IsDeal": isDeal == null ? null : isDeal,
    //"orderItemStatus": orderItemStatus == null ? null : orderItemStatus,
    "sizeid": sizeId == null ? null : sizeId,
   // "orderId": orderId == null ? null : orderId,
    "productid": productId == null ? null : productId,
   // "discountId": discountId,
   // "discount": discount,
    "dealid": dealId,
   // "discountedPrice": discountedPrice == null ? null : discountedPrice,
    "chairId": chairId,
  };
}

class OrderItemsTopping {
  OrderItemsTopping({
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.totalPrice,
    this.orderItemId,
    this.additionalItemId,
  });

  var id;
  String name;
  var price;
  var quantity;
  var totalPrice;
  var orderItemId;
  var additionalItemId;

  factory OrderItemsTopping.fromJson(Map<String, dynamic> json) => OrderItemsTopping(
  //  id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    price: json["price"] == null ? null : json["price"],
    quantity: json["quantity"] == null ? null : json["quantity"],
    totalPrice: json["totalPrice"] == null ? null : json["totalPrice"],
 //   orderItemId: json["orderItemId"] == null ? null : json["orderItemId"],
    additionalItemId: json["additionalItemId"] == null ? null : json["additionalItemId"],
  );

  Map<String, dynamic> toJson() => {
    //"id": id == null ? null : id,
    "name": name == null ? null : name,
    "price": price == null ? null : price,
    "quantity": quantity == null ? null : quantity,
    "totalprice": totalPrice == null ? null : totalPrice,
   // "orderItemId": orderItemId == null ? null : orderItemId,
    "additionalitemid": additionalItemId == null ? null : additionalItemId,
  };
}

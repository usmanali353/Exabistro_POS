import 'dart:convert';

import 'Orderitems.dart';


// class Order {
//   static List<Order> listOrderFromJson(String str) => List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));
//   static String listOrderToJson(List<Order> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//   static Order OrderFromJson(String str) => Order.fromJson(json.decode(str));
//   static String OrderToJson(Order data) => json.encode(data.toJson());
//   Order({
//     this.ordertype,
//     this.grosstotal,
//     this.customerId,
//     this.comment,
//     this.orderitems,
//   });
//
//   int ordertype;
//   String grosstotal;
//   int customerId;
//   String comment;
//   List<Orderitem> orderitems;
//
//   factory Order.fromJson(Map<String, dynamic> json) => Order(
//     ordertype: json["ordertype"],
//     grosstotal: json["grosstotal"],
//     customerId: json["customerId"],
//     comment: json["comment"],
//     orderitems: List<Orderitem>.from(json["orderitems"].map((x) => Orderitem.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "ordertype": ordertype,
//     "grosstotal": grosstotal,
//     "customerId": customerId,
//     "comment": comment,
//     "orderitems": List<dynamic>.from(orderitems.map((x) => x.toJson())),
//   };
// }


class Order {
  static List<Order> listOrderFromJson(String str) => List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));
  static String listOrderToJson(List<Order> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static String OrderToJson(Order data) => json.encode(data.toJson());
  static Order OrderFromJson(String str) => Order.fromJson(json.decode(str));

  Order({
    this.ordertype,
    this.grosstotal,
    this.orderChairs,
    this.orderitems,
    this.DeviceToken,
    this.orderPayments,
    this.id,
    this.dailySessionNo,
    this.salesNo,
    this.adjustment,
    this.netTotal,
    this.cashPay,
    this.balance,
    this.comment,
    this.orderStatus,
    this.paymentType,
    this.paymentOptions,
    this.isCashPaid,
    this.isVisible,
    this.driverId,
    this.driver,
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
    this.restaurant,
    this.customerId,
    this.TableId,
    this.orderPriority,
    this.voucher,
    this.orderTaxList,
    this.dineInEndTime,
    this.visitingCustomerEmail,
    this.visitingCustomerCellNo,
    this.employeeId

  });

  int dailySessionNo;
  int storeId;
  int ordertype;
  double grosstotal;
  String comment;
  String DeviceToken;
  String deliveryAddress;
  String deliveryLongitude;
  String deliveryLatitude;
  int paymentType;
  int paymentOptions;
  List<dynamic> orderChairs;
  List<Orderitem> orderitems;
  List<dynamic> orderPayments, orderTaxList;
  var voucher;
  int id;
  int salesNo;
  dynamic adjustment;
  double netTotal;
  double cashPay;
  double balance;
  int orderStatus;
  bool isCashPaid;
  bool isVisible;
  int driverId;
  dynamic driver;
  String driverAddress;
  String driverLongitude;
  String driverLatitude;
  int estimatedPrepareTime;
  dynamic actualPrepareTime;
  int estimatedDeliveryTime;
  String actualDriverDepartureTime;
  dynamic actualDeliveryTime;
  int createdBy;
  DateTime createdOn;
  int updatedBy;
  DateTime updatedOn;
  int restaurantId;
  dynamic restaurant;
  int customerId;
  int TableId;
  int orderPriority;
  String dineInEndTime;
  String visitingCustomerEmail;
  String visitingCustomerCellNo;
  int employeeId;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    orderitems: Orderitem.listOrderitemFromJson(json["orderItems"]),//json["orderItems"] == null ? null : List<Orderitem>.from(json["orderItems"].map((x) => x)),
    id: json["id"] == null ? null : json["id"],
    DeviceToken:json["DeviceToken"]==null?null:json["DeviceToken"],
    dailySessionNo: json["dailySessionNo"] == null ? null : json["dailySessionNo"],
    salesNo: json["salesNo"] == null ? null : json["salesNo"],
    grosstotal: json["grossTotal"] == null ? null : json["grossTotal"].toDouble(),
    adjustment: json["adjustment"],
    netTotal: json["netTotal"],
    cashPay: json["cashPay"] == null ? null : json["cashPay"].toDouble(),
    balance: json["balance"] == null ? null : json["balance"].toDouble(),
    comment: json["comment"] == null ? null : json["comment"],
    ordertype: json["orderType"] == null ? null : json["orderType"],
    orderStatus: json["orderStatus"] == null ? null : json["orderStatus"],
    paymentType: json["paymentType"] == null ? null : json["paymentType"],
    paymentOptions: json["paymentOptions"] == null ? null : json["paymentOptions"],
    isCashPaid: json["isCashPaid"] == null ? null : json["isCashPaid"],
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    driverId: json["driverId"] == null ? null : json["driverId"],
    driver: json["driver"],
    driverAddress: json["driverAddress"] == null ? null : json["driverAddress"],
    driverLongitude: json["driverLongitude"] == null ? null : json["driverLongitude"],
    driverLatitude: json["driverLatitude"] == null ? null : json["driverLatitude"],
    deliveryAddress: json["deliveryAddress"] == null ? null : json["deliveryAddress"],
    deliveryLongitude: json["deliveryLongitude"] == null ? null : json["deliveryLongitude"],
    deliveryLatitude: json["deliveryLatitude"] == null ? null : json["deliveryLatitude"],
    estimatedPrepareTime: json["estimatedPrepareTime"] == null ? null : json["estimatedPrepareTime"],
    actualPrepareTime: json["actualPrepareTime"],
    estimatedDeliveryTime: json["estimatedDeliveryTime"] == null ? null : json["estimatedDeliveryTime"],
    actualDriverDepartureTime: json["actualDriverDepartureTime"] == null ? null : json["actualDriverDepartureTime"],
    actualDeliveryTime: json["actualDeliveryTime"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
    updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    storeId: json["storeId"] == null ? null : json["storeId"],
    restaurantId: json["restaurantId"] == null ? null : json["restaurantId"],
    restaurant: json["restaurant"],
    customerId: json["customerId"] == null ? null : json["customerId"],
    TableId: json["tableId"] == null ? null : json["tableId"],
    orderPriority: json['OrderPriorityId']==null?null:json['OrderPriorityId'],
    orderChairs: json["orderChairs"] == null ? null : List<dynamic>.from(json["orderChairs"].map((x) => x)),


  );

  Map<String, dynamic> toJson() => {
    "DailySessionNo": dailySessionNo == null ? null : dailySessionNo,
    "StoreId": storeId == null ? null : storeId,
    "DeviceToken":DeviceToken==null?null:DeviceToken,
    "ordertype": ordertype == null ? null : ordertype,
    //"grosstotal": grosstotal == null ? null : grosstotal,
    "NetTotal":netTotal==null?null:netTotal,
    "comment": comment == null ? null : comment,
    "PaymentOptions":paymentOptions==null?null:paymentOptions,
    "TableId":TableId==null?null:TableId,
    "DeliveryAddress": deliveryAddress == null ? null : deliveryAddress,
    "DeliveryLongitude": deliveryLongitude == null ? null : deliveryLongitude,
    "DeliveryLatitude": deliveryLatitude == null ? null : deliveryLatitude,
    "PaymentType": paymentType == null ? null : paymentType,
    "OrderChairs": orderChairs ,//== null ? null : List<dynamic>.from(orderChairs.map((x) => x.toJson())),
    "orderitems": orderitems == null ? null : List<dynamic>.from(orderitems.map((x) => x.toJson())),
    "OrderPayments": orderPayments, //== null ? null : List<dy "OrderPriorityId":orderPriority==null?null:orderPriority,namic>.from(orderPayments.map((x) => x.toJson())),

  "OrderTaxes":orderTaxList==null?null:orderTaxList,
    "VoucherCode":voucher == null?null:voucher,
    "DineInEndTime": dineInEndTime==null?null:dineInEndTime,
     "CustomerEmail":visitingCustomerEmail==null?null:visitingCustomerEmail,
     "CustomerContactNo":visitingCustomerCellNo==null?null:visitingCustomerCellNo,
     "EmployeeId": employeeId==null?null:employeeId,


  };
}




// To parse this JSON data, do
//
//     final voucherDetails = voucherDetailsFromJson(jsonString);

import 'dart:convert';



class VoucherDetails {
 static VoucherDetails voucherDetailsFromJson(String str) => VoucherDetails.fromJson(json.decode(str));
  static String voucherDetailsToJson(VoucherDetails data) => json.encode(data.toJson());
  VoucherDetails({
    this.totalOrders,
    this.customersAmount,
    this.id,
    this.name,
    this.code,
    this.percentage,
    this.maxAmount,
    this.minOrderAmount,
    this.startDate,
    this.endDate,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.storeId,
    this.voucherCustomers,
  });

  double totalOrders;
  List<CustomersAmount> customersAmount;
  int id;
  String name;
  String code;
  double percentage;
  double maxAmount;
  double minOrderAmount;
  DateTime startDate;
  DateTime endDate;
  int createdBy;
  DateTime createdOn;
  dynamic updatedBy;
  dynamic updatedOn;
  bool isVisible;
  int storeId;
  List<dynamic> voucherCustomers;

  factory VoucherDetails.fromJson(Map<String, dynamic> json) => VoucherDetails(
    totalOrders: json["totalOrders"] == null ? null : json["totalOrders"],
    customersAmount: json["customersAmount"] == null ? null : List<CustomersAmount>.from(json["customersAmount"].map((x) => CustomersAmount.fromJson(x))),
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    code: json["code"] == null ? null : json["code"],
    percentage: json["percentage"] == null ? null : json["percentage"],
    maxAmount: json["maxAmount"] == null ? null : json["maxAmount"],
    minOrderAmount: json["minOrderAmount"] == null ? null : json["minOrderAmount"],
    startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
    endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"] == null ? null : json["storeId"],
    voucherCustomers: json["voucherCustomers"] == null ? null : List<dynamic>.from(json["voucherCustomers"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "totalOrders": totalOrders == null ? null : totalOrders,
    "customersAmount": customersAmount == null ? null : List<dynamic>.from(customersAmount.map((x) => x.toJson())),
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "code": code == null ? null : code,
    "percentage": percentage == null ? null : percentage,
    "maxAmount": maxAmount == null ? null : maxAmount,
    "minOrderAmount": minOrderAmount == null ? null : minOrderAmount,
    "startDate": startDate == null ? null : startDate.toIso8601String(),
    "endDate": endDate == null ? null : endDate.toIso8601String(),
    "createdBy": createdBy == null ? null : createdBy,
    "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedOn": updatedOn,
    "isVisible": isVisible == null ? null : isVisible,
    "storeId": storeId == null ? null : storeId,
    "voucherCustomers": voucherCustomers == null ? null : List<dynamic>.from(voucherCustomers.map((x) => x)),
  };
}

class CustomersAmount {
  CustomersAmount({
    this.name,
    this.amount,
    this.date,
  });

  String name;
  double amount;
  DateTime date;

  factory CustomersAmount.fromJson(Map<String, dynamic> json) => CustomersAmount(
    name: json["name"] == null ? null : json["name"],
    amount: json["amount"] == null ? null : json["amount"].toDouble(),
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name == null ? null : name,
    "amount": amount == null ? null : amount,
    "date": date == null ? null : date.toIso8601String(),
  };
}

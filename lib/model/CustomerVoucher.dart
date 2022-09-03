// To parse this JSON data, do
//
//     final customerVoucher = customerVoucherFromJson(jsonString);

import 'dart:convert';

class CustomerVoucher {
 static List<CustomerVoucher> customerVoucherListFromJson(String str) => List<CustomerVoucher>.from(json.decode(str).map((x) => CustomerVoucher.fromJson(x)));
 static CustomerVoucher customerVoucherFromJson(String str) => CustomerVoucher.fromJson(json.decode(str));
 static String customerVoucherToJson(CustomerVoucher data) => json.encode(data.toJson());
 static String updateCustomerVoucherToJson(CustomerVoucher data) => json.encode(data.toMap());

 CustomerVoucher({
    this.id,
    this.name,
    this.code,
    this.percentage,
    this.maxAmount,
    this.minOrderAmount,
    this.complaintId,
    this.customerId,
   this.voucherId,
   this.storeId,
    this.startDate,
    this.endDate,
  });
  int id;
  String name;
  String code;
  double percentage;
  double maxAmount;
  double minOrderAmount;
  int complaintId;
  int customerId;
  int storeId;
  String startDate;
  String endDate;
  int voucherId;

  factory CustomerVoucher.fromJson(Map<String, dynamic> json) => CustomerVoucher(
    // id: json['id'],
    // name: json["Name"] == null ? null : json["Name"],
    // code: json["Code"] == null ? null : json["Code"],
    // percentage: json["Percentage"] == null ? null : json["Percentage"],
    // maxAmount: json["MaxAmount"] == null ? null : json["MaxAmount"],
    // minOrderAmount: json["MinOrderAmount"] == null ? null : json["MinOrderAmount"],
    // complaintId: json["ComplaintId"] == null ? null : json["ComplaintId"],
    // customerId: json["CustomerId"] == null ? null : json["CustomerId"],
    // storeId: json["storeId"] == null ? null : json["storeId"],
    // startDate: json["StartDate"] == null ? null : json["StartDate"],
    // endDate: json["EndDate"] == null ? null : json["EndDate"],
    id: json["id"] == null ? null : json["id"],
    customerId: json["customerId"] == null ? null : json["customerId"],
    complaintId: json["complaintId"] == null ? null : json["complaintId"],
    storeId: json["storeId"] == null ? null : json["storeId"],
    name: json["name"] == null ? null : json["name"],
    code: json["code"] == null ? null : json["code"],
    percentage: json["percentage"] == null ? null : json["percentage"],
    maxAmount: json["maxAmount"] == null ? null : json["maxAmount"],
    minOrderAmount: json["minOrderAmount"] == null ? null : json["minOrderAmount"],
    startDate: json["startDate"] == null ? null : json["startDate"],
    endDate: json["endDate"] == null ? null : json["endDate"],
  );

  Map<String, dynamic> toJson() => {
    "Name": name == null ? null : name,
    "Code": code == null ? null : code,
    "Percentage": percentage == null ? null : percentage,
    "MaxAmount": maxAmount == null ? null : maxAmount,
    "MinOrderAmount": minOrderAmount == null ? null : minOrderAmount,
    "ComplaintId": complaintId == null ? null : complaintId,
    "CustomerId": customerId == null ? null : customerId,
    "VoucherId": voucherId == null ? null : voucherId,
    "StoreId": storeId == null ? null : storeId,
    "StartDate": startDate == null ? null : startDate,
    "EndDate": endDate == null ? null : endDate,
  };
 Map<String, dynamic> toMap() => {
   "id":id,
   "Name": name == null ? null : name,
   "Code": code == null ? null : code,
   "Percentage": percentage == null ? null : percentage,
   "MaxAmount": maxAmount == null ? null : maxAmount,
   "MinOrderAmount": minOrderAmount == null ? null : minOrderAmount,
   "ComplaintId": complaintId == null ? null : complaintId,
   "CustomerId": customerId == null ? null : customerId,
   "VoucherId": voucherId == null ? null : voucherId,
   "StoreId": storeId == null ? null : storeId,
   "StartDate": startDate == null ? null : startDate,
   "EndDate": endDate == null ? null : endDate,
 };
}

import 'dart:convert';


class Voucher {
  static List<Voucher> voucherListFromJson(String str) => List<Voucher>.from(json.decode(str).map((x) => Voucher.fromJson(x)));

  static String voucherListToJson(List<Voucher> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static Voucher voucherFromJson(String str) => Voucher.fromJson(json.decode(str));

  static String voucherToJson(Voucher data) => json.encode(data.toJson());
  static String updateVoucherToJson(Voucher data) => json.encode(data.toMap());
  Voucher({
    this.orders,
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
  });

  dynamic orders;
  int id;
  String name;
  String code;
  double percentage;
  dynamic maxAmount;
  dynamic minOrderAmount;
  String startDate;
  String endDate;
  int createdBy;
  DateTime createdOn;
  int updatedBy;
  DateTime updatedOn;
  bool isVisible;
  int storeId;

  factory Voucher.fromJson(Map<String, dynamic> json) => Voucher(
    orders: json["orders"],
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    code: json["code"] == null ? null : json["code"],
    percentage: json["percentage"] == null ? null : json["percentage"],
    maxAmount: json["maxAmount"],
    minOrderAmount: json["minOrderAmount"],
    startDate: json["startDate"] == null ? null : json["startDate"],
    endDate: json["endDate"] == null ? null : json["endDate"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
    updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"] == null ? null : json["storeId"],
  );

  Map<String, dynamic> toJson() => {
    "Name": name == null ? null : name,
    "Code": code == null ? null : code,
    "Percentage": percentage == null ? null : percentage,
    "MaxAmount": maxAmount,
    "MinOrderAmount": minOrderAmount,
    "StartDate": startDate == null ? null : startDate,
    "EndDate": endDate == null ? null : endDate,
    "StoreId": storeId == null ? null : storeId,
    "IsVisible":true,
  };
  Map<String, dynamic> toMap() => {
    "Id": id == null ? null : id,
    "Name": name == null ? null : name,
    "Code": code == null ? null : code,
    "Percentage": percentage == null ? null : percentage,
    "MaxAmount": maxAmount,
    "MinOrderAmount": minOrderAmount,
    "StartDate": startDate == null ? null : startDate,
    "EndDate": endDate == null ? null : endDate,
    "StoreId": storeId == null ? null : storeId,
    "IsVisible":true,
  };
}

import 'dart:convert';

class Tax {
  static List<Tax> taxListFromJson(String str) => List<Tax>.from(json.decode(str).map((x) => Tax.fromJson(x)));

  static String taxListToJson(List<Tax> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static Tax taxFromJson(String str) => Tax.fromJson(json.decode(str));

  static String taxToJson(Tax data) => json.encode(data.toJson());
  static String updatetaxToJson(Tax data) => json.encode(data.toMap());
  Tax({
    this.orderTaxes,
    this.id,
    this.name,
    this.percentage,
    this.price,
    this.delivery,
    this.dineIn,
    this.takeAway,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.storeId,
  });
  dynamic orderTaxes;
  int id;
  String name;
  double percentage,price;
  bool delivery;
  bool dineIn;
  bool takeAway;
  int createdBy;
  DateTime createdOn;
  int updatedBy;
  DateTime updatedOn;
  bool isVisible;
  int storeId;
  factory Tax.fromJson(Map<String, dynamic> json) => Tax(
    orderTaxes: json["orderTaxes"],
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    percentage: json["percentage"] == null ? null : json["percentage"],
    price: json['amount']==null?null:json['amount'],
    delivery: json["delivery"] == null ? null : json["delivery"],
    dineIn: json["dineIn"] == null ? null : json["dineIn"],
    takeAway: json["takeAway"] == null ? null : json["takeAway"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
    updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"] == null ? null : json["storeId"],
  );

  Map<String, dynamic> toJson() => {
  //  "id": id == null ? null : id,
    "Name": name == null ? null : name,
    "Percentage": percentage == null ? 0.0 : percentage,
    "Amount":price==null?0:price,
    "delivery": delivery == true ? true : false,
    "dineIn": dineIn == true ? true : false,
    "takeAway": takeAway== true ? true : false,
    "StoreId": storeId == null ? null : storeId,
    "IsVisible":true
  };
  Map<String, dynamic> toMap() => {
    "id": id == null ? null : id,
    "Name": name == null ? null : name,
    "Percentage": percentage == null ? 0.0 : percentage,
    "Amount":price==null?0:price,
    "delivery": delivery == true ? true : false,
    "dineIn": dineIn == true ? true : false,
    "takeAway": takeAway== true ? true : false,
    "StoreId": storeId == null ? null : storeId,
    "IsVisible":true
  };
}


import 'dart:convert';

class CompareMenuSale {
 static CompareMenuSale compareMenuSaleFromJson(String str) => CompareMenuSale.fromJson(json.decode(str));
 static String compareMenuSaleToJson(CompareMenuSale data) => json.encode(data.toJson());
  CompareMenuSale({
    this.quantityPerDay,
    this.anotherQuantityPerDay,
    this.pricePerDay,
    this.anotherPricePerDay,
    this.storeId,
    this.productId,
    this.productId2,
    this.lastDays,
    this.startDate,
    this.endDate,
    this.totalMenuItemSale,
    this.totalMenuItemEarning,
    this.totalAnotherMenuItemEarning,
    this.totalAnotherMenuItemSale,
  });

  List<double> quantityPerDay;
  List<double> anotherQuantityPerDay;
  List<double> pricePerDay;
  List<double> anotherPricePerDay;
  dynamic storeId;
  int productId;
  int productId2;
  double lastDays;
  dynamic startDate;
  dynamic endDate;
  var totalMenuItemSale;
  dynamic totalMenuItemEarning;
  dynamic totalAnotherMenuItemEarning;
  var totalAnotherMenuItemSale;

  factory CompareMenuSale.fromJson(Map<String, dynamic> json) => CompareMenuSale(
    quantityPerDay: json["quantityPerDay"] == null ? null : List<double>.from(json["quantityPerDay"].map((x) => x)),
    anotherQuantityPerDay: json["anotherQuantityPerDay"] == null ? null : List<double>.from(json["anotherQuantityPerDay"].map((x) => x)),
    pricePerDay: json["pricePerDay"] == null ? null : List<double>.from(json["pricePerDay"].map((x) => x)),
    anotherPricePerDay: json["anotherPricePerDay"] == null ? null : List<double>.from(json["anotherPricePerDay"].map((x) => x)),
    storeId: json["storeId"],
    productId: json["productId"] == null ? null : json["productId"],
    productId2: json["productId2"] == null ? null : json["productId2"],
    lastDays: json["lastDays"] == null ? null : json["lastDays"],
    startDate: json["startDate"],
    endDate: json["endDate"],
    totalMenuItemSale: json["totalMenuItemSale"] == null ? null : json["totalMenuItemSale"],
    totalMenuItemEarning: json["totalMenuItemEarning"],
    totalAnotherMenuItemEarning: json["totalAnotherMenuItemEarning"],
    totalAnotherMenuItemSale: json["totalAnotherMenuItemSale"] == null ? null : json["totalAnotherMenuItemSale"],
  );

  Map<String, dynamic> toJson() => {
    "quantityPerDay": quantityPerDay == null ? null : List<dynamic>.from(quantityPerDay.map((x) => x)),
    "anotherQuantityPerDay": anotherQuantityPerDay == null ? null : List<dynamic>.from(anotherQuantityPerDay.map((x) => x)),
    "pricePerDay": pricePerDay == null ? null : List<dynamic>.from(pricePerDay.map((x) => x)),
    "anotherPricePerDay": anotherPricePerDay == null ? null : List<dynamic>.from(anotherPricePerDay.map((x) => x)),
    "storeId": storeId,
    "productId": productId == null ? null : productId,
    "productId2": productId2 == null ? null : productId2,
    "lastDays": lastDays == null ? null : lastDays,
    "startDate": startDate,
    "endDate": endDate,
    "totalMenuItemSale": totalMenuItemSale == null ? null : totalMenuItemSale,
    "totalMenuItemEarning": totalMenuItemEarning,
    "totalAnotherMenuItemEarning": totalAnotherMenuItemEarning,
    "totalAnotherMenuItemSale": totalAnotherMenuItemSale == null ? null : totalAnotherMenuItemSale,
  };
}

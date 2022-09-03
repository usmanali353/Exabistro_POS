import 'dart:convert';



class MenuItemReport {
  static MenuItemReport menuItemReportFromJson(String str) => MenuItemReport.fromJson(json.decode(str));
  static String menuItemReportToJson(MenuItemReport data) => json.encode(data.toJson());
  MenuItemReport({
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
  dynamic anotherQuantityPerDay;
  List<double> pricePerDay;
  dynamic anotherPricePerDay;
  dynamic storeId;
  int productId;
  int productId2;
  var lastDays;
  dynamic startDate;
  dynamic endDate;
  var totalMenuItemSale;
  var totalMenuItemEarning;
  dynamic totalAnotherMenuItemEarning;
  dynamic totalAnotherMenuItemSale;

  factory MenuItemReport.fromJson(Map<String, dynamic> json) => MenuItemReport(
    quantityPerDay: json["quantityPerDay"] == null ? null : List<double>.from(json["quantityPerDay"].map((x) => x)),
    anotherQuantityPerDay: json["anotherQuantityPerDay"],
    pricePerDay: json["pricePerDay"] == null ? null : List<double>.from(json["pricePerDay"].map((x) => x)),
    anotherPricePerDay: json["anotherPricePerDay"],
    storeId: json["storeId"],
    productId: json["productId"] == null ? null : json["productId"],
    productId2: json["productId2"] == null ? null : json["productId2"],
    lastDays: json["lastDays"] == null ? null : json["lastDays"],
    startDate: json["startDate"],
    endDate: json["endDate"],
    totalMenuItemSale: json["totalMenuItemSale"] == null ? null : json["totalMenuItemSale"],
    totalMenuItemEarning: json["totalMenuItemEarning"] == null ? null : json["totalMenuItemEarning"],
    totalAnotherMenuItemEarning: json["totalAnotherMenuItemEarning"],
    totalAnotherMenuItemSale: json["totalAnotherMenuItemSale"],
  );

  Map<String, dynamic> toJson() => {
    "quantityPerDay": quantityPerDay == null ? null : List<dynamic>.from(quantityPerDay.map((x) => x)),
    "anotherQuantityPerDay": anotherQuantityPerDay,
    "pricePerDay": pricePerDay == null ? null : List<dynamic>.from(pricePerDay.map((x) => x)),
    "anotherPricePerDay": anotherPricePerDay,
    "storeId": storeId,
    "productId": productId == null ? null : productId,
    "productId2": productId2 == null ? null : productId2,
    "lastDays": lastDays == null ? null : lastDays,
    "startDate": startDate,
    "endDate": endDate,
    "totalMenuItemSale": totalMenuItemSale == null ? null : totalMenuItemSale,
    "totalMenuItemEarning": totalMenuItemEarning == null ? null : totalMenuItemEarning,
    "totalAnotherMenuItemEarning": totalAnotherMenuItemEarning,
    "totalAnotherMenuItemSale": totalAnotherMenuItemSale,
  };
}

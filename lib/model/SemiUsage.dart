// To parse this JSON data, do
//
//     final semiUsage = semiUsageFromJson(jsonString);

import 'dart:convert';


class SemiUsage {
 static SemiUsage semiUsageFromJson(String str) => SemiUsage.fromJson(json.decode(str));
 static String semiUsageToJson(SemiUsage data) => json.encode(data.toJson());

  SemiUsage({
    this.sales,
    this.quantityProduced,
  });

  dynamic sales;
  dynamic quantityProduced;

  factory SemiUsage.fromJson(Map<String, dynamic> json) => SemiUsage(
    sales: json["sales"] == null ? null : json["sales"],
    quantityProduced: json["quantityProduced"] == null ? null : json["quantityProduced"],
  );

  Map<String, dynamic> toJson() => {
    "sales": sales == null ? null : sales,
    "quantityProduced": quantityProduced == null ? null : quantityProduced,
  };
}

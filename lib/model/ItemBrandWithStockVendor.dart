
import 'dart:convert';

import 'ItemBrand.dart';
import 'StockRecovery.dart';
import 'StockVendors.dart';

  class ItemBrandWithStockVendor {
    static List<ItemBrandWithStockVendor> ItemBrandWithStockVendorListFromJson(String str) => List<ItemBrandWithStockVendor>.from(json.decode(str).map((x) => ItemBrandWithStockVendor.fromJson(x)));
    static String ItemBrandWithStockVendorListToJson(List<ItemBrandWithStockVendor> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
    static ItemBrandWithStockVendor ItemBrandWithStockVendorFromJson(String str) => ItemBrandWithStockVendor.fromJson(json.decode(str));
    static String ItemBrandWithStockVendorToJson(ItemBrandWithStockVendor data) => json.encode(data.toJson());
    static String updateItemBrandWithStockVendorToJson(ItemBrandWithStockVendor data) => json.encode(data.updateToJson());
    ItemBrandWithStockVendor({
    this.itemBrand,
    this.itemStockVendor,
    this.stockItem,
    this.id,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.itemBrandId,
    this.itemStockVendorId,
    this.stockItemId,
    });

    ItemBrand itemBrand;
    StockVendors itemStockVendor;
    StockItem stockItem;
    int id;
    int createdBy;
    DateTime createdOn;
    int updatedBy;
    DateTime updatedOn;
    bool isVisible;
    int itemBrandId;
    int itemStockVendorId;
    int stockItemId;

    factory ItemBrandWithStockVendor.fromJson(Map<String, dynamic> json) => ItemBrandWithStockVendor(
    itemBrand: json["itemBrand"] == null ? null : ItemBrand.fromJson(json["itemBrand"]),
    itemStockVendor: json["itemStockVendor"] == null ? null : StockVendors.fromJson(json["itemStockVendor"]),
    stockItem: json["stockItem"] == null ? null : StockItem.fromJson(json["stockItem"]),
    id: json["id"] == null ? null : json["id"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
    updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    itemBrandId: json["itemBrandId"] == null ? null : json["itemBrandId"],
    itemStockVendorId: json["itemStockVendorId"] == null ? null : json["itemStockVendorId"],
    stockItemId: json["stockItemId"] == null ? null : json["stockItemId"],
    );

    Map<String, dynamic> toJson() => {
    // "createdBy": createdBy == null ? null : createdBy,
    // "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    // "updatedBy": updatedBy == null ? null : updatedBy,
    // "updatedOn": updatedOn == null ? null : updatedOn.toIso8601String(),
    "isVisible": isVisible == null ? null : isVisible,
    "itemBrandId": itemBrandId == null ? null : itemBrandId,
    "itemStockVendorId": itemStockVendorId == null ? null : itemStockVendorId,
    "stockItemId": stockItemId == null ? null : stockItemId,
    };
    Map<String, dynamic> updateToJson() => {
      "id": id == null ? null : id,
     // "itemBrand": itemBrand == null ? null : itemBrand.toJson(),
     // "itemStockVendor": itemStockVendor,
     //  "stockItem": stockItem == null ? null : stockItem.toJson(),
     //  "createdBy": createdBy == null ? null : createdBy,
     //  "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
      // "updatedBy": updatedBy == null ? null : updatedBy,
      // "updatedOn": updatedOn == null ? null : updatedOn.toIso8601String(),
      //"isVisible": isVisible == null ? null : isVisible,
      "itemBrandId": itemBrandId == null ? null : itemBrandId,
      "itemStockVendorId": itemStockVendorId == null ? null : itemStockVendorId,
      "stockItemId": stockItemId == null ? null : stockItemId,
    };


  }

// To parse this JSON data, do
//
//     final productsInSemiFinish = productsInSemiFinishFromJson(jsonString);

import 'dart:convert';



class ProductsInSemiFinish {
 static List<ProductsInSemiFinish> productsInSemiFinishListFromJson(String str) => List<ProductsInSemiFinish>.from(json.decode(str).map((x) => ProductsInSemiFinish.fromJson(x)));
 static String productsInSemiFinishToJson(List<ProductsInSemiFinish> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  ProductsInSemiFinish({
    this.semiFinishedItem,
    this.product,
    this.size,
    this.id,
    this.quantity,
    this.unit,
    this.createdBy,
    this.createdOn,
    this.isVisible,
    this.semiFinishedItemsId,
    this.productId,
    this.sizeId,
  });

  dynamic semiFinishedItem;
  Product product;
  dynamic size;
  int id;
  double quantity;
  int unit;
  int createdBy;
  DateTime createdOn;
  bool isVisible;
  int semiFinishedItemsId;
  int productId;
  int sizeId;

  factory ProductsInSemiFinish.fromJson(Map<String, dynamic> json) => ProductsInSemiFinish(
    semiFinishedItem: json["semiFinishedItem"],
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    size: json["size"],
    id: json["id"] == null ? null : json["id"],
    quantity: json["quantity"] == null ? null : json["quantity"],
    unit: json["unit"] == null ? null : json["unit"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    semiFinishedItemsId: json["semiFinishedItemsId"] == null ? null : json["semiFinishedItemsId"],
    productId: json["productId"] == null ? null : json["productId"],
    sizeId: json["sizeId"] == null ? null : json["sizeId"],
  );

  Map<String, dynamic> toJson() => {
    "semiFinishedItem": semiFinishedItem,
    "product": product == null ? null : product.toJson(),
    "size": size,
    "id": id == null ? null : id,
    "quantity": quantity == null ? null : quantity,
    "unit": unit == null ? null : unit,
    "createdBy": createdBy == null ? null : createdBy,
    "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    "isVisible": isVisible == null ? null : isVisible,
    "semiFinishedItemsId": semiFinishedItemsId == null ? null : semiFinishedItemsId,
    "productId": productId == null ? null : productId,
    "sizeId": sizeId == null ? null : sizeId,
  };
}
class Product {

  Product({
    this.semifinishedItemsInProducts,
    this.id,
    this.name,
    this.description,
    this.image,
    this.createdBy,
    this.createdOn,
    this.isVisible,
    this.storeId,
    this.restaurantId,
    this.categoryId,
    this.subCategoryId,
  });

  List<ProductsInSemiFinish> semifinishedItemsInProducts;
  int id;
  String name;
  String description;
  String image;
  int createdBy;
  DateTime createdOn;
  bool isVisible;
  int storeId;
  dynamic restaurantId;
  int categoryId;
  int subCategoryId;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    semifinishedItemsInProducts: json["semifinishedItemsInProducts"] == null ? null : List<ProductsInSemiFinish>.from(json["semifinishedItemsInProducts"].map((x) => ProductsInSemiFinish.fromJson(x))),
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    description: json["description"] == null ? null : json["description"],
    image: json["image"] == null ? null : json["image"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"] == null ? null : json["storeId"],
    restaurantId: json["restaurantId"],
    categoryId: json["categoryId"] == null ? null : json["categoryId"],
    subCategoryId: json["subCategoryId"] == null ? null : json["subCategoryId"],
  );

  Map<String, dynamic> toJson() => {
    "semifinishedItemsInProducts": semifinishedItemsInProducts == null ? null : List<dynamic>.from(semifinishedItemsInProducts.map((x) => x.toJson())),
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "description": description == null ? null : description,
    "image": image == null ? null : image,
    "createdBy": createdBy == null ? null : createdBy,
    "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    "isVisible": isVisible == null ? null : isVisible,
    "storeId": storeId == null ? null : storeId,
    "restaurantId": restaurantId,
    "categoryId": categoryId == null ? null : categoryId,
    "subCategoryId": subCategoryId == null ? null : subCategoryId,
  };
}



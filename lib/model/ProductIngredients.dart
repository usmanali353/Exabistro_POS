import 'dart:convert';


class ProductIngredients {
  static List<ProductIngredients> productIngredientsListFromJson(String str) => List<ProductIngredients>.from(json.decode(str).map((x) => ProductIngredients.fromJson(x)));
  static String productIngredientsListToJson(List<ProductIngredients> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static ProductIngredients productIngredientsFromJson(String str) => ProductIngredients.fromJson(json.decode(str));
  static String productIngredientsToJson(ProductIngredients data) => json.encode(data.toJson());
  static String updateProductIngredientsToJson(ProductIngredients data) => json.encode(data.toMap());
  ProductIngredients({
    this.id,
    this.unit,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.storeId,
    this.quantity,
    this.stockItemId,
    this.categoryId,
    this.productId,
    this.sizeId
  });

  int quantity;
  int stockItemId;
  int id;
  int unit;
  int createdBy;
  DateTime createdOn;
  dynamic updatedBy;
  dynamic updatedOn;
  bool isVisible;
  int storeId;
  int categoryId;
  int productId;
  int sizeId;

  factory ProductIngredients.fromJson(Map<String, dynamic> json) => ProductIngredients(
    id: json["id"] == null ? null : json["id"],
    unit: json["unit"] == null ? null : json["unit"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"] == null ? null : json["storeId"],
    quantity:  json["quantity"] == null ? null : json["quantity"],
    categoryId: json["categoryId"] == null ? null : json["categoryId"],
    productId: json["productId"] == null ? null : json["productId"],
    stockItemId: json["stockItemId"] == null ? null : json["stockItemId"],
    sizeId: json["sizeId"] == null ? null : json["sizeId"],

  );

  Map<String, dynamic> toJson() => {
    "Unit": unit == null ? null : unit,
    "IsVisible": isVisible == null ? true : isVisible,
    "Quantity":quantity==null?null:quantity,
    "StoreId": storeId == null ? null : storeId,
    "CategoryId":categoryId==null?null:categoryId,
    "ProductId":productId==null?null:productId,
    "SizeId":sizeId==null?null:sizeId,
    "StockItemId":stockItemId==null?null:stockItemId
  };
  Map<String, dynamic> toMap() => {
    "id": id,
    "Unit": unit == null ? null : unit,
    "Quantity":quantity==null?null:quantity,
    "IsVisible": isVisible == null ? true : isVisible,
    "StoreId": storeId == null ? null : storeId,
    "CategoryId":categoryId==null?null:categoryId,
    "ProductId":productId==null?null:productId,
    "SizeId":sizeId==null?null:sizeId,
    "StockItemId":stockItemId==null?null:stockItemId
  };
}
class Ingredient {
  Ingredient({
    this.stockItemName,
    this.unit,
    this.quantity,
    this.sizeId,
  });

  String stockItemName;
  int unit;
  int quantity;
  int sizeId;

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    stockItemName: json["stockItemName"] == null ? null : json["stockItemName"],
    unit: json["unit"] == null ? null : json["unit"],
    quantity: json["quantity"] == null ? null : json["quantity"],
    sizeId: json["sizeId"] == null ? null : json["sizeId"],
  );

  Map<String, dynamic> toJson() => {
    "stockItemName": stockItemName == null ? null : stockItemName,
    "unit": unit == null ? null : unit,
    "quantity": quantity == null ? null : quantity,
    "sizeId": sizeId == null ? null : sizeId,
  };
}
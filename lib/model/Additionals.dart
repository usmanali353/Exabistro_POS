import 'dart:convert';
//
// class Additionals {
//   static List<Additionals> listAdditionalsFromJson(String str) => List<Additionals>.from(json.decode(str).map((x) => Additionals.fromJson(x)));
//   static String listAdditionalsToJson(List<Additionals> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//   static Additionals AdditionalsFromJson(String str) => Additionals.fromJson(json.decode(str));
//   static String AdditionalsToJson(Additionals data) => json.encode(data.toJson());
//   Additionals({
//     this.id,
//     this.name,
//     this.price,
//     this.createdBy,
//     this.updatedBy,
//     this.updatedOn,
//     this.isVisible,
//     this.categoryId,
//     this.stockItemId,
//     this.subCategoryId,
//   });
//
//   int id;
//   String name;
//   double price;
//   int createdBy;
//   dynamic updatedBy;
//   dynamic updatedOn;
//   bool isVisible;
//   int categoryId;
//   int stockItemId;
//   int subCategoryId;
//
//
//
//   factory Additionals.fromJson(Map<String, dynamic> json) => Additionals(
//     id: json["id"],
//     name: json["stockItemName"],
//     price: json["price"],
//     createdBy: json["createdBy"],
//     updatedBy: json["updatedBy"],
//     updatedOn: json["updatedOn"],
//     isVisible: json["isVisible"],
//     categoryId: json["categoryId"],
//     stockItemId: json["stockItemId"],
//     subCategoryId: json["subCategoryId"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "price": price,
//     "createdBy": createdBy,
//     "updatedBy": updatedBy,
//     "updatedOn": updatedOn,
//     "isVisible": isVisible,
//     "categoryId": categoryId,
//     "stockItemId": stockItemId,
//     "subCategoryId": subCategoryId,
//   };
// }
class Additionals {
  static List<Additionals> listAdditionalsFromJson(String str) => List<Additionals>.from(json.decode(str).map((x) => Additionals.fromJson(x)));
  static String listAdditionalsToJson(List<Additionals> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static Additionals AdditionalsFromJson(String str) => Additionals.fromJson(json.decode(str));
  static String AdditionalsToJson(Additionals data) => json.encode(data.toJson());

  Additionals({
    this.product,
    this.name,
    this.id,
    this.unit,
    this.quantity,
    this.price,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.storeId,
    this.store,
    this.categoryId,
    this.category,
    this.productId,
    this.sizeId,
    this.size,
    this.stockItemId,
    this.orderItemsToppings,
  });

  dynamic product;
  String name;
  int id;
  int unit;
  double quantity;
  double price;
  int createdBy;
  DateTime createdOn;
  dynamic updatedBy;
  dynamic updatedOn;
  bool isVisible;
  int storeId;
  dynamic store;
  int categoryId;
  dynamic category;
  int productId;
  int sizeId;
  dynamic size;
  int stockItemId;
  List<dynamic> orderItemsToppings;

  factory Additionals.fromJson(Map<String, dynamic> json) => Additionals(
    product: json["product"],
    name: json["stockItemName"] == null ? null : json["stockItemName"],
    id: json["id"] == null ? null : json["id"],
    unit: json["unit"] == null ? null : json["unit"],
    quantity: json["quantity"] == null ? null : json["quantity"],
    price: json["price"] == null ? null : json["price"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"] == null ? null : json["storeId"],
    store: json["store"],
    categoryId: json["categoryId"] == null ? null : json["categoryId"],
    category: json["category"],
    productId: json["productId"] == null ? null : json["productId"],
    sizeId: json["sizeId"] == null ? null : json["sizeId"],
    size: json["size"],
    stockItemId: json["stockItemId"] == null ? null : json["stockItemId"],
    orderItemsToppings: json["orderItemsToppings"] == null ? null : List<dynamic>.from(json["orderItemsToppings"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "product": product,
    "stockItemName": name == null ? null : name,
    "id": id == null ? null : id,
    "unit": unit == null ? null : unit,
    "quantity": quantity == null ? null : quantity,
    "price": price == null ? null : price,
    "createdBy": createdBy == null ? null : createdBy,
    "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedOn": updatedOn,
    "isVisible": isVisible == null ? null : isVisible,
    "storeId": storeId == null ? null : storeId,
    "store": store,
    "categoryId": categoryId == null ? null : categoryId,
    "category": category,
    "productId": productId == null ? null : productId,
    "sizeId": sizeId == null ? null : sizeId,
    "size": size,
    "stockItemId": stockItemId == null ? null : stockItemId,
    "orderItemsToppings": orderItemsToppings == null ? null : List<dynamic>.from(orderItemsToppings.map((x) => x)),
  };
}
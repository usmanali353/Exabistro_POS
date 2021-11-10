class Sizes {
  Sizes({
    this.id,
    this.name,
    this.price,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.categoryId,
    this.subCategoryId,
    this.storeId
  });

  final int id;
  final String name;
  final double price;
  final int createdBy;
  final DateTime createdOn;
  final dynamic updatedBy;
  final dynamic updatedOn;
  final bool isVisible;
  final int categoryId;
  final dynamic subCategoryId;
  final int storeId;



  factory Sizes.fromJson(Map<String, dynamic> json) => Sizes(
    id: json["id"],
    name: json["name"],
    price: json["price"].toDouble(),
    createdBy: json["createdBy"],
    createdOn: DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"],
    categoryId: json["categoryId"],
    subCategoryId: json["subCategoryId"],
    storeId: json["storeId"],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "createdBy": createdBy,
    "createdOn": createdOn.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedOn": updatedOn,
    "isVisible": isVisible,
    "categoryId": categoryId,
    "subCategoryId": subCategoryId,
    "StoreId":storeId
  };
}




// class Sizes {
//   Sizes({
//     this.id,
//     this.name,
//     this.price,
//     this.createdBy,
//     this.updatedBy,
//     this.updatedOn,
//     this.isVisible,
//     this.categoryId,
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
//   dynamic subCategoryId;
//
//   factory Sizes.fromJson(Map<String, dynamic> json) => Sizes(
//     id: json["id"],
//     name: json["name"],
//     price: json["price"].toDouble(),
//     createdBy: json["createdBy"],
//     updatedBy: json["updatedBy"],
//     updatedOn: json["updatedOn"],
//     isVisible: json["isVisible"],
//     categoryId: json["categoryId"],
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
//     "subCategoryId": subCategoryId,
//   };
// }
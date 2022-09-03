class BaseSections {
  BaseSections({
    this.id,
    this.name,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.productId,
  });

  final int id;
  final String name;
  final int createdBy;
  final DateTime createdOn;
  final dynamic updatedBy;
  final dynamic updatedOn;
  final bool isVisible;
  final int productId;

  factory BaseSections.fromJson(Map<String, dynamic> json) => BaseSections(
    id: json["id"],
    name: json["name"],
    createdBy: json["createdBy"],
    createdOn: DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"],
    productId: json["productId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "createdBy": createdBy,
    "createdOn": createdOn.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedOn": updatedOn,
    "isVisible": isVisible,
    "productId": productId,
  };
}

import 'dart:convert';



class ComplaintType {
  static List<ComplaintType> ListComplaintTypeFromJson(String str) => List<ComplaintType>.from(json.decode(str).map((x) => ComplaintType.fromJson(x)));
  static ComplaintType ComplaintTypeFromJson(String str) => ComplaintType.fromJson(json.decode(str));
  static String ComplaintTypeToJson(ComplaintType data) => json.encode(data.toJson());
  static String updateComplaintTypeToJson(ComplaintType data) => json.encode(data.toMap());

  ComplaintType({
    this.complaints,
    this.id,
    this.name,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.storeId,
  });

  dynamic complaints;
  int id;
  String name;
  int createdBy;
  DateTime createdOn;
  int updatedBy;
  DateTime updatedOn;
  bool isVisible;
  int storeId;

  factory ComplaintType.fromJson(Map<String, dynamic> json) => ComplaintType(
    complaints: json["complaints"],
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
    updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"] == null ? null : json["storeId"],
  );

  Map<String, dynamic> toJson() => {
    "name": name == null ? null : name,
    "StoreId": storeId == null ? null : storeId,
  };
  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name == null ? null : name,
    "StoreId": storeId == null ? null : storeId,
  };
}

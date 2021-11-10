// To parse this JSON data, do
//
//     final dropdown = dropdownFromJson(jsonString);

import 'dart:convert';


class Dropdown {
 static List<Dropdown> dropdownFromJson(String str) => List<Dropdown>.from(json.decode(str).map((x) => Dropdown.fromJson(x)));
  Dropdown({
    this.id,
    this.name,
  });

  int id;
  String name;

  factory Dropdown.fromJson(Map<String, dynamic> json) => Dropdown(
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "name": name == null ? null : name,
  };
}

import 'dart:convert';

class Orderitemstopping {
  static List<Orderitemstopping> listProductFromJson(String str) => List<Orderitemstopping>.from(json.decode(str).map((x) => Orderitemstopping.fromJson(x)));

  static String listProductToJson(List<Orderitemstopping> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static Orderitemstopping ProductFromJson(String str) => Orderitemstopping.fromJson(json.decode(str));

  static String ProductToJson(Orderitemstopping data) => json.encode(data.toJson());
  Orderitemstopping({
    this.name,
    this.price,
    this.quantity,
    this.totalprice,
    this.additionalitemid,
  });

  String name;
  double price;
  int quantity;
  double totalprice;
  int additionalitemid;

  factory Orderitemstopping.fromJson(Map<String, dynamic> json) => Orderitemstopping(
    name: json["name"],
    price: json["price"].toDouble(),
    quantity: json["quantity"],
    totalprice: json["totalprice"].toDouble(),
    additionalitemid: json["additionalitemid"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "quantity": quantity,
    "totalprice": totalprice,
    "additionalitemid": additionalitemid,
  };
}

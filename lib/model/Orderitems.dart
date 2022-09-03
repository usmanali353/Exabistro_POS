import 'dart:convert';

import 'orderItemTopping.dart';

// class Orderitem {
//   static List<Orderitem> listOrderitemFromJson(String str) => List<Orderitem>.from(json.decode(str).map((x) => Orderitem.fromJson(x)));
//
//   static String listOrderitemToJson(List<Orderitem> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//   static Orderitem OrderitemFromJson(String str) => Orderitem.fromJson(json.decode(str));
//
//   static String OrderitemToJson(Orderitem data) => json.encode(data.toJson());
//   Orderitem({
//     this.name,
//     this.price,
//     this.quantity,
//     this.totalprice,
//     this.havetopping,
//     this.IsDeal,
//     this.sizeid,
//     this.productid,
//     this.chair,
//     this.orderitemstoppings,
//   });
//
//   String name;
//   double price;
//   int quantity;
//   double totalprice;
//   bool havetopping,IsDeal;
//   int sizeid;
//   int productid;
//   int chair;
//   List<Orderitemstopping> orderitemstoppings;
//
//   factory Orderitem.fromJson(Map<String, dynamic> json) => Orderitem(
//     name: json["name"],
//     price: json["price"].toDouble(),
//     quantity: json["quantity"],
//     totalprice: json["totalprice"].toDouble(),
//     havetopping: json["havetopping"],
//     IsDeal:json["IsDeal"],
//     sizeid: json["sizeid"],
//     productid: json["productid"],
//       chair:json['chairId'],
//     orderitemstoppings: List<Orderitemstopping>.from(json["orderitemstoppings"].map((x) => Orderitemstopping.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "name": name,
//     "price": price,
//     "quantity": quantity,
//     "totalprice": totalprice,
//     "havetopping": havetopping,
//     "IsDeal":IsDeal,
//     "sizeid": sizeid,
//     "productid": productid,
//     "ChairId":chair,
//     "orderitemstoppings": List<dynamic>.from(orderitemstoppings.map((x) => x.toJson())),
//   };
// }


class Orderitem {
  static List<Orderitem> listOrderitemFromJson(String str) => List<Orderitem>.from(json.decode(str).map((x) => Orderitem.fromJson(x)));

  static String listOrderitemToJson(List<Orderitem> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static Orderitem OrderitemFromJson(String str) => Orderitem.fromJson(json.decode(str));

  static String OrderitemToJson(Orderitem data) => json.encode(data.toJson());
  Orderitem({
    this.sizeName,
    this.orderitemstoppings,
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.totalprice,
    this.salesType,
    this.havetopping,
    this.IsDeal,
    this.orderItemStatus,
    this.sizeid,
    this.orderId,
    this.productid,
    this.discountId,
    this.discount,
    this.dealId,
    this.discountedPrice,
    this.chair,
  });
  String name;
  double price;
  double quantity;
  double totalprice;
  bool havetopping,IsDeal;
  int sizeid;
  int productid;
  int chair;
  List<Orderitemstopping> orderitemstoppings;
  dynamic sizeName;
  int id;
  int salesType;
  int orderItemStatus;
  int orderId;
  dynamic discountId;
  dynamic discount;
  int dealId;
  double discountedPrice;

  factory Orderitem.fromJson(Map<String, dynamic> json) => Orderitem(
    sizeName: json["sizeName"],
    orderitemstoppings: json["orderItemsToppings"] == null ? null : List<dynamic>.from(json["orderItemsToppings"].map((x) => x)),
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    price: json["price"] == null ? null : json["price"],
    quantity: json["quantity"] == null ? null : json["quantity"],
    totalprice: json["totalPrice"] == null ? null : json["totalPrice"],
    salesType: json["salesType"] == null ? null : json["salesType"],
    havetopping: json["haveTopping"] == null ? null : json["haveTopping"],
    IsDeal: json["isDeal"] == null ? null : json["isDeal"],
    orderItemStatus: json["orderItemStatus"] == null ? null : json["orderItemStatus"],
    sizeid: json["sizeId"]==null?null:json["sizeId"],
    orderId: json["orderId"] == null ? null : json["orderId"],
    productid: json["productId"]==null?null:json["productId"],
    discountId: json["discountId"]==null?null:json["discountId"],
    discount: json["discount"]==null?null:json["discount"],
    dealId: json["dealId"] == null ? null : json["dealId"],
    discountedPrice: json["discountedPrice"] == null ? null : json["discountedPrice"],
    chair: json["chairId"]==null?null:json["chairId"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "quantity": quantity,
    "totalprice": totalprice,
    "havetopping": havetopping,
    "IsDeal":IsDeal==null?null:IsDeal,
    "sizeid": sizeid,
    "productid": productid,
    "dealid":dealId==null?null:dealId,
    "ChairId":chair==null?null:chair,
    "orderitemstoppings": orderitemstoppings==null?null:List<dynamic>.from(orderitemstoppings.map((x) => x.toJson())),
  };
  // Map<String, dynamic> toJson() => {
  //   "sizeName": sizeName,
  //   "orderItemsToppings": orderItemsToppings == null ? null : List<dynamic>.from(orderItemsToppings.map((x) => x)),
  //   "id": id == null ? null : id,
  //   "name": name == null ? null : name,
  //   "price": price == null ? null : price,
  //   "quantity": quantity == null ? null : quantity,
  //   "totalPrice": totalPrice == null ? null : totalPrice,
  //   "salesType": salesType == null ? null : salesType,
  //   "haveTopping": haveTopping == null ? null : haveTopping,
  //   "isDeal": isDeal == null ? null : isDeal,
  //   "orderItemStatus": orderItemStatus == null ? null : orderItemStatus,
  //   "sizeId": sizeId,
  //   "orderId": orderId == null ? null : orderId,
  //   "productId": productId,
  //   "discountId": discountId,
  //   "discount": discount,
  //   "dealId": dealId == null ? null : dealId,
  //   "discountedPrice": discountedPrice == null ? null : discountedPrice,
  //   "chairId": chairId,
  //   "chair": chair,
  // };
}
import 'dart:convert';



class Store {
 static List<Store> listStoreFromJson(String str) => List<Store>.from(json.decode(str).map((x) => Store.fromJson(x)));

 static String listStoreToJson(List<Store> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
 static Store StoreFromJson(String str) => Store.fromJson(json.decode(str));

 static String StoreToJson(Store data) => json.encode(data.toJson());
  Store({
    this.image,
    this.qrCodeImage,
    this.categories,
    this.products,
    this.stockItem,
    this.dailySessions,
    this.orders,
    this.discounts,
    this.tables,
    this.reservations,
    this.ordersFeedBack,
    this.productsFeedBacks,
    this.userRolesRestaurantStore,
    this.id,
    this.name,
    this.cellNo,
    this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.foodType,
    this.currencyCode,
    this.restaurantId,
    this.openTime,
    this.closeTime,
    this.delivery,
    this.dineIn,
    this.takeAway,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.merchantId,
    this.password,
    this.integritySalt,
    this.overallRating,
    this.allOrdersCount,
  });

  dynamic categories;
  dynamic products;
  dynamic stockItem;
  dynamic dailySessions;
  dynamic orders;
  dynamic discounts;
  dynamic tables;
  dynamic reservations;
  dynamic ordersFeedBack;
  dynamic productsFeedBacks;
  dynamic userRolesRestaurantStore;
  int id;
  String name;
  String cellNo;
  String city;
  String address;
  String latitude;
  String longitude;
  dynamic foodType;
  dynamic currencyCode;
  int restaurantId;
  dynamic openTime;
  dynamic closeTime;
  dynamic delivery;
  dynamic dineIn;
  dynamic takeAway;
  int createdBy;
  DateTime createdOn;
  dynamic updatedBy;
  dynamic updatedOn;
  bool isVisible;
  String image;
 dynamic qrCodeImage;
 String merchantId;
  String password;
  String integritySalt;
  double overallRating;
  double allOrdersCount;

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    image: json["restaurantImage"],
    categories: json["categories"],
    products: json["products"],
    stockItem: json["stockItem"],
    dailySessions: json["dailySessions"],
    orders: json["orders"],
    discounts: json["discounts"],
    tables: json["tables"],
    reservations: json["reservations"],
    ordersFeedBack: json["ordersFeedBack"],
    productsFeedBacks: json["productsFeedBacks"],
    userRolesRestaurantStore: json["userRolesRestaurantStore"],
    id: json["id"],
    name: json["name"],
    cellNo: json["cellNo"],
    city: json["city"],
    address: json["address"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    foodType: json["foodType"],
    currencyCode: json["currencyCode"],
    restaurantId: json["restaurantId"],
    openTime: json["openTime"],
    closeTime: json["closeTime"],
    delivery: json["delivery"],
    dineIn: json["dineIn"],
    takeAway: json["takeAway"],
    createdBy: json["createdBy"],
    createdOn: DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"],
    merchantId: json["merchantId"] == null ? null : json["merchantId"],
    password: json["password"] == null ? null : json["password"],
    integritySalt: json["integritySalt"] == null ? null : json["integritySalt"],
    qrCodeImage: json["qrCodeImage"],
    overallRating: json["overallRating"] == null ? null : json["overallRating"].toDouble(),
    allOrdersCount: json["allOrdersCount"] == null ? null : json["allOrdersCount"],
  );

  Map<String, dynamic> toJson() => {
    "categories": categories,
    "products": products,
    "stockItem": stockItem,
    "dailySessions": dailySessions,
    "orders": orders,
    "discounts": discounts,
    "tables": tables,
    "reservations": reservations,
    "ordersFeedBack": ordersFeedBack,
    "productsFeedBacks": productsFeedBacks,
    "userRolesRestaurantStore": userRolesRestaurantStore,
    "id": id,
    "Name": name,
    "CellNo": cellNo,
    "City": city,
    "Address": address,
    "Latitude": latitude,
    "Longitude": longitude,
    "FoodType": foodType,
    "CurrencyCode": currencyCode,
    "RestaurantId": restaurantId,
    "OpenTime": openTime,
    "CloseTime": closeTime,
    "Delivery": delivery,
    "DineIn": dineIn,
    "TakeAway": takeAway,
    "createdBy": createdBy,
    "createdOn": createdOn,//.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedOn": updatedOn,
    "isVisible": isVisible,
  };
}

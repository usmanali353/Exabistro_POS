// To parse this JSON data, do
//
//     final stockVendors = stockVendorsFromJson(jsonString);

import 'dart:convert';

class StockVendors {
  static List<StockVendors> stockVendorsListFromJson(String str) => List<StockVendors>.from(json.decode(str).map((x) => StockVendors.fromJson(x)));
  static String stockVendorsListToJson(List<StockVendors> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static StockVendors stockVendorsFromJson(String str) => StockVendors.fromJson(json.decode(str));
  static String stockVendorsToJson(StockVendors data) => json.encode(data.toJson());
  static String updateStockVendorsToJson(StockVendors data) => json.encode(data.updatetoJson());


  StockVendors({
    this.vendor,
    this.stockItems,
    this.id,
    this.productQuality,
    this.days,
    this.hours,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.vendorId,
    this.stockItemId,
    this.storeId
  });

  Vendor vendor;
  StockItemForVendor stockItems;
  int id;
  int productQuality;
  var days;
  dynamic hours;
  int createdBy;
  DateTime createdOn;
  dynamic updatedBy;
  dynamic updatedOn;
  bool isVisible;
  int vendorId;
  int stockItemId;
  int storeId;

  factory StockVendors.fromJson(Map<String, dynamic> json) => StockVendors(
    vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
    stockItems: json["stockItem"] == null ? null : StockItemForVendor.fromJson(json["stockItem"]),
    id: json["id"] == null ? null : json["id"],
    productQuality: json["productQuality"] == null ? null : json["productQuality"],
    days: json["days"] == null ? null : json["days"],
    hours: json["hours"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    vendorId: json["vendorId"] == null ? null : json["vendorId"],
    stockItemId: json["stockItemId"] == null ? null : json["stockItemId"],
    storeId: json["storeId"] == null ? null : json["storeId"],
  );

  Map<String, dynamic> toJson() => {
   // "id": id == null ? null : id,
    "productQuality": productQuality == null ? null : productQuality,
    "days": days == null ? null : days,
    "hours": hours,
    "createdBy": createdBy == null ? null : createdBy,
    "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedOn": updatedOn,
    "isVisible": isVisible == null ? null : isVisible,
    "vendorId": vendorId == null ? null : vendorId,
    "stockItemId": stockItemId == null ? null : stockItemId,
    "storeId": storeId == null ? null : storeId,

  };

  Map<String, dynamic> updatetoJson() => {
    "id": id == null ? null : id,
    "productQuality": productQuality == null ? null : productQuality,
    "days": days == null ? null : days,
    "hours": hours,
    "createdBy": createdBy == null ? null : createdBy,
    "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedOn": updatedOn,
    "isVisible": isVisible == null ? null : isVisible,
    "vendorId": vendorId == null ? null : vendorId,
    "stockItemId": stockItemId == null ? null : stockItemId,
    "storeId": storeId == null ? null : storeId,

  };
}
class StockItemForVendor {
  StockItemForVendor({
    this.store,
    this.restaurant,
    this.productIngredients,
    this.additionalItems,
    this.purchaseOrderItems,
    this.itemStockVendors,
    this.id,
    this.name,
    this.totalStockQty,
    this.totalPrice,
    this.unit,
    this.minQuantity,
    this.maxQuantity,
    this.isSauce,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.storeId,
    this.restaurantId,
  });

  dynamic store;
  dynamic restaurant;
  dynamic productIngredients;
  dynamic additionalItems;
  dynamic purchaseOrderItems;
  List<dynamic> itemStockVendors;
  int id;
  String name;
  double totalStockQty;
  double totalPrice;
  int unit;
  double minQuantity;
  double maxQuantity;
  bool isSauce;
  int createdBy;
  DateTime createdOn;
  dynamic updatedBy;
  dynamic updatedOn;
  bool isVisible;
  int storeId;
  dynamic restaurantId;

  factory StockItemForVendor.fromJson(Map<String, dynamic> json) => StockItemForVendor(
    store: json["store"],
    restaurant: json["restaurant"],
    productIngredients: json["productIngredients"],
    additionalItems: json["additionalItems"],
    purchaseOrderItems: json["purchaseOrderItems"],
    itemStockVendors: json["itemStockVendors"] == null ? null : List<dynamic>.from(json["itemStockVendors"].map((x) => x)),
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    totalStockQty: json["totalStockQty"] == null ? null : json["totalStockQty"],
    totalPrice: json["totalPrice"] == null ? null : json["totalPrice"],
    unit: json["unit"] == null ? null : json["unit"],
    minQuantity: json["minQuantity"] == null ? null : json["minQuantity"],
    maxQuantity: json["maxQuantity"] == null ? null : json["maxQuantity"],
    isSauce: json["isSauce"] == null ? null : json["isSauce"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"] == null ? null : json["storeId"],
    restaurantId: json["restaurantId"],
  );

  Map<String, dynamic> toJson() => {
    "store": store,
    "restaurant": restaurant,
    "productIngredients": productIngredients,
    "additionalItems": additionalItems,
    "purchaseOrderItems": purchaseOrderItems,
    "itemStockVendors": itemStockVendors == null ? null : List<dynamic>.from(itemStockVendors.map((x) => x)),
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "totalStockQty": totalStockQty == null ? null : totalStockQty,
    "totalPrice": totalPrice == null ? null : totalPrice,
    "unit": unit == null ? null : unit,
    "minQuantity": minQuantity == null ? null : minQuantity,
    "maxQuantity": maxQuantity == null ? null : maxQuantity,
    "isSauce": isSauce == null ? null : isSauce,
    "createdBy": createdBy == null ? null : createdBy,
    "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedOn": updatedOn,
    "isVisible": isVisible == null ? null : isVisible,
    "storeId": storeId == null ? null : storeId,
    "restaurantId": restaurantId,
  };
}

class Vendor {
  Vendor({
    this.address,
    this.driverOrder,
    this.formAccesses,
    this.stockItemDetails,
    this.orders,
    this.reservation,
    this.productsFeedBacks,
    this.storeFeedback,
    this.cutsomerOrdersFeedBack,
    this.driverOrdersFeedBack,
    this.userRolesRestaurantStore,
    this.complaints,
    this.voucherCustomers,
    this.usersHolidays,
    this.usersAttendance,
    this.itemStockVendors,
    this.id,
    this.userName,
    this.normalizedUserName,
    this.email,
    this.normalizedEmail,
    this.emailConfirmed,
    this.passwordHash,
    this.securityStamp,
    this.concurrencyStamp,
    this.phoneNumber,
    this.phoneNumberConfirmed,
    this.twoFactorEnabled,
    this.lockoutEnd,
    this.lockoutEnabled,
    this.accessFailedCount,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.cnic,
    this.cellNo,
    this.country,
    this.city,
    this.postCode,
    this.longitude,
    this.latitude,
    this.image,
    this.userStatusId,
    this.isAccountActive,
    this.dutyStartTime,
    this.dutyEndTime,
  });

  String address;
  dynamic driverOrder;
  dynamic formAccesses;
  dynamic stockItemDetails;
  dynamic orders;
  dynamic reservation;
  dynamic productsFeedBacks;
  dynamic storeFeedback;
  dynamic cutsomerOrdersFeedBack;
  dynamic driverOrdersFeedBack;
  dynamic userRolesRestaurantStore;
  dynamic complaints;
  dynamic voucherCustomers;
  dynamic usersHolidays;
  dynamic usersAttendance;
  List<dynamic> itemStockVendors;
  int id;
  String userName;
  String normalizedUserName;
  String email;
  String normalizedEmail;
  bool emailConfirmed;
  String passwordHash;
  String securityStamp;
  String concurrencyStamp;
  dynamic phoneNumber;
  bool phoneNumberConfirmed;
  bool twoFactorEnabled;
  dynamic lockoutEnd;
  bool lockoutEnabled;
  int accessFailedCount;
  String firstName;
  String lastName;
  DateTime dateOfBirth;
  int age;
  dynamic gender;
  dynamic cnic;
  String cellNo;
  String country;
  String city;
  String postCode;
  dynamic longitude;
  dynamic latitude;
  String image;
  int userStatusId;
  bool isAccountActive;
  DateTime dutyStartTime;
  DateTime dutyEndTime;

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    address: json["address"] == null ? null : json["address"],
    driverOrder: json["driverOrder"],
    formAccesses: json["formAccesses"],
    stockItemDetails: json["stockItemDetails"],
    orders: json["orders"],
    reservation: json["reservation"],
    productsFeedBacks: json["productsFeedBacks"],
    storeFeedback: json["storeFeedback"],
    cutsomerOrdersFeedBack: json["cutsomerOrdersFeedBack"],
    driverOrdersFeedBack: json["driverOrdersFeedBack"],
    userRolesRestaurantStore: json["userRolesRestaurantStore"],
    complaints: json["complaints"],
    voucherCustomers: json["voucherCustomers"],
    usersHolidays: json["usersHolidays"],
    usersAttendance: json["usersAttendance"],
    itemStockVendors: json["itemStockVendors"] == null ? null : List<dynamic>.from(json["itemStockVendors"].map((x) => x)),
    id: json["id"] == null ? null : json["id"],
    userName: json["userName"] == null ? null : json["userName"],
    normalizedUserName: json["normalizedUserName"] == null ? null : json["normalizedUserName"],
    email: json["email"] == null ? null : json["email"],
    normalizedEmail: json["normalizedEmail"] == null ? null : json["normalizedEmail"],
    emailConfirmed: json["emailConfirmed"] == null ? null : json["emailConfirmed"],
    passwordHash: json["passwordHash"] == null ? null : json["passwordHash"],
    securityStamp: json["securityStamp"] == null ? null : json["securityStamp"],
    concurrencyStamp: json["concurrencyStamp"] == null ? null : json["concurrencyStamp"],
    phoneNumber: json["phoneNumber"],
    phoneNumberConfirmed: json["phoneNumberConfirmed"] == null ? null : json["phoneNumberConfirmed"],
    twoFactorEnabled: json["twoFactorEnabled"] == null ? null : json["twoFactorEnabled"],
    lockoutEnd: json["lockoutEnd"],
    lockoutEnabled: json["lockoutEnabled"] == null ? null : json["lockoutEnabled"],
    accessFailedCount: json["accessFailedCount"] == null ? null : json["accessFailedCount"],
    firstName: json["firstName"] == null ? null : json["firstName"],
    lastName: json["lastName"] == null ? null : json["lastName"],
    dateOfBirth: json["dateOfBirth"] == null ? null : DateTime.parse(json["dateOfBirth"]),
    age: json["age"] == null ? null : json["age"],
    gender: json["gender"],
    cnic: json["cnic"],
    cellNo: json["cellNo"] == null ? null : json["cellNo"],
    country: json["country"] == null ? null : json["country"],
    city: json["city"] == null ? null : json["city"],
    postCode: json["postCode"] == null ? null : json["postCode"],
    longitude: json["longitude"],
    latitude: json["latitude"],
    image: json["image"] == null ? null : json["image"],
    userStatusId: json["userStatusId"] == null ? null : json["userStatusId"],
    isAccountActive: json["isAccountActive"] == null ? null : json["isAccountActive"],
    dutyStartTime: json["dutyStartTime"] == null ? null : DateTime.parse(json["dutyStartTime"]),
    dutyEndTime: json["dutyEndTime"] == null ? null : DateTime.parse(json["dutyEndTime"]),
  );

  Map<String, dynamic> toJson() => {
    "address": address == null ? null : address,
    "driverOrder": driverOrder,
    "formAccesses": formAccesses,
    "stockItemDetails": stockItemDetails,
    "orders": orders,
    "reservation": reservation,
    "productsFeedBacks": productsFeedBacks,
    "storeFeedback": storeFeedback,
    "cutsomerOrdersFeedBack": cutsomerOrdersFeedBack,
    "driverOrdersFeedBack": driverOrdersFeedBack,
    "userRolesRestaurantStore": userRolesRestaurantStore,
    "complaints": complaints,
    "voucherCustomers": voucherCustomers,
    "usersHolidays": usersHolidays,
    "usersAttendance": usersAttendance,
    "itemStockVendors": itemStockVendors == null ? null : List<dynamic>.from(itemStockVendors.map((x) => x)),
    "id": id == null ? null : id,
    "userName": userName == null ? null : userName,
    "normalizedUserName": normalizedUserName == null ? null : normalizedUserName,
    "email": email == null ? null : email,
    "normalizedEmail": normalizedEmail == null ? null : normalizedEmail,
    "emailConfirmed": emailConfirmed == null ? null : emailConfirmed,
    "passwordHash": passwordHash == null ? null : passwordHash,
    "securityStamp": securityStamp == null ? null : securityStamp,
    "concurrencyStamp": concurrencyStamp == null ? null : concurrencyStamp,
    "phoneNumber": phoneNumber,
    "phoneNumberConfirmed": phoneNumberConfirmed == null ? null : phoneNumberConfirmed,
    "twoFactorEnabled": twoFactorEnabled == null ? null : twoFactorEnabled,
    "lockoutEnd": lockoutEnd,
    "lockoutEnabled": lockoutEnabled == null ? null : lockoutEnabled,
    "accessFailedCount": accessFailedCount == null ? null : accessFailedCount,
    "firstName": firstName == null ? null : firstName,
    "lastName": lastName == null ? null : lastName,
    "dateOfBirth": dateOfBirth == null ? null : dateOfBirth.toIso8601String(),
    "age": age == null ? null : age,
    "gender": gender,
    "cnic": cnic,
    "cellNo": cellNo == null ? null : cellNo,
    "country": country == null ? null : country,
    "city": city == null ? null : city,
    "postCode": postCode == null ? null : postCode,
    "longitude": longitude,
    "latitude": latitude,
    "image": image == null ? null : image,
    "userStatusId": userStatusId == null ? null : userStatusId,
    "isAccountActive": isAccountActive == null ? null : isAccountActive,
    "dutyStartTime": dutyStartTime == null ? null : dutyStartTime.toIso8601String(),
    "dutyEndTime": dutyEndTime == null ? null : dutyEndTime.toIso8601String(),
  };
}

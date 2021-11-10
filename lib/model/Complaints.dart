// To parse this JSON data, do
//
//     final Complaint = ComplaintFromJson(jsonString);

import 'dart:convert';

class Complaint {
 static List<Complaint> ListComplaintFromJson(String str) => List<Complaint>.from(json.decode(str).map((x) => Complaint.fromJson(x)));
 static List<Complaint> customerListComplaintFromJson(String str) => List<Complaint>.from(json.decode(str).map((x) => Complaint.fromMap(x)));
 static Complaint ComplaintFromJson(String str) => Complaint.fromJson(json.decode(str));
 static String ComplaintToJson(Complaint data) => json.encode(data.toJson());
 static String updateComplaintToJson(Complaint data) => json.encode(data.toMap());

 Complaint({
    this.ComplainttType,
    this.customer,
    this.store,
    this.id,
    this.description,
    this.statusId,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.ComplaintTypeId,
    this.customerId,
    this.storeId,
   this.complainTypeName,
   this.storeName
  });

  dynamic ComplainttType;
 Customer customer;
  dynamic store;
 String complainTypeName;
 String storeName;
 int id;
  String description;
  int statusId;
  int createdBy;
  DateTime createdOn;
  int updatedBy;
  DateTime updatedOn;
  bool isVisible;
  int ComplaintTypeId;
  int customerId;
  int storeId;

  factory Complaint.fromJson(Map<String, dynamic> json) => Complaint(
    ComplainttType: json["ComplainttType"],
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    store: json["store"],
    id: json["id"] == null ? null : json["id"],
    description: json["description"] == null ? null : json["description"],
    statusId: json["statusId"] == null ? null : json["statusId"],
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
    updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    ComplaintTypeId: json["ComplainttTypeId"] == null ? null : json["ComplainttTypeId"],
    customerId: json["customerId"] == null ? null : json["customerId"],
    storeId: json["storeId"] == null ? null : json["storeId"],
  );
 factory Complaint.fromMap(Map<String, dynamic> json) => Complaint(
   storeName: json["storeName"] == null ? null : json["storeName"],
   complainTypeName: json["complainTypeName"] == null ? null : json["complainTypeName"],
   id: json["id"] == null ? null : json["id"],
   description: json["description"] == null ? null : json["description"],
   statusId: json["statusId"] == null ? null : json["statusId"],
   createdBy: json["createdBy"] == null ? null : json["createdBy"],
   createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
   updatedBy: json["updatedBy"],
   updatedOn: json["updatedOn"],
   isVisible: json["isVisible"] == null ? null : json["isVisible"],
   ComplaintTypeId: json["complaintTypeId"] == null ? null : json["complaintTypeId"],
   customerId: json["customerId"] == null ? null : json["customerId"],
   customer: json["customer"],
   storeId: json["storeId"] == null ? null : json["storeId"],
  // voucherCustomers: json["voucherCustomers"] == null ? null : List<dynamic>.from(json["voucherCustomers"].map((x) => x)),
 );
 Map<String, dynamic> toJson() => {
   "description": description == null ? null : description,
   "statusId": statusId == null ? null : statusId,
   "ComplaintTypeId": ComplaintTypeId == null ? null : ComplaintTypeId,
   "StoreId": storeId == null ? null : storeId,
   "CustomerId": customerId == null ? null : customerId,
 };
 Map<String, dynamic> toMap() => {
   "id":id,
   "description": description == null ? null : description,
   "statusId": statusId == null ? null : statusId,
   "ComplaintTypeId": ComplaintTypeId == null ? null : ComplaintTypeId,
   "StoreId": storeId == null ? null : storeId,
   "CustomerId": customerId == null ? null : customerId,
 };
}

class Customer {
  Customer({
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
    this.voucherCustomers,
    this.usersHolidays,
    this.usersAttendance,
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
  dynamic voucherCustomers;
  dynamic usersHolidays;
  dynamic usersAttendance;
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
  dynamic image;
  int userStatusId;
  bool isAccountActive;
  dynamic dutyStartTime;
  dynamic dutyEndTime;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
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
    voucherCustomers: json["voucherCustomers"],
    usersHolidays: json["usersHolidays"],
    usersAttendance: json["usersAttendance"],
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
    image: json["image"],
    userStatusId: json["userStatusId"] == null ? null : json["userStatusId"],
    isAccountActive: json["isAccountActive"] == null ? null : json["isAccountActive"],
    dutyStartTime: json["dutyStartTime"],
    dutyEndTime: json["dutyEndTime"],
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
    "voucherCustomers": voucherCustomers,
    "usersHolidays": usersHolidays,
    "usersAttendance": usersAttendance,
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
    "image": image,
    "userStatusId": userStatusId == null ? null : userStatusId,
    "isAccountActive": isAccountActive == null ? null : isAccountActive,
    "dutyStartTime": dutyStartTime,
    "dutyEndTime": dutyEndTime,
  };
}


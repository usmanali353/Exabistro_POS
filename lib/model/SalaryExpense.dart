import 'dart:convert';

import 'Vendors.dart';



class SalaryExpense {
 static List<SalaryExpense> salaryExpenseListFromJson(String str) => List<SalaryExpense>.from(json.decode(str).map((x) => SalaryExpense.fromJson(x)));
 static String salaryExpenseListToJson(List<SalaryExpense> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
  static SalaryExpense salaryExpenseFromJson(String str) => SalaryExpense.fromJson(json.decode(str));
  static String salaryExpenseToJson(SalaryExpense data) => json.encode(data.toJson());
 static String updateSalaryExpenseToJson(SalaryExpense data) => json.encode(data.updatetoJson());
  SalaryExpense({
    this.id,
    this.salaryAmount,
    this.workingHours,
    this.days,
    this.startDate,
    this.endDate,
    this.paymentDate,
    this.hoursWorked,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.userId,
    this.storesId,
    this.user,
    this.salaryPerHour
  });

  int id;
  double salaryAmount;
  double workingHours;
  int days;
  DateTime startDate;
  DateTime endDate;
  DateTime paymentDate;
  double hoursWorked;
  double salaryPerHour;
  int createdBy;
  DateTime createdOn;
  dynamic updatedBy;
  dynamic updatedOn;
  bool isVisible;
  int userId;
  int storesId;
  User user;

  factory SalaryExpense.fromJson(Map<String, dynamic> json) => SalaryExpense(
    id: json["id"] == null ? null : json["id"],
    salaryAmount: json["salaryAmount"] == null ? null : json["salaryAmount"],
    workingHours: json["workingHours"] == null ? null : json["workingHours"].toDouble(),
    days: json["days"] == null ? null : json["days"],
    startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
    endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
    paymentDate: json["paymentDate"] == null ? null : DateTime.parse(json["paymentDate"]),
    hoursWorked: json["hoursWorked"] == null ? null : json["hoursWorked"].toDouble(),
    salaryPerHour: json["salaryPerHour"] == null ? null : json["salaryPerHour"].toDouble(),
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    userId: json["userId"] == null ? null : json["userId"],
    storesId: json["storesId"] == null ? null : json["storesId"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    //"SalaryAmount": salaryAmount == null ? null : salaryAmount,
   // "WorkingHours": workingHours == null ? null : workingHours,
    "Days": days == null ? null : days,
    // "StartDate": startDate == null ? null : startDate.toIso8601String(),
    // "EndDate": endDate == null ? null : endDate.toIso8601String(),
    "PaymentDate": paymentDate == null ? null : paymentDate.toIso8601String(),
    //"HoursWorked": hoursWorked == null ? null : hoursWorked,
    "UserId": userId == null ? null : userId,
    "StoresId": storesId == null ? null : storesId,
    "IsVisible": isVisible==null?true:isVisible
  };
 Map<String, dynamic> updatetoJson() => {
   "Id":id,
 //  "SalaryAmount": salaryAmount == null ? null : salaryAmount,
//   "WorkingHours": workingHours == null ? null : workingHours,
   "Days": days == null ? null : days,
   // "StartDate": startDate == null ? null : startDate.toIso8601String(),
   // "EndDate": endDate == null ? null : endDate.toIso8601String(),
   "PaymentDate": paymentDate == null ? null : paymentDate.toIso8601String(),
 //  "HoursWorked": hoursWorked == null ? null : hoursWorked,
   "UserId": userId == null ? null : userId,
   "StoresId": storesId == null ? null : storesId,
   "IsVisible": isVisible==null?true:isVisible
 };
}

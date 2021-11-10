import 'dart:convert';

import 'Attendance.dart';



class EmployeeAttendance {
  static EmployeeAttendance employeeAttendanceFromJson(String str) => EmployeeAttendance.fromJson(json.decode(str));
  static String employeeAttendanceToJson(EmployeeAttendance data) => json.encode(data.toJson());
  EmployeeAttendance({
    this.userId,
    this.lastDays,
    this.attendances,
  });

  int userId;
  dynamic lastDays;
  List<Attendance> attendances;

  factory EmployeeAttendance.fromJson(Map<String, dynamic> json) => EmployeeAttendance(
    userId: json["userId"] == null ? null : json["userId"],
    lastDays: json["lastDays"],
    attendances: json["attendances"] == null ? null : List<Attendance>.from(json["attendances"].map((x) => Attendance.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "userId": userId == null ? null : userId,
    "lastDays": lastDays,
    "attendances": attendances == null ? null : List<dynamic>.from(attendances.map((x) => x.toJson())),
  };
}
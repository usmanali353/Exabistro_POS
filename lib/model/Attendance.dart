
import 'dart:convert';



class Attendance {

 static List<Attendance> listAttendanceFromJson(String str) => List<Attendance>.from(json.decode(str).map((x) => Attendance.fromJson(x)));
 static Attendance AttendanceFromJson(String str) => Attendance.fromJson(json.decode(str));
 static String AttendanceToJson(Attendance data) => json.encode(data.toJson());
 static String updateAttendanceToJson(Attendance data) => json.encode(data.toMap());

 Attendance({
   this.users,
   this.id,
   this.date,
   this.checkedIn,
   this.checkedOut,
   this.userId,
 });

 dynamic users;
 int id;
 DateTime date;
 String checkedIn;
 String checkedOut;
 int userId;

 factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
   users: json["users"],
   id: json["id"] == null ? null : json["id"],
   date: json["date"] == null ? null : DateTime.parse(json["date"]),
   checkedIn: json["checkedIn"] == null ? null : json["checkedIn"],
   checkedOut: json["checkedOut"] == null ? null : json["checkedOut"],
   userId: json["userId"] == null ? null : json["userId"],
 );
 Map<String, dynamic> toJson() => {
   "Date": date == null ? null : date.toIso8601String(),
   "CheckedIn": checkedIn == null ? null : checkedIn,
   "CheckedOut": checkedOut == null ? null : checkedOut,
   "UserId": userId == null ? null : userId,
 };
 Map<String, dynamic> toMap() => {
   "id":id,
   "Date": date == null ? null : date.toIso8601String(),
   "CheckedIn": checkedIn == null ? null : checkedIn,
   "CheckedOut": checkedOut == null ? null : checkedOut,
   "UserId": userId == null ? null : userId,
 };
}

import 'dart:convert';

import 'StockItems.dart';


class Notifications {
 static List<Notifications> notificationsListFromJson(String str) => List<Notifications>.from(json.decode(str).map((x) => Notifications.fromJson(x)));
 static Notifications notificationsFromJson(String str) => Notifications.fromJson(json.decode(str));
 static String notificationsToJson(Notifications data) => json.encode(data.toJson());
  Notifications({
    this.items,
    this.id,
    this.notificationTitle,
    this.notificationBody,
    this.isRead,
    this.createdOn,
    this.storeId,
  });

  List<StockItems> items;
  int id;
  String notificationTitle;
  String notificationBody;
  bool isRead;
  DateTime createdOn;
  int storeId;

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
    items: json["items"] == null ? null : List<StockItems>.from(json["items"].map((x) => StockItems.fromJsonForNotification(x))),
    id: json["id"] == null ? null : json["id"],
    notificationTitle: json["notificationTitle"] == null ? null : json["notificationTitle"],
    notificationBody: json["notificationBody"] == null ? null : json["notificationBody"],
    isRead: json["isRead"] == null ? null : json["isRead"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    storeId: json["storeId"] == null ? null : json["storeId"],
  );

  Map<String, dynamic> toJson() => {
    "items": items == null ? null : List<dynamic>.from(items.map((x) => x.toJson())),
    "id": id == null ? null : id,
    "notificationTitle": notificationTitle == null ? null : notificationTitle,
    "notificationBody": notificationBody == null ? null : notificationBody,
    "isRead": isRead == null ? null : isRead,
    "createdOn": createdOn == null ? null : createdOn.toIso8601String(),
    "storeId": storeId == null ? null : storeId,
  };
}
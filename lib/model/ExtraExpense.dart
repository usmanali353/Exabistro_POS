
import 'dart:convert';

class ExtraExpense {
 static List<ExtraExpense> extraExpenseListFromJson(String str) => List<ExtraExpense>.from(json.decode(str).map((x) => ExtraExpense.fromJson(x)));
 static String extraExpenseListToJson(List<ExtraExpense> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
 static ExtraExpense extraExpenseFromJson(String str) => ExtraExpense.fromJson(json.decode(str));
 static String extraExpenseToJson(ExtraExpense data) => json.encode(data.toJson());
 static String extraExpenseUpdateToJson(ExtraExpense data) => json.encode(data.updateToJson());

 ExtraExpense({
    this.id,
    this.expenseName,
    this.expenseAmount,
    this.expensesPaidDate,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isVisible,
    this.storeId,
  });

  int id;
  String expenseName;
  double expenseAmount;
  DateTime expensesPaidDate;
  int createdBy;
  DateTime createdOn;
  dynamic updatedBy;
  dynamic updatedOn;
  bool isVisible;
  int storeId;

  factory ExtraExpense.fromJson(Map<String, dynamic> json) => ExtraExpense(
    id: json["id"] == null ? null : json["id"],
    expenseName: json["expenseName"] == null ? null : json["expenseName"],
    expenseAmount: json["expenseAmount"] == null ? null : json["expenseAmount"],
    expensesPaidDate: json["expensesPaidDate"] == null ? null : DateTime.parse(json["expensesPaidDate"]),
    createdBy: json["createdBy"] == null ? null : json["createdBy"],
    createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    updatedBy: json["updatedBy"],
    updatedOn: json["updatedOn"],
    isVisible: json["isVisible"] == null ? null : json["isVisible"],
    storeId: json["storeId"] == null ? null : json["storeId"],
  );
 Map<String, dynamic> toJson() => {
   "ExpenseName": expenseName == null ? null : expenseName,
   "ExpenseAmount": expenseAmount == null ? null : expenseAmount,
   "ExpensesPaidDate": expensesPaidDate == null ? null : expensesPaidDate.toIso8601String(),
   "StoreId": storeId == null ? null : storeId,
   "isVisible": isVisible == null ? true : isVisible,
 };
 Map<String, dynamic> updateToJson() => {
   "Id":id == null ? null : id,
   "ExpenseName": expenseName == null ? null : expenseName,
   "ExpenseAmount": expenseAmount == null ? null : expenseAmount,
   "ExpensesPaidDate": expensesPaidDate == null ? null : expensesPaidDate.toIso8601String(),
   "StoreId": storeId == null ? null : storeId,
   "isVisible": isVisible == null ? true : isVisible,
 };
}

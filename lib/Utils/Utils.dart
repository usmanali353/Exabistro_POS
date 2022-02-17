import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:exabistro_pos/model/OrderById.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Utils{
   static String baseUrl(){
     return "http://173.212.235.106:8500/api/";
   }
   static Future<bool> check_connectivity () async{
     bool result = await InternetConnectionChecker().hasConnection;
     return result;
   }
   static Future<ConnectivityResult> check_connection() async {
     return await (Connectivity().checkConnectivity());
   }
   static bool validateStructure(String value){
     RegExp regExp = new RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^\w\s]).{6,}$');
     return regExp.hasMatch(value);
   }
   static bool validateEmail(String value){
     RegExp regExp=  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
     return regExp.hasMatch(value);
   }
   static Future addOfflineData(String key,String offlineData)async{
     APICacheDBModel cacheDBModel = new APICacheDBModel(
         key: key, syncData: offlineData);
     await APICacheManager().addCacheData(cacheDBModel);
   }

   static void deleteOfflineData(String key)async{
     await APICacheManager().deleteCache(key);
   }

   static Future<bool> checkOfflineDataExists(String key)async{
     return await APICacheManager().isAPICacheKeyExist(key);
   }

   static Future<APICacheDBModel> getOfflineData(String key)async{
     return await APICacheManager().getCacheData(key);
   }
   static dynamic myEncode(dynamic item){
     if(item is DateTime)
       return item.toIso8601String();
   }
   static void showSuccess(BuildContext context,String message){
     Flushbar(
       backgroundColor: Colors.green,
       duration: Duration(seconds: 3),
       message: message,
     ).show(context);

   }
   static void showError(BuildContext context,String message){
     Flushbar(
       backgroundColor: Colors.red,
       duration: Duration(seconds: 3),
       message: message,
     ).show(context);

   }
   static Map<String, dynamic> parseJwt(String token) {
     final parts = token.split('.');
     if (parts.length != 3) {
       throw Exception('invalid token');
     }

     final payload = _decodeBase64(parts[1]);
     final payloadMap = json.decode(payload);
     if (payloadMap is! Map<String, dynamic>) {
       throw Exception('invalid payload');
     }

     return payloadMap;
   }
   static String _decodeBase64(String str) {
     String output = str.replaceAll('-', '+').replaceAll('_', '/');

     switch (output.length % 4) {
       case 0:
         break;
       case 2:
         output += '==';
         break;
       case 3:
         output += '=';
         break;
       default:
         throw Exception('Illegal base64url string!"');
     }

     return utf8.decode(base64Url.decode(output));
   }
   static Future<bool> isLogin()async{
     bool res=true;
     SharedPreferences.getInstance().then((value) {
       var token = value.getString("token");
       if(token!=null){
         res = true;
       }
         });
     return res;
   }
   static Future<List<int>> printReceipt(PaperSize paper, CapabilityProfile profile,dynamic orderObj,dynamic storeObj,String tableName) async {
     final Generator ticket = Generator(paper, profile);
     List<int> bytes = [];
     List<OrderItem> orderitems=OrderItem.listOrderitemFromJson(jsonEncode(orderObj["orderItems"]));
     bytes+= ticket.text(
       storeObj["name"],
       styles: PosStyles(align: PosAlign.center,height: PosTextSize.size2,width: PosTextSize.size2,),
       //linesAfter: 1,
     );
     bytes+= ticket.text(
       storeObj["address"],
       styles: PosStyles(align: PosAlign.center,height: PosTextSize.size1,width: PosTextSize.size1,),
       //linesAfter: 1,
     );
     bytes+= ticket.text(
       storeObj["cellNo"],
       styles: PosStyles(align: PosAlign.center,height: PosTextSize.size1,width: PosTextSize.size1,),
       linesAfter: 1,
     );
     bytes+= ticket.row([
       PosColumn(text: 'Order#: ', width: 8,styles:PosStyles(bold: true,)),
       PosColumn(text: '${orderObj['id']}', width: 4,styles:PosStyles(bold: true)),
       // orderObj['orderType']==1?
       //   PosColumn(text: ' Table: ${orderObj['tableId'].toString()}', width: 4,styles:PosStyles(bold: true))
       // :orderObj["orderType'"]==2?
       //   PosColumn(text: ' P.Time: ${orderObj['pickingTime'].toString()}', width: 4,styles:PosStyles(bold: true)):
       // orderObj["orderType'"]==3?
       //   PosColumn(text: ' Est Time: ${orderObj['estimatedDeliveryTime'].toString()}', width: 4,styles:PosStyles(bold: true)):PosColumn(text:"Nothing",width: 4)
     ]);
     bytes+= ticket.row([
       PosColumn(text: 'Date: ', width: 8,styles:PosStyles(bold: true)),
       PosColumn(text: '${orderObj['createdOn'].toString().substring(0,10)}', width: 4),
     ]);
     bytes+= ticket.row([
       PosColumn(text: 'Order Type:', width: 8,styles:PosStyles(bold: true)),
       PosColumn(text: '${orderObj['orderType']==1?"Dine-In":orderObj['orderType']==2?"Takeaway":"Delivery"}', width: 4,styles:PosStyles(bold: true)),
     ]);
     if(orderObj['orderType']==1)
       bytes+= ticket.row([
         PosColumn(text: 'Table #:', width: 8,styles:PosStyles(bold: true)),
         PosColumn(text: '$tableName', width: 4,styles:PosStyles(bold: true)),
       ]);
     bytes+= ticket.row([
       PosColumn(text: 'Items Qty:', width: 8,styles:PosStyles(bold: true)),
       PosColumn(text: '${orderObj["orderItems"].length}', width: 4,styles:PosStyles(bold: true)),
     ]);

     bytes+= ticket.emptyLines(1);
     bytes+= ticket.hr();
     bytes+= ticket.row([
       PosColumn(text: 'Qty', width: 1,styles:PosStyles(bold: true)),
       PosColumn(text: ' Name/Size', width: 9,styles:PosStyles(bold: true)),
       PosColumn(text: 'Amt.', width: 2,styles:PosStyles(bold: true)),
     ]);
     bytes+= ticket.hr();
     for (var i = 0; i < orderitems.length; i++) {
       //total += orderitems[i].price;
       //bytes+= ticket.text(itemList[i]['name']);

       bytes+= ticket.row([
         PosColumn(text: '${orderitems[i].quantity.toStringAsFixed(0)}', width: 1,),
         PosColumn(text: ' ${orderitems[i].name.length>=16?orderitems[i].name.substring(0,16)+" "+"(${orderObj["orderItems"][i]["sizeName"].toString().substring(0,1)})":orderitems[i].name+" "+"(${orderObj["orderItems"][i]["sizeName"].toString().substring(0,1)})"}', width: 9,styles: PosStyles(align: PosAlign.left)),
         // PosColumn(text: '${ itemList[i]['price']} ', width: 2),
         PosColumn(text: '${ orderitems[i].totalPrice.toStringAsFixed(0)} ', width: 2),
       ]);
       // bytes+= ticket.text('Topping', styles:PosStyles(bold: true),);
       if(orderitems[i].haveTopping){
         for (var j = 0; j < orderitems[i].orderItemsToppings.length; j++) {
           //  total += itemList[i]['price'];
           bytes+= ticket.row([
             PosColumn(text: '-', width: 1, styles:PosStyles(bold: true)),
             PosColumn(text: 'x${orderitems[i].orderItemsToppings[j].quantity.toStringAsFixed(0)}', width: 2,),
             PosColumn(text: ' ${orderObj["orderItems"][i]["orderItemsToppings"][j]['additionalItem']['stockItemName']}', width: 5),
             PosColumn(text: ' ${ orderitems[i].orderItemsToppings[j].price} ', width: 4),
           ]);
         }
       }
     }
     bytes+= ticket.feed(1);
     bytes+= ticket.hr();
     bytes+= ticket.row([
       PosColumn(text: 'SubTotal', width: 10, styles: PosStyles(bold: true)),
       PosColumn(text: '${orderObj['netTotal']}', width: 2, styles: PosStyles(bold: true)),
     ]);
     bytes+= ticket.hr();
     for (var i = 0; i < orderObj["logicallyArrangedTaxes"].length; i++) {
       bytes+= ticket.row([
         PosColumn(text: ' ${orderObj["logicallyArrangedTaxes"][i]['taxName']}', width: 10),
         PosColumn(text: '${ orderObj["logicallyArrangedTaxes"][i]['amount']} ', width: 2),
       ]);
       // bytes+= ticket.row([
       //   PosColumn(text: '${"Olives\n Mashroom"}', width: 12),
       //   //PosColumn(text: '${ itemList[i]['price']} x ${itemList[i]['quantity']}', width: 4),
       //
       // ]);
     }
     bytes+= ticket.hr();

     bytes+= ticket.row([
       PosColumn(text: 'Total', width: 10, styles: PosStyles(bold: true)),
       PosColumn(text: '${orderObj["grossTotal"].toStringAsFixed(0)}', width: 2, styles: PosStyles(bold: true)),
     ]);
     bytes+= ticket.hr();
     bytes+= ticket.feed(2);
     bytes+= ticket.text('Thank You',styles: PosStyles(align: PosAlign.center, bold: true));
     bytes+= ticket.text('Scan to Visit Our Website',styles: PosStyles(align: PosAlign.center, bold: true));
     bytes+= ticket.emptyLines(1);
     bytes+= ticket.qrcode("http://dev.exabistro.com/#/StoreMenu/${storeObj["id"]}");

     bytes+= ticket.cut();
     //bytes+= ticket.drawer();
     return bytes;
   }
   static Future printReceiptByWifiPrinter(String printerIp, BuildContext ctx,dynamic storeObj,dynamic orderObj,String tableName) async {
     // TODO Don't forget to choose printer's paper size
     const PaperSize paper = PaperSize.mm58;
     final profile = await CapabilityProfile.load();
     final printer = NetworkPrinter(paper, profile);

     final PosPrintResult res = await printer.connect(printerIp, port: 9100);

     if (res == PosPrintResult.success) {
       // DEMO RECEIPT
       print("Printer Connected");
       List<OrderItem> orderitems=OrderItem.listOrderitemFromJson(jsonEncode(orderObj["orderItems"]));
       printer.text(
         storeObj["name"],
         styles: PosStyles(align: PosAlign.center,height: PosTextSize.size2,width: PosTextSize.size2,),
         //linesAfter: 1,
       );
       printer.text(
         storeObj["address"],
         styles: PosStyles(align: PosAlign.center,height: PosTextSize.size1,width: PosTextSize.size1,),
         //linesAfter: 1,
       );
       printer.text(
         storeObj["cellNo"],
         styles: PosStyles(align: PosAlign.center,height: PosTextSize.size1,width: PosTextSize.size1,),
         linesAfter: 1,
       );
       printer.row([
         PosColumn(text: 'Order#: ', width: 8,styles:PosStyles(bold: true,)),
         PosColumn(text: '${orderObj['id']}', width: 4,styles:PosStyles(bold: true)),
         // orderObj['orderType']==1?
         //   PosColumn(text: ' Table: ${orderObj['tableId'].toString()}', width: 4,styles:PosStyles(bold: true))
         // :orderObj["orderType'"]==2?
         //   PosColumn(text: ' P.Time: ${orderObj['pickingTime'].toString()}', width: 4,styles:PosStyles(bold: true)):
         // orderObj["orderType'"]==3?
         //   PosColumn(text: ' Est Time: ${orderObj['estimatedDeliveryTime'].toString()}', width: 4,styles:PosStyles(bold: true)):PosColumn(text:"Nothing",width: 4)
       ]);
       printer.row([
         PosColumn(text: 'Date: ', width: 8,styles:PosStyles(bold: true)),
         PosColumn(text: '${orderObj['createdOn'].toString().substring(0,10)}', width: 4),
       ]);
       printer.row([
         PosColumn(text: 'Order Type:', width: 8,styles:PosStyles(bold: true)),
         PosColumn(text: '${orderObj['orderType']==1?"Dine-In":orderObj['orderType']==2?"Takeaway":"Delivery"}', width: 4,styles:PosStyles(bold: true)),
       ]);
       if(orderObj['orderType']==1)
         printer.row([
           PosColumn(text: 'Table #:', width: 8,styles:PosStyles(bold: true)),
           PosColumn(text: '$tableName', width: 4,styles:PosStyles(bold: true)),
         ]);
       printer.row([
         PosColumn(text: 'Items Qty:', width: 8,styles:PosStyles(bold: true)),
         PosColumn(text: '${orderObj["orderItems"].length}', width: 4,styles:PosStyles(bold: true)),
       ]);

       printer.emptyLines(1);
       printer.hr();
       printer.row([
         PosColumn(text: 'Qty', width: 1,styles:PosStyles(bold: true)),
         PosColumn(text: ' Name/Size', width: 9,styles:PosStyles(bold: true)),
         PosColumn(text: 'Amt.', width: 2,styles:PosStyles(bold: true)),
       ]);
       printer.hr();
       for (var i = 0; i < orderitems.length; i++) {
         //total += orderitems[i].price;
         //printer.text(itemList[i]['name']);

         printer.row([
           PosColumn(text: '${orderitems[i].quantity.toStringAsFixed(0)}', width: 1,),
           PosColumn(text: ' ${orderitems[i].name.length>=16?orderitems[i].name.substring(0,16)+" "+"(${orderObj["orderItems"][i]["sizeName"].toString().substring(0,1)})":orderitems[i].name+" "+"(${orderObj["orderItems"][i]["sizeName"].toString().substring(0,1)})"}', width: 9,styles: PosStyles(align: PosAlign.left)),
           // PosColumn(text: '${ itemList[i]['price']} ', width: 2),
           PosColumn(text: '${ orderitems[i].totalPrice} ', width: 2),
         ]);
         // printer.text('Topping', styles:PosStyles(bold: true),);
         if(orderitems[i].haveTopping){
           for (var j = 0; j < orderitems[i].orderItemsToppings.length; j++) {
             //  total += itemList[i]['price'];
             printer.row([
               PosColumn(text: '-', width: 1, styles:PosStyles(bold: true)),
               PosColumn(text: 'x${orderitems[i].orderItemsToppings[j].quantity}', width: 2,),
               PosColumn(text: ' ${orderObj["orderItems"][i]["orderItemsToppings"][j]['additionalItem']['stockItemName']}', width: 5),
               PosColumn(text: ' ${ orderitems[i].orderItemsToppings[j].price} ', width: 4),
             ]);
           }
         }
       }
       printer.feed(1);
       printer.hr();
       printer.row([
         PosColumn(text: 'SubTotal', width: 10, styles: PosStyles(bold: true)),
         PosColumn(text: '${orderObj['netTotal']}', width: 2, styles: PosStyles(bold: true)),
       ]);
       printer.hr();
       for (var i = 0; i < orderObj["logicallyArrangedTaxes"].length; i++) {
         printer.row([
           PosColumn(text: ' ${orderObj["logicallyArrangedTaxes"][i]['taxName']}', width: 10),
           PosColumn(text: '${ orderObj["logicallyArrangedTaxes"][i]['amount']} ', width: 2),
         ]);
         // printer.row([
         //   PosColumn(text: '${"Olives\n Mashroom"}', width: 12),
         //   //PosColumn(text: '${ itemList[i]['price']} x ${itemList[i]['quantity']}', width: 4),
         //
         // ]);
       }
       printer.hr();

       printer.row([
         PosColumn(text: 'Total', width: 10, styles: PosStyles(bold: true)),
         PosColumn(text: '${orderObj["grossTotal"].toStringAsFixed(0)}', width: 2, styles: PosStyles(bold: true)),
       ]);
       printer.hr();
       printer.feed(2);
       printer.text('Thank You',styles: PosStyles(align: PosAlign.center, bold: true));
       printer.text('Scan to Visit Our Website',styles: PosStyles(align: PosAlign.center, bold: true));
       printer.emptyLines(1);
       printer.qrcode("http://dev.exabistro.com/#/StoreMenu/${storeObj["id"]}");

       printer.cut();
       //printer.drawer();

       // TEST PRINT
       // await testReceipt(printer);
       printer.disconnect();
     }

     final snackBar =
     SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
     Scaffold.of(ctx).showSnackBar(snackBar);
   }
   static Future printReceiptKitchenByWifiPrinter(String printerIp, BuildContext ctx,dynamic storeObj,dynamic orderObj,String tableName) async {
     // TODO Don't forget to choose printer's paper size
     const PaperSize paper = PaperSize.mm58;
     final profile = await CapabilityProfile.load();
     final printer = NetworkPrinter(paper, profile);

     final PosPrintResult res = await printer.connect(printerIp, port: 9100);

     if (res == PosPrintResult.success) {
       // DEMO RECEIPT
       print("Printer Connected");
       List<OrderItem> orderitems=OrderItem.listOrderitemFromJson(jsonEncode(orderObj["orderItems"]));
       printer.text(
         storeObj["name"],
         styles: PosStyles(align: PosAlign.center,height: PosTextSize.size2,width: PosTextSize.size2,),
         //linesAfter: 1,
       );
       printer.text(
         storeObj["address"],
         styles: PosStyles(align: PosAlign.center,height: PosTextSize.size1,width: PosTextSize.size1,),
         //linesAfter: 1,
       );
       printer.text(
         storeObj["cellNo"],
         styles: PosStyles(align: PosAlign.center,height: PosTextSize.size1,width: PosTextSize.size1,),
         linesAfter: 1,
       );
       printer.row([
         PosColumn(text: 'Order#: ', width: 8,styles:PosStyles(bold: true,)),
         PosColumn(text: '${orderObj['id']}', width: 4,styles:PosStyles(bold: true)),
         // orderObj['orderType']==1?
         //   PosColumn(text: ' Table: ${orderObj['tableId'].toString()}', width: 4,styles:PosStyles(bold: true))
         // :orderObj["orderType'"]==2?
         //   PosColumn(text: ' P.Time: ${orderObj['pickingTime'].toString()}', width: 4,styles:PosStyles(bold: true)):
         // orderObj["orderType'"]==3?
         //   PosColumn(text: ' Est Time: ${orderObj['estimatedDeliveryTime'].toString()}', width: 4,styles:PosStyles(bold: true)):PosColumn(text:"Nothing",width: 4)
       ]);
       printer.row([
         PosColumn(text: 'Date: ', width: 8,styles:PosStyles(bold: true)),
         PosColumn(text: '${orderObj['createdOn'].toString().substring(0,10)}', width: 4),
       ]);
       printer.row([
         PosColumn(text: 'Order Type:', width: 8,styles:PosStyles(bold: true)),
         PosColumn(text: '${orderObj['orderType']==1?"Dine-In":orderObj['orderType']==2?"Takeaway":"Delivery"}', width: 4,styles:PosStyles(bold: true)),
       ]);
       if(orderObj['orderType']==1)
         printer.row([
           PosColumn(text: 'Table #:', width: 8,styles:PosStyles(bold: true)),
           PosColumn(text: '$tableName', width: 4,styles:PosStyles(bold: true)),
         ]);
       printer.row([
         PosColumn(text: 'Items Qty:', width: 8,styles:PosStyles(bold: true)),
         PosColumn(text: '${orderObj["orderItems"].length}', width: 4,styles:PosStyles(bold: true)),
       ]);

       printer.emptyLines(1);
       printer.hr();
       printer.row([
         PosColumn(text: 'Qty', width: 1,styles:PosStyles(bold: true)),
         PosColumn(text: ' Name/Size', width: 11,styles:PosStyles(bold: true)),
       ]);
       printer.hr();
       for (var i = 0; i < orderitems.length; i++) {
         //total += orderitems[i].price;
         //printer.text(itemList[i]['name']);

         printer.row([
           PosColumn(text: '${orderitems[i].quantity}', width: 1,),
           PosColumn(text: '${orderitems[i].name.length>=16?orderitems[i].name+" "+"(${orderObj["orderItems"][i]["sizeName"].toString().substring(0,1)})":orderitems[i].name+" "+"(${orderObj["orderItems"][i]["sizeName"].toString().substring(0,1)})"}', width: 11,styles: PosStyles(align: PosAlign.left)),
           // PosColumn(text: '${ itemList[i]['price']} ', width: 2),
         ]);
         // printer.text('Topping', styles:PosStyles(bold: true),);
         if(orderitems[i].haveTopping){
           for (var j = 0; j < orderitems[i].orderItemsToppings.length; j++) {
             //  total += itemList[i]['price'];
             printer.row([
               PosColumn(text: '-', width: 1, styles:PosStyles(bold: true)),
               PosColumn(text: 'x${orderitems[i].orderItemsToppings[j].quantity}', width: 2,),
               PosColumn(text: ' ${orderObj["orderItems"][i]["orderItemsToppings"][j]['additionalItem']['stockItemName']}', width: 9),
             ]);
           }
         }
       }
       printer.cut();
       //printer.drawer();

       // TEST PRINT
       // await testReceipt(printer);
       printer.disconnect();
     }

     final snackBar =
     SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
     Scaffold.of(ctx).showSnackBar(snackBar);
   }
   static Future<List<int>> printReceiptKitchen(PaperSize paper, CapabilityProfile profile,dynamic orderObj,dynamic storeObj,String tableName) async {
     final Generator ticket = Generator(paper, profile);
     List<int> bytes = [];
     List<OrderItem> orderitems=OrderItem.listOrderitemFromJson(jsonEncode(orderObj["orderItems"]));
     bytes+= ticket.text(
       storeObj["name"],
       styles: PosStyles(align: PosAlign.center,height: PosTextSize.size2,width: PosTextSize.size2,),
       //linesAfter: 1,
     );
     bytes+= ticket.text(
       storeObj["address"],
       styles: PosStyles(align: PosAlign.center,height: PosTextSize.size1,width: PosTextSize.size1,),
       //linesAfter: 1,
     );
     bytes+= ticket.text(
       storeObj["cellNo"],
       styles: PosStyles(align: PosAlign.center,height: PosTextSize.size1,width: PosTextSize.size1,),
       linesAfter: 1,
     );
     bytes+= ticket.row([
       PosColumn(text: 'Order#: ', width: 8,styles:PosStyles(bold: true,)),
       PosColumn(text: '${orderObj['id']}', width: 4,styles:PosStyles(bold: true)),
       // orderObj['orderType']==1?
       //   PosColumn(text: ' Table: ${orderObj['tableId'].toString()}', width: 4,styles:PosStyles(bold: true))
       // :orderObj["orderType'"]==2?
       //   PosColumn(text: ' P.Time: ${orderObj['pickingTime'].toString()}', width: 4,styles:PosStyles(bold: true)):
       // orderObj["orderType'"]==3?
       //   PosColumn(text: ' Est Time: ${orderObj['estimatedDeliveryTime'].toString()}', width: 4,styles:PosStyles(bold: true)):PosColumn(text:"Nothing",width: 4)
     ]);
     bytes+= ticket.row([
       PosColumn(text: 'Date: ', width: 8,styles:PosStyles(bold: true)),
       PosColumn(text: '${orderObj['createdOn'].toString().substring(0,10)}', width: 4),
     ]);
     bytes+= ticket.row([
       PosColumn(text: 'Order Type:', width: 8,styles:PosStyles(bold: true)),
       PosColumn(text: '${orderObj['orderType']==1?"Dine-In":orderObj['orderType']==2?"Takeaway":"Delivery"}', width: 4,styles:PosStyles(bold: true)),
     ]);
     if(orderObj['orderType']==1)
       bytes+= ticket.row([
         PosColumn(text: 'Table #:', width: 8,styles:PosStyles(bold: true)),
         PosColumn(text: '$tableName', width: 4,styles:PosStyles(bold: true)),
       ]);
     bytes+= ticket.row([
       PosColumn(text: 'Items Qty:', width: 8,styles:PosStyles(bold: true)),
       PosColumn(text: '${orderObj["orderItems"].length}', width: 4,styles:PosStyles(bold: true)),
     ]);

     bytes+= ticket.emptyLines(1);
     bytes+= ticket.hr();
     bytes+= ticket.row([
       PosColumn(text: 'Qty', width: 1,styles:PosStyles(bold: true)),
       PosColumn(text: ' Name/Size', width: 11,styles:PosStyles(bold: true)),
     ]);
     bytes+= ticket.hr();
     for (var i = 0; i < orderitems.length; i++) {
       //total += orderitems[i].price;
       //bytes+= ticket.text(itemList[i]['name']);

       bytes+= ticket.row([
         PosColumn(text: '${orderitems[i].quantity}', width: 1,),
         PosColumn(text: ' ${orderitems[i].name.length>=16?orderitems[i].name.substring(0,16)+" "+"(${orderObj["orderItems"][i]["sizeName"].toString().substring(0,1)})":orderitems[i].name+" "+"(${orderObj["orderItems"][i]["sizeName"].toString().substring(0,1)})"}', width: 11,styles: PosStyles(align: PosAlign.left)),
         // PosColumn(text: '${ itemList[i]['price']} ', width: 2),
       ]);
       // bytes+= ticket.text('Topping', styles:PosStyles(bold: true),);
       if(orderitems[i].haveTopping){
         for (var j = 0; j < orderitems[i].orderItemsToppings.length; j++) {
           //  total += itemList[i]['price'];
           bytes+= ticket.row([
             PosColumn(text: '-', width: 1, styles:PosStyles(bold: true)),
             PosColumn(text: 'x${orderitems[i].orderItemsToppings[j].quantity}', width: 2,),
             PosColumn(text: ' ${orderObj["orderItems"][i]["orderItemsToppings"][j]['additionalItem']['stockItemName']}', width: 9),
           ]);
         }
       }
     }
     bytes+= ticket.feed(1);
     bytes+= ticket.hr();

     bytes+= ticket.cut();
     //bytes+= ticket.drawer();
     return bytes;
   }

  static Widget shiftReportDialog(BuildContext context,dynamic shiftData){
     return Scaffold(
       body: Center(
         child: Container(
           width: 400,
           height: 130,
           child: Card(
             elevation: 8,
             child: InkWell(
               child: Container(
                 width: MediaQuery.of(context).size.width,
                 //height: 50,
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(4),
                   //border: Border.all(color: Colors.orange, width: 1)
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Container(
                       width: MediaQuery.of(context).size.width,
                       height: 30,
                       decoration: BoxDecoration(
                         color: yellowColor,
                         borderRadius: BorderRadius.circular(4),
                         //border: Border.all(color: Colors.orange, width: 1)
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text(
                             'Session#: ',
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: 25,
                               fontWeight: FontWeight.w700,
                               //fontStyle: FontStyle.italic,
                             ),
                           ),
                           Text(
                             //'XXL',
                             shiftData['sessionNo']!=null?shiftData['sessionNo'].toString():"",
                             style: TextStyle(
                               color: blueColor,
                               fontSize: 25,
                               fontWeight: FontWeight.w700,
                               //fontStyle: FontStyle.italic,
                             ),
                           ),
                         ],
                       ),
                     ),
                     Padding(
                       padding: const EdgeInsets.only(left: 8,top: 2),
                       child: Row(
                         children: [
                           Text(
                             'Opening Balance: ',
                             style: TextStyle(
                               color: yellowColor,
                               fontSize: 17,
                               fontWeight: FontWeight.w700,
                               //fontStyle: FontStyle.italic,
                             ),
                           ),
                           Text(
                             //'XXL',
                             shiftData['openingBalance']!=null?shiftData['openingBalance'].toString():"",
                             style: TextStyle(
                               color: blueColor,
                               fontSize: 17,
                               fontWeight: FontWeight.w600,
                               //fontStyle: FontStyle.italic,
                             ),
                           ),
                         ],
                       ),
                     ),
                     Padding(
                       padding: const EdgeInsets.only(left: 8,top: 2),
                       child: Row(
                         children: [
                           Text(
                             'Closing Balance: ',
                             style: TextStyle(
                               color: yellowColor,
                               fontSize: 17,
                               fontWeight: FontWeight.w700,
                               //fontStyle: FontStyle.italic,
                             ),
                           ),
                           Text(
                             //'XXL',
                             shiftData['closingBalance']!=null?shiftData['closingBalance'].toString():"",
                             style: TextStyle(
                               color: blueColor,
                               fontSize: 17,
                               fontWeight: FontWeight.w600,
                               //fontStyle: FontStyle.italic,
                             ),
                           ),
                         ],
                       ),
                     ),
                     Padding(
                       padding: const EdgeInsets.only(top: 2,left: 8,bottom: 2),
                       child: Row(
                         children: [
                           Text(
                             'Time: ',
                             style: TextStyle(
                               color: yellowColor,
                               fontSize: 17,
                               fontWeight: FontWeight.w700,
                               //fontStyle: FontStyle.italic,
                             ),
                           ),
                           Text(
                             //'XXL',
                             shiftData['createdOn']!=null?shiftData['createdOn'].toString().substring(0,16):"",
                             style: TextStyle(
                               color: blueColor,
                               fontSize: 17,
                               fontWeight: FontWeight.w600,
                               //fontStyle: FontStyle.italic,
                             ),
                           ),
                         ],
                       ),
                     ),
                     Padding(
                       padding: const EdgeInsets.only(top: 2,left: 8),
                       child: Row(
                         children: [
                           Text(
                             'User: ',
                             style: TextStyle(
                               color: yellowColor,
                               fontSize: 17,
                               fontWeight: FontWeight.w700,
                               //fontStyle: FontStyle.italic,
                             ),
                           ),
                           Text(
                             //'XXL',
                             shiftData['userName']!=null?shiftData['userName'].toString():"",
                             style: TextStyle(
                               color: blueColor,
                               fontSize: 17,
                               fontWeight: FontWeight.w600,
                               //fontStyle: FontStyle.italic,
                             ),
                           ),
                         ],
                       ),
                     ),
                     SizedBox(height: 2,),
                   ],
                 ),
               ),
             ),
           ),
         ),
       ),
     );
   }

  static buildInvoice(dynamic order,var store,String customerName)async{
     List<List<dynamic>> tableData=[];
     List<String> topping=[],toppingUnitPrice=[],toppingTotalPrice=[],toppingQuantity=[];
     for(int i=0;i<order["orderItems"].length;i++){
       if(order["orderItems"][i]["isRefunded"]==null||order["orderItems"][i]["isRefunded"]==false){
         if(order["orderItems"][i]["orderItemsToppings"]!=null&&order["orderItems"][i]["orderItemsToppings"].length>0){
           for(int j=0;j<order["orderItems"][i]["orderItemsToppings"].length;j++){

             topping.add(order["orderItems"][i]["orderItemsToppings"][j]['additionalItem']['stockItemName']);
             toppingUnitPrice.add(order["orderItems"][i]["orderItemsToppings"][j]["price"].toStringAsFixed(0));
             toppingTotalPrice.add(order["orderItems"][i]["orderItemsToppings"][j]["totalPrice"].toStringAsFixed(0));
             toppingQuantity.add("x"+order["orderItems"][i]["orderItemsToppings"][j]["quantity"].toStringAsFixed(0));
           }
         }
         if(topping.length>0&&toppingTotalPrice.length>0&&toppingUnitPrice.length>0) {
           tableData.add([
             order["orderItems"][i]["name"]+" "+"(${order["orderItems"][i]["sizeName"]})"+"\n"+topping.toString(),
             order["orderItems"][i]["price"].toStringAsFixed(0)+"\n"+toppingUnitPrice.toString(),
             "x "+order["orderItems"][i]["quantity"].toStringAsFixed(0)+"\n"+toppingQuantity.toString(),
             order["orderItems"][i]["totalPrice"].toStringAsFixed(0)+"\n"+toppingTotalPrice.toString()
           ]);
         }
         else{
           tableData.add([
             order["orderItems"][i]["sizeName"]!=null?order["orderItems"][i]["name"]+" "+"(${order["orderItems"][i]["sizeName"]})" : order["orderItems"][i]["name"],
             order["orderItems"][i]["price"].toStringAsFixed(0),
             "x "+order["orderItems"][i]["quantity"].toStringAsFixed(0),
             order["orderItems"][i]["totalPrice"].toStringAsFixed(0)
           ]);
         }
       }

       toppingTotalPrice.clear();
       toppingUnitPrice.clear();
       topping.clear();
       toppingQuantity.clear();
     }
     final titles = <String>[
       'Order Number:',
       'Order Date:',
       'Order Type:',
       'Items Qty:'
     ];
     final data = <String>[
       order["id"].toString(),
       DateFormat.yMd().format(DateTime.now()).toString(),
       order["orderType"]==1?"Dine-In":order["orderType"]==2?"Take-Away":order["orderType"]==3?"Home Delivery":"None",
       order["orderItems"].length.toString(),
     ];

     final doc = pw.Document();
     doc.addPage(pw.MultiPage(
       maxPages: 2,
        pageFormat: PdfPageFormat.a4,
         header: (context){
           return pw.Column(
               crossAxisAlignment: pw.CrossAxisAlignment.start,
               children: [
                 pw.SizedBox(height: 1 * PdfPageFormat.cm),
                 pw.Row(
                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                     children: [
                       pw.Column(
                           crossAxisAlignment: pw.CrossAxisAlignment.start,
                           children: [
                             pw.Text(store["name"].toString(),style: pw.TextStyle(fontSize:20,fontWeight: pw.FontWeight.bold)),
                             pw.SizedBox(height: 1 * PdfPageFormat.mm),
                             pw.Text(store["address"].toString()),
                           ]
                       ),
                       pw.Container(
                           width: 50,
                           height:50,
                           child: pw.BarcodeWidget(
                               barcode: pw.Barcode.qrCode(),
                               data: "http://dev.exabistro.com/#/storeMenu/${store["id"]}"
                           )
                       )

                     ]
                 ),
                 pw.SizedBox(height: 1 * PdfPageFormat.cm),
                 pw.Row(
                     crossAxisAlignment: pw.CrossAxisAlignment.end,
                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                     children: [
                       pw.Column(
                           crossAxisAlignment: pw.CrossAxisAlignment.start,
                           children: [
                             pw.Text(order["visitingCustomer"]!=null?order["visitingCustomer"]:customerName.toString(),style: pw.TextStyle(fontSize: 18,fontWeight: pw.FontWeight.bold)),
                             pw.SizedBox(height: 1 * PdfPageFormat.mm),
                             pw.Text(order["customerContactNo"].toString()),
                           ]
                       ),
                       pw.Column(
                           crossAxisAlignment: pw.CrossAxisAlignment.start,
                           children: List.generate(titles.length, (index){
                             final title = titles[index];
                             final value = data[index];
                             return pw.Container(
                                 width: 200,
                                 child: pw.Row(
                                     children:[
                                       pw.Expanded(
                                           child: pw.Text(title,style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                       ),
                                       pw.Text(
                                           value,
                                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                       )
                                     ]

                                 )
                             );
                           })
                       ),
                     ]
                 ),
                 pw.SizedBox(height: 2 * PdfPageFormat.cm),
               ]
           );
         },
         footer: (context){
           return pw.Column(
               crossAxisAlignment: pw.CrossAxisAlignment.center,
               children: [
                 pw.Divider(),
                 pw.SizedBox(
                     height: 2 * PdfPageFormat.mm
                 ),
                 pw.Row(
                     mainAxisSize: pw.MainAxisSize.min,
                     crossAxisAlignment: pw.CrossAxisAlignment.end,
                     children: [
                       pw.Text("Address",style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                       pw.SizedBox(
                           width: 2 * PdfPageFormat.mm
                       ),
                       pw.Text(store["address"].toString())
                     ]
                 ),
                 pw.Row(
                     mainAxisSize: pw.MainAxisSize.min,
                     crossAxisAlignment: pw.CrossAxisAlignment.end,
                     children: [
                       pw.Text("Phone",style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                       pw.SizedBox(
                           width: 2 * PdfPageFormat.mm
                       ),
                       pw.Text(store["cellNo"].toString())
                     ]
                 ),
               ]
           );
         },
         build: (pw.Context context) {
           return[
             pw.Column(
               children: [
                 pw.Column(

                     crossAxisAlignment: pw.CrossAxisAlignment.start,
                     children: [
                       pw.Text(
                         "Invoice",
                         style: pw.TextStyle(fontSize: 24,fontWeight: pw.FontWeight.bold),
                       ),
                       pw.SizedBox(
                           height: 20
                       ),
                       pw.Container(
                         height: 305,
                         child:  pw.Table.fromTextArray(
                             headers: ["Name","Unit Price","Quantity","Total"],
                             data:tableData,
                             border: null,
                             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                             headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                             cellHeight: 30,
                             cellAlignments: {
                               0: pw.Alignment.centerLeft,
                               1: pw.Alignment.centerLeft,
                               2: pw.Alignment.centerLeft,
                               3: pw.Alignment.centerLeft
                             }
                         ),
                       ),
                       pw.Divider(),
                       pw.Container(
                           alignment: pw.Alignment.centerRight,
                           child: pw.Row(
                             children: [
                               pw.Spacer(flex: 6),
                               pw.Expanded(
                                 flex:4,
                                 child: pw.Column(
                                     crossAxisAlignment: pw.CrossAxisAlignment.start,
                                     children: [

                                       pw.Container(
                                           width: double.infinity,
                                           child: pw.Row(
                                               children: [
                                                 pw.Expanded(
                                                     child: pw.Text("SubTotal",style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                                 ),
                                                 pw.Text(
                                                     order["netTotal"].toStringAsFixed(0),
                                                     style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                                 )
                                               ]
                                           )
                                       ),
                                       for(int i=0;i<order["logicallyArrangedTaxes"].length;i++)
                                       pw.Container(
                                           width: double.infinity,
                                           child: pw.Row(
                                               children: [
                                                 pw.Expanded(
                                                     child: pw.Text(order["logicallyArrangedTaxes"][i]["taxName"],style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                                 ),
                                                 pw.Text(
                                                     order["logicallyArrangedTaxes"][i]["amount"].toStringAsFixed(0),
                                                     style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                                 )
                                               ]
                                           )
                                       ),
                                       pw.Divider(),
                                       pw.Container(
                                           width: double.infinity,
                                           child: pw.Row(
                                               children: [
                                                 pw.Expanded(
                                                     child: pw.Text("Total",style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                                 ),
                                                 pw.Text(
                                                     order["grossTotal"].toStringAsFixed(0),
                                                     style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                                 )
                                               ]
                                           )
                                       ),

                                       pw.SizedBox(
                                           height: 2 * PdfPageFormat.mm
                                       ),
                                       pw.Container(
                                           height:1,
                                           color: PdfColors.grey400
                                       ),
                                       pw.SizedBox(
                                           height: 0.5 * PdfPageFormat.mm
                                       ),
                                       pw.Container(
                                           height:1,
                                           color: PdfColors.grey400
                                       ),
                                     ]
                                 ),
                               )
                             ],
                           )
                       )
                     ]
                 )
               ],

             )];

         }

     ));
     await Printing.layoutPdf(
         onLayout: (PdfPageFormat format) async => doc.save());
   }
}
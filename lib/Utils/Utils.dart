import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:exabistro_pos/model/OrderById.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

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
         PosColumn(text: '${orderitems[i].quantity}', width: 1,),
         PosColumn(text: ' ${orderitems[i].name.length>=16?orderitems[i].name.substring(0,16)+" "+"(${orderObj["orderItems"][i]["sizeName"].toString().substring(0,1)})":orderitems[i].name+" "+"(${orderObj["orderItems"][i]["sizeName"].toString().substring(0,1)})"}', width: 9,styles: PosStyles(align: PosAlign.left)),
         // PosColumn(text: '${ itemList[i]['price']} ', width: 2),
         PosColumn(text: '${ orderitems[i].totalPrice} ', width: 2),
       ]);
       // bytes+= ticket.text('Topping', styles:PosStyles(bold: true),);
       if(orderitems[i].haveTopping){
         for (var j = 0; j < orderitems[i].orderItemsToppings.length; j++) {
           //  total += itemList[i]['price'];
           bytes+= ticket.row([
             PosColumn(text: '-', width: 1, styles:PosStyles(bold: true)),
             PosColumn(text: 'x${orderitems[i].orderItemsToppings[j].quantity}', width: 2,),
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
     for (var i = 0; i < orderObj['orderTaxes'].length; i++) {
       bytes+= ticket.row([
         PosColumn(text: ' ${orderObj['orderTaxes'][i]['taxName']}', width: 10),
         PosColumn(text: '${ orderObj['orderTaxes'][i]['amount']} ', width: 2),
       ]);
       // bytes+= ticket.row([
       //   PosColumn(text: '${"Olives\n Mashroom"}', width: 12),
       //   //PosColumn(text: '${ itemList[i]['price']} x ${itemList[i]['quantity']}', width: 4),
       //
       // ]);
     }
     if(orderObj["discountedPrice"]!=null&&orderObj["discountedPrice"]!=0.0)
       bytes+= ticket.row([
         PosColumn(text: ' ${"Discount"}', width: 10),
         PosColumn(text: '${orderObj["discountedPrice"].toStringAsFixed(1)} ', width: 2),
       ]);
     bytes+= ticket.hr();

     bytes+= ticket.row([
       PosColumn(text: 'Total', width: 10, styles: PosStyles(bold: true)),
       PosColumn(text: '${orderObj["discountedPrice"]!=null&&orderObj["discountedPrice"]!=0.0?(orderObj["grossTotal"]-orderObj["discountedPrice"]).toStringAsFixed(1):orderObj["grossTotal"].toStringAsFixed(1)}', width: 2, styles: PosStyles(bold: true)),
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
           PosColumn(text: '${orderitems[i].quantity}', width: 1,),
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
       for (var i = 0; i < orderObj['orderTaxes'].length; i++) {
         printer.row([
           PosColumn(text: ' ${orderObj['orderTaxes'][i]['taxName']}', width: 10),
           PosColumn(text: '${ orderObj['orderTaxes'][i]['amount']} ', width: 2),
         ]);
         // printer.row([
         //   PosColumn(text: '${"Olives\n Mashroom"}', width: 12),
         //   //PosColumn(text: '${ itemList[i]['price']} x ${itemList[i]['quantity']}', width: 4),
         //
         // ]);
       }
       if(orderObj["discountedPrice"]!=null&&orderObj["discountedPrice"]!=0.0)
         printer.row([
           PosColumn(text: ' ${"Discount"}', width: 10),
           PosColumn(text: '${orderObj["discountedPrice"].toStringAsFixed(1)} ', width: 2),
         ]);
       printer.hr();

       printer.row([
         PosColumn(text: 'Total', width: 10, styles: PosStyles(bold: true)),
         PosColumn(text: '${orderObj["discountedPrice"]!=null&&orderObj["discountedPrice"]!=0.0?(orderObj["grossTotal"]-orderObj["discountedPrice"]).toStringAsFixed(1):orderObj["grossTotal"].toStringAsFixed(1)}', width: 2, styles: PosStyles(bold: true)),
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
       printer.feed(1);
       printer.hr();
       // printer.row([
       //   PosColumn(text: 'SubTotal', width: 10, styles: PosStyles(bold: true)),
       //   PosColumn(text: '${orderObj['netTotal']}', width: 2, styles: PosStyles(bold: true)),
       // ]);
       // printer.hr();
       // for (var i = 0; i < orderObj['orderTaxes'].length; i++) {
       //   printer.row([
       //     PosColumn(text: ' ${orderObj['orderTaxes'][i]['taxName']}', width: 10),
       //     PosColumn(text: '${ orderObj['orderTaxes'][i]['amount']} ', width: 2),
       //   ]);
       //   // printer.row([
       //   //   PosColumn(text: '${"Olives\n Mashroom"}', width: 12),
       //   //   //PosColumn(text: '${ itemList[i]['price']} x ${itemList[i]['quantity']}', width: 4),
       //   //
       //   // ]);
       // }
       // if(orderObj["discountedPrice"]!=null&&orderObj["discountedPrice"]!=0.0)
       //   printer.row([
       //     PosColumn(text: ' ${"Discount"}', width: 10),
       //     PosColumn(text: '${orderObj["discountedPrice"].toStringAsFixed(1)} ', width: 2),
       //   ]);
       // printer.hr();
       //
       // printer.row([
       //   PosColumn(text: 'Total', width: 10, styles: PosStyles(bold: true)),
       //   PosColumn(text: '${orderObj["discountedPrice"]!=null&&orderObj["discountedPrice"]!=0.0?(orderObj["grossTotal"]-orderObj["discountedPrice"]).toStringAsFixed(1):orderObj["grossTotal"].toStringAsFixed(1)}', width: 2, styles: PosStyles(bold: true)),
       // ]);
       // printer.hr();
       // printer.feed(2);
       // printer.text('Thank You',styles: PosStyles(align: PosAlign.center, bold: true));
       // printer.text('Scan to Visit Our Website',styles: PosStyles(align: PosAlign.center, bold: true));
       // printer.emptyLines(1);
       // printer.qrcode("http://dev.exabistro.com/#/StoreMenu/${storeObj["id"]}");

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
}
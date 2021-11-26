import 'dart:convert';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils{
   static String baseUrl(){
     return "http://173.212.235.106:8500/api/";
   }
   static Future<bool> check_connectivity () async{
     bool result = await DataConnectionChecker().hasConnection;
     return result;
   }
   static bool validateStructure(String value){
     RegExp regExp = new RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^\w\s]).{6,}$');
     return regExp.hasMatch(value);
   }
   static bool validateEmail(String value){
     RegExp regExp=  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
     return regExp.hasMatch(value);
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
}
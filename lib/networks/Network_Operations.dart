import 'dart:convert';
import 'dart:developer';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:exabistro_pos/model/Additionals.dart';
import 'package:exabistro_pos/model/Products.dart';
import 'package:exabistro_pos/model/Stores.dart';
import 'package:exabistro_pos/model/Tax.dart';
import 'package:exabistro_pos/networks/sqlite_helper.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:http/http.dart' as http;
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/model/Categories.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/Mobile/RolesBaseStoreSelection.dart';
import '../Screens/RolesBaseStoreSelection.dart';
import '../model/ComplaintTypes.dart';
import '../model/Vendors.dart';

class Network_Operations{

  static Future signIn(BuildContext context,String email,String password,bool isTablet) async {
    var body=jsonEncode({"email":email,"password":password});
    try{
      List rolesAndStores =[],restaurantList=[];
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("response"+email);
      var isPassExist = await APICacheManager().isAPICacheKeyExist("password"+email);

       var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist && isPassExist) {
          var cacheData = await APICacheManager().getCacheData("response"+email);
          var passData = await APICacheManager().getCacheData("password"+email);
          List decoded = jsonDecode(cacheData.syncData)['roles'];
          rolesAndStores.clear();
          restaurantList.clear();
          for(int i=0;i<decoded.length;i++){
            rolesAndStores.add(decoded[i]);
            restaurantList.add(decoded[i]['restaurant']);
          }
          var claims = Utils.parseJwt(jsonDecode(cacheData.syncData)['token']);
          if(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")).isBefore(DateTime.now())){
            Utils.showError(context, translate("error_messages.token_expire_please_login_again"),);
            return false;
          }else {
            if (passData.syncData == password) {

              SharedPreferences.getInstance().then((prefs) {
                prefs.setString("token", jsonDecode(cacheData.syncData)['token']);
                prefs.setString("email", email);
                prefs.setString('userId', claims['nameid']);
                prefs.setString('nameid', claims['nameid']);
                prefs.setString("name", claims['unique_name']);
                prefs.setString('password', password);
                prefs.setString("roles", jsonEncode(decoded));
                prefs.setString("discountService",jsonDecode(cacheData.syncData)["user"]["discountService"].toString());
                prefs.setString("waiveOffService", jsonDecode(cacheData.syncData)["user"]["waiveOffService"].toString());
              });
              Utils.showSuccess(context, translate("error_messages.login_successful"));
              if(isTablet){
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) =>
                        RoleBaseStoreSelection(rolesAndStores)), (
                        Route<dynamic> route) => false);
              }else{
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) =>
                        RoleBaseStoreSelectionForMobile(rolesAndStores)), (
                        Route<dynamic> route) => false);
              }

                  return true;
            }else{
              Utils.showError(context, translate("error_messages.your_password_is_incorrect"));
              return false;
            }
          }

        }else{
          Utils.showError(context, translate("error_messages.not_connected_to_internet"));
          return false;
        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi) {
        //pd.show();
        var response=await http.post(Uri.parse(Utils.baseUrl()+"account/login"),body:body,headers: {"Content-type":"application/json"});
        if(response!=null&&response.statusCode==200){
          List decoded = jsonDecode(response.body)['roles'];
          rolesAndStores.clear();
          restaurantList.clear();
          for(int i=0;i<decoded.length;i++){
            rolesAndStores.add(decoded[i]);
            restaurantList.add(decoded[i]['restaurant']);
          }
          print(rolesAndStores);
          if(decoded[0]["roleId"]==6||decoded[0]["roleId"]==5||decoded[0]["roleId"]==11){
            var claims = Utils.parseJwt(jsonDecode(response.body)['token']);
            SharedPreferences.getInstance().then((prefs){
              prefs.setString("token", jsonDecode(response.body)['token']);
              prefs.setString("email", email);
              prefs.setString('userId', claims['nameid']);
              prefs.setString('nameid', claims['nameid']);
              prefs.setString("name", claims['unique_name']);
              prefs.setString('password', password);
              prefs.setString("roles", jsonEncode(decoded));
              prefs.setString("discountService",jsonDecode(response.body)["user"]["discountService"].toString());
              prefs.setString("waiveOffService", jsonDecode(response.body)["user"]["waiveOffService"].toString());
              // prefs.setString('isCustomer', claims['IsCustomerOnly']);
            });
            Utils.showSuccess(context, translate("error_messages.login_successful"));

            APICacheDBModel cacheDBModel = new APICacheDBModel(
                key: "response"+email, syncData: response.body);
            await APICacheManager().addCacheData(cacheDBModel);
            APICacheDBModel cacheDBModel1 = new APICacheDBModel(
                key: "password"+email, syncData: password);
            await APICacheManager().addCacheData(cacheDBModel1);
            if(isTablet){
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) =>
                      RoleBaseStoreSelection(rolesAndStores)), (
                      Route<dynamic> route) => false);
            }else{
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) =>
                      RoleBaseStoreSelectionForMobile(rolesAndStores)), (
                      Route<dynamic> route) => false);
            }
          }else {
            Utils.showError(context, translate("error_messages.this_app_is_only_for_employees"));
          }
        }
        else{
          if(response.body!=null&&response.body.isNotEmpty){
            Utils.log("LoginApi",{"status":response.statusCode,"error_msg":response.body});
          }else{
            Utils.log("LoginApi","LoginApi is throwing "+response.statusCode.toString());
          }
          Utils.showError(context, "${response.body}");
          return false;
        }
      }
    }catch(e) {

      print(e);
      Utils.showError(context, translate("error_messages.please_enter_valid_email_address"));
    }
  }
  static Future<dynamic> getRoles(BuildContext context)async{
    try{
      var response=await http.get(Uri.parse(Utils.baseUrl()+"Account/GetAllRolesExceptSuperAdmin"),);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        return data;
      }
      else{
        Utils.showError(context, response.statusCode.toString());
        return null;
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.error_found"));
    }
    return null;
  }
  static Future<List<Products>> getProduct(BuildContext context,int categoryId,int storeId,String search)async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("productList"+categoryId.toString());
       var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("productList"+categoryId.toString());
          print(cacheData.syncData);
          var data= jsonDecode(cacheData.syncData);
          List<Products> list=List();
          list.clear();
          for(int i=0;i<data.length;i++){
            list.add(Products(name: data[i]['name'],id: data[i]['id'],image: data[i]['image'],
                subCategoryId: data[i]['subCategoryId'],isVisible: data[i]['isVisible'],orderCount: data[i]['orderCount'],totalQuantityOrdered: data[i]['totalQuantityOrdered'],
                description: data[i]['description'],storeId: data[i]['storeId'],categoryId: data[i]['categoryId'],productSizes: data[i]['productSizes'],isVeg:data[i]["isVeg"],allergic_description:data[i]["allergic_description"]));
          }
          return list;
        }else{
          Utils.showError(context, translate("error_messages.no_offline_data"));
        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
        var response=await http.get(Uri.parse(Utils.baseUrl()+"Products/GetByCategoryId?StoreId=$storeId&categoryId="+categoryId.toString()+"&searchstring=$search"),);
        APICacheDBModel cacheDBModel = new APICacheDBModel(
            key: "productList"+categoryId.toString(), syncData: response.body);
        await APICacheManager().addCacheData(cacheDBModel);

        var data= jsonDecode(response.body);
        if(response.statusCode==200){
          log(response.body.toString());
          if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
            List<Products> list=List();
            list.clear();
            for(int i=0;i<data.length;i++){
              list.add(Products(name: data[i]['name'],id: data[i]['id'],image: data[i]['image'],
                  subCategoryId: data[i]['subCategoryId'],isVisible: data[i]['isVisible'],orderCount: data[i]['orderCount'],totalQuantityOrdered: data[i]['totalQuantityOrdered'],
                  description: data[i]['description'],storeId: data[i]['storeId'],categoryId: data[i]['categoryId'],productSizes: data[i]['productSizes'],isVeg:data[i]["isVeg"],allergic_description:data[i]["allergic_description"]));
            }
            return list;
          }
        }
        else{
          Utils.showError(context, response.body);
        }
      } else{
        Utils.showError(context, translate("error_messages.you_are_in_offline_mode"));
      }
    }catch(e){

    }
    return null;
  }
  static Future<dynamic> getAllOrdersWithItemsByOrderStatusId(BuildContext context,String token,int orderStatusId,int storeId)async{
    try{
      List list=[];
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Uri.parse(Utils.baseUrl()+"orders/getallbasicorderswithitems/"+orderStatusId.toString()+"?StoreId="+storeId.toString()),headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        if(data!=[])
          list=List.from(data.reversed);
        return list;
      }
      // else if(response.statusCode == 401){
      //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      // }
      else{
        Utils.showError(context, translate("error_messages.please_try_again"));
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.unable_to_fetch_orders"));
    }
    return null;
  }

  static Future<List<dynamic>> getTableList(BuildContext context,String token,int storeId)async{
   // ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);
    try{
      // pd.show();
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("tableList"+storeId.toString());
       var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist) {
          List list=[];
          var cacheData = await APICacheManager().getCacheData("tableList"+storeId.toString());
          print("cache hit");
          var data= jsonDecode(cacheData.syncData);
          if(data!=[])
            list=List.from(data.reversed);
          return list;
        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
        var response=await http.get(Uri.parse(Utils.baseUrl()+"tables/GetAll/?storeId=$storeId"),headers: headers);
        var data= jsonDecode(response.body);
        if(response.statusCode==200){
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "tableList", syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          List list =[];
          //pd.hide();
          for(int i=0;i<data.length;i++){
            if(data[i]['isVisible'] == true){
              list.add(data[i]);
            }
          }
          return list;
      }

      }
      else{

       // pd.hide();
        Utils.showError(context, translate("error_messages.please_try_again"));
        return null;
      }
    }catch(e){
     // pd.hide();
      Utils.showError(context, translate("error_messages.unable_to_fetch_tables"));
    }
    return null;
  }
  static Future<List<Categories>> getCategory (BuildContext context, String token,int storeId,String search) async {
    try{
      Map<String, String> headers = {'Authorization':'Bearer '+token, 'Content-Type':'application/json'};
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("categoryList");
       var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("categoryList");
          print("cache hit");
          return Categories.listCategoriesFromJson(cacheData.syncData);
        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
        final response = await http.get(Uri.parse(Utils.baseUrl() +
            'Categories/GetAll?StoreId=$storeId&ShowByTime=0&searchstring=$search'),
          headers: headers,);
        if (response.statusCode == 200) {
          if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi) {
            APICacheDBModel cacheDBModel = new APICacheDBModel(
                key: "categoryList", syncData: response.body);
            await APICacheManager().addCacheData(cacheDBModel);

            //List<Categories> category_list = [];
            return Categories.listCategoriesFromJson(response.body);
            // for(int i=0; i<jsonDecode(response.body).length; i++){
            //   category_list.add(Categories.fromJson(jsonDecode(response.body)[i]));
            // }
            // return category_list;
          }
        } else {
          if(response.body!=null&&response.body.isNotEmpty){
            Utils.log("getCategoryApi",{"status":response.statusCode,"error_msg":response.body});
          }else{
            Utils.log("getCategoryApi","getCategoryApi is throwing "+response.statusCode.toString());
          }
          Utils.showError(context, translate("error_messages.please_try_again"));
        }
      }
      else{
        Utils.showError(context, translate("error_messages.you_are_in_offline_mode"));
      }
    }
    catch(e){
      //Utils.showError(context, e.toString());
    }
    return null;
  }

  static Future<List<dynamic>> getAllDeals(BuildContext context,String token,int storeId,{String startingPrice,String endingPrice,String search,DateTime startDate,DateTime endDate})async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("dealList");
       var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("dealList");
          return jsonDecode(cacheData.syncData);

        }else{
          Utils.showError(context, translate("error_messages.no_offline_data"));
        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
        var response;
        Map<String,String> headers = {'Authorization':'Bearer '+token};
        //  response=await http.get(Utils.baseUrl()+"deals/GetAll?storeId=$storeId&searchstring=$search",headers: headers);
        if(startDate ==null && endDate==null && startingPrice==null && endingPrice==null && search==null)
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAllActive?storeId=$storeId"),headers: headers);
        else if(startDate ==null && endDate==null && startingPrice==null && endingPrice==null)
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAllActive?storeId=$storeId&searchstring=$search"),headers: headers);
        else if(startDate !=null && endDate!=null)
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAllActive?storeId=$storeId&startingDate=$startDate&EndingDate=$endDate"),headers: headers);
        else if(startingPrice !=null && endingPrice!=null)
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAllActive?storeId=$storeId&startingPrice=$startingPrice&endingPrice=$endingPrice"),headers: headers);
        else if(startDate !=null && endDate!=null && startingPrice!=null && endingPrice!=null)
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAllActive?storeId=$storeId&startingPrice=$startingPrice&endingPrice=$endingPrice&startingDate=$startDate&EndingDate=$endDate"),headers: headers);
        else
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAllActive?storeId=$storeId"),headers: headers);
        var data= jsonDecode(response.body);
        print(data);
        if(response.statusCode==200){
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "dealList", syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          return data;
        }
        else{
          if(response.body!=null&&response.body.isNotEmpty){
            Utils.log("getAllDealsApi",{"status":response.statusCode,"error_msg":response.body});
          }else{
            Utils.log("getAllDealsApi","getAllDealsApi is throwing "+response.statusCode.toString());
          }
          Utils.showError(context, translate("error_messages.please_try_again"));
          return null;
        }
      }else{
        Utils.showError(context, translate("error_messages.you_are_in_offline_mode"));
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.unable_to_fetch_deals"));
    }
    return null;
  }
  static Future<List<Additionals>> getAdditionals(BuildContext context,String token,int productId,int sizeId)async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("getAdditional"+productId.toString());
       var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("getAdditional"+productId.toString());
          return Additionals.listAdditionalsFromJson(cacheData.syncData);

        }else{
          Utils.showError(context, translate("error_messages.no_offline_data"));
        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){

        Map<String,String> headers = {'Authorization':'Bearer '+token};
        var response=await http.get(Uri.parse(Utils.baseUrl()+"additionalitems/GetAdditionalItemsByCategorySizeProductId/0/"+"$sizeId/"+productId.toString()),headers: headers);
        var data= jsonDecode(response.body);
        if(response.statusCode==200){
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "getAdditional"+productId.toString(), syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          return Additionals.listAdditionalsFromJson(response.body);
        }
        else{
          if(response.body!=null&&response.body.isNotEmpty){
            Utils.log("getAdditionalsApi",{"status":response.statusCode,"error_msg":response.body});
          }else{
            Utils.log("getAdditionalsApi","getAdditionalsApi is throwing "+response.statusCode.toString());
          }
         // pd.hide();
          //Utils.showError(context, translate("error_messages.please_try_again"));
        }
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.unable_to_fetch_additional"));
    }
    return null;
  }
  static Future<List<Tax>> getTaxListByStoreId(BuildContext context,int storeId )async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("getTaxList"+storeId.toString());
       var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("getTaxList"+storeId.toString());
          print("cache hit");
          return Tax.taxListFromJson(cacheData.syncData);

        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){

        var response=await http.get(Uri.parse(Utils.baseUrl()+"Taxes/GetAll/"+storeId.toString()));
        var data= jsonDecode(response.body);
        print("Taxes Json "+data.toString());
        if(response.statusCode==200){
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "getTaxList"+storeId.toString(), syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          return Tax.taxListFromJson(response.body);
        }
        else{
          if(response.body!=null&&response.body.isNotEmpty){
            Utils.log("getTaxListByStoreIdApi",{"status":response.statusCode,"error_msg":response.body});
          }else{
            Utils.log("getTaxListByStoreIdApi","getTaxListByStoreIdApi is throwing "+response.statusCode.toString());
          }
          Utils.showError(context, translate("error_messages.please_try_again"));
          return null;
        }
      }
    }catch(e){
      print(e);
      Utils.showError(context, translate("error_messages.unable_to_fetch_taxes"));
    }
    return null;
  }

  static Future<dynamic> placeOrder(BuildContext context,String token,dynamic orderData)async {
    //ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);

    try{
      //pd.show();
      Map<String,String> headers = {'Content-Type':'application/json','Authorization':'Bearer '+token};

      var body=jsonEncode(
          orderData,
          toEncodable: Utils.myEncode
      );
      var response=await http.post(Uri.parse(Utils.baseUrl()+"orders/Add"),headers: headers,body: body);
      print(response.statusCode);
      if(response.statusCode==200){
        //pd.hide();
        sqlite_helper().deletecart();
        // sqlite_helper().deletecartStaff();
        return response.body;
      }
      else{
        //pd.hide();
        if(response.body!=null&&response.body.isNotEmpty){
          Utils.log("placeOrderApi",{"status":response.statusCode,"error_msg":response.body});
        }else{
          Utils.log("placeOrderApi","placeOrderApi is throwing "+response.statusCode.toString());
        }
        return response.body;
      }
    }catch(e){

      Utils.showError(context, translate("error_messages.error_found"));
      return null;
    }
  }
  static Future<bool> payCashOrder(BuildContext context,String token,dynamic payCash)async {
    try{
      Map<String,String> headers = {'Content-Type':'application/json','Authorization':'Bearer '+token};

      var body=jsonEncode(
          payCash
      );
      var response=await http.post(Uri.parse(Utils.baseUrl()+"orders/paycash"),headers: headers,body: body);
      if(response.statusCode==200){
        Utils.showSuccess(context, translate("error_messages.order_delivered_and_cash_paid"));
        return true;
      }
      else{
        if(response.body!=null&&response.body.isNotEmpty){
          Utils.log("payCashOrderApi",{"status":response.statusCode,"error_msg":response.body});
        }else{
          Utils.log("payCashOrderApi","payCashOrderApi is throwing "+response.statusCode.toString());
        }
        Utils.showError(context, "${jsonDecode(response.body)['message']}");
        return false;
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.unable_to_fetch_orders"));
      return false;
    }
    //return null;
  }

  static Future<List<dynamic>> getAvailableTable(BuildContext context,String token,dynamic reservationData)async {
    //ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);

    try{
      //pd.show();
      Map<String,String> headers = {'Content-Type':'application/json','Authorization':'Bearer '+token};

      var body=jsonEncode(
          reservationData
      );
      var response=await http.post(Uri.parse(Utils.baseUrl()+"reservation/GetAvailableTables"),headers: headers,body: body);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        //pd.hide();
        //Utils.showSuccess(context, "Getting Table");
        return data;
      }
      else{
        //pd.hide();
        //Utils.showError(context, translate("error_messages.please_try_again"));
        return null;
      }
    }catch(e){
      //pd.hide();
      Utils.showError(context, translate("error_messages.unable_to_fetch_available_tables"));

      return null;
    }
    return null;
  }
  static Future<List<dynamic>> getAllOrders(BuildContext context,String token,int storeId)async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("orderList"+storeId.toString());
       var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist) {
          List list=[];
          var cacheData = await APICacheManager().getCacheData("orderList"+storeId.toString());
          print("cache hit");
          var data= jsonDecode(cacheData.syncData);
          if(data!=[])
            list=List.from(data.reversed);
          return list;
        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
        List list=[];
        Map<String,String> headers = {'Authorization':'Bearer '+token};
        var response=await http.get(Uri.parse(Utils.baseUrl()+"orders/getallbasicorders?storeId=$storeId"),headers: headers);
        var data= jsonDecode(response.body);
        if(response.statusCode==200){
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "orderList"+storeId.toString(), syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          if(data!=[])
            list=List.from(data.reversed);
          return list;
          //return data;
        }
        // else if(response.statusCode == 401){
        //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
        // }
        else{
          if(response.body!=null&&response.body.isNotEmpty){
            Utils.log("getAllOrdersApi",{"status":response.statusCode,"error_msg":response.body});
          }else{
            Utils.log("getAllOrdersApi","getAllOrdersApi is throwing "+response.statusCode.toString());
          }
          Utils.showError(context, translate("error_messages.please_try_again"));
          return null;
        }
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.unable_to_fetch_orders"));
      return null;
    }

  }
  static Future<List<dynamic>> getAllOrdersByComplaintTypeId(BuildContext context,String token,int ComplaintTypeId)async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("orderListByComplaintType"+ComplaintTypeId.toString());
      var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist) {
          List list=[];
          var cacheData = await APICacheManager().getCacheData("orderListByComplaintType"+ComplaintTypeId.toString());
          print("cache hit");
          var data= jsonDecode(cacheData.syncData);
          if(data!=[])
            list=List.from(data.reversed);
          return list;
        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
        List list=[];
        Map<String,String> headers = {'Authorization':'Bearer '+token};
        var response=await http.get(Uri.parse(Utils.baseUrl()+"orders/getallbasicorders?ComplaintTypeId=$ComplaintTypeId"),headers: headers);
        var data= jsonDecode(response.body);
        print("Api Response: "+response.statusCode.toString());
        if(response.statusCode==200){
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "orderListByComplaintType"+ComplaintTypeId.toString(), syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          if(data!=[])
            list=List.from(data.reversed);
          return list;
          //return data;
        }
        // else if(response.statusCode == 401){
        //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
        // }
        else{
          if(response.body!=null&&response.body.isNotEmpty){
            Utils.log("getAllOrdersByComplaintTypeIdApi",{"status":response.statusCode,"error_msg":response.body});
          }else{
            Utils.log("getAllOrdersByComplaintTypeIdApi","getAllOrdersByComplaintTypeIdApi is throwing "+response.statusCode.toString());
          }
          Utils.showError(context, translate("error_messages.please_try_again"));
          return null;
        }
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.unable_to_fetch_orders"));
      return null;
    }

  }
  static Future<List<dynamic>> getOrdersByTableId(BuildContext context,String token,int tableId,int storeId)async{
    try{
      List list=[];
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Uri.parse(Utils.baseUrl()+"orders/GetOrdersByTableId/$tableId"),headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        if(data!=[])
          list=List.from(data.reversed);
        return list;
      }
      else{
        if(response.body!=null&&response.body.isNotEmpty){
          Utils.log("getOrdersByTableIdApi",{"status":response.statusCode,"error_msg":response.body});
        }else{
          Utils.log("getOrdersByTableIdApi","getOrdersByTableIdApi is throwing "+response.statusCode.toString());
        }
        Utils.showError(context, translate("error_messages.please_try_again"));
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.unable_to_filter_orders_by_tables"));
    }
    return null;
  }
  static Future<List<dynamic>>getPredefinedReasons(BuildContext context,String token,int storeId)async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("PredefinedReasons"+storeId.toString());
      var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("PredefinedReasons"+storeId.toString());
          return jsonDecode(cacheData.syncData);
        }else{
          Utils.showError(context, translate("error_messages.no_offline_data"));
        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi) {
        Map<String, String> headers = {'Authorization': 'Bearer ' + token};
        var response = await http.get(Uri.parse(Utils.baseUrl() + "predefinedReasons/GetPredefinedReasons?storeId="+ storeId.toString()),headers: headers);
        var data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "PredefinedReasons"+storeId.toString(), syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          return data;
        }
        else {
          Utils.showError(context, translate("error_messages.please_try_again"));
          return null;
        }
      }else{
        Utils.showError(context, translate("error_messages.you_are_in_offline_mode"));
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.unable_to_fetch_info"));
    }
  }
  static Future<dynamic> getCustomerById(BuildContext context,String token,int Id)async{

    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("customerById"+Id.toString());
       var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("customerById"+Id.toString());
          return jsonDecode(cacheData.syncData);
        }else{
          Utils.showError(context, translate("error_messages.no_offline_data"));
        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi) {
        Map<String, String> headers = {'Authorization': 'Bearer ' + token};
        var response = await http.get(Uri.parse(Utils.baseUrl() + "account/GetUserById/"+ Id.toString()),headers: headers);
        var data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "customerById"+Id.toString(), syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          return data;
        }
        else {
          Utils.showError(context, translate("error_messages.please_try_again"));
          return null;
        }
      }else{
        Utils.showError(context, translate("error_messages.you_are_in_offline_mode"));
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.unable_to_fetch_info"));
    }
    return null;
  }
  static Future<dynamic> getItemsByOrderId(BuildContext context,String token,int OrderId)async{

    try{
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Uri.parse(Utils.baseUrl()+"orders/GetItemsByOrderId/"+OrderId.toString()),headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        return data;
      }
      // else if(response.statusCode == 401){
      //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      // }
      else{

        Utils.showError(context, translate("error_messages.please_try_again"));
      }
    }catch(e){
      var claims= Utils.parseJwt(token);
      if(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")).isBefore(DateTime.now())){
        Utils.showError(context, translate("error_messages.token_expire_please_login_again"));
        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      }else {
        Utils.showError(context, translate("error_messages.error_found"));
      }
    }
    return null;
  }
  static Future<dynamic> getDailySessionByStoreId(BuildContext context,String token,int storeId)async{

    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("getDailySession"+storeId.toString());
       var result=await Utils.check_connection();
      if (result == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("getDailySession"+storeId.toString());
          return jsonDecode(cacheData.syncData);

        }else{
          Utils.showError(context, translate("error_messages.no_offline_data"));
        }
      }
      if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
        Map<String,String> headers = {'Authorization':'Bearer '+token};
        var response=await http.get(Uri.parse(Utils.baseUrl()+"dailysession/getdailysessionno/"+storeId.toString()),headers: headers);
        var data= jsonDecode(response.body);
        if(response.statusCode==200){
          print("abc"+data.toString());
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "getDailySession"+storeId.toString(), syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          return data;

        }
        // else if(response.statusCode == 401){
        //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
        // }
        else{

          Utils.showError(context, translate("error_messages.please_try_again"));
        }
      }
    }catch(e){
      var claims= Utils.parseJwt(token);
      if(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")).isBefore(DateTime.now())){
        Utils.showError(context, translate("error_messages.token_expire_please_login_again"));
        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      }else {
        Utils.showError(context, translate("error_messages.unable_to_fetch_current_shift"));
      }
    }
    return null;
  }

  static Future<dynamic> getReservationList(BuildContext context,String token,int storeId,String email,DateTime startDate,DateTime endDate)async{

    try{
      var response;
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      if(startDate ==null && endDate==null && email==null)
        response=await http.get(Uri.parse(Utils.baseUrl()+"reservation/Get?storeId=$storeId"),headers: headers);
      // else if(startDate ==null && endDate==null && email!=null)
      //   response=await http.get(Utils.baseUrl()+"reservation/Get?storeId=$storeId&customerEmail=$email",headers: headers);
      // else
      //   response=await http.get(Utils.baseUrl()+"reservation/Get?storeId=$storeId&customerEmail=$email&startDate=$startDate&endDate=$endDate",headers: headers);
      var data= jsonDecode(response.body);
      print(data);
      if(response.statusCode==200){
        List list = [];
        if(data!=[])
          list=List.from(data.reversed);
        return list;
      }
      else{
        Utils.showError(context, translate("error_messages.please_try_again"));
        return null;
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.data_not_found_or_error_found"));
    }
    return null;
  }

  static Future<dynamic> cancelOrder(BuildContext context,String token,int orderId,int statusId)async{
    try{
      Map<String,String> header = {'Authorization':'Bearer '+token};
      var response=await http.get(Uri.parse(Utils.baseUrl()+"orders/DeleteOrderById/"+orderId.toString()+"/"+statusId.toString()),headers: header);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        return data;
      }
      else{
        Utils.showError(context, translate("error_messages.please_try_again"));
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.unable_to_cancel_order"));
    }
    return null;
  }

  static Future<List<dynamic>> getOrdersBySession(BuildContext context,String token,int sessionId)async{
    try{
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Uri.parse(Utils.baseUrl()+"orders/getbasicordersbysessionid/"+sessionId.toString()),headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        return data;
      }
      else{
        Utils.showError(context, translate("error_messages.please_try_again"));
      }
    }catch(e){
      print(e);
      Utils.showError(context, translate("error_messages.error_found"));
    }
    return null;
  }

  static Future<dynamic> getAllDailySessionByStoreId(BuildContext context,String token,int storeId)async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("getAllDailySession"+storeId.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("getAllDailySession"+storeId.toString());
          return Store.StoreFromJson(cacheData.syncData);

        }else{
          Utils.showError(context, translate("error_messages.no_offline_data"));
        }
      }
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
        Map<String,String> headers = {'Authorization':'Bearer '+token};
        var response=await http.get(Uri.parse(Utils.baseUrl()+"dailysession/GetAll/"+storeId.toString()),headers: headers);
        var data= jsonDecode(response.body);
        print(response.statusCode);
        print(response.body.toString());
        if(response.statusCode==200){
          print("abc"+data.toString());
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "getAllDailySession"+storeId.toString(), syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          return data;
        }
        // else if(response.statusCode == 401){
        //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
        // }
        else{
          Utils.showError(context, translate("error_messages.please_try_again"));
        }
      }
    }catch(e){
      var claims= Utils.parseJwt(token);
      if(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")).isBefore(DateTime.now())){
        Utils.showError(context, translate("error_messages.token_expire_please_login_again"));
        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      }else {
        Utils.showError(context, translate("error_messages.error_found"));
      }
    }
    return null;
  }

  static Future<dynamic> refundOrder({BuildContext context, String token, List<String> orderItemsId, int orderId,String refundReason,int ComplaintTypeId}) async {
    try{
      Map<String,String> headers = {'Content-Type':'application/json','Authorization':'Bearer '+token};

      var body=jsonEncode({
        "OrderItemsId": orderItemsId,
        "OrderId":orderId,
        "RefundReason":refundReason,
        "ComplaintTypeId":ComplaintTypeId
      }
      );
      print("Body "+body.toString());
      var response=await http.post(Uri.parse(Utils.baseUrl()+"orders/RefundedOrder"),headers: headers,body: body);
      if(response.statusCode==200){
        return true;
      }
      else{
        if(response.body!=null&&response.body.isNotEmpty){
          Utils.log("refundOrderApi",{"status":response.statusCode,"error_msg":response.body});
        }else{
          Utils.log("refundOrderApi","refundOrderApi is throwing "+response.statusCode.toString());
        }
        if(response.body!=null){
          print("response "+response.body.toString());
        }
        Utils.showError(context, translate("error_messages.please_try_again"));
        return false;
      }
    }catch(e){
      print("Exception "+e);
      Utils.showError(context, translate("error_messages.unable_to_refund_order"));
      return false;
    }
  }

  static Future<dynamic> refundOrderByCash({BuildContext context, String token, List<String> orderItemsId, int orderId,String refundReason,int ComplaintTypeId,String cashAmount}) async {
    try{
      Map<String,String> headers = {'Content-Type':'application/json','Authorization':'Bearer '+token};

      var body=jsonEncode({
        "OrderId":orderId,
        "RefundReason":refundReason,
        "ComplaintTypeId":ComplaintTypeId,
        "CashAmount":cashAmount
      }
      );
      print("Body "+body.toString());
      var response=await http.post(Uri.parse(Utils.baseUrl()+"orders/RefundbyCash"),headers: headers,body: body);
      if(response.statusCode==200){
        return true;
      }
      else{
        if(response.body!=null&&response.body.isNotEmpty){
          Utils.log("refundOrderByCashApi",{"status":response.statusCode,"error_msg":response.body});
        }else{
          Utils.log("refundOrderByCashApi","refundOrderByCashApi is throwing "+response.statusCode.toString());
        }
        if(response.body!=null){
          print("response "+response.body.toString());
        }
        Utils.showError(context, translate("error_messages.please_try_again"));
        return false;
      }
    }catch(e){
      print("Exception "+e);
      Utils.showError(context, translate("error_messages.unable_to_refund_order"));
      return false;
    }
  }
  static Future<List<ComplaintType>> getComplainTypeListByStoreId(BuildContext context,String token,int storeId )async{

    try{
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Uri.parse(Utils.baseUrl()+"Complaint/GetAllComplaintType/"+storeId.toString()),headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        return ComplaintType.ListComplaintTypeFromJson(response.body);
      }
      else{
        Utils.showError(context, translate("error_messages.please_try_again"));
        return null;
      }
    }catch(e){
      print(e);
      Utils.showError(context, translate("error_messages.unable_to_fetch_complaint_type"));
    }
    return null;
  }

  static Future<bool> changeOrderStatus(BuildContext context,String token,dynamic OrderStatusData)async{

    try{
      Map<String,String> headers = {'Content-Type':'application/json','Authorization':'Bearer '+token};
      var body=jsonEncode(
          OrderStatusData
      );

      var response=await http.post(Uri.parse(Utils.baseUrl()+"orders/UpdateStatus"),headers: headers,body: body);

      var data= jsonDecode(response.body);
      print(response.body);
      if(response.statusCode==200){
        Utils.showSuccess(context, translate("error_messages.order_status_changed"));
        return true;
      }
      else{
        if(response.body!=null&&response.body.isNotEmpty){
          Utils.log("changeOrderStatusApi",{"status":response.statusCode,"error_msg":response.body});
        }else{
          Utils.log("changeOrderStatusApi","changeOrderStatusApi is throwing "+response.statusCode.toString());
        }
        print(response.body);
        print(response.statusCode);
        Utils.showError(context, translate("error_messages.please_try_again"));
        return false;
      }
    }catch(e){
      Utils.showError(context, translate("error_messages.error_found"));
      return false;
    }
    return null;
  }
  static Future<List<Vendors>> getRiderListByStoreId(BuildContext context,String token,int storeId)async{
    try{
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Uri.parse(Utils.baseUrl()+"account/GetRiders/"+storeId.toString()),headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        return Vendors.vendorsListFromJson(response.body);
      }
      else{
        Utils.showError(context, translate("error_messages.please_try_again"));
        return null;
      }
    }catch(e){
      throw e;
    }
    return null;
  }

}
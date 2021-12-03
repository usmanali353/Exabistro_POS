import 'dart:convert';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:connectivity/connectivity.dart';
import 'package:exabistro_pos/model/Additionals.dart';
import 'package:exabistro_pos/model/Products.dart';
import 'package:exabistro_pos/model/Tax.dart';
import 'package:exabistro_pos/networks/sqlite_helper.dart';
import 'package:http/http.dart' as http;
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/model/Categories.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/RolesBaseStoreSelection.dart';

class Network_Operations{

  static Future signIn(BuildContext context,String email,String password) async {
    var body=jsonEncode({"email":email,"password":password});
    try{
      List rolesAndStores =[],restaurantList=[];
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("response"+email);
      var isPassExist = await APICacheManager().isAPICacheKeyExist("password"+email);

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
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
          print(rolesAndStores);
          var claims = Utils.parseJwt(jsonDecode(cacheData.syncData)['token']);
          if(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")).isBefore(DateTime.now())){
            Utils.showError(context, "Token Expire Please Login Again");
          }else {
            if (passData.syncData == password) {
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString("token", jsonDecode(cacheData.syncData)['token']);
                prefs.setString("email", email);
                prefs.setString('userId', claims['nameid']);
                prefs.setString('nameid', claims['nameid']);
                prefs.setString("name", claims['unique_name']);
                prefs.setString('password', password);
              });
              Utils.showSuccess(context, "Login Successful");
              print(claims['IsCustomerOnly'].toString() + "vfdgfdgfdgfdgdfgd");
              if (claims['IsCustomerOnly'] == "false") {

                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) =>
                          RoleBaseStoreSelection(rolesAndStores)), (
                          Route<dynamic> route) => false);
              }
            }else{
              Utils.showError(context, "Your Password is Incorrect");
            }
          }

        }
      }
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
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
          var claims = Utils.parseJwt(jsonDecode(response.body)['token']);
          SharedPreferences.getInstance().then((prefs){
            prefs.setString("token", jsonDecode(response.body)['token']);
            prefs.setString("email", email);
            prefs.setString('userId', claims['nameid']);
            prefs.setString('nameid', claims['nameid']);
            prefs.setString("name", claims['unique_name']);
            prefs.setString('password', password);
            // prefs.setString('isCustomer', claims['IsCustomerOnly']);
          });
          Utils.showSuccess(context, "Login Successful");
          if(claims['IsCustomerOnly'] == "false"){
            APICacheDBModel cacheDBModel = new APICacheDBModel(
                key: "response"+email, syncData: response.body);
            await APICacheManager().addCacheData(cacheDBModel);
            APICacheDBModel cacheDBModel1 = new APICacheDBModel(
                key: "password"+email, syncData: password);
            await APICacheManager().addCacheData(cacheDBModel1);

              Navigator.pushAndRemoveUntil(context,
                  //MaterialPageRoute(builder: (context) => DashboardScreen()), (
                  MaterialPageRoute(builder: (context) => RoleBaseStoreSelection(rolesAndStores)), (
                      Route<dynamic> route) => false);
            }
        }
        else{
          print(jsonDecode(response.body));
          Utils.showError(context, "${response.body}");
        }
      }
    }catch(e) {
      print(e);
      Utils.showError(context, "Please Enter Valid Email Address");
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
      Utils.showError(context, "Error Found: ");
    }
    return null;
  }
  static Future<List<Products>> getProduct(BuildContext context,int categoryId,int storeId,String search)async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("productList"+categoryId.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("productList"+categoryId.toString());
          print(cacheData.syncData);
          var data= jsonDecode(cacheData.syncData);
          List<Products> list=List();
          list.clear();
          for(int i=0;i<data.length;i++){
            list.add(Products(name: data[i]['name'],id: data[i]['id'],image: data[i]['image'],
                subCategoryId: data[i]['subCategoryId'],isVisible: data[i]['isVisible'],orderCount: data[i]['orderCount'],totalQuantityOrdered: data[i]['totalQuantityOrdered'],
                description: data[i]['description'],storeId: data[i]['storeId'],categoryId: data[i]['categoryId'],productSizes: data[i]['productSizes']));
          }
          return list;
        }else{
          Utils.showError(context, "No Offline Data");
        }
      }
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
        var response=await http.get(Uri.parse(Utils.baseUrl()+"Products/GetByCategoryId?StoreId=$storeId&categoryId="+categoryId.toString()+"&searchstring=$search"),);
        APICacheDBModel cacheDBModel = new APICacheDBModel(
            key: "productList"+categoryId.toString(), syncData: response.body);
        await APICacheManager().addCacheData(cacheDBModel);

        var data= jsonDecode(response.body);
        if(response.statusCode==200){
          if(connectivityResult != ConnectivityResult.none){
            List<Products> list=List();
            list.clear();
            for(int i=0;i<data.length;i++){
              list.add(Products(name: data[i]['name'],id: data[i]['id'],image: data[i]['image'],
                  subCategoryId: data[i]['subCategoryId'],isVisible: data[i]['isVisible'],orderCount: data[i]['orderCount'],totalQuantityOrdered: data[i]['totalQuantityOrdered'],
                  description: data[i]['description'],storeId: data[i]['storeId'],categoryId: data[i]['categoryId'],productSizes: data[i]['productSizes']));
            }
            return list;
          }
        }
        else{
          Utils.showError(context, response.body);
        }
      } else{
        Utils.showError(context, "You are in Offline mode");
      }
    }catch(e){
      print(e);
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
        Utils.showError(context, "Please Try Again");
      }
    }catch(e){
      Utils.showError(context, "Error Found: $e");
    }
    return null;
  }

  static Future<List<dynamic>> getTableList(BuildContext context,String token,int storeId)async{
   // ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);
    try{
      // pd.show();
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Uri.parse(Utils.baseUrl()+"tables/GetAll/?storeId=$storeId"),headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        List list =[];
        //pd.hide();
        for(int i=0;i<data.length;i++){
          if(data[i]['isVisible'] == true){
            list.add(data[i]);
          }
        }
        return list;
      }
      else{
       // pd.hide();
        Utils.showError(context, "Please Try Again");
        return null;
      }
    }catch(e){
     // pd.hide();
      Utils.showError(context, "Data Not Found Or Error Found");
    }
    return null;
  }
  static Future<bool> changeOrderStatus(BuildContext context,String token,dynamic OrderStatusData)async{

    try{
      Map<String,String> headers = {'Content-Type':'application/json','Authorization':'Bearer '+token};
      var body=jsonEncode(
          OrderStatusData
      );
      print(body);
      var response=await http.post(Uri.parse(Utils.baseUrl()+"orders/UpdateStatus"),headers: headers,body: body);
      print(response.body);

      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        return true;
      }
      else{
        Utils.showError(context, "Please Try Again");
        return false;
      }
    }catch(e){
      Utils.showError(context, "Error Found: $e");
      return false;
    }
    return null;
  }
  static Future<List<Categories>> getCategories(BuildContext context,int storeId)async{

    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("getCategory"+storeId.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("getCategory"+storeId.toString());
          var data= jsonDecode(cacheData.syncData);
          List<Categories> list=List();
          list.clear();
          for(int i=0;i<data.length;i++){
            list.add(Categories(name: data[i]['name'],id: data[i]['id'],image: data[i]['image'],isSubCategoriesExist: data[i]['isSubCategoriesExist'],storeId: data[i]['storeId']));
          }
          return list;

        }else{
          Utils.showError(context, "No Offline Data");
        }
      }
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){

        // pd.show();
        var response=await http.get(Uri.parse(Utils.baseUrl()+"Categories/GetAll?StoreId=$storeId&ShowByTime=1",));//0 is for time limitation
        var data= jsonDecode(response.body);
        if(response.statusCode==200){
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "getCategory"+storeId.toString(), syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          List<Categories> list=List();
          list.clear();
          for(int i=0;i<data.length;i++){
            list.add(Categories(name: data[i]['name'],id: data[i]['id'],image: data[i]['image'],isSubCategoriesExist: data[i]['isSubCategoriesExist'],storeId: data[i]['storeId']));
          }
          return list;
        }else{
          Utils.showError(context, response.body);
        }
      }else{
        Utils.showError(context, "You are in Offline mode");
      }
    }catch(e){
      Utils.showError(context, e.toString());
    }
    //pd.hide();
    return null;
  }
  static Future<List<Categories>> getCategory (BuildContext context, String token,int storeId,String search) async {
    try{
      Map<String, String> headers = {'Authorization':'Bearer '+token, 'Content-Type':'application/json'};
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("categoryList");
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("categoryList");
          print("cache hit");
          return Categories.listCategoriesFromJson(cacheData.syncData);

        }
      }
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
        final response = await http.get(Uri.parse(Utils.baseUrl() +
            'Categories/GetAll?StoreId=$storeId&ShowByTime=0&searchstring=$search'),
          headers: headers,);
        if (response.statusCode == 200) {
          if(connectivityResult != ConnectivityResult.none) {
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
          Utils.showError(context, "Please Try Again");
        }
      }
      else{
        Utils.showError(context, "You are in Offline mode");
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
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("dealList");
          return jsonDecode(cacheData.syncData);

        }else{
          Utils.showError(context, "No Offline Data");
        }
      }
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
        var response;
        Map<String,String> headers = {'Authorization':'Bearer '+token};
        //  response=await http.get(Utils.baseUrl()+"deals/GetAll?storeId=$storeId&searchstring=$search",headers: headers);
        if(startDate ==null && endDate==null && startingPrice==null && endingPrice==null && search==null)
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAll?storeId=$storeId"),headers: headers);
        else if(startDate ==null && endDate==null && startingPrice==null && endingPrice==null)
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAll?storeId=$storeId&searchstring=$search"),headers: headers);
        else if(startDate !=null && endDate!=null)
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAll?storeId=$storeId&startingDate=$startDate&EndingDate=$endDate"),headers: headers);
        else if(startingPrice !=null && endingPrice!=null)
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAll?storeId=$storeId&startingPrice=$startingPrice&endingPrice=$endingPrice"),headers: headers);
        else if(startDate !=null && endDate!=null && startingPrice!=null && endingPrice!=null)
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAll?storeId=$storeId&startingPrice=$startingPrice&endingPrice=$endingPrice&startingDate=$startDate&EndingDate=$endDate"),headers: headers);
        else
          response=await http.get(Uri.parse(Utils.baseUrl()+"deals/GetAll?storeId=$storeId"),headers: headers);
        var data= jsonDecode(response.body);
        print(data);
        if(response.statusCode==200){
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "dealList", syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          return data;
        }
        else{
          Utils.showError(context, "Please Try Again");
          return null;
        }
      }else{
        Utils.showError(context, "You are in Offline mode");
      }
    }catch(e){
      Utils.showError(context, "Error Found:");
    }
    return null;
  }
  static Future<List<Additionals>> getAdditionals(BuildContext context,String token,int productId,int sizeId)async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("getAdditional"+productId.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("getAdditional"+productId.toString());
          return Additionals.listAdditionalsFromJson(cacheData.syncData);

        }else{
          Utils.showError(context, "No Offline Data");
        }
      }
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){

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
         // pd.hide();
          Utils.showError(context, "Please Try Again");
        }
      }
    }catch(e){
      Utils.showError(context, e.toString());
    }
    return null;
  }
  static Future<List<Tax>> getTaxListByStoreId(BuildContext context,int storeId )async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("getTaxList"+storeId.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("getTaxList"+storeId.toString());
          print("cache hit");
          return Tax.taxListFromJson(cacheData.syncData);

        }
      }
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){

        var response=await http.get(Uri.parse(Utils.baseUrl()+"Taxes/GetAll/"+storeId.toString()));
        var data= jsonDecode(response.body);
        if(response.statusCode==200){
          APICacheDBModel cacheDBModel = new APICacheDBModel(
              key: "getTaxList"+storeId.toString(), syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          return Tax.taxListFromJson(response.body);
        }
        else{
          Utils.showError(context, "Please Try Again");
          return null;
        }
      }
    }catch(e){
      print(e);
      Utils.showError(context, "Error Found:");
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
        print("Order Error "+response.body.toString());

        return response.body;
      }
    }catch(e){

      Utils.showError(context, "Error Found: $e");
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
        Utils.showSuccess(context, "Order Delivered & Cash Paid");
        return true;
      }
      else{
        Utils.showError(context, "${jsonDecode(response.body)['message']}");
        return false;
      }
    }catch(e){
      Utils.showError(context, "Error Found: ");
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
        //Utils.showError(context, "Please Try Again");
        return null;
      }
    }catch(e){
      //pd.hide();
      Utils.showError(context, "Data Not Found Or Error Found");

      return null;
    }
    return null;
  }
  static Future<List<dynamic>> getAllOrders(BuildContext context,String token,int storeId)async{
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("orderList"+storeId.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
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
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
        List list=[];
        Map<String,String> headers = {'Authorization':'Bearer '+token};
        var response=await http.get(Uri.parse(Utils.baseUrl()+"orders/getallbasicorders/$storeId"),headers: headers);
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
          Utils.showError(context, "Please Try Again");
          return null;
        }
      }
    }catch(e){
      Utils.showError(context, "Error Found: $e");
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
        Utils.showError(context, "Please Try Again");
      }
    }catch(e){
      Utils.showError(context, "Error Found: $e");
    }
    return null;
  }

  static Future<dynamic> getCustomerById(BuildContext context,String token,int Id)async{

    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("customerById"+Id.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("customerById"+Id.toString());
          return jsonDecode(cacheData.syncData);
        }else{
          Utils.showError(context, "No Offline Data");
        }
      }
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
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
          Utils.showError(context, "Please Try Again");
          return null;
        }
      }else{
        Utils.showError(context, "You are in Offline mode");
      }
    }catch(e){
      Utils.showError(context, "Error Found: $e");
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

        Utils.showError(context, "Please Try Again");
      }
    }catch(e){
      var claims= Utils.parseJwt(token);
      if(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")).isBefore(DateTime.now())){
        Utils.showError(context, "Token Expire Please Login Again");
        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      }else {
        Utils.showError(context, "Error Found: $e");
      }
    }
    return null;
  }
  static Future<dynamic> getDailySessionByStoreId(BuildContext context,String token,int storeId)async{

    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("getDailySession"+storeId.toString());
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("getDailySession"+storeId.toString());
          return jsonDecode(cacheData.syncData);

        }else{
          Utils.showError(context, "No Offline Data");
        }
      }
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
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

          Utils.showError(context, "Please Try Again");
        }
      }
    }catch(e){
      var claims= Utils.parseJwt(token);
      if(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")).isBefore(DateTime.now())){
        Utils.showError(context, "Token Expire Please Login Again");
        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      }else {
        Utils.showError(context, "Error Found: $e");
      }
    }
    return null;
  }
}
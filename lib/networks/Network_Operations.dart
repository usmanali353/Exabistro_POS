import 'dart:convert';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:connectivity/connectivity.dart';
import 'package:exabistro_pos/model/Additionals.dart';
import 'package:exabistro_pos/model/Products.dart';
import 'package:exabistro_pos/model/Stores.dart';
import 'package:exabistro_pos/model/Tax.dart';
import 'package:http/http.dart' as http;
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/model/Categories.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/RolesBaseStoreSelection.dart';

class Network_Operations{
  static Future signIn(BuildContext context,String email,String password,String admin) async {
    var body=jsonEncode({"email":email,"password":password});
    try{
      List rolesAndStores =[],restaurantList=[];
      var response=await http.post(Utils.baseUrl()+"account/login",body:body,headers: {"Content-type":"application/json"});
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
        print("fghjk"+claims.toString());
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
        print(claims['IsCustomerOnly'].toString()+"vfdgfdgfdgfdgdfgd");
        if(claims['IsCustomerOnly'] == "false"){
          //  if(decoded[0]['roleId']==2){
          //   Navigator.pushAndRemoveUntil(context,
          //       //MaterialPageRoute(builder: (context) => DashboardScreen()), (
          //       MaterialPageRoute(builder: (context) => RestaurantScreen(restaurantList,2)), (
          //           Route<dynamic> route) => false);
          //   // MaterialPageRoute(builder: (context) => NewRestaurantList()), (
          //   // Route<dynamic> route) => false);
          //   //MaterialPageRoute(builder: (context) => RestaurantScreen(restaurantList,2)), (
          //   // Route<dynamic> route) => false);
          // }

          Navigator.pushAndRemoveUntil(context,
              //MaterialPageRoute(builder: (context) => DashboardScreen()), (
              MaterialPageRoute(builder: (context) => RoleBaseStoreSelection(rolesAndStores)), (
                  Route<dynamic> route) => false);
          }
        print(response.body);
      }
      // else if(response.body!=null){
      //   pd.hide();
      //   Utils.showError(context, "Try Again");
      // }
      else{
        print(jsonDecode(response.body));
        Utils.showError(context, "${response.body}");
      }
    }catch(e) {
      print(e);
      Utils.showError(context, "Please Confirm your Email Address");
    }
  }
  static Future<dynamic> getRoles(BuildContext context)async{

    try{
      var response=await http.get(Utils.baseUrl()+"Account/GetAllRolesExceptSuperAdmin",);
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
  static Future<List<Categories>> getSubcategories(BuildContext context,int storeId)async{
    //ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);
    try{
    //  pd.show();
      var response=await http.get(Utils.baseUrl()+"subcategories/getbycategoryid?StoreId="+storeId.toString(),);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        //pd.hide();
        print(response.body);
        List<Categories> list=List();
        list.clear();
        for(int i=0;i<data.length;i++){
          if(data[i]['isVisible'] == true) {
            list.add(Categories(name: data[i]['name'],
                id: data[i]['id'],
                image: data[i]['image'],
                isVisible: data[i]['isVisible'],
                categoryId: data[i]["categoryId"]
            )
            );
          }
        }
        return list;
      }
      else{
       // pd.hide();
        Utils.showError(context, "Error Occur");
      }
    }catch(e){
      //pd.hide();
      Utils.showError(context, e.toString());
    }
    return null;
  }
  static Future<List<Products>> getProduct(BuildContext context,int categoryId,subCategoryId,int storeId,String search)async{
    //ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);
    try{
      var isCacheExist = await APICacheManager().isAPICacheKeyExist("productList");
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none){
        if (isCacheExist) {
          var cacheData = await APICacheManager().getCacheData("productList");
          return Products.listProductFromJson(cacheData.syncData);
        }else{
          Utils.showError(context, "No Offline Data");
        }
      }
      if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
        //pd.show();
        var response=await http.get(Utils.baseUrl()+"Products/GetByCategoryId?StoreId=$storeId&categoryId="+categoryId.toString()+"&subCategoryId="+subCategoryId.toString()+"&searchstring=$search",);
        APICacheDBModel cacheDBModel = new APICacheDBModel(
            key: "productList", syncData: response.body);
        await APICacheManager().addCacheData(cacheDBModel);

        var data= jsonDecode(response.body);
        print(data);
        if(response.statusCode==200){
          if(connectivityResult != ConnectivityResult.none){
          //  pd.hide();
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
          //pd.hide();
          Utils.showError(context, response.body);
        }
      }
      else{
       // pd.hide();
        Utils.showError(context, "You are in Offline mode");
      }
    }catch(e){
    //  pd.hide();
      Utils.showError(context, e.toString());
    }
    return null;
  }
  static Future<dynamic> getAllOrdersWithItemsByOrderStatusId(BuildContext context,String token,int orderStatusId,int storeId)async{
    ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);

    try{
      pd.show();
      List list=[];
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Utils.baseUrl()+"orders/getallbasicorderswithitems/"+orderStatusId.toString()+"?StoreId="+storeId.toString(),headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        pd.hide();
        if(data!=[])
          list=List.from(data.reversed);
        return list;
      }
      // else if(response.statusCode == 401){
      //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      // }
      else{
        pd.hide();
        Utils.showError(context, "Please Try Again");
      }
    }catch(e){
      pd.hide();
      Utils.showError(context, "Error Found: $e");
    }
    pd.hide();
    return null;
  }
  static Future<dynamic> getAllOrdersWithItemsByOrderStatusIdCategorized(BuildContext context,String token,int orderStatusId,int categoryId,int storeId)async{
    ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);

    try{
      pd.show();
      List list=[];
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Utils.baseUrl()+"orders/getallbasicorderswithitems/"+orderStatusId.toString()+"?CategoryId="+categoryId.toString()+"&StoreId="+storeId.toString(),headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        pd.hide();
        if(data!=[])
          list=List.from(data.reversed);
        return list;
      }
      else{
        pd.hide();
        Utils.showError(context, "Please Try Again");
      }
    }catch(e){
      pd.hide();
      Utils.showError(context, "Error Found: $e");
    }
    pd.hide();
    return null;
  }
  static Future<dynamic> getTableList(BuildContext context,String token,int storeId)async{
    ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);
    try{
      // pd.show();
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Utils.baseUrl()+"tables/GetAll/?storeId=$storeId",headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        List list =[];
        pd.hide();
        for(int i=0;i<data.length;i++){
          if(data[i]['isVisible'] == true){
            list.add(data[i]);
          }
        }
        return list;
      }
      else{
        pd.hide();
        Utils.showError(context, "Please Try Again");
        return null;
      }
    }catch(e){
      pd.hide();
      Utils.showError(context, "Data Not Found Or Error Found");
    }
    return null;
  }
  static Future<dynamic> getAllTables(BuildContext context,String token,int storeId,String search)async{
    ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);
    try{
      pd.show();
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Utils.baseUrl()+"tables/GetAll?StoreId=$storeId&searchstring=$search",headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        pd.hide();
        return data;
      }
      else{
        pd.hide();
        Utils.showError(context, "Please Try Again");
        return null;
      }
    }catch(e){
      pd.hide();
      Utils.showError(context, "Data Not Found Or Error Found");
    }
    return null;
  }
  static Future<List<Store>> getAllStoresByRestaurantId(BuildContext context,dynamic storeData)async{
    ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);
    try{
      // pd.show();
      var body=jsonEncode(
          storeData
      );
      Map<String,String> headers = {'Content-Type':'application/json','Authorization':'Bearer '};
      var response=await http.post(Utils.baseUrl()+"Store/GetAll",headers:headers,body: body );
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        pd.hide();
        //return data;
        // List<Store> list=List();
        // list.clear();
        // for(int i=0;i<data.length;i++){
        //   list.add(Store(name: data[i]['name'],id: data[i]['id'],image: data[i]['image'],
        //       address:  data[i]['address'],isVisible: data[i]['isVisible'],
        //       city:  data[i]['city'],restaurantId: data[i]['restaurantId'],));
        // }
        // print(data.toString());
        // return list;
        return Store.listStoreFromJson(response.body);

      }
      else{
        pd.hide();
        Utils.showError(context, "Please Try Again");
        return null;
      }
    }catch(e){
      pd.hide();
      print(e);
      Utils.showError(context, "Error Found:");
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
      var response=await http.post(Utils.baseUrl()+"orders/UpdateStatus",headers: headers,body: body);
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
  static Future<dynamic> changeOrderItemStatus(BuildContext context,String token,int orderItemId,int statusId,var chefId)async{

    try{
      Map<String,String> header = {'Authorization':'Bearer '+token};
      var response=await http.get(Utils.baseUrl()+"orders/UpdateOrderItemStatus/"+orderItemId.toString()+"/"+statusId.toString()+"/$chefId",headers: header);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        return data;
      }
      else{
        Utils.showError(context, "Please Try Again");
      }
    }catch(e){
      Utils.showError(context, "Error Found");
    }
    return null;
  }
  static Future<List<Categories>> getCategories(BuildContext context,int storeId)async{
    ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);

    try{
      // pd.show();
      var response=await http.get(Utils.baseUrl()+"Categories/GetAll?StoreId=$storeId&ShowByTime=1",);//0 is for time limitation
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        pd.hide();
        List<Categories> list=List();
        list.clear();
        for(int i=0;i<data.length;i++){
          list.add(Categories(name: data[i]['name'],id: data[i]['id'],image: data[i]['image'],isSubCategoriesExist: data[i]['isSubCategoriesExist'],storeId: data[i]['storeId']));
        }
        return list;
      }else{
        pd.hide();
        Utils.showError(context, response.body);
      }
    }catch(e){
      pd.hide();
      Utils.showError(context, e.toString());
    }
    //pd.hide();
    return null;
  }
  static Future<Store> getStoreById(BuildContext context,String token,storeId)async{

    try{
      //Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Utils.baseUrl()+"Store/"+storeId.toString());
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        return Store.StoreFromJson(response.body);
      }
      else{
        Utils.showError(context, "Please Try Again");
        return null;
      }
    }catch(e){
      print(e);
      Utils.showError(context, "Error Found:");
    }
    return null;
  }
  static Future<List<dynamic>> getAllDeals(BuildContext context,String token,int storeId,{String startingPrice,String endingPrice,String search,DateTime startDate,DateTime endDate})async{
    try{
      var response;
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      if(startDate ==null && endDate==null && startingPrice==null && endingPrice==null && search==null)
        response=await http.get(Utils.baseUrl()+"deals/GetAll?storeId=$storeId",headers: headers);
      else if(startDate ==null && endDate==null && startingPrice==null && endingPrice==null)
        response=await http.get(Utils.baseUrl()+"deals/GetAll?storeId=$storeId&searchstring=$search",headers: headers);
      else if(startDate !=null && endDate!=null)
        response=await http.get(Utils.baseUrl()+"deals/GetAll?storeId=$storeId&startingDate=$startDate&EndingDate=$endDate",headers: headers);
      else if(startingPrice !=null && endingPrice!=null)
        response=await http.get(Utils.baseUrl()+"deals/GetAll?storeId=$storeId&startingPrice=$startingPrice&endingPrice=$endingPrice",headers: headers);
      else if(startDate !=null && endDate!=null && startingPrice!=null && endingPrice!=null)
        response=await http.get(Utils.baseUrl()+"deals/GetAll?storeId=$storeId&startingPrice=$startingPrice&endingPrice=$endingPrice&startingDate=$startDate&EndingDate=$endDate",headers: headers);
      else
        response=await http.get(Utils.baseUrl()+"deals/GetAll?storeId=$storeId",headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
       // pd.hide();
        return data;
      }
      else{
        //pd.hide();
        Utils.showError(context, "Please Try Again");
        return null;
      }
    }catch(e){
      //pd.hide();
      print(e);
      Utils.showError(context, "Error Found:");
    }
    return null;
  }
  static Future<List<Additionals>> getAdditionals(BuildContext context,String token,int productId,int sizeId)async{
    //ProgressDialog pd = ProgressDialog(context,type: ProgressDialogType.Normal);
    //pd.show();
    try{
      Map<String,String> headers = {'Authorization':'Bearer '+token};
      var response=await http.get(Utils.baseUrl()+"additionalitems/GetAdditionalItemsByCategorySizeProductId/0/"+"$sizeId/"+productId.toString(),headers: headers);
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
       // pd.hide();
        return Additionals.listAdditionalsFromJson(response.body);
      }
      else{
      //  pd.hide();
        Utils.showError(context, "Please Try Again");
      }
    }catch(e){

    }
    return null;
  }
  static Future<List<Tax>> getTaxListByStoreId(BuildContext context,int storeId )async{
    try{
      var response=await http.get(Utils.baseUrl()+"Taxes/GetAll/"+storeId.toString());
      var data= jsonDecode(response.body);
      print(data);
      if(response.statusCode==200){
        return Tax.taxListFromJson(response.body);
      }
      else{
        Utils.showError(context, "Please Try Again");
        return null;
      }
    }catch(e){
      print(e);
      Utils.showError(context, "Error Found:");
    }
    return null;
  }
}
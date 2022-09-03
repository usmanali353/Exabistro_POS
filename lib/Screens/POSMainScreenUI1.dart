import 'dart:async';
import 'dart:convert';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:exabistro_pos/Screens/LoginScreen.dart';
import 'package:exabistro_pos/Screens/Orders/HistoryTabsComponents.dart';
import 'package:exabistro_pos/Screens/OrdersHistoryTab/Components/PaidTabsComponents.dart';
import 'package:exabistro_pos/Screens/OrdersHistoryTab/Components/Screens/PaidOrdersList.dart';
import 'package:exabistro_pos/Utils/Utils.dart';

import 'package:exabistro_pos/model/Additionals.dart';
import 'package:exabistro_pos/model/CartItems.dart';
import 'package:exabistro_pos/model/Categories.dart';
import 'package:exabistro_pos/model/Orderitems.dart';
import 'package:exabistro_pos/model/Orders.dart';
import 'package:exabistro_pos/model/Products.dart';
import 'package:exabistro_pos/model/Tax.dart';
import 'package:exabistro_pos/model/Toppings.dart';
import 'package:exabistro_pos/model/orderItemTopping.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:exabistro_pos/networks/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_counter/flutter_counter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Utils/constants.dart';
import 'LoadingScreen.dart';

class POSMainScreenUI1 extends StatefulWidget {
 var store;
 POSMainScreenUI1({this.store});

  @override
  _POSMainScreenUI1State createState() => _POSMainScreenUI1State();
}

class _POSMainScreenUI1State extends State<POSMainScreenUI1> {
  List<Categories> subCategories = [],categories=[];
  List<dynamic> dealsList = [],taxesList=[];
  List<Products> products = [];
  String categoryName = "",userId="";
  bool isLoading = true;
  List<String> menuTypeDropdownItems = ["Products", "Deals"];
  List<String> discountTypeDropdownItems = ["Percentage", "Cash"];
  String selectedMenuType;
  var overallTotalPrice=0.0,overallTotalPriceWithTax=0.0,totalTax=0.0;
  List<CartItems> cartList = [];
  TimeOfDay pickingTime;
  Order finalOrder;
  List<Orderitem> orderitem = [];
  List<Orderitemstopping> itemToppingList = [];
  List<Tax> orderTaxes=[],typeBasedTaxes=[];
  dynamic ordersList;
  List<dynamic> toppingList = [], orderItems = [],tables=[];
  List<String> topping = [];
  List<bool> _selected=[];
  var nonServiceTaxesPrice=0.0,serviceBasedTaxes=0.0;
  var currentDailySession;
  APICacheDBModel offlineData;
  var selectedOrderTypeId,selectedWaiter,selectedWaiterId,selectedTable,selectedTableId;
  TextEditingController timePickerField,customerName,customerPhone,customerEmail,customerAddress,discountValue;
  String token,discountService,waiveOffService;
  List<int> cartCounter=[];
  final formKey= GlobalKey<FormState>();
  Timer t;

@override
  void initState() {
  timePickerField=TextEditingController();
  customerName=TextEditingController();
  customerAddress=TextEditingController();
  customerEmail=TextEditingController();
  customerPhone=TextEditingController();
  discountValue=TextEditingController();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  SharedPreferences.getInstance().then((prefs){
    setState(() {
      this.token=prefs.getString("token");
      this.discountService=prefs.getString("discountService");
      this.waiveOffService=prefs.getString("waiveOffService");
    });
    var reservationData = {
      "Date":DateTime.now().toString().substring(0,10),
      "StartTime":DateTime.now().toString().substring(10,16),
      "EndTime": DateTime.now().add(Duration(hours:1)).toString().substring(10,16),
      "storeId":widget.store["id"]
    };
    Network_Operations.getAvailableTable(context, prefs.getString("token"), reservationData).then((availableTables){
      setState(() {
        if(availableTables!=null&&availableTables.length>0){
          this.tables=availableTables;
        }

        t= Timer.periodic(Duration(minutes: 1), (timer) {
          var reservationData = {
            "Date":DateTime.now().toString().substring(0,10),
            "StartTime":DateTime.now().toString().substring(10,16),
            "EndTime": DateTime.now().add(Duration(hours:1)).toString().substring(10,16),
            
            "storeId":widget.store["id"]
          };
          Network_Operations.getAvailableTable(context, prefs.getString("token"), reservationData).then((availableTables){
            setState(() {
              print("Called After 1 Minute");
              if(availableTables!=null&&availableTables.length>0){
                this.tables=availableTables;
              }
            });
          });
          // do something or call a function
        });
      });
    });
    Network_Operations.getDailySessionByStoreId(context, prefs.getString("token"),widget.store["id"]).then((dailySession){
      setState(() {
        currentDailySession=dailySession;
        print("Current Daily Session"+currentDailySession.toString());
      });
    });
    Network_Operations.getCategory(context,prefs.getString("token"),widget.store["id"],"")
        .then((sub) {
      if(sub!=null)
        setState(() {
          if (sub != null && sub.length > 0) {
            for(int i = 0;i<sub.length;i++){
              if((int.parse(sub[i].startTime.substring(0,2)) <= TimeOfDay.now().hour ||
                  int.parse(sub[i].endTime.substring(0,2)) >= TimeOfDay.now().hour) &&
                  int.parse(sub[i].startTime.substring(3,5)) <= TimeOfDay.now().minute){
                categories.add(sub[i]);
              }
            }
            List<String> lst = prefs.getStringList("reorderedcategories${widget.store["id"].toString()}");
            if(lst!=null&&lst.length>0&&categories != null && categories.length > 0){
              this.subCategories= lst.map(
                    (String indx) => sub
                    .where((Categories item) => int.parse(indx) == item.id)
                    .first,
              ).toList();
              if(categories.length>subCategories.length){
                int additionalElements=categories.length-subCategories.length;
                List<Categories> reversedList =  List.from(categories.reversed);

                for(int i= 0;i<additionalElements;i++){
                  subCategories.add(reversedList[i]);
                }
              }
            }else{
              subCategories.addAll(categories);
            }

            categoryName = subCategories[0].name;
            Network_Operations.getProduct(
                context,
                subCategories[0].id,
                widget.store["id"],
                "")
                .then((p) {
              setState(() {
                if (p != null && p.length > 0) {
                  isLoading = false;
                  List<String> lst = prefs.getStringList("reorderedproducts${subCategories[0].id.toString()}");

                  if(lst!=null&&lst.length>0){
                    this.products= lst.map(
                          (String indx) => p
                          .where((Products item) => int.parse(indx) == item.id)
                          .first,
                    ).toList();
                    if(p.length>products.length){
                      int additionalElements=p.length-products.length;
                      List<Products> reversedList =  List.from(p.reversed);

                      for(int i= 0;i<additionalElements;i++){
                        products.add(reversedList[i]);
                      }
                    }
                  }else{
                    products.addAll(p);
                  }

                  //products.sort((x,y)=>y.orderCount.compareTo(x.orderCount));
                } else
                  isLoading = false;
                setState(() {
                  this.userId=prefs.getString("userId");
                });
                Network_Operations.getAllDeals(
                    context, prefs.getString("token"), widget.store["id"],endDate: DateTime.now(),startDate: DateTime.now().subtract(Duration(days: 365)))
                    .then((deals) {
                  setState(() {
                    List<String> lst = prefs.getStringList("reordereddeals${widget.store["id"].toString()}");
                    if(lst!=null&&lst.length>0&&deals!=null&&deals.length>0){
                      try{
                        this.dealsList= lst.map(
                              (String indx) => deals
                              .where((dynamic item) => int.parse(indx) == item["id"])
                              .first,
                        ).toList();
                        print("Length of Api Deals: "+(deals.length>dealsList.length).toString());
                        if(deals.length>dealsList.length){
                          int additionalElements=deals.length-dealsList.length;
                          print("additional Elements: "+additionalElements.toString());
                          var reversedList =  List.from(deals.reversed);

                          for(int i= 0;i<additionalElements;i++){
                            dealsList.add(reversedList[i]);
                          }
                        }
                      }catch(e){
                        this.dealsList.addAll(deals);
                      }

                    }else{
                      if (deals.length > 0) {
                        this.dealsList.addAll(deals);
                      }
                    }
                  });
                });
                sqlite_helper().getcart1().then((value) {
                  setState(() {
                    cartList.clear();
                    cartCounter.clear();
                    cartList = value;
                    if (cartList.length > 0) {
                      for(CartItems item in cartList){
                        cartCounter.add(item.quantity);
                      }
                    }
                  });
                });
                Network_Operations.getTaxListByStoreId(context,widget.store["id"]).then((taxes){
                  setState(() {
                    for(int i=0;i<taxes.length;i++){
                      if(taxes[i].isVisible){
                        orderTaxes.add(taxes[i]);
                        print(taxes[i].toJson().toString());
                      }
                    }

                    sqlite_helper().gettotal().then((value){
                      setState(() {
                        overallTotalPrice=value[0]["SUM(totalPrice)"];
                      });
                    });
                  });
                });
              });
            });

          } else {
            isLoading = false;
            Utils.showSuccess(context, translate("in_app_errors.unable_to_place Order"));
          }
        });
    });
  });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      drawer: Drawer(
       child: Container(
         decoration: BoxDecoration(
             image: DecorationImage(
               fit: BoxFit.cover,
               //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
               image: AssetImage('assets/bb.jpg'),
             )),
         child: ListView(
           children: [
             Container(
               width: MediaQuery.of(context).size.width,
               //height: 170,
               decoration: BoxDecoration(
                 //color: yellowColor
                 //: Border.all(color: yellowColor)
               ),
               child: Column(
                 children: [
                   Container(
                     width: 170,
                     height: 150,
                     //color: yellowColor,
                     child: Center(child: Image.asset(
                       "assets/caspian11.png",
                       fit: BoxFit.contain,
                     ),
                     ),
                   ),
                   SizedBox(height: 9,),
                   Text(
                     "Exabistro - POS",
                     //"$name",
                     style: TextStyle(
                         color: blueColor,
                         fontSize: 25,
                         fontWeight: FontWeight.bold
                     ),
                   ),
                   Text(
                     "staff@mailinator.com",
                     //"$email",
                     style: TextStyle(
                         color: Colors.grey,
                         fontSize: 16,
                         fontWeight: FontWeight.w600
                     ),
                   )
                 ],
               ),
             ),
             Divider(color: yellowColor, thickness: 2,),
             ListTile(
               onTap: (){
                 if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
                   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>PaidOrdersScreenForTab(widget.store)), (route) => false);
                 }else {
                   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>PaidTabsScreen(storeId:widget.store)), (route) => false);
                 }
               },
               title: Text(
                 translate("drawer_items.today_orders"),
                 style: TextStyle(
                   color: blueColor,
                   fontSize: 22,
                   fontWeight: FontWeight.bold
                 ),
               ),
               trailing: FaIcon(FontAwesomeIcons.utensils,color: yellowColor,),
             ),
             Divider(color: yellowColor, thickness: 1,),
             ListTile(
               onTap: (){
                 Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>OrdersHistoryTabsScreen(storeId:widget.store)), (route) => false);
               },
               title: Text(
                 translate("drawer_items.orders_history"),
                 style: TextStyle(
                     color: blueColor,
                     fontSize: 22,
                     fontWeight: FontWeight.bold
                 ),
               ),
               trailing: FaIcon(FontAwesomeIcons.history,color: yellowColor,),
             ),
             Divider(color: yellowColor, thickness: 1,),
             ListTile(
               onTap: (){
                 this.isLoading=true;
                 Network_Operations.getAllDailySessionByStoreId(context, token,widget.store["id"]).then((value){
                   this.isLoading=false;
                   if(value!=null&&value.length>0){
                     showDialog(
                         context: context,
                         builder:(context){
                           return Dialog(
                             backgroundColor: Colors.transparent,
                             child: Container(
                               width: 400,
                               height:  LocalizedApp.of(context).delegate.currentLocale.languageCode=="ur"||LocalizedApp.of(context).delegate.currentLocale.languageCode=="ar"?166:130,
                               child: Utils.shiftReportDialog(context,value.last),
                             ),
                           ) ;
                         }
                     );

                   }
                 });
               },
               title: Text(
                 translate("drawer_items.shift_report"),
                 style: TextStyle(
                     color: blueColor,
                     fontSize: 22,
                     fontWeight: FontWeight.bold
                 ),
               ),
               trailing: FaIcon(FontAwesomeIcons.calendar,color: yellowColor,),
             ),
             Divider(color: yellowColor, thickness: 1,),
             ListTile(
               onTap: (){
                 SharedPreferences.getInstance().then((value) {
                   value.remove("token");
                   value.remove("roles");
                   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>LoginScreen()), (route) => false);
                 });
               },
               title: Text(
                 translate("drawer_items.logout"),
                 style: TextStyle(
                     color: blueColor,
                     fontSize: 22,
                     fontWeight: FontWeight.bold
                 ),
               ),
               trailing: FaIcon(FontAwesomeIcons.signOutAlt,color: yellowColor,),
             ),
             Divider(color: yellowColor, thickness: 1,),
           ],
         ),
       ),
      ),




      body: isLoading
          ? LoadingScreen()
          : Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/bb.jpg'),
            )
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  AppBar(
                    iconTheme: IconThemeData(color: BackgroundColor, size: 30),
                    backgroundColor: yellowColor,
                    centerTitle: true,
                    title: Text(
                        translate("main_screen.menu"),
                      style: TextStyle(
                          color: BackgroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                      ),
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView.builder(
                      itemCount:subCategories!=null?subCategories.length:0,
                      itemBuilder:(BuildContext context,int index){
                        return Padding(
                          key: ValueKey(subCategories[index].id),
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: (){
                              Network_Operations.getProduct(
                                  context,
                                  subCategories[index]
                                      .id,
                                  widget.store["id"],
                                  "")
                                  .then((p) {
                                setState(() {
                                  if (p != null &&
                                      p.length > 0) {
                                    categoryName =
                                        subCategories[index]
                                            .name;

                                    SharedPreferences.getInstance().then((prefs){
                                      List<String> lst = prefs.getStringList("reorderedproducts${subCategories[index].id.toString()}");
                                      products.clear();
                                      if(lst!=null&&lst.length>0){
                                        this.products= lst.map(
                                              (String indx) => p
                                              .where((Products item) => int.parse(indx) == item.id)
                                              .first,
                                        ).toList();
                                        if(p.length>products.length){
                                          int additionalElements=p.length-products.length;
                                          List<Products> reversedList =  List.from(p.reversed);

                                          for(int i= 0;i<additionalElements;i++){
                                            products.add(reversedList[i]);
                                          }
                                        }
                                      }else{
                                        products.addAll(p);
                                      }
                                    });

                                  }
                                });
                              });
                            },
                            child: Container(
                              width: 180,
                              height: 85,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(subCategories[index]
                                        .image !=
                                        null
                                        ? subCategories[index].image
                                        : "http://anokha.world/images/not-found.png"),
                                    fit: BoxFit.cover,
                                  )),
                              child:  Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child:  Center(
                                  child: AutoSizeText(
                                    subCategories!=null&&subCategories.length>0&&subCategories[index].name!=null?subCategories[index].name:"",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                // Center(
                                //   child: Text(
                                //     "CATEGORY",
                                //     textAlign: TextAlign.center,
                                //     style: TextStyle(
                                //         fontSize: 19,
                                //         color: Colors.white,
                                //         fontWeight: FontWeight.bold),
                                //   ),
                                // ),
                              ),

                            ),
                          ),
                        );
                      },
                      onReorder: (oldIndex,newIndex){
                        setState(() {
                          // showDialog(context: context,
                          //     builder: (context){
                          //        return Dialog(
                          //           backgroundColor: Colors.transparent,
                          //          child: Container(
                          //            width: 400,
                          //            height: 300,
                          //            child: Scaffold(
                          //              body: StatefulBuilder(
                          //                builder: (context,innersetState){
                          //                  return ListView(
                          //                    children: [
                          //                      Center(
                          //                        child: Container(
                          //                          width: 400,
                          //                          height: 300,
                          //                          child: Container(
                          //                            decoration: BoxDecoration(
                          //                                image: DecorationImage(
                          //                                  fit: BoxFit.fill,
                          //                                  //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                          //                                  image: AssetImage('assets/bb.jpg'),
                          //                                )
                          //                            ),
                          //                            child:Form(
                          //                              key: formKey,
                          //                              child: Column(
                          //                                children: [
                          //                                  Padding(
                          //                                    padding: const EdgeInsets.only(top:16.0,left:16.0,right:16.0),
                          //                                    child: TextFormField(
                          //                                      controller: email,
                          //                                      textInputAction: TextInputAction.next,
                          //                                      keyboardType: TextInputType.emailAddress,
                          //                                      autofocus: true,
                          //                                      validator: (value) {
                          //                                        if (value == null || value.isEmpty) {
                          //                                          return 'Email is Required';
                          //                                        }
                          //                                        return null;
                          //                                      },
                          //                                      decoration: InputDecoration(
                          //                                        border: OutlineInputBorder(),
                          //                                        hintText: translate("unpaid_today_orders_popup.amount_paid"),
                          //                                        hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                          //                                      ),
                          //                                    ),
                          //                                  ),
                          //                                  Padding(
                          //                                    padding: const EdgeInsets.only(top:16.0,left:16.0,right:16.0),
                          //                                    child: TextFormField(
                          //                                      controller: password,
                          //                                      textInputAction: TextInputAction.go,
                          //                                      keyboardType: TextInputType.visiblePassword,
                          //                                      autofocus: true,
                          //                                      validator: (value) {
                          //                                        if (value == null || value.isEmpty) {
                          //                                          return 'Password is Required';
                          //                                        }
                          //                                        return null;
                          //                                      },
                          //                                      decoration: InputDecoration(
                          //                                        border: OutlineInputBorder(),
                          //                                        hintText: translate("unpaid_today_orders_popup.amount_paid"),
                          //                                        hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                          //                                      ),
                          //                                    ),
                          //                                  ),
                          //                                  InkWell(
                          //                                    onTap: (){
                          //
                          //                                    },
                          //                                    child: Padding(
                          //                                      padding: EdgeInsets.all(16),
                          //                                      child: Card(
                          //                                        elevation: 8,
                          //                                        child: Container(
                          //                                          width: 230,
                          //                                          height: 50,
                          //                                          decoration: BoxDecoration(
                          //                                              borderRadius: BorderRadius.circular(4),
                          //                                              color: yellowColor
                          //                                          ),
                          //                                          child: Center(child: Text(translate("unpaid_today_orders_popup.payout"),style: TextStyle(color: BackgroundColor, fontWeight: FontWeight.bold, fontSize: 30),)),
                          //                                        ),
                          //                                      ),
                          //                                    ),
                          //                                  )
                          //                                ],
                          //                              ),
                          //                            )
                          //                          ),
                          //                        ),
                          //                      )
                          //                    ],
                          //                  );
                          //                },
                          //              ),
                          //            ),
                          //          ),
                          //        );
                          //     }
                          // );
                          if (newIndex > oldIndex) {
                            newIndex = newIndex - 1;
                          }
                          final element = subCategories.removeAt(oldIndex);
                          subCategories.insert(newIndex, element);
                          print("reorderedcategories${widget.store["id"].toString()}");
                           SharedPreferences.getInstance().then((prefs){
                             prefs.setStringList("reorderedcategories${widget.store["id"].toString()}", subCategories.map((m) => m.id.toString()).toList());
                           });
                        });
                      },
                        ),
                  ),
                ],
              )
            ),
            SizedBox(width: 5,),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    flex: 8,
                    child: Column(
                      children: [
                        // AppBar(
                        //   actions: [
                        //     Expanded(
                        //       child: Container(
                        //         height: 50,
                        //         //color: Colors.black38,
                        //         child: Center(
                        //           child: _buildChips(),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        //   backgroundColor: yellowColor,
                        //   //centerTitle: true,
                        //   //automaticallyImplyLeading: false,
                        //   title: Text(
                        //     categoryName,
                        //     style: TextStyle(
                        //         color: BackgroundColor,
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 30
                        //     ),
                        //   ),
                        // ),
                        Container(
                          color:yellowColor,
                          height: 58,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              Text(
                                  categoryName,
                                  style: TextStyle(
                                      color: BackgroundColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30
                                  ),
                                ),
                                    Container(
                                      height: 50,
                                      width: 200,
                                      //color: Colors.black38,
                                      child: Center(
                                        child: _buildChips(),
                                      ),
                                    ),

                              ],
                            ),
                          ),
                        ),
                        Expanded(
                            child: ReorderableGridView.builder(
                              onReorder: (oldIndex,newIndex){
                                setState(() {
                                  final element = products.removeAt(oldIndex);
                                  products.insert(newIndex, element);
                                  int id= subCategories.where((element) => element.name==categoryName).toList()[0].id;
                                  print("reorderedproducts${id.toString()}");
                                  SharedPreferences.getInstance().then((prefs){
                                    prefs.setStringList("reorderedproducts${id.toString()}", products.map((m) => m.id.toString()).toList());
                                  });
                                });
                              },
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 203,
                                    //childAspectRatio: 5 / 6,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    mainAxisExtent: 180
                                ),
                                itemCount: products!=null?products.length:0,
                                itemBuilder: (context, index){
                                  return InkWell(
                                    key: ValueKey(products[index].id),
                                    onTap: (){
                                      showDialog(
                                          context: context,
                                          builder:(BuildContext context){
                                            return productsPopupLayout(products[index]);
                                          });
                                    },
                                    child: Card(
                                        elevation: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: 137,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8),),
                                                    image: DecorationImage(
                                                      image: NetworkImage(products[index].image),
                                                      fit: BoxFit.cover,
                                                    )),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: 35,
                                                color: yellowColor,
                                                child: Center(
                                                  child: AutoSizeText(
                                                    products[index].name!=null?products[index].name:"",
                                                      textAlign: TextAlign.center,
                                                    style: TextStyle(

                                                      color: BackgroundColor,
                                                        fontSize: 16,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),

                                              // AutoSizeText(
                                              //   'Rs: 450.90',
                                              //   style: TextStyle(
                                              //       color: yellowColor,
                                              //       fontSize: 15,
                                              //       fontWeight: FontWeight.bold
                                              //   ),
                                              //   maxLines: 2,
                                              // ),
                                            ],
                                          ),
                                          // height: 250,
                                          // width: 150,
                                        ),
                                        // child: Container(
                                        //   height: 150,
                                        //   width: 190,
                                        //   decoration: BoxDecoration(
                                        //       borderRadius: BorderRadius.circular(8),
                                        //       image: DecorationImage(
                                        //         image: AssetImage('assets/food11.jpeg'),
                                        //         fit: BoxFit.cover,
                                        //       )),
                                        //   child: Container(
                                        //     decoration: BoxDecoration(
                                        //       color: Colors.black38,
                                        //       borderRadius: BorderRadius.circular(6),
                                        //     ),
                                        //     child: Center(
                                        //       child: Text(
                                        //         "CATEGORY",
                                        //         textAlign: TextAlign.center,
                                        //         style: TextStyle(
                                        //             fontSize: 19,
                                        //             color: Colors.white,
                                        //             fontWeight: FontWeight.bold),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // )

                                    ),
                                  );
                                })
                        )
                      ],
                    ),
                  ),
                 dealsList!=null&&dealsList.length>0?Expanded(
                    flex: 1,
                    child:
                    ReorderableListView.builder(
                        onReorder: (oldIndex,newIndex){
                          if (newIndex > oldIndex) {
                            newIndex = newIndex - 1;
                          }
                          final element = dealsList.removeAt(oldIndex);
                          dealsList.insert(newIndex, element);
                          print("reordereddeals${widget.store["id"].toString()}");
                          SharedPreferences.getInstance().then((prefs){
                            prefs.setStringList("reordereddeals${widget.store["id"].toString()}", dealsList.map((m) => m["id"].toString()).toList());
                          });
                        },
                        scrollDirection: Axis.horizontal,
                        itemCount:dealsList!=null?dealsList.length:0,
                        itemBuilder: (context, index){
                          return Padding(
                            key: ValueKey(dealsList[index]["id"]),
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: (){
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                              height: LocalizedApp.of(context).delegate.currentLocale.languageCode=="ar"||LocalizedApp.of(context).delegate.currentLocale.languageCode=="ur"?460:430,
                                              width: 400,
                                              child: dealsPopupLayout(dealsList[index])
                                          )
                                      );
                                    });
                              },
                              child: Container(
                                width: 180,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(dealsList[index]["image"] != null
                                          ? dealsList[index]["image"]
                                          : "http://anokha.world/images/not-found.png"),
                                      fit: BoxFit.cover,
                                    )),
                                child:  Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child:  Center(
                                    child: AutoSizeText(
                                    dealsList!=null&&dealsList.length>0&&dealsList[index]["name"]!=null?dealsList[index]["name"]:"",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  // Center(
                                  //   child: Text(
                                  //     "CATEGORY",
                                  //     textAlign: TextAlign.center,
                                  //     style: TextStyle(
                                  //         fontSize: 19,
                                  //         color: Colors.white,
                                  //         fontWeight: FontWeight.bold),
                                  //   ),
                                  // ),
                                ),

                              ),
                            ),
                          );
                        }),
                  ):Container(),
                ],
              ),
            ),
            SizedBox(width: 5,),
            Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: yellowColor,
                      centerTitle: true,
                      automaticallyImplyLeading: false,
                      title: Text(
                        //"Cart",
                        translate("main_screen.cart"),
                        style: TextStyle(
                            color: BackgroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 30
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          //color: Colors.teal.shade900,
                        ),
                        child: cartList.isNotEmpty? ListView.builder(
                            itemCount:cartList!=null?cartList.length:0,
                            itemBuilder: (context, index){
                              topping.clear();
                              // toppingList.clear();
                              if (cartList[index].topping != null) {
                                 List<Toppings> toppings=Toppings.toppingListFromJson(cartList[index].topping);
                                 if(toppings!=null&&toppings.length>0){
                                   for(Toppings t in toppings){
                                     topping.add(t.name+" (${widget.store["currencyCode"].toString()+""+t.price.toStringAsFixed(0) })  "+"   x"+t.quantity.toString()+"   "+widget.store["currencyCode"].toString()+": "+t.totalprice.toStringAsFixed(0)+"\n");
                                   }
                                 }
                              }
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Slidable(
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    extentRatio: 0.20,
                                    children: [
                                      SlidableAction(
                                        onPressed: (context){
                                          print(cartList[index].id);
                                          sqlite_helper()
                                              .deleteProductsById(cartList[index].id);
                                         Utils.showSuccess(context, translate("in_app_errors.item_deleted"));
                                          sqlite_helper().getcart1().then((value) {
                                            setState(() {
                                              cartCounter.clear();
                                              cartList.clear();
                                              cartList = value;
                                              if (cartList.length > 0) {
                                                for(CartItems item in cartList){
                                                  cartCounter.add(item.quantity);
                                                }
                                              }
                                            });
                                          });
                                          sqlite_helper().gettotal().then((value){
                                            setState(() {
                                              overallTotalPrice=value[0]["SUM(totalPrice)"];
                                            });
                                          });
                                        },
                                        backgroundColor: Color(0xFFFE4A49),
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                      ),

                                    ],
                                  ),
                                  child: Card(
                                    elevation: 5,
                                    //color: BackgroundColor,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      //height: 230,
                                      decoration: BoxDecoration(
                                        //color: BackgroundColor,
                                        //border: Border.all(color: BackgroundColor, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: yellowColor,
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8),),
                                            ),
                                            child: Center(
                                              child: AutoSizeText(
                                                cartList[index].productName,
                                                style: TextStyle(
                                                    color: BackgroundColor,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold
                                                ),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex:2,
                                                  child: Container(
                                                    width: 90,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      //color: yellowColor,
                                                      border: Border.all(color: yellowColor, width: 2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Center(
                                                      child: AutoSizeText(
                                                        //'Unit Price: ',
                                                        translate("cart_items.unit_price"),
                                                        style: TextStyle(
                                                            color: yellowColor,
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2,),
                                                Expanded(
                                                  flex:3,
                                                  child: Container(
                                                    width: 90,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: yellowColor, width: 2),
                                                      //color: BackgroundColor,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Center(
                                                      child: Text(widget.store["currencyCode"].toString()+": "+cartList[index].price.toStringAsFixed(0),style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),)
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex:2,
                                                  child: Container(
                                                    width: 90,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      //color: yellowColor,
                                                      border: Border.all(color: yellowColor, width: 2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Center(
                                                      child: AutoSizeText(
                                                        //'Quantity: ',
                                                        translate("cart_items.quantity"),
                                                        style: TextStyle(
                                                            color: yellowColor,
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2,),
                                                Expanded(
                                                  flex:3,
                                                  child: Container(
                                                    width: 90,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: yellowColor, width: 2),
                                                      //color: BackgroundColor,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Center(
                                                      child: Counter(
                                                        minValue: 1,
                                                        maxValue: 10,

                                                        initialValue: cartCounter.isEmpty?1:cartCounter[index],
                                                        decimalPlaces: 0,
                                                        color: yellowColor,
                                                        onChanged: (value){
                                                          setState(() {
                                                            cartCounter[index]=value;
                                                            var priceOfTopping=0.0;
                                                            if(cartList[index].topping!=null){
                                                              List<Toppings> topping= Toppings.toppingListFromJson(cartList[index].topping);
                                                              if(topping!=null){
                                                                for(Toppings t in topping) {
                                                                  setState(() {
                                                                    priceOfTopping =
                                                                        priceOfTopping +
                                                                            t.totalprice;
                                                                  });
                                                                }
                                                              }
                                                            }
                                                            if(value !=null) {
                                                              sqlite_helper().updatePriceAndQuantity(cartList[index].id, (cartList[index].price*cartCounter[index])+priceOfTopping, cartCounter[index]).then((updatedItemsCount){
                                                                if(updatedItemsCount!=null&&updatedItemsCount>0){
                                                                  sqlite_helper().getcart1().then((value) {
                                                                    setState(() {
                                                                      cartCounter.clear();
                                                                      cartList.clear();
                                                                      cartList = value;
                                                                      if (cartList.length > 0) {
                                                                        for(CartItems item in cartList){
                                                                          cartCounter.add(item.quantity);
                                                                        }
                                                                      }
                                                                    });
                                                                  });
                                                                  sqlite_helper().gettotal().then((value){
                                                                    setState(() {
                                                                      overallTotalPrice=value[0]["SUM(totalPrice)"];
                                                                    });
                                                                  });
                                                                }else{
                                                                  Utils.showSuccess(context, translate("in_app_errors.unable_to_update"));
                                                                }
                                                              });
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                            Expanded(
                                                  flex:2,
                                                  child: Container(
                                                    width: 90,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      //color: yellowColor,
                                                      border: Border.all(color: yellowColor, width: 2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Center(
                                                      child: AutoSizeText(
                                                        //'Size: ',
                                                        translate("cart_items.size"),
                                                        style: TextStyle(
                                                            color: yellowColor,
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2,),
                                                 Expanded(
                                                  flex:3,
                                                  child: Container(
                                                    width: 90,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: yellowColor, width: 2),
                                                      //color: BackgroundColor,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Center(
                                                      child: AutoSizeText(
                                                        cartList[index].sizeName!=null?cartList[index].sizeName:"N/A",
                                                        style: TextStyle(
                                                            color: blueColor,
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child:cartList.isNotEmpty&&cartList[index].topping!=null||cartList.isNotEmpty&&cartList[index].dealProducts!=null? Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  // Expanded(
                                                  //   flex:2,
                                                  //   child: Container(
                                                  //     width: 90,
                                                  //     height: 100,
                                                  //     decoration: BoxDecoration(
                                                  //       //color: yellowColor,
                                                  //       border: Border.all(color: yellowColor, width: 2),
                                                  //       borderRadius: BorderRadius.circular(8),
                                                  //     ),
                                                  //     child: Center(
                                                  //       child: AutoSizeText(
                                                  //         'Extras: ',
                                                  //         style: TextStyle(
                                                  //             color: yellowColor,
                                                  //             fontSize: 22,
                                                  //             fontWeight: FontWeight.bold
                                                  //         ),
                                                  //         maxLines: 2,
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  // SizedBox(width: 2,),
                                                  Expanded(
                                                    flex:3,
                                                    child: InkWell(
                                                      onTap: (){
                                                        if(cartList[index].topping!=null){
                                                          showDialog(
                                                              context: context,
                                                              builder:(context){
                                                                return Dialog(
                                                                  backgroundColor: Colors.transparent,
                                                                  child: Container(
                                                                    width: 400,
                                                                    height:400,
                                                                    child: editToppingDialog(cartList[index]),
                                                                  ),
                                                                );
                                                              }
                                                          );
                                                        }
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: yellowColor, width: 2),
                                                          //color: BackgroundColor,
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            AutoSizeText(
                                                             cartList[index].dealProducts!=null?"Deal Products: ":'Extras: ',
                                                              style: TextStyle(
                                                                  color: yellowColor,
                                                                  fontSize: 22,
                                                                  fontWeight: FontWeight.bold
                                                              ),
                                                              maxLines: 2,
                                                            ),
                                                            Center(
                                                              child: Text((){
                                                                if(topping!=null&&topping.length>0){
                                                                  return topping
                                                                      .toString()
                                                                      .replaceAll("[", "- ")
                                                                      .replaceAll(",", "- ")
                                                                      .replaceAll("]", "");
                                                                }else if(cartList[index].dealProducts!=null){
                                                                  var dealProductsList=[];

                                                                  for(String dealProduct in cartList[index].dealProducts.split(",")){
                                                                    dealProductsList.add("- "+dealProduct+"\n");
                                                                  }
                                                                  return dealProductsList.toString().replaceAll("[", " ")
                                                                      .replaceAll(",", "")
                                                                      .replaceAll("]", "");
                                                                }
                                                                return "N/A";
                                                              }(),
                                                                style: TextStyle(
                                                                    color: blueColor,
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.bold
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              ):Container(),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: yellowColor,
                                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(6), bottomLeft: Radius.circular(6),),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  AutoSizeText(
                                                    //'Price',
                                                    translate("cart_items.price"),
                                                    style: TextStyle(
                                                        color: BackgroundColor,
                                                        fontSize: 25,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                  Row(
                                                    children: [
                                                      AutoSizeText(
                                                        widget.store["currencyCode"].toString()+": ",
                                                        style: TextStyle(
                                                            color: BackgroundColor,
                                                            fontSize: 25,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                      AutoSizeText(
                                                        cartList[index].totalPrice.toString(),
                                                        style: TextStyle(
                                                            color: blueColor,
                                                            fontSize: 25,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ),
                                        ],
                                      )
                                    ),
                                  ),
                                ),
                              );
                            })
                            :Center(
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              //color: Colors.white60,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/emptycart.png'),
                                )
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child:  Container(
                        color: blueColor,
                        width: MediaQuery.of(context)
                            .size
                            .width,
                       // height: 70,
                        child: Padding(
                          padding:
                          const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Text(
                                //"TOTAL ",
                                translate("main_screen.total"),
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight
                                        .bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":"",
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: yellowColor,
                                        fontWeight:
                                        FontWeight
                                            .bold),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(0)+"/-":"0.0/-",
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors
                                            .white,
                                        fontWeight:
                                        FontWeight
                                            .bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            widget.store["dineIn"]!=null&&widget.store["dineIn"]&&tables!=null&&tables.length>0?Expanded(
                              child: Container(
                                // width: MediaQuery.of(context).size.width,
                                // height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  //color: Colors.teal.shade900,
                                ),
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:tables!=null?tables.length:0,
                                    itemBuilder: (context, index){
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: (){
                                            setState(() {
                                              overallTotalPriceWithTax=0.0;
                                              totalTax=0.0;
                                              typeBasedTaxes.clear();
                                              taxesList.clear();
                                              orderItems.clear();
                                              discountValue.clear();
                                              priceWithDiscount=0.0;
                                              deductedPrice=0.0;
                                              nonServiceTaxesPrice=0.0;
                                              serviceBasedTaxes=0.0;
                                              selectedDiscountType=null;
                                              selectedTable=tables[index]["name"];
                                              selectedTableId=tables[index]["id"];
                                              customerName.clear();
                                              customerPhone.clear();
                                              overallTotalPriceWithTax=overallTotalPrice;
                                              serviceBasedTaxes=overallTotalPrice;
                                              if(orderTaxes!=null&&orderTaxes.length>0){
                                                var tempTaxList = orderTaxes.where((element) => element.dineIn);
                                                if(tempTaxList!=null&&tempTaxList.length>0){
                                                  for(Tax t in tempTaxList.toList()){
                                                    setState(() {
                                                      if(t.isService!=null&&t.isService==true){
                                                        if(t.percentage!=null&&t.percentage!=0.0){
                                                          var percentTax= overallTotalPrice/100*t.percentage;
                                                          totalTax=totalTax+percentTax;
                                                          serviceBasedTaxes=serviceBasedTaxes+percentTax;
                                                          overallTotalPriceWithTax=overallTotalPriceWithTax+percentTax;
                                                        }
                                                        if(t.price!=null&&t.price!=0.0){
                                                          overallTotalPriceWithTax=overallTotalPriceWithTax+t.price;
                                                          totalTax=totalTax+t.price;
                                                          serviceBasedTaxes=serviceBasedTaxes+t.price;
                                                        }
                                                        typeBasedTaxes.add(t);
                                                      }



                                                      taxesList.add({
                                                        "TaxId": t.id
                                                      });
                                                    });


                                                  }
                                                  typeBasedTaxes.add(Tax(name: "Discount",price:0,percentage:0,isService:true));
                                                  typeBasedTaxes.add(Tax(name: "Net Total",price:overallTotalPriceWithTax,isService:true));

                                                  for(Tax t in tempTaxList.toList()){
                                                    setState(() {
                                                      if(t.isService==null||t.isService==false){
                                                        print("Non Service Taxes json "+t.toJson().toString());
                                                        if(t.percentage!=null&&t.percentage!=0.0) {
                                                          var percentTax = overallTotalPriceWithTax / 100 * t.percentage;
                                                          nonServiceTaxesPrice=nonServiceTaxesPrice+percentTax;
                                                          totalTax=totalTax+percentTax;
                                                        }else if(t.price!=null&&t.price!=0.0){
                                                          nonServiceTaxesPrice=nonServiceTaxesPrice+t.price;
                                                          totalTax=totalTax+t.price;
                                                        }
                                                        typeBasedTaxes.add(t);
                                                      }
                                                    });
                                                  }
                                                  overallTotalPriceWithTax=overallTotalPriceWithTax+nonServiceTaxesPrice;
                                                }
                                              }
                                              if(discountService!="null"&&discountService=="true"){
                                                showDialog(context: context, builder:(BuildContext context){
                                                  return Dialog(
                                                      //backgroundColor: Colors.transparent,
                                                      // insetPadding: EdgeInsets.all(16),
                                                      child: Container(
                                                          height:380,
                                                          width: MediaQuery.of(context).size.width/2,
                                                          child: orderPopUpHorizontalDineIn()
                                                      )
                                                  );
                                                });
                                              }
                                              else{
                                                showDialog(context: context, builder:(BuildContext context){
                                                  return Dialog(
                                                      backgroundColor: Colors.transparent,
                                                      // insetPadding: EdgeInsets.all(16),
                                                      child: Container(
                                                          height:300,
                                                          width: MediaQuery.of(context).size.width/2,
                                                          child: orderPopupHorizontalDineInWithOutDiscount()
                                                      )
                                                  );
                                                });
                                              }

                                            });
                                          },
                                          child: Container(
                                            width: 150,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: yellowColor,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child:  Center(
                                              child: AutoSizeText(
                                                tables[index]["name"],
                                                style: TextStyle(
                                                    color: BackgroundColor,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold
                                                ),
                                                maxLines: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ):Container(),
                          ],
                        ),

                      ),
                    ),
                    widget.store["takeAway"]!=null&&widget.store["takeAway"]? Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: ()async{
                            setState(() {
                              overallTotalPriceWithTax=0.0;
                              typeBasedTaxes.clear();
                              totalTax=0.0;
                              typeBasedTaxes.clear();
                              taxesList.clear();
                              orderItems.clear();
                              discountValue.clear();
                              customerName.clear();
                              customerPhone.clear();
                              priceWithDiscount=0.0;
                              deductedPrice=0.0;
                              serviceBasedTaxes=0.0;
                              nonServiceTaxesPrice=0.0;
                              selectedDiscountType=null;
                              overallTotalPriceWithTax=overallTotalPrice;
                              serviceBasedTaxes=overallTotalPriceWithTax;
                              if(orderTaxes!=null&&orderTaxes.length>0){
                                var tempTaxList = orderTaxes.where((element) => element.takeAway);
                                if(tempTaxList!=null&&tempTaxList.length>0){
                                  for(Tax t in tempTaxList.toList()){
                                    setState(() {
                                      if(t.isService!=null&&t.isService==true){
                                        if(t.percentage!=null&&t.percentage!=0.0){
                                          var percentTax= overallTotalPrice/100*t.percentage;
                                          totalTax=totalTax+percentTax;
                                          serviceBasedTaxes=serviceBasedTaxes+percentTax;
                                          overallTotalPriceWithTax=overallTotalPriceWithTax+percentTax;
                                        }
                                        if(t.price!=null&&t.price!=0.0){
                                          overallTotalPriceWithTax=overallTotalPriceWithTax+t.price;
                                          totalTax=totalTax+t.price;
                                          serviceBasedTaxes=serviceBasedTaxes+t.price;
                                        }
                                        typeBasedTaxes.add(t);
                                      }



                                      taxesList.add({
                                        "TaxId": t.id
                                      });
                                    });


                                  }
                                  typeBasedTaxes.add(Tax(name: "Discount",price:0,percentage:0,isService:true));
                                  typeBasedTaxes.add(Tax(name: "Net Total",price:overallTotalPriceWithTax,isService:true));
                                  for(Tax t in tempTaxList.toList()){
                                    setState(() {
                                      if(t.isService==null||t.isService==false){
                                        if(t.percentage!=null&&t.percentage!=0.0) {
                                          var percentTax = overallTotalPriceWithTax / 100 * t.percentage;
                                          nonServiceTaxesPrice=nonServiceTaxesPrice+percentTax;
                                          totalTax=totalTax+percentTax;
                                        }else if(t.price!=null&&t.price!=0.0){
                                          nonServiceTaxesPrice=nonServiceTaxesPrice+t.price;
                                          totalTax=totalTax+t.price;
                                        }
                                        typeBasedTaxes.add(t);
                                      }
                                    });
                                  }
                                  overallTotalPriceWithTax=overallTotalPriceWithTax+nonServiceTaxesPrice;
                                }
                              }
                            });

                            var result=await Utils.check_connection();
                            if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi) {
                              var exists = await Utils
                                  .checkOfflineDataExists(
                                  "addOrderStaff");
                              if (exists) {
                                offlineData = await Utils
                                    .getOfflineData(
                                    "addOrderStaff");
                                showAlertDialog(
                                    context, offlineData);
                              }else{
                                if(discountService!="null"&&discountService=="true"){
                                  showDialog(context: context, builder:(BuildContext context){
                                    return Dialog(
                                        backgroundColor: Colors.transparent,
                                        // insetPadding: EdgeInsets.all(16),
                                        child: Container(
                                            height:450,
                                            width: MediaQuery.of(context).size.width/2,
                                            child: orderPopupHorizontalTakeAway()
                                        )
                                    );
                                  });
                                }
                                else{
                                  showDialog(context: context, builder:(BuildContext context){
                                    return Dialog(
                                        backgroundColor: Colors.transparent,
                                        // insetPadding: EdgeInsets.all(16),
                                        child: Container(
                                            height:300,
                                            width: MediaQuery.of(context).size.width/2,
                                            child: orderPopupHorizontalTakeAwayWithOutDiscount()
                                        )
                                    );
                                  });
                                }
                              }
                            }else{
                              if(discountService!="null"&&discountService=="true"){
                                showDialog(context: context, builder:(BuildContext context){
                                  return Dialog(
                                      backgroundColor: Colors.transparent,
                                      // insetPadding: EdgeInsets.all(16),
                                      child: Container(
                                          height:450,
                                          width: MediaQuery.of(context).size.width/2,
                                          child: orderPopupHorizontalTakeAway()
                                      )
                                  );
                                });
                              }
                              else{
                                showDialog(context: context, builder:(BuildContext context){
                                  return Dialog(
                                      backgroundColor: Colors.transparent,
                                      // insetPadding: EdgeInsets.all(16),
                                      child: Container(
                                          height:300,
                                          width: MediaQuery.of(context).size.width/2,
                                          child: orderPopupHorizontalTakeAwayWithOutDiscount()
                                      )
                                  );
                                });
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: yellowColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:  Center(
                              child: AutoSizeText(
                                //'Take-Away',
                                translate("main_screen.takeaway_btn"),
                                style: TextStyle(
                                    color: BackgroundColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ):Container(),

                    widget.store["delivery"]!=null&&widget.store["delivery"]? Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: ()async{
                            setState(() {
                              overallTotalPriceWithTax=0.0;
                              totalTax=0.0;
                              typeBasedTaxes.clear();
                              taxesList.clear();
                              orderItems.clear();
                              discountValue.clear();
                              customerAddress.clear();
                              customerName.clear();
                              customerPhone.clear();
                              priceWithDiscount=0.0;
                              deductedPrice=0.0;
                              serviceBasedTaxes=0.0;
                              nonServiceTaxesPrice=0.0;
                              selectedDiscountType=null;
                              overallTotalPriceWithTax=overallTotalPrice;
                              serviceBasedTaxes=overallTotalPrice;
                              if(orderTaxes!=null&&orderTaxes.length>0){
                                var tempTaxList = orderTaxes.where((element) => element.delivery);
                                if(tempTaxList!=null&&tempTaxList.length>0){
                                  for(Tax t in tempTaxList.toList()){
                                    setState(() {
                                      if(t.isService!=null&&t.isService==true){
                                        if(t.percentage!=null&&t.percentage!=0.0){
                                          var percentTax= overallTotalPrice/100*t.percentage;
                                          totalTax=totalTax+percentTax;
                                          serviceBasedTaxes=serviceBasedTaxes+percentTax;
                                          overallTotalPriceWithTax=overallTotalPriceWithTax+percentTax;
                                        }
                                        if(t.price!=null&&t.price!=0.0){
                                          overallTotalPriceWithTax=overallTotalPriceWithTax+t.price;
                                          totalTax=totalTax+t.price;
                                          serviceBasedTaxes=serviceBasedTaxes+t.price;
                                        }
                                        typeBasedTaxes.add(t);
                                      }
                                      taxesList.add({
                                        "TaxId": t.id
                                      });
                                    });
                                  }
                                  typeBasedTaxes.add(Tax(name: "Discount",price:0,percentage:0,isService:true));
                                  typeBasedTaxes.add(Tax(name: "Net Total",price:overallTotalPriceWithTax,isService:true));
                                  for(Tax t in tempTaxList.toList()){
                                    setState(() {
                                      if(t.isService==null||t.isService==false){
                                        print("Non Service Taxes json "+t.toJson().toString());
                                        if(t.percentage!=null&&t.percentage!=0.0) {
                                          var percentTax = overallTotalPriceWithTax / 100 * t.percentage;
                                          nonServiceTaxesPrice=nonServiceTaxesPrice+percentTax;
                                          totalTax=totalTax+percentTax;
                                        }else if(t.price!=null&&t.price!=0.0){
                                          nonServiceTaxesPrice=nonServiceTaxesPrice+t.price;
                                          totalTax=totalTax+t.price;
                                        }
                                        typeBasedTaxes.add(t);
                                      }
                                    });
                                  }
                                  overallTotalPriceWithTax=overallTotalPriceWithTax+nonServiceTaxesPrice;
                                }
                              }

                            });
                            var result=await Utils.check_connection();
                            if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi) {
                              var exists = await Utils
                                  .checkOfflineDataExists(
                                  "addOrderStaff");
                              if (exists) {
                                offlineData = await Utils
                                    .getOfflineData(
                                    "addOrderStaff");
                                showAlertDialog(
                                    context, offlineData);
                              }else{
                                if(discountService!="null"&&discountService=="true"){
                                  showDialog(context: context, builder:(BuildContext context){
                                    return Dialog(
                                        backgroundColor: Colors.transparent,
                                        // insetPadding: EdgeInsets.all(16),
                                        child: Container(
                                            height:450,
                                            width: MediaQuery.of(context).size.width/2,
                                            child: orderPopupHorizontalDelivery()
                                        )
                                    );
                                  });
                                }
                                else{
                                  showDialog(context: context, builder:(BuildContext context){
                                    return Dialog(
                                        backgroundColor: Colors.transparent,
                                        // insetPadding: EdgeInsets.all(16),
                                        child: Container(
                                            height:370,
                                            width: MediaQuery.of(context).size.width/2,
                                            child: orderPopupHorizontalDeliveryWithoutDiscount()
                                        )
                                    );
                                  });
                                }
                              }
                            }else{
                              if(discountService!="null"&&discountService=="true"){
                                showDialog(context: context, builder:(BuildContext context){
                                  return Dialog(
                                      backgroundColor: Colors.transparent,
                                      // insetPadding: EdgeInsets.all(16),
                                      child: Container(
                                          height:450,
                                          width: MediaQuery.of(context).size.width/2,
                                          child: orderPopupHorizontalDelivery()
                                      )
                                  );
                                });
                              }
                              else{
                                showDialog(context: context, builder:(BuildContext context){
                                  return Dialog(
                                      backgroundColor: Colors.transparent,
                                      // insetPadding: EdgeInsets.all(16),
                                      child: Container(
                                          height:300,
                                          width: MediaQuery.of(context).size.width/2,
                                          child: orderPopupHorizontalDeliveryWithoutDiscount()
                                      )
                                  );
                                });
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: yellowColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:  Center(
                              child: AutoSizeText(
                                //'Delivery',
                                translate("main_screen.delivery_btn"),
                                style: TextStyle(
                                    color: BackgroundColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ):Container(),
                    SizedBox(height: 5,),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  //Popup's
  Widget dealsPopupLayout(dynamic deal) {
    var count = 1;
    debugPrint(deal.toString());
    var price = 0.0,actualPrice=0.0;
    var updatedPrice = 0.0,updatedActualPrice=0.0;
    List<String> dealProducts = [];
    if (deal["productDeals"] != null && deal["productDeals"].length > 0) {
      for (var pd in deal["productDeals"]) {
        if (pd["product"] != null && pd["size"] != null) {
          dealProducts.add(pd["product"]["name"] +
              " (" +
              pd["size"]["name"] +
              ") x" +
              pd["quantity"].toString());
        }
      }
    }
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
          builder: (thisLowerContext, innerSetState) {
            if (deal != null) {
              innerSetState(() {
                price = deal["price"];
                actualPrice = deal["actualPrice"];
                print("Actual Deal Price $actualPrice");
              });
            }
            return Center(
              child: Container(
                height: LocalizedApp.of(context).delegate.currentLocale.languageCode=="ar"||LocalizedApp.of(context).delegate.currentLocale.languageCode=="ur"?460:430,
                width: 400,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                      image: AssetImage('assets/bb.jpg'),
                    )),
                child: Column(
                  children: [

                    Card(
                      elevation: 8,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        color: yellowColor,
                        child: Center(
                          child: Text(
                            deal["name"],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          //height: 80,
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        //"Discounted Price: ",
                                        translate("deals_popup.discounted_price"),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: yellowColor),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            widget.store["currencyCode"]+": ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                                color: yellowColor),
                                          ),
                                          Text(
                                            updatedPrice.toString() == "0.0"
                                                ? price.toString()
                                                : updatedPrice.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                                color: blueColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        //"Actual Price: ",
                                        translate("deals_popup.actual_price"),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: yellowColor),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            widget.store["currencyCode"]+": ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                                color: yellowColor),
                                          ),
                                          Text(
                                            updatedActualPrice.toString()=="0.0"? actualPrice.toString():updatedActualPrice.toString(),
                                            style: TextStyle(
                                                decoration: TextDecoration.lineThrough,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                                color: blueColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )
                          )),
                    ),
                    Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: ListTile(
                          title: Text(
                            //"Products",
                            translate("deals_popup.products"),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: yellowColor,
                                fontSize: 28),
                          ),
                          subtitle: Text(
                            dealProducts
                                .toString()
                                .replaceAll("[", "")
                                .replaceAll("]", ""),
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: blueColor,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  //"Quantity: ",
                                  translate("deals_popup.quantity"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: yellowColor),
                                ),
                                Counter(
                                    initialValue: count,
                                    minValue: 1,
                                    maxValue: 10,
                                    onChanged: (value) {
                                      innerSetState(() {
                                        count = value;
                                        updatedPrice = 0.0;
                                        updatedPrice = price * count;
                                        updatedActualPrice = actualPrice * count;
                                      });
                                    },
                                    step: 1,
                                    decimalPlaces: 0),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        print(dealProducts.toString());
                        sqlite_helper().dealCheckAlreadyExists(deal["id"]).then((foundDeals){
                          if(foundDeals!=null&&foundDeals.length>0){
                            var tempDeals=CartItems(
                                id: foundDeals[0]["id"],
                                productId: null,
                                productName: deal["name"],
                                isDeal: 1,
                                dealId: deal["id"],
                                sizeId: null,
                                sizeName: null,
                                price: deal["price"],
                                totalPrice: updatedPrice == 0.0 ? price : updatedPrice,
                                quantity: count,
                                dealProducts: dealProducts.toString(),
                                storeId: deal["storeId"],
                                topping: null);
                            sqlite_helper().updateCart(tempDeals).then((updatedEntries){
                              sqlite_helper().getcart1().then((value) {
                                setState(() {
                                  cartList.clear();
                                  cartCounter.clear();
                                  cartList = value;
                                  if (cartList.length > 0) {
                                    for(CartItems item in cartList){
                                      cartCounter.add(item.quantity);
                                    }
                                  }
                                });
                              });
                              sqlite_helper().gettotal().then((value){
                                setState(() {
                                  overallTotalPrice=value[0]["SUM(totalPrice)"];
                                });
                              });
                            });
                            Navigator.of(context).pop();
                           Utils.showSuccess(context, translate("in_app_errors.updated_to_cart_successfully"));                          }else{
                            sqlite_helper()
                                .create_cart(CartItems(
                                productId: null,
                                productName: deal["name"],
                                isDeal: 1,
                                dealId: deal["id"],
                                sizeId: null,
                                sizeName: null,
                                price: deal["price"],
                                totalPrice: updatedPrice == 0.0 ? price : updatedPrice,
                                quantity: count,
                                dealProducts: dealProducts.toString(),
                                storeId: deal["storeId"],
                                topping: null))
                                .then((isInserted) {
                              if (isInserted > 0) {
                                innerSetState(() {

                                  sqlite_helper().getcart1().then((value) {
                                    setState(() {
                                      cartCounter.clear();
                                      cartList.clear();
                                      cartList = value;
                                      if (cartList.length > 0) {
                                        for(CartItems item in cartList){
                                          cartCounter.add(item.quantity);
                                        }
                                      }
                                    });
                                  });
                                  sqlite_helper().gettotal().then((value){
                                    setState(() {
                                      overallTotalPrice=value[0]["SUM(totalPrice)"];
                                    });
                                  });
                                });
                                Navigator.of(context).pop();
                                Utils.showSuccess(context, translate("in_app_errors.added_to_cart_successfully"));
                              } else {
                                Navigator.of(context).pop();
                                Utils.showSuccess(context, translate("in_app_errors.some_error_occur"));
                              }
                            });
                          }
                        });

                      },
                      child: Card(
                        elevation: 8,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 65,
                          decoration: BoxDecoration(
                              color: yellowColor,
                              borderRadius: BorderRadius.circular(4)),
                          child: Center(
                            child: Text(
                              //"Add To Cart",
                              translate("deals_popup.addToCard_btn"),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget orderPopupHorizontalDelivery(){
    var discountedValue=0.0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context,innersetState){
          return Center(
            child: Container(
                height:450,
                width: MediaQuery.of(context).size.width/2,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                      image: AssetImage('assets/bb.jpg'),
                    )
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      color: yellowColor,
                      child: Center(
                        child: Text(
                          //"Place Order For Delivery",
                          translate("delivery_popup.deliveryLabel"),
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerName,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Name*",
                                              translate("delivery_popup.customer_name_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerAddress,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Address*",
                                              translate("delivery_popup.customer_address_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        // Padding(
                                        //   padding: const EdgeInsets.all(8.0),
                                        //   child: DropdownButtonFormField<String>(
                                        //     decoration: InputDecoration(
                                        //       labelText: "Select Discount Type",
                                        //       alignLabelWithHint: true,
                                        //       labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                        //       enabledBorder: OutlineInputBorder(
                                        //       ),
                                        //       focusedBorder:  OutlineInputBorder(
                                        //         borderSide: BorderSide(color:yellowColor),
                                        //       ),
                                        //     ),
                                        //
                                        //     value: selectedDiscountType,
                                        //     onChanged: (Value) {
                                        //       innersetState(() {
                                        //         selectedDiscountType = Value;
                                        //         priceWithDiscount=overallTotalPrice;
                                        //         deductedPrice=0.0;
                                        //         if(typeBasedTaxes.last.name=="Discount"){
                                        //           priceWithDiscount=overallTotalPrice;
                                        //           typeBasedTaxes.remove(typeBasedTaxes.last);
                                        //         }
                                        //         if(discountValue.text.isNotEmpty){
                                        //           if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                        //             var tempPercentage=(overallTotalPrice/100*double.parse(discountValue.text));
                                        //             setState(() {
                                        //               deductedPrice=tempPercentage;
                                        //             });
                                        //             priceWithDiscount=priceWithDiscount-tempPercentage+totalTax;
                                        //             print("percent discount "+priceWithDiscount.toString());
                                        //             typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(discountValue.text)));
                                        //           }else if(selectedDiscountType!=null&&selectedDiscountType=="Cash"){
                                        //             setState(() {
                                        //               deductedPrice=double.parse(discountValue.text);
                                        //             });
                                        //             var tempSum=overallTotalPrice-double.parse(discountValue.text);
                                        //             priceWithDiscount=tempSum+totalTax;
                                        //             typeBasedTaxes.add(Tax(name: "Discount",price: double.parse(discountValue.text)));
                                        //           }
                                        //         }else{
                                        //           innersetState(() {
                                        //             priceWithDiscount=overallTotalPriceWithTax;
                                        //           });
                                        //         }
                                        //       });
                                        //     },
                                        //     items: discountType.map((value) {
                                        //       return  DropdownMenuItem<String>(
                                        //         value: value,
                                        //         child: Row(
                                        //           children: <Widget>[
                                        //             Text(
                                        //               value,
                                        //               style:  TextStyle(color: yellowColor,fontSize: 13),
                                        //             ),
                                        //             //user.icon,
                                        //             //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                                        //           ],
                                        //         ),
                                        //       );
                                        //     }).toList(),
                                        //   ),
                                        // ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerPhone,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(

                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Phone# *",
                                              translate("delivery_popup.customer_phone_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: discountValue,
                                            keyboardType: TextInputType.number,
                                            onChanged: (value){
                                              innersetState(() {
                                                print(discountValue.text);
                                                print("Total Tax "+totalTax.toString());
                                                priceWithDiscount=overallTotalPriceWithTax;
                                                if(value.isNotEmpty){
                                                  discountedValue=0.0;
                                                  // // if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                                  //   var tempPercentage=((priceWithDiscount-nonServiceTaxesPrice)/100)*double.parse(value);
                                                  //   priceWithDiscount=priceWithDiscount-tempPercentage;
                                                  //   priceWithDiscount=priceWithDiscount;
                                                  //   print("percentage"+tempPercentage.toString());
                                                  //   setState(() {
                                                  //     deductedPrice=tempPercentage;
                                                  //   });
                                                  //
                                                  //   for(int i=0;i<typeBasedTaxes.length;i++){
                                                  //     if(typeBasedTaxes[i].isService==null||typeBasedTaxes[i].isService==false){
                                                  //       if(typeBasedTaxes[i].price!=null&&typeBasedTaxes[i].price!=0.0){
                                                  //         priceWithDiscount=priceWithDiscount+typeBasedTaxes[i].price;
                                                  //       }else if(typeBasedTaxes[i].percentage!=null&&typeBasedTaxes[i].percentage!=0.0){
                                                  //         var tempPercentage = (priceWithDiscount/100)*typeBasedTaxes[i].percentage;
                                                  //         print("Service Tax "+tempPercentage.toString());
                                                  //         priceWithDiscount=priceWithDiscount+tempPercentage;
                                                  //       }
                                                  //     }
                                                  //   }
                                                  //   typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(value)));
                                                  // }else
                                                  print("Price with service charges only "+serviceBasedTaxes.toStringAsFixed(0));
                                                  print("Non Service Charges "+nonServiceTaxesPrice.toStringAsFixed(0));
                                                  print("Price with Discount before cash "+priceWithDiscount.toStringAsFixed(0));
                                                  var tempSum=serviceBasedTaxes-double.parse(value);
                                                  setState(() {
                                                    deductedPrice=double.parse(discountValue.text);
                                                  });
                                                  priceWithDiscount=tempSum;
                                                  discountedValue=priceWithDiscount;
                                                  typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Net Total").toList()[0])]=Tax(name: "Net Total",price: priceWithDiscount,isService:true);
                                                  print("Price with Discount after cash "+priceWithDiscount.toStringAsFixed(0));
                                                  // print("Price with Discount after service charges removal "+priceWithDiscount.toStringAsFixed(0));
                                                  for(int i=0;i<typeBasedTaxes.length;i++){
                                                    if(typeBasedTaxes[i].isService==null||typeBasedTaxes[i].isService==false){
                                                      if(typeBasedTaxes[i].price!=null&&typeBasedTaxes[i].price!=0.0){
                                                        priceWithDiscount=priceWithDiscount+typeBasedTaxes[i].price;
                                                      }else if(typeBasedTaxes[i].percentage!=null&&typeBasedTaxes[i].percentage!=0.0){
                                                        var tempPercentage = typeBasedTaxes[i].percentage*(discountedValue/100);
                                                        print("Service Tax "+tempPercentage.toString());
                                                        //  typeBasedTaxes[i]=Tax(name: typeBasedTaxes[i].name,percentage: null,price: tempPercentage,isService:typeBasedTaxes[i].isService);
                                                        priceWithDiscount=priceWithDiscount+tempPercentage;
                                                        // discountedTax=discountedTax+tempPercentage;
                                                      }
                                                    }
                                                  }

                                                  print("Price after Taxes "+priceWithDiscount.toStringAsFixed(0));
                                                  typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Discount").toList()[0])]=Tax(name: "Discount",price: double.parse(value),isService: true);
                                                }else{
                                                  innersetState(() {
                                                    priceWithDiscount=overallTotalPriceWithTax;
                                                    typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Net Total").toList()[0])]=Tax(name: "Net Total",price: overallTotalPriceWithTax-nonServiceTaxesPrice,isService:true);
                                                    typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Discount").toList()[0])]=Tax(name: "Discount",price: 0,percentage:0,isService: true);
                                                  });
                                                }

                                              });

                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Discount Amount",
                                              translate("delivery_popup.discount_amount_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  //"SubTotal: ",
                                                  translate("delivery_popup.sub_total"),
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":" ",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(0)+"/-":"0.0/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          blueColor,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Container(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width,
                                              height: 175,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: yellowColor),
                                                //borderRadius: BorderRadius.circular(8)
                                              ),

                                              child: ListView.builder(itemCount: typeBasedTaxes.length,itemBuilder: (context, index){
                                                return  Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0?typeBasedTaxes[index].name+" (${typeBasedTaxes[index].percentage.toStringAsFixed(0)})":typeBasedTaxes[index].name,
                                                        style: TextStyle(
                                                            fontSize:
                                                            16,
                                                            color:
                                                            yellowColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text((){
                                                            if(typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0){
                                                              return widget.store["currencyCode"].toString()+": "+typeBasedTaxes[index].price.toStringAsFixed(0);
                                                            }else if((typeBasedTaxes[index].isService==null||typeBasedTaxes[index].isService==false)&&typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&discountedValue>0){
                                                              var temp=(discountedValue)/100*typeBasedTaxes[index].percentage;
                                                              return widget.store["currencyCode"].toString()+": "+(temp).toStringAsFixed(0);
                                                            }else if((typeBasedTaxes[index].isService==null||typeBasedTaxes[index].isService==false)&&typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&priceWithDiscount==0){
                                                              var temp=(overallTotalPriceWithTax-nonServiceTaxesPrice)/100*typeBasedTaxes[index].percentage;
                                                              return widget.store["currencyCode"].toString()+": "+(temp).toStringAsFixed(0);
                                                            }else
                                                              return widget.store["currencyCode"].toString()+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(0);
                                                          }(),
                                                            style: TextStyle(
                                                                fontSize:
                                                                16,
                                                                color:
                                                                blueColor,
                                                                fontWeight:
                                                                FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  //"Total: ",
                                                  translate("delivery_popup.total"),
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":"",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(0)+"/-":overallTotalPriceWithTax.toStringAsFixed(0)+"/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          blueColor,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height:15),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: ()async{
                                    if(customerName.text!=null&&customerName.text.isNotEmpty&&customerAddress.text!=null&&customerAddress.text.isNotEmpty&&customerPhone.text.isNotEmpty){
                                      for(int i=0;i<cartList.length;i++){
                                        orderItems.add({
                                          "dealid":cartList[i].dealId,
                                          "name":cartList[i].productName,
                                          "price":cartList[i].price,
                                          "quantity":cartList[i].quantity,
                                          "totalprice":cartList[i].totalPrice,
                                          "havetopping":cartList[i].topping=="null"||cartList[i].topping==null || cartList[i].topping== "[]" ?false:jsonDecode(cartList[i].topping).length>0?true:false,
                                          "sizeid":cartList[i].sizeId,
                                          "IsDeal": cartList[i].isDeal==0?false:true,
                                          "productid":cartList[i].productId,
                                          "orderitemstoppings":cartList[i].topping==null||cartList[i].topping == "[]"?[]:jsonDecode(cartList[i].topping),
                                        });
                                      }
                                      dynamic order = {
                                        "DailySessionNo": currentDailySession!=null?currentDailySession:7,
                                        "storeId":widget.store["id"],
                                        "DeviceToken":null,
                                        "ordertype":3,
                                        "NetTotal":overallTotalPrice,
                                        //  "grosstotal":widget.netTotal,
                                        "comment":null,
                                        "TableId":null,
                                        "DeliveryAddress" : customerAddress.text,
                                        "DeliveryLongitude" : null,
                                        "DeliveryLatitude" : null,
                                        "PaymentType" : 1,
                                        "orderitems":orderItems,
                                        "CardNumber": null,
                                        "CVV": null,
                                        "ExpiryDate": null,
                                        "OrderTaxes":taxesList,
                                        "VoucherCode": "",
                                        "OrderStatus":7,
                                        "customerName":customerName.text,
                                        "discountedPrice":deductedPrice,
                                        "CustomerContactNo":customerPhone.text,
                                        "employeeId": int.parse(userId),
                                        "IsCashPaid":selectedType=="Create Order"?false:selectedType=="Payment"?true:false,
                                        "CreatedOn":DateTime.now()
                                      };
                                      debugPrint(jsonEncode(order,toEncodable: Utils.myEncode));
                                      var result=await Utils.check_connection();
                                      if(result == ConnectivityResult.none){
                                        var offlineOrderList=[];
                                        //final body = jsonEncode(order,toEncodable: Utils.myEncode);
                                        var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                        if(exists){
                                          print("in if");
                                          offlineData = await Utils.getOfflineData("addOrderStaff");
                                          //print(offlineData.syncData);

                                          for(int i=0;i<jsonDecode(offlineData.syncData).length;i++){
                                            print(jsonDecode(offlineData.syncData)[i]);
                                            offlineOrderList.add(jsonDecode(offlineData.syncData)[i]);
                                          }
                                          offlineOrderList.add(order);
                                        }else
                                          offlineOrderList.add(order);

                                        //offlineOrderList.add(body);
                                        await Utils.addOfflineData("addOrderStaff",jsonEncode(offlineOrderList,toEncodable: Utils.myEncode));
                                        offlineData = await Utils.getOfflineData("addOrderStaff");
                                        sqlite_helper().deletecart();
                                        orderItems.clear();
                                        sqlite_helper().getcart1().then((value) {
                                          setState(() {
                                            cartList.clear();
                                            cartCounter.clear();
                                            cartList = value;
                                            if (cartList.length > 0) {
                                              for(CartItems item in cartList){
                                                cartCounter.add(item.quantity);
                                              }
                                            }
                                            isLoading=false;
                                          });
                                        });
                                        sqlite_helper().gettotal().then((value){
                                          setState(() {
                                            overallTotalPrice=value[0]["SUM(totalPrice)"];
                                          });
                                        });
                                        Navigator.of(context).pop();
                                       Utils.showSuccess(context, translate("in_app_errors.your_order_stored_offline"));
                                      }
                                      else if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
                                        SharedPreferences.getInstance().then((prefs){
                                          setState(() {
                                            isLoading=true;
                                            Navigator.of(context).pop(context);
                                          });
                                          Network_Operations.placeOrder(context, prefs.getString("token"), order).then((orderPlaced){
                                            if(orderPlaced!=null){
                                              setState(() {
                                                this.ordersList=orderPlaced;
                                              });
                                              orderItems.clear();
                                              sqlite_helper().getcart1().then((value) {
                                                setState(() {
                                                  cartCounter.clear();
                                                  cartList.clear();
                                                  cartList = value;
                                                  if (cartList.length > 0) {
                                                    for(CartItems item in cartList){
                                                      cartCounter.add(item.quantity);
                                                    }
                                                  }
                                                  isLoading=false;
                                                });
                                              });
                                              sqlite_helper().gettotal().then((value){
                                                setState(() {
                                                  overallTotalPrice=value[0]["SUM(totalPrice)"];
                                                });
                                              });
                                              if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
                                                showDialog(
                                                    context: this.context,
                                                    builder: (context){
                                                      return Dialog(
                                                        backgroundColor: Colors.transparent,
                                                        child: Container(
                                                          width: 400,
                                                          height: 370,
                                                          child: payoutDialog(orderPlaced),
                                                        ),
                                                      );
                                                    }
                                                );

                                              }
                                              Utils.showSuccess(context, translate("in_app_errors.order_placed_successfully"));
                                            }else{
                                              setState(() {
                                                isLoading=false;
                                              });
                                              Utils.showSuccess(context, translate("in_app_errors.unable_to_place Order"));
                                            }
                                          });
                                        });
                                      }
                                    }else{
                                      Utils.showSuccess(context, translate("in_app_errors.provide_all_required_information"));
                                    }
                                  },
                                  child: Card(
                                    elevation:8,
                                    child: Container(
                                      width: 400,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          color: yellowColor,
                                          borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Center(
                                        child: Text(
                                          //"Submit Order",
                                          translate("delivery_popup.submitOrder_btn"),
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ),
          );
        },
      ),
    );
  }
  Widget orderPopupHorizontalDeliveryWithoutDiscount(){

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context,innersetState){
          return Center(
            child: Container(
                height:370,
                width: MediaQuery.of(context).size.width/2,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                      image: AssetImage('assets/bb.jpg'),
                    )
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      color: yellowColor,
                      child: Center(
                        child: Text(
                          //"Place Order For Delivery",
                          translate("delivery_popup.deliveryLabel"),
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerName,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Name*",
                                              translate("delivery_popup.customer_name_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerPhone,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Phone# *",
                                              translate("delivery_popup.customer_phone_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerAddress,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Address *",
                                              translate("delivery_popup.customer_address_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 30,),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  //"SubTotal: ",
                                                  translate("delivery_popup.sub_total"),
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":" ",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(0)+"/-":"0.0/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          blueColor,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Container(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width,
                                              height: 115,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: yellowColor),
                                                //borderRadius: BorderRadius.circular(8)
                                              ),

                                              child: ListView.builder(itemCount: typeBasedTaxes.length,itemBuilder: (context, index){
                                                return  Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0?typeBasedTaxes[index].name+" (${typeBasedTaxes[index].percentage.toStringAsFixed(0)})":typeBasedTaxes[index].name,
                                                        style: TextStyle(
                                                            fontSize:
                                                            16,
                                                            color:
                                                            yellowColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text((){
                                                            if(typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0){
                                                              return widget.store["currencyCode"].toString()+" "+typeBasedTaxes[index].price.toStringAsFixed(0);
                                                            }else if(typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1){
                                                              return widget.store["currencyCode"].toString()+": "+(typeBasedTaxes[index].percentage/100*overallTotalPrice).toStringAsFixed(0);
                                                            }
                                                            else
                                                              return widget.store["currencyCode"].toString()+": "+(typeBasedTaxes[index].percentage/100*overallTotalPrice).toStringAsFixed(0);
                                                          }()
                                                            // typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0?widget.store["currencyCode"].toString()+" "+typeBasedTaxes[index].price.toStringAsFixed(0):typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1?widget.store["currencyCode"].toString()+": "+(typeBasedTaxes[index].percentage/100*overallTotalPrice).toStringAsFixed(0):widget.store["currencyCode"].toString()+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(0)
                                                            ,style: TextStyle(
                                                                fontSize:
                                                                16,
                                                                color:
                                                                blueColor,
                                                                fontWeight:
                                                                FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  //"Total: ",
                                                  translate("delivery_popup.total"),
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":"",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(0)+"/-":overallTotalPriceWithTax.toStringAsFixed(0)+"/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          blueColor,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: ()async{
                          if(customerName.text!=null&&customerName.text.isNotEmpty&&customerAddress.text!=null&&customerAddress.text.isNotEmpty&&customerPhone.text.isNotEmpty){
                            for(int i=0;i<cartList.length;i++){
                              orderItems.add({
                                "dealid":cartList[i].dealId,
                                "name":cartList[i].productName,
                                "price":cartList[i].price,
                                "quantity":cartList[i].quantity,
                                "totalprice":cartList[i].totalPrice,
                                "havetopping":cartList[i].topping=="null"||cartList[i].topping==null || cartList[i].topping== "[]" ?false:jsonDecode(cartList[i].topping).length>0?true:false,
                                "sizeid":cartList[i].sizeId,
                                "IsDeal": cartList[i].isDeal==0?false:true,
                                "productid":cartList[i].productId,
                                "orderitemstoppings":cartList[i].topping==null||cartList[i].topping == "[]"?[]:jsonDecode(cartList[i].topping),
                              });
                            }
                            dynamic order = {
                              "DailySessionNo": currentDailySession!=null?currentDailySession:7,
                              "storeId":widget.store["id"],
                              "DeviceToken":null,
                              "ordertype":3,
                              "NetTotal":overallTotalPrice,
                              //  "grosstotal":widget.netTotal,
                              "comment":null,
                              "TableId":null,
                              "DeliveryAddress" : customerAddress.text,
                              "DeliveryLongitude" : null,
                              "DeliveryLatitude" : null,
                              "PaymentType" : 1,
                              "orderitems":orderItems,
                              "CardNumber": null,
                              "CVV": null,
                              "ExpiryDate": null,
                              "OrderTaxes":taxesList,
                              "VoucherCode": "",
                              "OrderStatus":7,
                              "customerName":customerName.text,
                              "discountedPrice":deductedPrice,
                              "CustomerContactNo":customerPhone.text,
                              "employeeId": int.parse(userId),
                              "IsCashPaid":selectedType=="Create Order"?false:selectedType=="Payment"?true:false,
                              "CreatedOn":DateTime.now()
                            };
                            debugPrint(jsonEncode(order,toEncodable: Utils.myEncode));
                            var result=await Utils.check_connection();
                            if(result == ConnectivityResult.none){
                              var offlineOrderList=[];
                              //final body = jsonEncode(order,toEncodable: Utils.myEncode);
                              var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                              if(exists){
                                print("in if");
                                offlineData = await Utils.getOfflineData("addOrderStaff");
                                //print(offlineData.syncData);

                                for(int i=0;i<jsonDecode(offlineData.syncData).length;i++){
                                  print(jsonDecode(offlineData.syncData)[i]);
                                  offlineOrderList.add(jsonDecode(offlineData.syncData)[i]);
                                }
                                offlineOrderList.add(order);
                              }else
                                offlineOrderList.add(order);

                              //offlineOrderList.add(body);
                              await Utils.addOfflineData("addOrderStaff",jsonEncode(offlineOrderList,toEncodable: Utils.myEncode));
                              offlineData = await Utils.getOfflineData("addOrderStaff");
                              sqlite_helper().deletecart();
                              orderItems.clear();
                              sqlite_helper().getcart1().then((value) {
                                setState(() {
                                  cartList.clear();
                                  cartCounter.clear();
                                  cartList = value;
                                  if (cartList.length > 0) {
                                    for(CartItems item in cartList){
                                      cartCounter.add(item.quantity);
                                    }
                                  }
                                  isLoading=false;
                                });
                              });
                              sqlite_helper().gettotal().then((value){
                                setState(() {
                                  overallTotalPrice=value[0]["SUM(totalPrice)"];
                                });
                              });
                              Navigator.of(context).pop();
                             Utils.showSuccess(context, translate("in_app_errors.your_order_stored_offline"));
                            }
                            else if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
                              SharedPreferences.getInstance().then((prefs){
                                setState(() {
                                  isLoading=true;
                                  Navigator.of(context).pop(context);
                                });
                                Network_Operations.placeOrder(context, prefs.getString("token"), order).then((orderPlaced){
                                  if(orderPlaced!=null){
                                    setState(() {
                                      this.ordersList=orderPlaced;
                                    });
                                    orderItems.clear();
                                    sqlite_helper().getcart1().then((value) {
                                      setState(() {
                                        cartCounter.clear();
                                        cartList.clear();
                                        cartList = value;
                                        if (cartList.length > 0) {
                                          for(CartItems item in cartList){
                                            cartCounter.add(item.quantity);
                                          }
                                        }
                                        isLoading=false;
                                      });
                                    });
                                    sqlite_helper().gettotal().then((value){
                                      setState(() {
                                        overallTotalPrice=value[0]["SUM(totalPrice)"];
                                      });
                                    });
                                    if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
                                      showDialog(
                                          context: this.context,
                                          builder: (context){
                                            return Dialog(
                                              backgroundColor: Colors.transparent,
                                              child: Container(
                                                width: 400,
                                                height: 370,
                                                child: payoutDialog(orderPlaced),
                                              ),
                                            );
                                          }
                                      );

                                    }
                                    Utils.showSuccess(context, translate("in_app_errors.order_placed_successfully"));
                                  }else{
                                    setState(() {
                                      isLoading=false;
                                    });
                                    Utils.showSuccess(context, translate("in_app_errors.unable_to_place Order"));
                                  }
                                });
                              });
                            }
                          }else{
                            Utils.showSuccess(context, translate("in_app_errors.provide_all_required_information"));
                          }
                        },
                        child: Card(
                          elevation:8,
                          child: Container(
                            width: 400,
                            height: 60,
                            decoration: BoxDecoration(
                                color: yellowColor,
                                borderRadius: BorderRadius.circular(4)
                            ),
                            child: Center(
                              child: Text(
                                //"Submit Order",
                                translate("delivery_popup.submitOrder_btn"),
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ),
          );
        },
      ),
    );
  }

  var discountType=["Cash","Percentage"];
  var priceWithDiscount=0.0,deductedPrice=0.0;
  String selectedType="Payment",selectedDiscountType;
  Widget orderPopupHorizontalTakeAway(){
    var discountedValue=0.0;
    return Scaffold(

      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context,innersetState){
          return Center(
            child: Container(
                height:380,
                width: MediaQuery.of(context).size.width/2,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                      image: AssetImage('assets/bb.jpg'),
                    )
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      color: yellowColor,
                      child: Center(
                        child: Text(
                          //"Place Order For Take-Away",
                          translate("takeAway_popup.takeAwayLabel"),
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Expanded(
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.all(8.0),
                                  //     child: DropdownButtonFormField<String>(
                                  //       decoration: InputDecoration(
                                  //         labelText: "Select Type",
                                  //         alignLabelWithHint: true,
                                  //         labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                  //         enabledBorder: OutlineInputBorder(
                                  //         ),
                                  //         focusedBorder:  OutlineInputBorder(
                                  //           borderSide: BorderSide(color:yellowColor),
                                  //         ),
                                  //       ),
                                  //
                                  //       value: selectedType,
                                  //       onChanged: (Value) {
                                  //         innersetState(() {
                                  //           selectedType = Value;
                                  //         });
                                  //       },
                                  //       items: types.map((value) {
                                  //         return  DropdownMenuItem<String>(
                                  //           value: value,
                                  //           child: Row(
                                  //             children: <Widget>[
                                  //               Text(
                                  //                 value,
                                  //                 style:  TextStyle(color: yellowColor,fontSize: 13),
                                  //               ),
                                  //               //user.icon,
                                  //               //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                                  //             ],
                                  //           ),
                                  //         );
                                  //       }).toList(),
                                  //     ),
                                  //   ),
                                  // ),

                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerName,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Name*",
                                              translate("takeAway_popup.customer_name_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerPhone,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Phone# *",
                                              translate("takeAway_popup.customer_phone_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        // Padding(
                                        //   padding: const EdgeInsets.all(8.0),
                                        //   child: DropdownButtonFormField<String>(
                                        //     decoration: InputDecoration(
                                        //       labelText: "Select Discount Type",
                                        //       alignLabelWithHint: true,
                                        //       labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                        //       enabledBorder: OutlineInputBorder(
                                        //       ),
                                        //       focusedBorder:  OutlineInputBorder(
                                        //         borderSide: BorderSide(color:yellowColor),
                                        //       ),
                                        //     ),
                                        //
                                        //     value: selectedDiscountType,
                                        //     onChanged: (Value) {
                                        //       innersetState(() {
                                        //         selectedDiscountType = Value;
                                        //        // priceWithDiscount=overallTotalPrice;
                                        //         deductedPrice=0.0;
                                        //         if(typeBasedTaxes.last.name=="Discount"){
                                        //           priceWithDiscount=overallTotalPrice;
                                        //           typeBasedTaxes.remove(typeBasedTaxes.last);
                                        //         }
                                        //         if(discountValue.text.isNotEmpty){
                                        //           if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                        //             var tempPercentage=(overallTotalPrice/100*double.parse(discountValue.text));
                                        //             setState(() {
                                        //               deductedPrice=tempPercentage;
                                        //             });
                                        //             priceWithDiscount=priceWithDiscount-tempPercentage+totalTax;
                                        //             typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(discountValue.text)));
                                        //           }else if(selectedDiscountType!=null&&selectedDiscountType=="Cash"){
                                        //             setState(() {
                                        //               deductedPrice=double.parse(discountValue.text);
                                        //             });
                                        //             var tempSum=overallTotalPrice-double.parse(discountValue.text);
                                        //             priceWithDiscount=tempSum+totalTax;
                                        //             typeBasedTaxes.add(Tax(name: "Discount",price: double.parse(discountValue.text)));
                                        //           }
                                        //         }else{
                                        //           innersetState(() {
                                        //             priceWithDiscount=overallTotalPriceWithTax;
                                        //           });
                                        //         }
                                        //       });
                                        //     },
                                        //     items: discountType.map((value) {
                                        //       return  DropdownMenuItem<String>(
                                        //         value: value,
                                        //         child: Row(
                                        //           children: <Widget>[
                                        //             Text(
                                        //               value,
                                        //               style:  TextStyle(color: yellowColor,fontSize: 13),
                                        //             ),
                                        //             //user.icon,
                                        //             //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                                        //           ],
                                        //         ),
                                        //       );
                                        //     }).toList(),
                                        //   ),
                                        // ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: discountValue,
                                            keyboardType: TextInputType.number,
                                            onChanged: (value){
                                              innersetState(() {
                                                print(discountValue.text);
                                                print("Total Tax "+totalTax.toString());
                                                priceWithDiscount=overallTotalPriceWithTax;
                                                if(value.isNotEmpty){
                                                  discountedValue=0.0;
                                                  // // if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                                  //   var tempPercentage=((priceWithDiscount-nonServiceTaxesPrice)/100)*double.parse(value);
                                                  //   priceWithDiscount=priceWithDiscount-tempPercentage;
                                                  //   priceWithDiscount=priceWithDiscount;
                                                  //   print("percentage"+tempPercentage.toString());
                                                  //   setState(() {
                                                  //     deductedPrice=tempPercentage;
                                                  //   });
                                                  //
                                                  //   for(int i=0;i<typeBasedTaxes.length;i++){
                                                  //     if(typeBasedTaxes[i].isService==null||typeBasedTaxes[i].isService==false){
                                                  //       if(typeBasedTaxes[i].price!=null&&typeBasedTaxes[i].price!=0.0){
                                                  //         priceWithDiscount=priceWithDiscount+typeBasedTaxes[i].price;
                                                  //       }else if(typeBasedTaxes[i].percentage!=null&&typeBasedTaxes[i].percentage!=0.0){
                                                  //         var tempPercentage = (priceWithDiscount/100)*typeBasedTaxes[i].percentage;
                                                  //         print("Service Tax "+tempPercentage.toString());
                                                  //         priceWithDiscount=priceWithDiscount+tempPercentage;
                                                  //       }
                                                  //     }
                                                  //   }
                                                  //   typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(value)));
                                                  // }else
                                                  print("Price with service charges only "+serviceBasedTaxes.toStringAsFixed(0));
                                                  print("Non Service Charges "+nonServiceTaxesPrice.toStringAsFixed(0));
                                                  print("Price with Discount before cash "+priceWithDiscount.toStringAsFixed(0));
                                                  var tempSum=serviceBasedTaxes-double.parse(value);
                                                  setState(() {
                                                    deductedPrice=double.parse(discountValue.text);
                                                  });
                                                  priceWithDiscount=tempSum;
                                                  discountedValue=priceWithDiscount;
                                                  typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Net Total").toList()[0])]=Tax(name: "Net Total",price: priceWithDiscount,isService:true);
                                                  print("Price with Discount after cash "+priceWithDiscount.toStringAsFixed(0));
                                                  // print("Price with Discount after service charges removal "+priceWithDiscount.toStringAsFixed(0));
                                                  for(int i=0;i<typeBasedTaxes.length;i++){
                                                    if(typeBasedTaxes[i].isService==null||typeBasedTaxes[i].isService==false){
                                                      if(typeBasedTaxes[i].price!=null&&typeBasedTaxes[i].price!=0.0){
                                                        priceWithDiscount=priceWithDiscount+typeBasedTaxes[i].price;
                                                      }else if(typeBasedTaxes[i].percentage!=null&&typeBasedTaxes[i].percentage!=0.0){
                                                        var tempPercentage = typeBasedTaxes[i].percentage*(discountedValue/100);
                                                        print("Service Tax "+tempPercentage.toString());
                                                        //  typeBasedTaxes[i]=Tax(name: typeBasedTaxes[i].name,percentage: null,price: tempPercentage,isService:typeBasedTaxes[i].isService);
                                                        priceWithDiscount=priceWithDiscount+tempPercentage;
                                                        // discountedTax=discountedTax+tempPercentage;
                                                      }
                                                    }
                                                  }

                                                  print("Price after Taxes "+priceWithDiscount.toStringAsFixed(0));
                                                  typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Discount").toList()[0])]=Tax(name: "Discount",price: double.parse(value),isService: true);
                                                }else{
                                                  innersetState(() {
                                                    priceWithDiscount=overallTotalPriceWithTax;
                                                    typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Net Total").toList()[0])]=Tax(name: "Net Total",price: overallTotalPriceWithTax-nonServiceTaxesPrice,isService:true);
                                                    typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Discount").toList()[0])]=Tax(name: "Discount",price: 0,percentage:0,isService: true);
                                                  });
                                                }

                                              });

                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Discount Amount",
                                              translate("takeAway_popup.discount_amount_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 50,
                                            color: yellowColor,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    //"SubTotal: ",
                                                    translate("takeAway_popup.sub_total"),
                                                    style: TextStyle(
                                                        fontSize:
                                                        20,
                                                        color:
                                                        Colors.white,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":" ",
                                                        style: TextStyle(
                                                            fontSize:
                                                            20,
                                                            color:
                                                            Colors.white,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(0)+"/-":"0.0/-",
                                                        style: TextStyle(
                                                            fontSize:
                                                            20,
                                                            color:
                                                            blueColor,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Container(
                                                width: MediaQuery.of(
                                                    context)
                                                    .size
                                                    .width,
                                                height: 105,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: yellowColor),
                                                  //borderRadius: BorderRadius.circular(8)
                                                ),

                                                child: ListView.builder(itemCount: typeBasedTaxes.length,itemBuilder: (context, index){
                                                  return  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Text(
                                                          typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0?typeBasedTaxes[index].name+" (${typeBasedTaxes[index].percentage.toStringAsFixed(0)})":typeBasedTaxes[index].name,
                                                          style: TextStyle(
                                                              fontSize:
                                                              16,
                                                              color:
                                                              yellowColor,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text((){
                                                              if(typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0){
                                                                return widget.store["currencyCode"].toString()+": "+typeBasedTaxes[index].price.toStringAsFixed(0);
                                                              }else if((typeBasedTaxes[index].isService==null||typeBasedTaxes[index].isService==false)&&typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&discountedValue>0){
                                                                print("Price with Discount First If "+discountedValue.toStringAsFixed(0));
                                                                var temp=(discountedValue)/100*typeBasedTaxes[index].percentage;
                                                                return widget.store["currencyCode"].toString()+": "+(temp).toStringAsFixed(0);
                                                              }else if((typeBasedTaxes[index].isService==null||typeBasedTaxes[index].isService==false)&&typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&priceWithDiscount==0){
                                                                print("Price with Discount second If "+priceWithDiscount.toStringAsFixed(0));
                                                                var temp=(overallTotalPriceWithTax-nonServiceTaxesPrice)/100*typeBasedTaxes[index].percentage;
                                                                return widget.store["currencyCode"].toString()+": "+(temp).toStringAsFixed(0);
                                                              }else
                                                                return widget.store["currencyCode"].toString()+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(0);

                                                            }(),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                  16,
                                                                  color:
                                                                  blueColor,
                                                                  fontWeight:
                                                                  FontWeight.bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                })
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 50,
                                            color: yellowColor,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    //"Total: ",
                                                    translate("takeAway_popup.total"),
                                                    style: TextStyle(
                                                        fontSize:
                                                        20,
                                                        color:
                                                        Colors.white,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":"",
                                                        style: TextStyle(
                                                            fontSize:
                                                            20,
                                                            color:
                                                            Colors.white,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(0)+"/-":overallTotalPriceWithTax.toStringAsFixed(0)+"/-",
                                                        style: TextStyle(
                                                            fontSize:
                                                            20,
                                                            color:
                                                            blueColor,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height:10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: ()async{

                                      for(int i=0;i<cartList.length;i++){
                                        orderItems.add({
                                          "dealid":cartList[i].dealId,
                                          "name":cartList[i].productName,
                                          "price":cartList[i].price,
                                          "quantity":cartList[i].quantity,
                                          "totalprice":cartList[i].totalPrice,
                                          "havetopping":cartList[i].topping=="null"||cartList[i].topping==null || cartList[i].topping== "[]" ?false:jsonDecode(cartList[i].topping).length>0?true:false,
                                          "sizeid":cartList[i].sizeId,
                                          "IsDeal": cartList[i].isDeal==0?false:true,
                                          "productid":cartList[i].productId,
                                          "orderitemstoppings":cartList[i].topping==null||cartList[i].topping == "[]"?[]:jsonDecode(cartList[i].topping),
                                        });
                                      }
                                      print(taxesList);
                                      dynamic order = {
                                        "DailySessionNo": currentDailySession!=null?currentDailySession:7,
                                        "storeId":widget.store["id"],
                                        "DeviceToken":null,
                                        "ordertype":2,
                                        "NetTotal":overallTotalPrice,
                                        //  "grosstotal":widget.netTotal,
                                        "comment":null,
                                        "TableId":null,
                                        "DeliveryAddress" : null,
                                        "DeliveryLongitude" : null,
                                        "DeliveryLatitude" : null,
                                        "PaymentType" : 1,
                                        "orderitems":orderItems,
                                        "CardNumber": null,
                                        "CVV": null,
                                        "ExpiryDate": null,
                                        "OrderTaxes":taxesList,
                                        "VoucherCode": "",
                                        "OrderStatus":7,
                                        "customerName":customerName.text,
                                        "CustomerContactNo":customerPhone.text,
                                        "employeeId": int.parse(userId),
                                        "IsCashPaid":selectedType=="Create Order"?false:selectedType=="Payment"?true:false,
                                        "CreatedOn":DateTime.now(),
                                        "discountedPrice":deductedPrice,
                                      };
                                      var result=await Utils.check_connection();
                                      if(result == ConnectivityResult.none){
                                        var offlineOrderList=[];
                                        //final body = jsonEncode(order,toEncodable: Utils.myEncode);
                                        var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                        if(exists){
                                          offlineData = await Utils.getOfflineData("addOrderStaff");
                                          //print(offlineData.syncData);

                                          for(int i=0;i<jsonDecode(offlineData.syncData).length;i++){
                                            print(jsonDecode(offlineData.syncData)[i]);
                                            offlineOrderList.add(jsonDecode(offlineData.syncData)[i]);
                                          }
                                          offlineOrderList.add(order);
                                        }else
                                          offlineOrderList.add(order);

                                        //offlineOrderList.add(body);
                                        await Utils.addOfflineData("addOrderStaff",jsonEncode(offlineOrderList,toEncodable: Utils.myEncode));
                                        offlineData = await Utils.getOfflineData("addOrderStaff");
                                        sqlite_helper().deletecart();
                                        orderItems.clear();
                                        sqlite_helper().getcart1().then((value) {
                                          setState(() {
                                            cartCounter.clear();
                                            cartList.clear();
                                            cartList = value;
                                            if (cartList.length > 0) {
                                              for(CartItems item in cartList){
                                                cartCounter.add(item.quantity);
                                              }
                                            }
                                            isLoading=false;
                                          });
                                        });
                                        sqlite_helper().gettotal().then((value){
                                          setState(() {
                                            overallTotalPrice=value[0]["SUM(totalPrice)"];
                                          });
                                        });

                                        Navigator.of(context).pop();
                                       Utils.showSuccess(context, translate("in_app_errors.your_order_stored_offline"));
                                      }
                                      else if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
                                        SharedPreferences.getInstance().then((prefs){
                                          setState(() {
                                            isLoading=true;
                                            Navigator.of(context).pop(context);
                                          });
                                          Network_Operations.placeOrder(context, prefs.getString("token"), order).then((orderPlaced){
                                            if(orderPlaced!=null){
                                              setState(() {
                                                this.ordersList=orderPlaced;
                                              });
                                              orderItems.clear();
                                              sqlite_helper().getcart1().then((value) {
                                                setState(() {
                                                  cartCounter.clear();
                                                  cartList.clear();
                                                  cartList = value;
                                                  if (cartList.length > 0) {
                                                    for(CartItems item in cartList){
                                                      cartCounter.add(item.quantity);
                                                    }
                                                  }
                                                  isLoading=false;
                                                });
                                              });
                                              sqlite_helper().gettotal().then((value){
                                                setState(() {
                                                  overallTotalPrice=value[0]["SUM(totalPrice)"];
                                                });
                                              });
                                              if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
                                                showDialog(
                                                    context: this.context,
                                                    builder: (context){
                                                      return Dialog(
                                                        backgroundColor: Colors.transparent,
                                                        child: Container(
                                                          width: 400,
                                                          height: 370,
                                                          child: payoutDialog(orderPlaced),
                                                        ),
                                                      );
                                                    }
                                                );
                                                
                                              }
                                              Utils.showSuccess(context, translate("in_app_errors.order_placed_successfully"));
                                            }else{
                                              Utils.showSuccess(context, translate("in_app_errors.unable_to_place Order"));
                                            }
                                          });
                                        });
                                      }
                                  },
                                  child: Card(
                                    elevation:8,
                                    child: Container(
                                      width: 400,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          color: yellowColor,
                                          borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Center(
                                        child: Text(
                                          //"Submit Order",
                                          translate("takeAway_popup.submitOrder_btn"),
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ),
          );
        },
      ),
    );
  }
  Widget orderPopupHorizontalTakeAwayWithOutDiscount(){
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context,innersetState){
          return Center(
            child: Container(
                height:300,
                width: MediaQuery.of(context).size.width/2,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                      image: AssetImage('assets/bb.jpg'),
                    )
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      color: yellowColor,
                      child: Center(
                        child: Text(
                          //"Place Order For Take-Away",
                          translate("takeAway_popup.takeAwayLabel"),
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                             SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerName,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Name*",
                                              translate("takeAway_popup.customer_name_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerPhone,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Phone# *",
                                              translate("takeAway_popup.customer_phone_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            onTap: ()async{

                                              for(int i=0;i<cartList.length;i++){
                                                orderItems.add({
                                                  "dealid":cartList[i].dealId,
                                                  "name":cartList[i].productName,
                                                  "price":cartList[i].price,
                                                  "quantity":cartList[i].quantity,
                                                  "totalprice":cartList[i].totalPrice,
                                                  "havetopping":cartList[i].topping=="null"||cartList[i].topping==null || cartList[i].topping== "[]" ?false:jsonDecode(cartList[i].topping).length>0?true:false,
                                                  "sizeid":cartList[i].sizeId,
                                                  "IsDeal": cartList[i].isDeal==0?false:true,
                                                  "productid":cartList[i].productId,
                                                  "orderitemstoppings":cartList[i].topping==null||cartList[i].topping == "[]"?[]:jsonDecode(cartList[i].topping),
                                                });
                                              }
                                              print(taxesList);
                                              dynamic order = {
                                                "DailySessionNo": currentDailySession!=null?currentDailySession:7,
                                                "storeId":widget.store["id"],
                                                "DeviceToken":null,
                                                "ordertype":2,
                                                "NetTotal":overallTotalPrice,
                                                //  "grosstotal":widget.netTotal,
                                                "comment":null,
                                                "TableId":null,
                                                "DeliveryAddress" : null,
                                                "DeliveryLongitude" : null,
                                                "DeliveryLatitude" : null,
                                                "PaymentType" : 1,
                                                "orderitems":orderItems,
                                                "CardNumber": null,
                                                "CVV": null,
                                                "ExpiryDate": null,
                                                "OrderTaxes":taxesList,
                                                "VoucherCode": "",
                                                "OrderStatus":7,
                                                "customerName":customerName.text,
                                                "CustomerContactNo":customerPhone.text,
                                                "employeeId": int.parse(userId),
                                                "IsCashPaid":selectedType=="Create Order"?false:selectedType=="Payment"?true:false,
                                                "CreatedOn":DateTime.now(),
                                                "discountedPrice":deductedPrice,
                                              };
                                              var result=await Utils.check_connection();
                                              if(result == ConnectivityResult.none){
                                                var offlineOrderList=[];
                                                //final body = jsonEncode(order,toEncodable: Utils.myEncode);
                                                var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                                if(exists){
                                                  offlineData = await Utils.getOfflineData("addOrderStaff");
                                                  //print(offlineData.syncData);

                                                  for(int i=0;i<jsonDecode(offlineData.syncData).length;i++){
                                                    print(jsonDecode(offlineData.syncData)[i]);
                                                    offlineOrderList.add(jsonDecode(offlineData.syncData)[i]);
                                                  }
                                                  offlineOrderList.add(order);
                                                }else
                                                  offlineOrderList.add(order);

                                                //offlineOrderList.add(body);
                                                await Utils.addOfflineData("addOrderStaff",jsonEncode(offlineOrderList,toEncodable: Utils.myEncode));
                                                offlineData = await Utils.getOfflineData("addOrderStaff");
                                                sqlite_helper().deletecart();
                                                orderItems.clear();
                                                sqlite_helper().getcart1().then((value) {
                                                  setState(() {
                                                    cartCounter.clear();
                                                    cartList.clear();
                                                    cartList = value;
                                                    if (cartList.length > 0) {
                                                      for(CartItems item in cartList){
                                                        cartCounter.add(item.quantity);
                                                      }
                                                    }
                                                    isLoading=false;
                                                  });
                                                });
                                                sqlite_helper().gettotal().then((value){
                                                  setState(() {
                                                    overallTotalPrice=value[0]["SUM(totalPrice)"];
                                                  });
                                                });

                                                Navigator.of(context).pop();
                                               Utils.showSuccess(context, translate("in_app_errors.your_order_stored_offline"));
                                              }
                                              else if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
                                                SharedPreferences.getInstance().then((prefs){
                                                  setState(() {
                                                    isLoading=true;
                                                    Navigator.of(context).pop(context);
                                                  });
                                                  Network_Operations.placeOrder(context, prefs.getString("token"), order).then((orderPlaced){
                                                    if(orderPlaced!=null){
                                                      setState(() {
                                                        this.ordersList=orderPlaced;
                                                      });
                                                      orderItems.clear();
                                                      sqlite_helper().getcart1().then((value) {
                                                        setState(() {
                                                          cartCounter.clear();
                                                          cartList.clear();
                                                          cartList = value;
                                                          if (cartList.length > 0) {
                                                            for(CartItems item in cartList){
                                                              cartCounter.add(item.quantity);
                                                            }
                                                          }
                                                          isLoading=false;
                                                        });
                                                      });
                                                      sqlite_helper().gettotal().then((value){
                                                        setState(() {
                                                          overallTotalPrice=value[0]["SUM(totalPrice)"];
                                                        });
                                                      });
                                                      if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
                                                        showDialog(
                                                            context: this.context,
                                                            builder: (context){
                                                              return Dialog(
                                                                backgroundColor: Colors.transparent,
                                                                child: Container(
                                                                  width: 400,
                                                                  height: 370,
                                                                  child: payoutDialog(orderPlaced),
                                                                ),
                                                              );
                                                            }
                                                        );
                                                        
                                                      }
                                                      Utils.showSuccess(context, translate("in_app_errors.order_placed_successfully"));
                                                    }else{
                                                      Utils.showSuccess(context, translate("in_app_errors.unable_to_place Order"));
                                                    }
                                                  });
                                                });
                                              }
                                            },
                                            child: Card(
                                              elevation:8,
                                              child: Container(
                                                width: 400,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                    color: yellowColor,
                                                    borderRadius: BorderRadius.circular(4)
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    //"Submit Order",
                                                    translate("takeAway_popup.submitOrder_btn"),
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 30,),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  //"SubTotal: ",
                                                  translate("takeAway_popup.sub_total"),
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":" ",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(0)+"/-":"0.0/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          blueColor,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Container(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width,
                                              height: 115,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: yellowColor),
                                                //borderRadius: BorderRadius.circular(8)
                                              ),

                                              child: ListView.builder(itemCount: typeBasedTaxes.length,itemBuilder: (context, index){
                                                return  Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0?typeBasedTaxes[index].name+" (${typeBasedTaxes[index].percentage.toStringAsFixed(0)})":typeBasedTaxes[index].name,
                                                        style: TextStyle(
                                                            fontSize:
                                                            16,
                                                            color:
                                                            yellowColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text((){
                                                            if(typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0){
                                                              return widget.store["currencyCode"].toString()+" "+typeBasedTaxes[index].price.toStringAsFixed(0);
                                                            }else if(typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1){
                                                              return widget.store["currencyCode"].toString()+": "+(typeBasedTaxes[index].percentage/100*overallTotalPrice).toStringAsFixed(0);
                                                            }
                                                            else
                                                              return widget.store["currencyCode"].toString()+": "+(typeBasedTaxes[index].percentage/100*overallTotalPrice).toStringAsFixed(0);
                                                          }()
                                                            // typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0?widget.store["currencyCode"].toString()+" "+typeBasedTaxes[index].price.toStringAsFixed(0):typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1?widget.store["currencyCode"].toString()+": "+(typeBasedTaxes[index].percentage/100*overallTotalPrice).toStringAsFixed(0):widget.store["currencyCode"].toString()+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(0)
                                                            ,style: TextStyle(
                                                                fontSize:
                                                                16,
                                                                color:
                                                                blueColor,
                                                                fontWeight:
                                                                FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  //"Total: ",
                                                  translate("takeAway_popup.total"),
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":"",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(0)+"/-":overallTotalPriceWithTax.toStringAsFixed(0)+"/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          blueColor,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ),
          );
        },
      ),
    );
  }

  Widget orderPopupHorizontalDineInWithOutDiscount(){
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context,innersetState){
          return Center(
            child: Container(
                height:300,
                width: MediaQuery.of(context).size.width/2,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                      image: AssetImage('assets/bb.jpg'),
                    )
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      color: yellowColor,
                      child: Center(
                        child: Text(
                          //"Place Order For Dine-In",
                          translate("dineIn_popup.dineInLabel"),
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerName,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText:  translate("dineIn_popup.customer_name_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerPhone,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Phone# *",
                                              translate("dineIn_popup.customer_phone_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            onTap: ()async{
                                              for(int i=0;i<cartList.length;i++){
                                                orderItems.add({
                                                  "dealid":cartList[i].dealId,
                                                  "name":cartList[i].productName,
                                                  "price":cartList[i].price,
                                                  "quantity":cartList[i].quantity,
                                                  "totalprice":cartList[i].totalPrice,
                                                  "havetopping":cartList[i].topping=="null"||cartList[i].topping==null || cartList[i].topping== "[]" ?false:jsonDecode(cartList[i].topping).length>0?true:false,
                                                  "sizeid":cartList[i].sizeId,
                                                  "IsDeal": cartList[i].isDeal==0?false:true,
                                                  "productid":cartList[i].productId,
                                                  "orderitemstoppings":cartList[i].topping==null||cartList[i].topping == "[]"?[]:jsonDecode(cartList[i].topping),
                                                });
                                              }

                                              dynamic order = {
                                               "DineInEndTime":LocalizedApp.of(context).delegate.currentLocale.languageCode!="ar"?DateFormat("HH:mm:ss").format(DateTime.now().add(Duration(hours: 1))):DateFormat("HH:mm:ss","en").format(DateTime.now().add(Duration(hours: 1))),
                                                "DailySessionNo": currentDailySession!=null?currentDailySession:7,
                                                "TableId":selectedTableId!=null?selectedTableId:null,
                                                "storeId":widget.store["id"],
                                                "DeviceToken":null,
                                                "ordertype":1,
                                                "NetTotal":overallTotalPrice,
                                                //  "grosstotal":widget.netTotal,
                                                "comment":null,
                                                "DeliveryAddress" : null,
                                                "DeliveryLongitude" : null,
                                                "DeliveryLatitude" : null,
                                                "PaymentType" : 1,
                                                "orderitems":orderItems,
                                                "CardNumber": null,
                                                "CVV": null,
                                                "ExpiryDate": null,
                                                "OrderTaxes":taxesList,
                                                "VoucherCode": "",
                                                "OrderStatus":1,
                                                "discountedPrice":deductedPrice,
                                                "customerName":customerName.text,
                                                "CustomerContactNo":customerPhone.text,
                                                "employeeId": int.parse(userId),
                                                "IsCashPaid":selectedType=="Create Order"?false:selectedType=="Payment"?true:false,
                                                "CreatedOn":DateTime.now(),
                                              };
                                              debugPrint(jsonEncode(order,toEncodable: Utils.myEncode));
                                              var result = await Utils.check_connection();
                                              if(result == ConnectivityResult.none){
                                                var offlineOrderList=[];
                                                //final body = jsonEncode(order,toEncodable: Utils.myEncode);
                                                var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                                if(exists){
                                                  print("in if");
                                                  offlineData = await Utils.getOfflineData("addOrderStaff");
                                                  //print(offlineData.syncData);

                                                  for(int i=0;i<jsonDecode(offlineData.syncData).length;i++){
                                                    print(jsonDecode(offlineData.syncData)[i]);
                                                    offlineOrderList.add(jsonDecode(offlineData.syncData)[i]);
                                                  }
                                                  offlineOrderList.add(order);
                                                }else
                                                  offlineOrderList.add(order);

                                                //offlineOrderList.add(body);
                                                await Utils.addOfflineData("addOrderStaff",jsonEncode(offlineOrderList,toEncodable: Utils.myEncode));
                                                offlineData = await Utils.getOfflineData("addOrderStaff");
                                                sqlite_helper().deletecart();
                                                orderItems.clear();
                                                sqlite_helper().getcart1().then((value) {
                                                  setState(() {
                                                    cartCounter.clear();
                                                    cartList.clear();
                                                    cartList = value;
                                                    if (cartList.length > 0) {
                                                      for(CartItems item in cartList){
                                                        cartCounter.add(item.quantity);
                                                      }
                                                    }
                                                    isLoading=false;
                                                  });
                                                });
                                                sqlite_helper().gettotal().then((value){
                                                  setState(() {
                                                    overallTotalPrice=value[0]["SUM(totalPrice)"];
                                                  });
                                                });
                                                Navigator.of(context).pop();
                                               Utils.showSuccess(context, translate("in_app_errors.your_order_stored_offline"));
                                              }
                                              else if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
                                                var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                                if(exists){
                                                  offlineData = await Utils.getOfflineData("addOrderStaff");
                                                  showAlertDialog(context,offlineData);
                                                }else{
                                                  SharedPreferences.getInstance().then((prefs){
                                                    setState(() {
                                                      isLoading=true;
                                                      Navigator.of(context).pop(context);
                                                    });
                                                    Network_Operations.placeOrder(context, prefs.getString("token"), order).then((orderPlaced){
                                                      if(orderPlaced!=null){
                                                        setState(() {
                                                          this.ordersList=orderPlaced;
                                                        });
                                                        var reservationData = {
                                                          "Date":DateTime.now().toString().substring(0,10),
                                                          "StartTime":DateTime.now().toString().substring(10,16),
                                                          "EndTime": DateTime.now().add(Duration(hours:1)).toString().substring(10,16),
                                                          "storeId":widget.store["id"]
                                                        };
                                                        Network_Operations.getAvailableTable(context, prefs.getString("token"), reservationData).then((availableTables){
                                                          setState(() {
                                                            if(availableTables!=null&&availableTables.length>0){
                                                              this.tables=availableTables;
                                                            }
                                                          });
                                                        });
                                                        orderItems.clear();
                                                        sqlite_helper().getcart1().then((value) {
                                                          setState(() {
                                                            cartCounter.clear();
                                                            cartList.clear();
                                                            cartList = value;
                                                            if (cartList.length > 0) {
                                                              for(CartItems item in cartList){
                                                                cartCounter.add(item.quantity);
                                                              }
                                                            }
                                                            isLoading=false;
                                                          });
                                                        });
                                                        sqlite_helper().gettotal().then((value){
                                                          setState(() {
                                                            overallTotalPrice=value[0]["SUM(totalPrice)"];
                                                          });
                                                        });
                                                        if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
                                                          showDialog(
                                                              context: this.context,
                                                              builder: (context){
                                                                return Dialog(
                                                                  backgroundColor: Colors.transparent,
                                                                  child: Container(
                                                                    width: 400,
                                                                    height: 370,
                                                                    child: payoutDialog(orderPlaced),
                                                                  ),
                                                                );
                                                              }
                                                          );
                                                          
                                                        }
                                                        Utils.showSuccess(context, translate("in_app_errors.order_placed_successfully"));
                                                      }else{
                                                        Utils.showSuccess(context, translate("in_app_errors.unable_to_place Order"));
                                                      }
                                                    });
                                                  });
                                                }

                                              }

                                            },
                                            child: Card(
                                              elevation:8,
                                              child: Container(
                                                width: 400,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                    color: yellowColor,
                                                    borderRadius: BorderRadius.circular(4)
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    //"Submit Order",
                                                    translate("dineIn_popup.submitOrder_btn"),
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 30,),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  //"SubTotal: ",
                                                  translate("dineIn_popup.sub_total"),
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":" ",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(0)+"/-":"0.0/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          blueColor,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Container(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width,
                                              height: 115,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: yellowColor),
                                                //borderRadius: BorderRadius.circular(8)
                                              ),

                                              child: ListView.builder(itemCount: typeBasedTaxes.length,itemBuilder: (context, index){
                                                return  Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0?typeBasedTaxes[index].name+" (${typeBasedTaxes[index].percentage.toStringAsFixed(0)})":typeBasedTaxes[index].name,
                                                        style: TextStyle(
                                                            fontSize:
                                                            16,
                                                            color:
                                                            yellowColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text((){
                                                            if(typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0){
                                                              return widget.store["currencyCode"].toString()+" "+typeBasedTaxes[index].price.toStringAsFixed(0);
                                                            }else if(typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1){
                                                              return widget.store["currencyCode"].toString()+": "+(typeBasedTaxes[index].percentage/100*overallTotalPrice).toStringAsFixed(0);
                                                            }
                                                            else
                                                              return widget.store["currencyCode"].toString()+": "+(typeBasedTaxes[index].percentage/100*overallTotalPrice).toStringAsFixed(0);
                                                          }()
                                                            // typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0?widget.store["currencyCode"].toString()+" "+typeBasedTaxes[index].price.toStringAsFixed(0):typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1?widget.store["currencyCode"].toString()+": "+(typeBasedTaxes[index].percentage/100*overallTotalPrice).toStringAsFixed(0):widget.store["currencyCode"].toString()+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(0)
                                                            ,style: TextStyle(
                                                                fontSize:
                                                                16,
                                                                color:
                                                                blueColor,
                                                                fontWeight:
                                                                FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  //"Total: ",
                                                  translate("dineIn_popup.total"),
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":"",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(0)+"/-":overallTotalPriceWithTax.toStringAsFixed(0)+"/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          blueColor,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ),
          );
        },
      ),
    );
  }
  Widget orderPopUpHorizontalDineIn(){
    var discountedValue=0.0;
    return Scaffold(
      resizeToAvoidBottomInset:false,
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context,innersetState){
          return Center(
            child: Container(
                height:380,
                width: MediaQuery.of(context).size.width/2,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                      image: AssetImage('assets/bb.jpg'),
                    )
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      color: yellowColor,
                      child: Center(
                        child: Text(
                          //"Place Order For Dine-In",
                          translate("dineIn_popup.dineInLabel"),
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerName,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Name *",
                                              translate("dineIn_popup.customer_name_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerPhone,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Customer Phone# *",
                                              translate("dineIn_popup.customer_phone_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        // Padding(
                                        //   padding: const EdgeInsets.all(8.0),
                                        //   child: DropdownButtonFormField<String>(
                                        //     decoration: InputDecoration(
                                        //       labelText: "Select Discount Type",
                                        //       alignLabelWithHint: true,
                                        //       labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                        //       enabledBorder: OutlineInputBorder(
                                        //       ),
                                        //       focusedBorder:  OutlineInputBorder(
                                        //         borderSide: BorderSide(color:yellowColor),
                                        //       ),
                                        //     ),
                                        //
                                        //     value: selectedDiscountType,
                                        //     onChanged: (Value) {
                                        //       innersetState(() {
                                        //         selectedDiscountType = Value;
                                        //         priceWithDiscount=overallTotalPriceWithTax;
                                        //         deductedPrice=0.0;
                                        //
                                        //         if(typeBasedTaxes.last.name=="Discount"){
                                        //           priceWithDiscount=overallTotalPriceWithTax;
                                        //           typeBasedTaxes.remove(typeBasedTaxes.last);
                                        //         }
                                        //         if(discountValue.text.isNotEmpty){
                                        //           if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                        //             var tempPercentage=(overallTotalPriceWithTax/100*double.parse(discountValue.text));
                                        //             setState(() {
                                        //               deductedPrice=tempPercentage;
                                        //             });
                                        //             priceWithDiscount=priceWithDiscount-tempPercentage;
                                        //             print("percent discount "+priceWithDiscount.toString());
                                        //             typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(discountValue.text)));
                                        //           }else if(selectedDiscountType!=null&&selectedDiscountType=="Cash"){
                                        //             setState(() {
                                        //               deductedPrice=double.parse(discountValue.text);
                                        //             });
                                        //             var tempSum=overallTotalPriceWithTax-double.parse(discountValue.text);
                                        //             priceWithDiscount=tempSum+totalTax;
                                        //             typeBasedTaxes.add(Tax(name: "Discount",price: double.parse(discountValue.text)));
                                        //           }
                                        //         }else{
                                        //           innersetState(() {
                                        //             priceWithDiscount=overallTotalPriceWithTax;
                                        //           });
                                        //         }
                                        //       });
                                        //     },
                                        //     items: discountType.map((value) {
                                        //       return  DropdownMenuItem<String>(
                                        //         value: value,
                                        //         child: Row(
                                        //           children: <Widget>[
                                        //             Text(
                                        //               value,
                                        //               style:  TextStyle(color: yellowColor,fontSize: 13),
                                        //             ),
                                        //             //user.icon,
                                        //             //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                                        //           ],
                                        //         ),
                                        //       );
                                        //     }).toList(),
                                        //   ),
                                        // ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: discountValue,
                                            keyboardType: TextInputType.number,
                                            onChanged: (value){
                                              innersetState(() {
                                                print(discountValue.text);
                                                print("Total Tax "+totalTax.toString());
                                                priceWithDiscount=overallTotalPriceWithTax;
                                                if(value.isNotEmpty){
                                                  discountedValue=0.0;
                                                  // // if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                                  //   var tempPercentage=((priceWithDiscount-nonServiceTaxesPrice)/100)*double.parse(value);
                                                  //   priceWithDiscount=priceWithDiscount-tempPercentage;
                                                  //   priceWithDiscount=priceWithDiscount;
                                                  //   print("percentage"+tempPercentage.toString());
                                                  //   setState(() {
                                                  //     deductedPrice=tempPercentage;
                                                  //   });
                                                  //
                                                  //   for(int i=0;i<typeBasedTaxes.length;i++){
                                                  //     if(typeBasedTaxes[i].isService==null||typeBasedTaxes[i].isService==false){
                                                  //       if(typeBasedTaxes[i].price!=null&&typeBasedTaxes[i].price!=0.0){
                                                  //         priceWithDiscount=priceWithDiscount+typeBasedTaxes[i].price;
                                                  //       }else if(typeBasedTaxes[i].percentage!=null&&typeBasedTaxes[i].percentage!=0.0){
                                                  //         var tempPercentage = (priceWithDiscount/100)*typeBasedTaxes[i].percentage;
                                                  //         print("Service Tax "+tempPercentage.toString());
                                                  //         priceWithDiscount=priceWithDiscount+tempPercentage;
                                                  //       }
                                                  //     }
                                                  //   }
                                                  //   typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(value)));
                                                  // }else
                                                  print("Price with service charges only "+serviceBasedTaxes.toStringAsFixed(0));
                                                  print("Non Service Charges "+nonServiceTaxesPrice.toStringAsFixed(0));
                                                  print("Price with Discount before cash "+priceWithDiscount.toStringAsFixed(0));
                                                  var tempSum=serviceBasedTaxes-double.parse(value);
                                                  setState(() {
                                                    deductedPrice=double.parse(discountValue.text);
                                                  });
                                                  priceWithDiscount=tempSum;
                                                  discountedValue=priceWithDiscount;
                                                  typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Net Total").toList()[0])]=Tax(name: "Net Total",price: priceWithDiscount,isService:true);
                                                  print("Price with Discount after cash "+priceWithDiscount.toStringAsFixed(0));
                                                  // print("Price with Discount after service charges removal "+priceWithDiscount.toStringAsFixed(0));
                                                  for(int i=0;i<typeBasedTaxes.length;i++){
                                                    if(typeBasedTaxes[i].isService==null||typeBasedTaxes[i].isService==false){
                                                      if(typeBasedTaxes[i].price!=null&&typeBasedTaxes[i].price!=0.0){
                                                        priceWithDiscount=priceWithDiscount+typeBasedTaxes[i].price;
                                                      }else if(typeBasedTaxes[i].percentage!=null&&typeBasedTaxes[i].percentage!=0.0){
                                                        var tempPercentage = typeBasedTaxes[i].percentage*(discountedValue/100);
                                                        print("Service Tax "+tempPercentage.toString());
                                                      //  typeBasedTaxes[i]=Tax(name: typeBasedTaxes[i].name,percentage: null,price: tempPercentage,isService:typeBasedTaxes[i].isService);
                                                        priceWithDiscount=priceWithDiscount+tempPercentage;
                                                        // discountedTax=discountedTax+tempPercentage;
                                                      }
                                                    }
                                                  }

                                                  print("Price after Taxes "+priceWithDiscount.toStringAsFixed(0));
                                                  typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Discount").toList()[0])]=Tax(name: "Discount",price: double.parse(value),isService: true);
                                                }else{
                                                  innersetState(() {
                                                    priceWithDiscount=overallTotalPriceWithTax;
                                                    typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Net Total").toList()[0])]=Tax(name: "Net Total",price: overallTotalPriceWithTax-nonServiceTaxesPrice,isService:true);
                                                    typeBasedTaxes[typeBasedTaxes.indexOf(typeBasedTaxes.where((element) => element.name=="Discount").toList()[0])]=Tax(name: "Discount",price: 0,percentage:0,isService: true);
                                                  });
                                                }

                                              });

                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: //"Discount Amount",
                                              translate("dineIn_popup.discount_amount_hint"),
                                              hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 50,
                                            color: yellowColor,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    //"SubTotal: ",
                                                    translate("dineIn_popup.sub_total"),
                                                    style: TextStyle(
                                                        fontSize:
                                                        20,
                                                        color:
                                                        Colors.white,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":" ",
                                                        style: TextStyle(
                                                            fontSize:
                                                            20,
                                                            color:
                                                            Colors.white,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(0)+"/-":"0.0/-",
                                                        style: TextStyle(
                                                            fontSize:
                                                            20,
                                                            color:
                                                            blueColor,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Container(
                                                width: MediaQuery.of(
                                                    context)
                                                    .size
                                                    .width,
                                                height: 105,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: yellowColor),
                                                  //borderRadius: BorderRadius.circular(8)
                                                ),

                                                child: ListView.builder(itemCount: typeBasedTaxes.length,itemBuilder: (context, index){
                                                  return  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Text(
                                                          typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0?typeBasedTaxes[index].name+" (${typeBasedTaxes[index].percentage.toStringAsFixed(0)})":typeBasedTaxes[index].name,
                                                          style: TextStyle(
                                                              fontSize:
                                                              16,
                                                              color:
                                                              yellowColor,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text((){
                                                                if(typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0){
                                                                  return widget.store["currencyCode"].toString()+": "+typeBasedTaxes[index].price.toStringAsFixed(0);
                                                                }else if((typeBasedTaxes[index].isService==null||typeBasedTaxes[index].isService==false)&&typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&discountedValue>0){
                                                                  print("Price with Discount First If "+discountedValue.toStringAsFixed(0));
                                                                  var temp=(discountedValue)/100*typeBasedTaxes[index].percentage;
                                                                  return widget.store["currencyCode"].toString()+": "+(temp).toStringAsFixed(0);
                                                                }else if((typeBasedTaxes[index].isService==null||typeBasedTaxes[index].isService==false)&&typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&priceWithDiscount==0){
                                                                  print("Price with Discount second If "+priceWithDiscount.toStringAsFixed(0));
                                                                  var temp=(overallTotalPriceWithTax-nonServiceTaxesPrice)/100*typeBasedTaxes[index].percentage;
                                                                  return widget.store["currencyCode"].toString()+": "+(temp).toStringAsFixed(0);
                                                                }else
                                                                  return widget.store["currencyCode"].toString()+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(0);

                                                            }(),
                                                              style: TextStyle(
                                                                fontSize:
                                                                16,
                                                                color:
                                                                blueColor,
                                                                fontWeight:
                                                                FontWeight.bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                })
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 50,
                                            color: yellowColor,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    //"Total: ",
                                                    translate("dineIn_popup.total"),
                                                    style: TextStyle(
                                                        fontSize:
                                                        20,
                                                        color:
                                                        Colors.white,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":"",
                                                        style: TextStyle(
                                                            fontSize:
                                                            20,
                                                            color:
                                                            Colors.white,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(0)+"/-":overallTotalPriceWithTax.toStringAsFixed(0)+"/-",
                                                        style: TextStyle(
                                                            fontSize:
                                                            20,
                                                            color:
                                                            blueColor,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height:10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: ()async{
                                    for(int i=0;i<cartList.length;i++){
                                      orderItems.add({
                                        "dealid":cartList[i].dealId,
                                        "name":cartList[i].productName,
                                        "price":cartList[i].price,
                                        "quantity":cartList[i].quantity,
                                        "totalprice":cartList[i].totalPrice,
                                        "havetopping":cartList[i].topping=="null"||cartList[i].topping==null || cartList[i].topping== "[]" ?false:jsonDecode(cartList[i].topping).length>0?true:false,
                                        "sizeid":cartList[i].sizeId,
                                        "IsDeal": cartList[i].isDeal==0?false:true,
                                        "productid":cartList[i].productId,
                                        "orderitemstoppings":cartList[i].topping==null||cartList[i].topping == "[]"?[]:jsonDecode(cartList[i].topping),
                                      });
                                    }

                                    dynamic order = {
                                      "DineInEndTime":LocalizedApp.of(context).delegate.currentLocale.languageCode!="ar"?DateFormat("HH:mm:ss").format(DateTime.now().add(Duration(hours: 1))):DateFormat("HH:mm:ss","en").format(DateTime.now().add(Duration(hours: 1))),
                                      "DailySessionNo": currentDailySession!=null?currentDailySession:7,
                                      "TableId":selectedTableId!=null?selectedTableId:null,
                                      "storeId":widget.store["id"],
                                      "DeviceToken":null,
                                      "ordertype":1,
                                      "NetTotal":overallTotalPrice,
                                      //  "grosstotal":widget.netTotal,
                                      "comment":null,
                                      "DeliveryAddress" : null,
                                      "DeliveryLongitude" : null,
                                      "DeliveryLatitude" : null,
                                      "PaymentType" : 1,
                                      "orderitems":orderItems,
                                      "CardNumber": null,
                                      "CVV": null,
                                      "ExpiryDate": null,
                                      "OrderTaxes":taxesList,
                                      "VoucherCode": "",
                                      "OrderStatus":1,
                                      "discountedPrice":deductedPrice,
                                      "customerName":customerName.text,
                                      "CustomerContactNo":customerPhone.text,
                                      "employeeId": int.parse(userId),
                                      "IsCashPaid":selectedType=="Create Order"?false:selectedType=="Payment"?true:false,
                                      "CreatedOn":DateTime.now(),
                                    };
                                    debugPrint(jsonEncode(order,toEncodable: Utils.myEncode));
                                    var result = await Utils.check_connection();
                                    if(result == ConnectivityResult.none){
                                      var offlineOrderList=[];
                                      //final body = jsonEncode(order,toEncodable: Utils.myEncode);
                                      var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                      if(exists){
                                        print("in if");
                                        offlineData = await Utils.getOfflineData("addOrderStaff");
                                        //print(offlineData.syncData);

                                        for(int i=0;i<jsonDecode(offlineData.syncData).length;i++){
                                          print(jsonDecode(offlineData.syncData)[i]);
                                          offlineOrderList.add(jsonDecode(offlineData.syncData)[i]);
                                        }
                                        offlineOrderList.add(order);
                                      }else
                                        offlineOrderList.add(order);

                                      //offlineOrderList.add(body);
                                      await Utils.addOfflineData("addOrderStaff",jsonEncode(offlineOrderList,toEncodable: Utils.myEncode));
                                      offlineData = await Utils.getOfflineData("addOrderStaff");
                                      sqlite_helper().deletecart();
                                      orderItems.clear();
                                      sqlite_helper().getcart1().then((value) {
                                        setState(() {
                                          cartCounter.clear();
                                          cartList.clear();
                                          cartList = value;
                                          if (cartList.length > 0) {
                                            for(CartItems item in cartList){
                                              cartCounter.add(item.quantity);
                                            }
                                          }
                                          isLoading=false;
                                        });
                                      });
                                      sqlite_helper().gettotal().then((value){
                                        setState(() {
                                          overallTotalPrice=value[0]["SUM(totalPrice)"];
                                        });
                                      });
                                      Navigator.of(context).pop();
                                     Utils.showSuccess(context, translate("in_app_errors.your_order_stored_offline"));
                                    }
                                    else if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
                                      var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                      if(exists){
                                        offlineData = await Utils.getOfflineData("addOrderStaff");
                                        showAlertDialog(context,offlineData);
                                      }else{
                                        SharedPreferences.getInstance().then((prefs){
                                          setState(() {
                                            isLoading=true;
                                            Navigator.of(context).pop(context);
                                          });
                                          Network_Operations.placeOrder(context, prefs.getString("token"), order).then((orderPlaced){
                                            if(orderPlaced!=null){
                                              setState(() {
                                                this.ordersList=orderPlaced;
                                              });
                                              var reservationData = {
                                                "Date":DateTime.now().toString().substring(0,10),
                                                "StartTime":DateTime.now().toString().substring(10,16),
                                                "EndTime": DateTime.now().add(Duration(hours:1)).toString().substring(10,16),
                                                "storeId":widget.store["id"]
                                              };
                                              Network_Operations.getAvailableTable(context, prefs.getString("token"), reservationData).then((availableTables){
                                                setState(() {
                                                  if(availableTables!=null&&availableTables.length>0){
                                                    this.tables=availableTables;
                                                  }
                                                });
                                              });
                                              orderItems.clear();
                                              sqlite_helper().getcart1().then((value) {
                                                setState(() {
                                                  cartCounter.clear();
                                                  cartList.clear();
                                                  cartList = value;
                                                  if (cartList.length > 0) {
                                                    for(CartItems item in cartList){
                                                      cartCounter.add(item.quantity);
                                                    }
                                                  }
                                                  isLoading=false;
                                                });
                                              });
                                              sqlite_helper().gettotal().then((value){
                                                setState(() {
                                                  overallTotalPrice=value[0]["SUM(totalPrice)"];
                                                });
                                              });
                                              if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
                                                showDialog(
                                                    context: this.context,
                                                    builder: (context){
                                                      return Dialog(
                                                        backgroundColor: Colors.transparent,
                                                        child: Container(
                                                          width: 400,
                                                          height: 370,
                                                          child: payoutDialog(orderPlaced),
                                                        ),
                                                      );
                                                    }
                                                );
                                                
                                              }
                                              Utils.showSuccess(context, translate("in_app_errors.order_placed_successfully"));
                                            }else{
                                              Utils.showSuccess(context, translate("in_app_errors.unable_to_place Order"));
                                            }
                                          });
                                        });
                                      }

                                    }

                                  },
                                  child: Card(
                                    elevation:8,
                                    child: Container(
                                      width: 400,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          color: yellowColor,
                                          borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Center(
                                        child: Text(
                                          //"Submit Order",
                                          translate("dineIn_popup.submitOrder_btn"),
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ),
          );
        },
      ),
    );
  }
  var productPopupHeight=330.0;
  Widget productsPopupLayout(Products product) {
    print(product.allergic_description);
    var count = 1;
    var price=0.0;
    var discountedPrice=0.0;
    var updatedActualPrice=0.0;
    var selectedSizeObj;
    var totalprice=0.0;
    int selectedSizeId=0;
    String selectedSizeName="";
    List<Additionals> additionals = [];
    List<Toppings> topping = [];
    bool isvisible = false;
    List<int> _counter = List();
    StreamController _event = StreamController<int>.broadcast();
    selectedSizeId=product.productSizes[0]["size"]["id"];
    selectedSizeName=product.productSizes[0]["size"]["name"];
    selectedSizeObj=product.productSizes[0];
    price=product.productSizes[0]["price"];
    discountedPrice=product.productSizes[0]["discountedPrice"];
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context, innersetState) {

          SharedPreferences.getInstance().then((prefs){
             if(additionals==null||additionals.length==0){
               Network_Operations.getAdditionals(context, prefs.getString("token"), product.id, product.productSizes[0]["size"]["id"]).then((value){
                 innersetState(() {
                   additionals=value;
                   if(additionals.length>0){
                     innersetState(() {
                       isvisible=true;
                       productPopupHeight=650.0;
                     });
                   }else
                     innersetState(() {
                       isvisible=false;
                       productPopupHeight=330.0;
                     });
                 });


               });
             }

          });
          void ItemCount(int qty, int index) {
            innersetState(() {

              _counter[index] = qty;
              _event.add(_counter[index]);
            });
          }
          return Center(
              child: Container(
                  height: productPopupHeight,
                  width: 400,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                        image: AssetImage('assets/bb.jpg'),
                      )
                  ),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        color: yellowColor,
                        child:  Padding(
                          padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5, top: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                             product.allergic_description!=null&&product.allergic_description.isNotEmpty? IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.infoCircle,
                                  size: 35,
                                  color: blueColor,
                                ),
                                onPressed: () {
                                    showDialog(context: context, builder:(BuildContext context){
                                      return AlertDialog(
                                        title:Text(translate("in_app_errors.allergic_description")),
                                        content: Text(product.allergic_description),
                                      );
                                    });
                                },
                              ):Container(),
                              Text(product.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25
                                ),
                              ),
                              IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.times,
                                  size: 35,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),

                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:16.0,left:16,right:16),
                        child: DropdownButtonFormField<dynamic>(
                          decoration: InputDecoration(
                            labelText: //"Select Size",
                            translate("product_popup.select_size"),
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                            enabledBorder: OutlineInputBorder(
                            ),
                            focusedBorder:  OutlineInputBorder(
                              borderSide: BorderSide(color:yellowColor),
                            ),
                          ),

                          value: product.productSizes[0]["size"]["name"],
                          onChanged: (value) {
                            innersetState(() {
                              var selectedSize= product.productSizes.where((element) => element["size"]["name"]==value.toString());
                              selectedSizeId=selectedSize.toList()[0]["size"]["id"];
                              selectedSizeName=selectedSize.toList()[0]["size"]["name"];
                              selectedSizeObj=selectedSize.toList()[0];
                              count=1;
                              price=selectedSize.toList()[0]["price"];
                              if(selectedSizeObj["discountedPrice"]!=0.0) {
                                //updatedPrice = selectedSize.toList()[0]["discountedPrice"];
                                discountedPrice=selectedSize.toList()[0]["discountedPrice"];
                               // updatedActualPrice=selectedSize.toList()[0]["price"];
                              }
                              var totalToppingPrice=0.0;
                              if(selectedSizeId!=0){
                                SharedPreferences.getInstance().then((prefs){
                                  Network_Operations.getAdditionals(context, prefs.getString("token"), product.id, selectedSizeId).then((value){
                                    innersetState(() {
                                     // var totalToppingPrice=0.0;
                                      for(var t in topping){
                                        totalToppingPrice=totalToppingPrice+t.totalprice;
                                      }
                                      topping.clear();
                                      _counter.clear();
                                      additionals.clear();
                                      additionals=value;
                                    });
                                  });
                                });
                              }
                              if(discountedPrice!=0.0){
                                totalprice = (discountedPrice * count ) + totalToppingPrice;
                                updatedActualPrice=(price * count ) + totalToppingPrice;
                              }else{
                                totalprice = (price * count ) + totalToppingPrice;
                                updatedActualPrice=(price * count ) + totalToppingPrice;
                              }
                              //updatedPrice=selectedSizeId=selectedSize.toList()[0]["price"];
                              // priority = Value;
                              // priorityId = priorityList.indexOf(priority);
                            });
                          },
                          items: product.productSizes.map((value) {
                            return  DropdownMenuItem<String>(
                              value: value["size"]["name"],
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    value["size"]["name"].toString(),
                                    style:  TextStyle(color: yellowColor,fontSize: 13),
                                  ),
                                  //user.icon,
                                  //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          //"Quantity",
                          translate("product_popup.quantity"),
                          style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 20
                          ),
                        ),
                        trailing: Counter(
                          color: yellowColor,
                          initialValue: count,
                          maxValue: 10,
                          minValue: 1,
                          step: 1,
                          decimalPlaces: 0,
                          onChanged: (value){
                            innersetState(() {
                              var totalToppingPrice=0.0;
                              for(var t in topping){
                                totalToppingPrice=totalToppingPrice+t.totalprice;
                              }
                              count=value;
                              if(discountedPrice!=0.0){
                                totalprice = (discountedPrice * count ) + totalToppingPrice;
                                updatedActualPrice=(price * count ) + totalToppingPrice;
                              }else{
                                totalprice = (price * count ) + totalToppingPrice;
                                updatedActualPrice=(price * count ) + totalToppingPrice;
                              }
                            });
                          },
                        ),
                      ),
                      Visibility(
                        visible: isvisible,
                        child: Expanded(
                          child: ListView.builder(
                              itemCount: additionals.length!=null?additionals.length:0,
                              itemBuilder: (BuildContext context, int index) {
                                if (_counter.length < additionals.length) {
                                  _counter.add(0);
                                }
                                return Card(
                                  elevation: 8,
                                  child: new Container(
                                    decoration: BoxDecoration(
                                        color: BackgroundColor,
                                        // borderRadius: BorderRadius.only(
                                        //   bottomRight: Radius.circular(15),
                                        //   topLeft: Radius.circular(15),
                                        // ),
                                        border: Border.all(color: yellowColor, width: 1)
                                    ),
                                    padding: new EdgeInsets.all(10.0),
                                    child: new Column(
                                      children: <Widget>[
                                        new ListTile(
                                            title: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                new Text( (){
                                                  if(_counter[index]!=null&&_counter[index]!=0&&_counter[index]!=1){
                                                    return additionals[index].name +" (${widget.store["currencyCode"].toString()+" "+additionals[index].price.toStringAsFixed(0)})  ${widget.store["currencyCode"].toString()} " +(additionals[index].price*_counter[index]).toStringAsFixed(0);
                                                   }
                                                  return additionals[index].name +"  ${widget.store["currencyCode"].toString()} "+additionals[index].price.toStringAsFixed(0);
                                    }()
                                                  ,style: TextStyle(color: yellowColor, fontSize: 17, fontWeight: FontWeight.bold),),
                                                Container(
                                                  //color: Colors.black12,
                                                  height: 50,

                                                  child: Counter(
                                                    initialValue: _counter[index],
                                                    minValue: 0,
                                                    maxValue: 10,
                                                    decimalPlaces:0,
                                                    color:yellowColor,
                                                    onChanged: (value){
                                                      innersetState(() {

                                                        ItemCount(value, index);
                                                        var a=0.0;
                                                          //a = _counter[index] * additionals[index].price;
                                                          if(value!=0){
                                                              var toppingExists=topping.where((element) => element.additionalitemid==additionals[index].id).toList();
                                                              if(toppingExists!=null&&toppingExists.length>0){
                                                                  topping[topping.indexOf(toppingExists[0])].quantity=_counter[index] ;
                                                                  topping[topping.indexOf(toppingExists[0])].totalprice=_counter[index] *additionals[index].price;
                                                                 // print("Updated Topping "+topping[topping.indexOf(toppingExists[0])].toJson().toString());
                                                                  for(Toppings t in topping){
                                                                     print("Updated Topping "+t.toJson().toString());
                                                                  }
                                                              }else{
                                                                topping.add(Toppings(additionalitemid: additionals[index].id,quantity: _counter[index],price: additionals[index].price,totalprice: _counter[index]*additionals[index].price,name: additionals[index].name));
                                                                //print("added Topping "+Toppings(additionalitemid: additionals[index].id,quantity: _counter[index],price: additionals[index].price,totalprice: _counter[index]*additionals[index].price).toJson().toString());
                                                              }
                                                              print("length of Topping "+topping.length.toString());
                                                            for(Toppings t in topping){
                                                              a+=t.totalprice;
                                                            }
                                                          }else{
                                                            _counter[index]=0;
                                                            topping.removeAt(topping.indexOf(topping.where((element) => element.additionalitemid==additionals[index].id).toList()[0]));
                                                            for(Toppings t in topping){
                                                              print("List after removed Topping "+t.toJson().toString());
                                                            }
                                                            for(Toppings t in topping){
                                                              a+=t.totalprice;
                                                            }
                                                          }
                                                          print("Single Topping Price "+a.toString());
                                                          if(totalprice==0.0){
                                                            if(selectedSizeObj["discountedPrice"]!=0.0){
                                                              if(discountedPrice!=0.0){
                                                                totalprice = (discountedPrice * count ) + a;
                                                                updatedActualPrice=(price * count ) + a;
                                                              }else{
                                                                totalprice = (price * count ) + a;
                                                                updatedActualPrice=(price * count ) + a;
                                                              }
                                                            //  updatedActualPrice=updatedActualPrice+price+a;
                                                            }else {
                                                             totalprice = (price * count ) + a;
                                                              updatedActualPrice=(price * count ) + a;
                                                            }
                                                          }else{
                                                            if(discountedPrice!=0.0){
                                                              totalprice = (discountedPrice * count ) + a;
                                                              updatedActualPrice=(price * count ) + a;
                                                            }else{
                                                              totalprice = (price * count ) + a;
                                                              updatedActualPrice=(price * count ) + a;
                                                            }
                                                            print("in outer else"+a.toString());
                                                          }

                                                      }
                                                      );
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                            )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                      selectedSizeObj["discountedPrice"]==0.0?
                      Center(
                          child: Text(
                           translate("product_popup.price")+": "+"${totalprice==0.0?price.toString():totalprice.toString()}",
                            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color:blueColor),)
                      ):Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: (
                              TextSpan(
                                  text:  translate("product_popup.price"),
                                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color:yellowColor),
                                  children: [
                                    TextSpan(
                                      text: "  ${updatedActualPrice==0.0?price.toString():updatedActualPrice.toString()}",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color:blueColor,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "  ${totalprice==0.0?discountedPrice.toString():totalprice.toString()}",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color:blueColor,
                                      ),
                                    ),
                                  ]
                              )
                          ),
                        ),
                      ),
                      SizedBox(height: 1,),
                      InkWell(
                        onTap: () {
                          print(selectedSizeName);
                          print(selectedSizeId);
                          sqlite_helper().checkAlreadyExists(product.id).then((foundProducts){
                            if(foundProducts.length>0){
                              var tempCartItem =CartItems(
                                  id: foundProducts[0]["id"],
                                  productId: product.id,
                                  productName: product.name,
                                  isDeal: 0,
                                  dealId: null,
                                  sizeId: selectedSizeId,
                                  sizeName: selectedSizeName,
                                  price: selectedSizeObj["discountedPrice"]==0.0? price:selectedSizeObj["discountedPrice"]!=0.0?selectedSizeObj["discountedPrice"] : price,
                                  totalPrice:selectedSizeObj["discountedPrice"]==0.0&&totalprice == 0.0 ? price:selectedSizeObj["discountedPrice"]!=0.0&&totalprice == 0.0?selectedSizeObj["discountedPrice"] : totalprice,
                                  quantity: count,
                                  storeId: product.storeId,
                                  topping: topping.length>0?jsonEncode(topping):null
                              );
                              sqlite_helper().updateCart(tempCartItem).then((value){
                                sqlite_helper().getcart1().then((value) {
                                  setState(() {
                                    cartCounter.clear();
                                    cartList.clear();
                                    cartList = value;
                                    if (cartList.length > 0) {
                                      for(CartItems item in cartList){
                                        cartCounter.add(item.quantity);
                                      }
                                    }
                                    sqlite_helper().gettotal().then((value){
                                      setState(() {
                                        overallTotalPrice=value[0]["SUM(totalPrice)"];
                                      });
                                    });
                                  });
                                });
                              });
                              Navigator.of(context).pop();
                             Utils.showSuccess(context, translate("in_app_errors.updated_to_cart_successfully"));                            }else{

                              sqlite_helper()
                                  .create_cart(CartItems(
                                  productId: product.id,
                                  productName: product.name,
                                  isDeal: 0,
                                  dealId: null,
                                  sizeId: selectedSizeId,
                                  sizeName: selectedSizeName,
                                  price: selectedSizeObj["discountedPrice"]==0.0? price:selectedSizeObj["discountedPrice"]!=0.0?selectedSizeObj["discountedPrice"] : price,
                                  totalPrice:selectedSizeObj["discountedPrice"]==0.0&&totalprice == 0.0 ? price:selectedSizeObj["discountedPrice"]!=0.0&&totalprice == 0.0?selectedSizeObj["discountedPrice"] : totalprice,
                                  quantity: count,
                                  storeId: product.storeId,
                                  topping: topping.length>0?jsonEncode(topping):null))
                                  .then((isInserted) {
                                if (isInserted > 0) {
                                  innersetState(() {
                                    sqlite_helper().getcart1().then((value) {
                                      setState(() {
                                        cartCounter.clear();
                                        cartList.clear();
                                        cartList = value;
                                        if (cartList.length > 0) {
                                          for(CartItems item in cartList){
                                            cartCounter.add(item.quantity);
                                          }
                                        }
                                        sqlite_helper().gettotal().then((value){
                                          setState(() {
                                            overallTotalPrice=value[0]["SUM(totalPrice)"];
                                          });
                                        });
                                      });
                                    });
                                  });
                                  Navigator.of(context).pop();
                                  Utils.showSuccess(context, translate("in_app_errors.added_to_cart_successfully"));
                                } else {
                                  Navigator.of(context).pop();
                                  Utils.showSuccess(context, translate("in_app_errors.some_error_occur"));
                                }
                              });
                            }
                          });


                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 65,
                            decoration: BoxDecoration(
                                color: yellowColor,
                                borderRadius: BorderRadius.circular(4)),
                            child: Center(
                              child: Text(
                                translate("product_popup.addToCard_btn"),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              )
          );
        },
      ),
    );
  }


  showAlertDialog(BuildContext context,APICacheDBModel data) {

    // set up the buttons
    Widget remindButton = TextButton(
      child: Text(translate("alert_dialog.cancel"),),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: Text(translate("alert_dialog.delete"),),
      onPressed:  () async{
        Utils.deleteOfflineData("addOrderStaff");
        Navigator.pop(context);
      },
    );
    Widget launchButton = TextButton(
      child: Text(translate("alert_dialog.add_from_cache"),),
      onPressed:  () async {
        print(jsonDecode(data.syncData).length);
        for(int i=0;i<jsonDecode(data.syncData).length;i++)
        {
          var value= await Network_Operations.placeOrder(context,token,jsonDecode(data.syncData)[i]);
          if(value!=null){
            if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
              var payCash ={
                "orderid": jsonDecode(value)["id"],
                "CashPay": overallTotalPriceWithTax==0.0?overallTotalPriceWithTax:overallTotalPriceWithTax,
                "Balance": overallTotalPriceWithTax==0.0?overallTotalPriceWithTax:overallTotalPriceWithTax,
                "Comment": null,
                "PaymentType": 1,
                "OrderStatus": 7,
              };
              bool isPaid = await Network_Operations.payCashOrder(this.context, token, payCash);
              if(isPaid){
                Utils.showSuccess(context, translate("in_app_errors.payment_successful"));
              }else{
                Utils.showSuccess(context, translate("in_app_errors.problem_in_making_payment"));
              }

            }
          }
        }
        Utils.deleteOfflineData("addOrderStaff");
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(translate("alert_dialog.notice"),),
      content: Text(translate("alert_dialog.content"),),
      actions: [
        remindButton,
        cancelButton,
        launchButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

 Widget editToppingDialog(CartItems item){
    List<Toppings> topping=[],newTopping=[];
    List<int> toppingCounter=[];
    if(item.topping!=null){
      topping=Toppings.toppingListFromJson(item.topping);
      if(topping.length>0){
        for(Toppings t in topping){
          toppingCounter.add(t.quantity);
        }
      }
    }
    return Scaffold(
      body: StatefulBuilder(
        builder: (context,innerSetState){
          return Center(
            child: Container(
                width: 400,
                height:400,
                child:Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      color: yellowColor,
                      child: Center(
                        child: Text(
                          translate("alert_dialog.edit_extras"),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 4,),
                    Expanded(
                      child: ListView.builder(
                        itemCount: topping!=null?topping.length:0,
                        itemBuilder:(context,index){
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 5.0,
                                  child: ListTile(
                                    title:Text(topping[index].name+" (${widget.store["currencyCode"].toString()+""+topping[index].price.toStringAsFixed(0) })    "+widget.store["currencyCode"].toString()+" "+(topping[index].price*toppingCounter[index]).toStringAsFixed(0), style: TextStyle(
                                      fontWeight: FontWeight.bold
                                    ),),
                                    trailing: Counter(
                                      color: yellowColor,
                                      decimalPlaces: 0,
                                      minValue: 0,
                                      maxValue: 10,
                                      step: 1,

                                      initialValue: toppingCounter[index],
                                      onChanged: (value){
                                        innerSetState(() {
                                          toppingCounter[index]=value;
                                        });

                                      },
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                          color: yellowColor,
                          child: Text(translate("alert_dialog.update_toppings"),style: TextStyle(color: Colors.white),),
                          elevation: 5.0,
                          onPressed:(){
                            innerSetState(() {
                              print("Previous Topping Size "+topping.length.toString());
                              for(int i=0;i<toppingCounter.length;i++){
                                if(toppingCounter[i]>0){
                                  newTopping.add(Toppings(name: topping[i].name,quantity: toppingCounter[i],price: topping[i].price,totalprice:toppingCounter[i]*topping[i].price,additionalitemid: topping[i].additionalitemid));
                                }
                              }
                              print("New Topping Size "+newTopping.length.toString());

                              sqlite_helper().updateTopping(item.id,
                                  newTopping.isNotEmpty?jsonEncode(newTopping):null).then((isUpdated){
                                if(isUpdated>0){
                                  var priceOfTopping=0.0;
                                    if(newTopping!=null){
                                      for(Toppings t in newTopping) {
                                        innerSetState(() {
                                          priceOfTopping =
                                              priceOfTopping +
                                                  t.totalprice;
                                        });
                                      }
                                      print("Price of Topping "+priceOfTopping.toString());
                                    }
                                    sqlite_helper().updatePriceAndQuantity(item.id, (item.price*item.quantity)+priceOfTopping, item.quantity).then((updatedItemsCount){
                                      if(updatedItemsCount!=null&&updatedItemsCount>0){
                                        Navigator.pop(context);
                                        Utils.showSuccess(context, translate("in_app_errors.quantity_successfully_updated"));
                                        sqlite_helper().getcart1().then((value) {
                                          setState(() {
                                            cartCounter.clear();
                                            cartList.clear();
                                            cartList = value;
                                            if (cartList.length > 0) {
                                              for(CartItems item in cartList){
                                                cartCounter.add(item.quantity);
                                              }
                                            }
                                            if (cartList.length > 0) {
                                              print(cartList.toString());
                                            }
                                          });
                                        });
                                        sqlite_helper().gettotal().then((value){
                                          setState(() {
                                            overallTotalPrice=value[0]["SUM(totalPrice)"];
                                          });

                                        });
                                      }else{
                                        Utils.showSuccess(context, translate("in_app_errors.unable_to_update"));
                                      }
                                    });
                                  }
                              });
                            });


                          }
                      ),
                    )
                  ],
                )

            ),
          );
        },
      ),
    );
  }

  TextEditingController amountPaid=TextEditingController();
  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();
  Widget payoutDialog(dynamic orders){
    print("Placed Order "+orders.toString());
    int totalAmount=int.parse(jsonDecode(orders)["result"]["grossTotal"].toStringAsFixed(0));
    int balance= 0;
    return Scaffold(
      body: StatefulBuilder(
          builder: (context,innersetState){
            return ListView(
              children: [
                Center(
                  child: Container(
                    width: 400,
                    height: 370,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                            image: AssetImage('assets/bb.jpg'),
                          )
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            color: yellowColor,
                            child: Center(child: Text(translate("alert_dialog.payout"),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: BackgroundColor),)),

                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:16.0,left:16.0,right:16.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width/0.9,
                              height: 70,
                              decoration: BoxDecoration(
                                  color: BackgroundColor,
                                  border: Border.all(color: yellowColor, width: 2),
                                  borderRadius: BorderRadius.circular(9)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(translate("alert_dialog.total_amount"),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: yellowColor),),
                                    Text(totalAmount.toString(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: PrimaryColor),),
                                  ],
                                ),
                              ),
                            ),

                          ),
                          Form(
                            key: formKey,
                            child: Padding(
                              padding: const EdgeInsets.only(top:16.0,left:16.0,right:16.0),
                              child: TextFormField(

                                controller: amountPaid,
                                textInputAction: TextInputAction.go,
                                keyboardType: TextInputType.number,
                                autofocus: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Amount is Required';
                                  }else if(int.parse(value)<totalAmount){
                                    return "Paid Amount should be greater then equal to total Amount";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: translate("alert_dialog.amount_paid"),hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                onChanged: (value){
                                  innersetState(() {
                                    if(value.isNotEmpty) {
                                      balance =
                                      (int.parse(amountPaid.text)-totalAmount);
                                    }else{
                                      balance=0;
                                    }
                                  });

                                },

                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width/0.9,
                              height: 70,
                              decoration: BoxDecoration(
                                  color: BackgroundColor,
                                  border: Border.all(color: yellowColor, width: 2),
                                  borderRadius: BorderRadius.circular(9)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(translate("alert_dialog.balance"),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: yellowColor),),
                                    Text(balance.toStringAsFixed(0),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: PrimaryColor),),
                                  ],
                                ),
                              ),
                            ),

                          ),
                          InkWell(
                            onTap: (){
                              if(!formKey.currentState.validate()){

                              }else{
                                var payCash ={
                                  "orderid": jsonDecode(orders)["id"],
                                  "CashPay": jsonDecode(orders)["result"]["grossTotal"],
                                  "Balance": jsonDecode(orders)["result"]["grossTotal"],
                                  "Comment": null,
                                  "PaymentType": 1,
                                  "OrderStatus": 7,
                                };
                                Navigator.pop(context);
                                Network_Operations.payCashOrder(this.context,token, payCash).then((isPaid){
                                  if(isPaid){
                                    setState(() {
                                      // WidgetsBinding.instance
                                      //     .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                    });
                                    Utils.showSuccess(context, translate("in_app_errors.payment_successful"));
                                  }else{
                                    Utils.showSuccess(context, translate("in_app_errors.problem_in_making_payment"));
                                  }
                                });
                              }
                            },
                            child: Card(
                              elevation: 8,
                              child: Container(
                                width: 230,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: yellowColor
                                ),
                                child: Center(child: Text(translate("alert_dialog.payout_btn"),style: TextStyle(color: BackgroundColor, fontWeight: FontWeight.bold, fontSize: 30),)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          }
      ),
    );
  }

  Widget _buildChips() {
    List<Widget> chips = new List();
    List<String> foodTypes=[translate("in_app_errors.veg"),translate("in_app_errors.non_veg")];
    for (int i = 0; i < 2; i++) {
      _selected.add(false);
      FilterChip filterChip = FilterChip(
        selected: _selected[i],
        label: Text(foodTypes[i], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        // avatar: FlutterLogo(),
        elevation: 10,
        pressElevation: 5,
        //shadowColor: Colors.teal,
        backgroundColor: Colors.red,
        selectedColor: Colors.lightGreen,
        onSelected: (bool selected) {
          setState(() {
            for(int j=0;j<_selected.length;j++){
              if(_selected[j]){
                _selected[j]=false;
              }
            }
            _selected[i] = selected;
            if(_selected[i]){
              if(i==0){
                print(subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])].id.toString());
                Network_Operations.getProduct(
                    context,
                    subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])]
                        .id,
                    widget.store["id"],
                    "")
                    .then((p) {
                  setState(() {
                    if (p != null && p.length > 0) {
                      products.clear();
                      for(int i=0;i<p.length;i++){
                        if(p[i].isVeg!=null&&p[i].isVeg){
                          products.add(p[i]);
                        }
                      }
                      categoryName = subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])].name;
                      print(categoryName);

                    }
                  });
                });
              }else{
                Network_Operations.getProduct(
                    context,
                    subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])]
                        .id,
                    widget.store["id"],
                    "")
                    .then((p) {
                  setState(() {
                    if (p != null && p.length > 0) {
                      products.clear();
                      for(int i=0;i<p.length;i++){
                        if(p[i].isVeg==null||!p[i].isVeg){
                          products.add(p[i]);
                        }
                      }
                      categoryName = subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])].name;
                      print(categoryName);

                    }
                  });
                });
              }

            }else{
              Network_Operations.getProduct(
                  context,
                  subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])]
                      .id,
                  widget.store["id"],
                  "")
                  .then((p) {
                setState(() {
                  if (p != null && p.length > 0) {
                    products.clear();
                    SharedPreferences.getInstance().then((prefs){
                      List<String> lst = prefs.getStringList("reorderedproducts${subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])]
                          .id.toString()}");
                      products.clear();
                      if(lst!=null&&lst.length>0){
                        this.products= lst.map(
                              (String indx) => p
                              .where((Products item) => int.parse(indx) == item.id)
                              .first,
                        ).toList();
                        if(p.length>products.length){
                          int additionalElements=p.length-products.length;
                          List<Products> reversedList =  List.from(p.reversed);

                          for(int i= 0;i<additionalElements;i++){
                            products.add(reversedList[i]);
                          }
                        }
                      }else{
                        products.addAll(p);
                      }
                    });
                    categoryName = subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])].name;
                    print(categoryName);
                  }
                });
              });
            }

          });
        },
      );

      chips.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: filterChip
      ));
    }

    return ListView(
      // This next line does the trick.
      scrollDirection: Axis.horizontal,
      children: chips,
    );
  }
}

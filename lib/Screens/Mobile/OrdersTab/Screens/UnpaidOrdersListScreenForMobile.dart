import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:exabistro_pos/Screens/Mobile/OrdersTab/Screens/KitchenOrdersDetails.dart';
import 'package:exabistro_pos/Utils/Utils.dart';

import 'package:exabistro_pos/model/Vendors.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utils/constants.dart';
import '../../../LoadingScreen.dart';



class UnPaidOrdersScreenForMobile extends StatefulWidget {
  var store;

  UnPaidOrdersScreenForMobile(this.store);

  @override
  _KitchenTabViewState createState() => _KitchenTabViewState();
}

class _KitchenTabViewState extends State<UnPaidOrdersScreenForMobile>{

  String token;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  // bool isVisible=false;
  List orderList = [];
  List itemsList=[],toppingName =[];
  List topping = [];
  List<dynamic> foodList = [];
  List<Map<String,dynamic>> foodList1 = [];
  bool isListVisible = false;
  List allTables=[];
  bool selectedCategory = false;
  List<bool> _selected = [];
  int quantity=5;
  bool isLoading=false;
  List<Vendors> riderList=[];
  List<String> riderNames=[];
  Vendors selectedRider;



  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    SharedPreferences.getInstance().then((value) {
      setState(() {
        this.token = value.getString("token");
      });
    });

    // TODO: implement initState
    super.initState();
  }
  String getTableName(int id){
    String name;
    if(id!=null&&allTables!=null){
      for(int i=0;i<allTables.length;i++){
        if(allTables[i]['id'] == id) {
          name = allTables[i]['name'];
        }
      }
      return name!=null?name:"-";
    }else
      return "empty";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: (){
            return Utils.check_connectivity().then((result){
              if(result){
                setState(() {
                  isLoading=true;
                });
                orderList.clear();
                Network_Operations.getAllOrders(context, token,widget.store["id"]).then((value) {
                  setState(() {
                    isLoading=false;
                    if(value!=null&&value.length>0){
                      //value=value.reversed.toList();
                      for(var order in value){
                        if(LocalizedApp.of(context).delegate.currentLocale.languageCode!="ar"){
                          String createdOn=DateFormat("yyyy-MM-dd").parse(order["createdOn"]).toString().split(" ")[0].trim();
                          String todayDate=DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day).toIso8601String().replaceAll("T00:00:00.000","").trim();
                          if(createdOn.contains(todayDate)&&order["cashPay"]==null&&order["orderStatus"]!=2){
                            orderList.add(order);
                          }
                        }else{
                          if(DateTime.now().difference(DateTime.parse(order["createdOn"])).inDays==0&&order["cashPay"]==null&&order["orderStatus"]!=2){
                            orderList.add(order);
                          }
                        }
                      }
                    }
                    //orderList = value;
                  });
                });
                Network_Operations.getRiderListByStoreId(context,token,widget.store["id"]).then((value){
                  if(value!=null){
                    setState(() {
                      riderList = value;
                      if(riderList!=null&&riderList.length>0){
                        for(int i=0;i<riderList.length;i++){
                          if(riderList[i].user!=null&&riderList[i].user.firstName!=null){
                            riderNames.add((riderList[i].user.firstName+" "+riderList[i].user.lastName.toString()));
                          }
                        }
                      }
                    });
                  }
                });
                Network_Operations.getTableList(context,token,widget.store["id"])
                    .then((value) {
                  setState(() {
                    this.allTables = value;
                    print(allTables);
                  });
                });
              }else{
                Utils.showError(context, translate("error_messages.not_connected_to_internet"));
              }
            });
          },

          child:
          //isLoading?LoadingScreen():
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                    image: AssetImage('assets/bb.jpg'),
                  )
              ),
              child: new Container(
                //decoration: new BoxDecoration(color: Colors.black.withOpacity(0.3)),
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Row(
                            children: [
                              Card(
                                elevation:8,
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 17,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: yellowColor, width: 2),
                                    //color: yellowColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(translate("unpaid_today_orders.total_orders"),
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: yellowColor,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(orderList!=null?orderList.length.toString():"0",
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: PrimaryColor,
                                            fontWeight: FontWeight.bold
                                        ),
                                      )
                                    ],
                                  ),
                                  //child:  _buildChips()
                                ),
                              ),
                            ],
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          height: 50,
                          //color: Colors.black38,
                          child: Center(
                            child: _buildChips(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child:ListView.builder(
                                itemCount: orderList!=null?orderList.length:0,
                                itemBuilder: (context, index){
                                  return InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder:(BuildContext context){
                                            return Dialog(
                                                backgroundColor: Colors.transparent,
                                                child: Container(
                                                    height: 800,
                                                    width: 600,
                                                    child: orderDetailPopup(orderList[index])
                                                    //ordersDetailPopupLayoutHorizontal(orderList[index])
                                                )
                                            );
                                          });
                                    },
                                    child: Card(
                                        elevation: 8,
                                        child: Container(
                                          height: 100,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          child: Column(
                                            children: [
                                              Card(
                                                elevation:6,
                                                color: yellowColor,
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(4),
                                                      color: yellowColor
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(right: 6, left: 6),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Order ID: ',
                                                              style: TextStyle(
                                                                  fontSize: 25,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.white
                                                              ),
                                                            ),
                                                            Text(
                                                              //"01",
                                                              orderList[index]['id']!=null?orderList[index]['id'].toString():"",
                                                              style: TextStyle(
                                                                  fontSize: 25,
                                                                  color: blueColor,
                                                                  fontWeight: FontWeight.bold
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        orderList[index]["orderType"]==1? FaIcon(FontAwesomeIcons.utensils, color: blueColor, size:30):orderList[index]["orderType"]==2?FaIcon(FontAwesomeIcons.shoppingBag, color: blueColor,size:30):FaIcon(FontAwesomeIcons.biking, color: blueColor,size:30)
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: 1,
                                                color: yellowColor,
                                              ),
                                              SizedBox(height: 5,),
                                              Padding(
                                                padding: const EdgeInsets.all(4),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(translate("unpaid_today_orders.total"),
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: yellowColor
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 2.5),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              //"Dine-In",
                                                              widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":" ",
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: PrimaryColor
                                                              ),
                                                            ),
                                                            Text(
                                                              //"Dine-In",
                                                              orderList[index]['grossTotal'].toStringAsFixed(0),
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: PrimaryColor
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Visibility(
                                                      visible: orderList[index]['orderType']==1,
                                                      child: Row(
                                                        children: [
                                                          Text(translate("unpaid_today_orders.table"),
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.bold,
                                                                color: yellowColor
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(left: 2.5),
                                                          ),
                                                          Text(
                                                            //"01",
                                                            orderList[index]['tableId']!=null?getTableName(orderList[index]['tableId']):"",
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.bold,
                                                                color: PrimaryColor
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  ],
                                                ),

                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                  );
                                }),
                          ),
                        ),
                      )
                    ],
                  )

              )
          ),
        )

    );
  }
  String getOrderType(int id){
    String status;
    if(id!=null){
      if(id ==0){
        status = "None";
      }else if(id ==1){
        status = "Dine-In";
      }else if(id ==2){
        status = "Take Away";
      }else if(id ==3){
        status = "Delivery";
      }
      return status;
    }else{
      return "";
    }
  }
  String getStatus(int id){
    String status;

    if(id!=null){
      if(id==0){
        status = "None";
      }
      else if(id ==1){
        status = "InQueue";
      }else if(id ==2){
        status = "Cancel";
      }else if(id ==3){
        status = "OrderVerified";
      }else if(id ==4){
        status = "InProgress";
      }else if(id ==5){
        status = "Ready";
      } else if(id ==6){
        status = "On The Way";
      }else if(id ==7){
        status = "Delivered";
      }

      return status;
    }else{
      return "";
    }
  }


  Widget _buildChips() {
    List<Widget> chips = new List();

    for (int i = 0; i < allTables.length; i++) {
      _selected.add(false);
      FilterChip filterChip = FilterChip(

        selected: _selected[i],
        label: Text(getTableName(allTables[i]["id"]), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        // avatar: FlutterLogo(),
        elevation: 10,
        pressElevation: 5,
        //shadowColor: Colors.teal,
        backgroundColor: yellowColor,
        selectedColor: PrimaryColor,
        onSelected: (bool selected) {
          setState(() {
            for(int j=0;j<_selected.length;j++){
              if(_selected[j]){
                _selected[j]=false;
              }
            }
            _selected[i] = selected;
            if(_selected[i]){
              Utils.check_connectivity().then((result){
                if(result){
                  orderList.clear();
                  Network_Operations.getOrdersByTableId(context, token,allTables[i]["id"],widget.store["id"]).then((value) {
                    setState(() {
                      if(value!=null&&value.length>0){
                        for(var order in value){
                          String createdOn=DateFormat("yyyy-MM-dd").parse(order["createdOn"]).toString().split(" ")[0].trim();
                          String todayDate=DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day).toIso8601String().replaceAll("T00:00:00.000","").trim();
                          print(order["cashPay"]==null);
                          if(createdOn.contains(todayDate)&&order["cashPay"]==null&&order["orderStatus"]!=2){
                            orderList.add(order);
                          }
                        }
                      }


                    });
                  });
                }else{
                  Utils.showError(context, translate("error_messages.not_connected_to_internet"));
                }
              });
            }else{
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
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
  showAlertDialog(BuildContext context,int orderId) {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        barrierColor: Colors.black45,

        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext,
            Animation animation,
            Animation secondaryAnimation) {
          return Center(
            child: Container(
                width: 450,
                height:350,

                child: DealsDetailsForKitchen(orderId)

            ),
          );
        });


  }

  String waiterName="-",customerName="-";
  Widget orderDetailPopup(dynamic orders){
    print("Orders Response"+orders.toString());
    if(orders["discountedPrice"]!=null&&orders["discountedPrice"]!=0.0){
      if(orders["orderTaxes"].where((element)=>element["taxName"]=="Discount").toList()!=null&&orders["orderTaxes"].where((element)=>element["taxName"]=="Discount").toList().length>0){
        orders["orderTaxes"].remove(orders["orderTaxes"].last);
      }
      orders["orderTaxes"].add({"taxName":"Discount","amount":orders["discountedPrice"]});
    }
    return Scaffold(
        body: StatefulBuilder(
            builder: (context,innerSetstate){
              if(orders!=null&&orders["customerId"]!=null) {
                Network_Operations.getCustomerById(
                    context, token, orders["customerId"]).then((customerInfo) {
                  innerSetstate(() {
                    customerName=customerInfo["firstName"];
                    print("Customer Name "+customerName);
                  });
                });
              }
              if(orders!=null&&orders["employeeId"]!=null){
                Network_Operations.getCustomerById(
                    context, token, orders["employeeId"]).then((waiterInfo) {
                  innerSetstate(() {
                    waiterName=waiterInfo["firstName"]+""+waiterInfo["lastName"];
                    print("employee Name "+waiterName);
                  });
                });
              }
              return Container(
                height:800,
                width: 600,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/bb.jpg'),
                    )
                ),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: yellowColor
                        ),
                        child:  Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  orders["orderType"]==1? FaIcon(FontAwesomeIcons.utensils, color: blueColor, size:25):orders["orderType"]==2?FaIcon(FontAwesomeIcons.shoppingBag, color: blueColor,size:30):FaIcon(FontAwesomeIcons.biking, color: blueColor,size:30),
                                ],
                              ),

                              Row(
                                children: [
                                  Text(translate("unpaid_today_orders.order_id")+": ",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  ),
                                  Text(orders['id']!=null?orders['id'].toString():"",
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: blueColor,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  orders["orderStatus"]!=7?InkWell(
                                    child: Padding(
                                        padding: const EdgeInsets.only(top: 3,bottom: 16.0,right: 8.0,left: 8.0),
                                        child: FaIcon(FontAwesomeIcons.history, color: blueColor, size: 25,)),
                                    onTap: (){
                                      if(orders["orderStatus"]==1){
                                        var orderStatusData={
                                          "Id":orders['id'],
                                          "status":3,
                                        };
                                        Navigator.pop(context);
                                        Network_Operations.changeOrderStatus(context, token, orderStatusData).then((value){
                                          if(value){
                                            setState(() {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                            });
                                            Utils.showSuccess(context, translate("error_messages.order_status_changed"));
                                          }else{
                                            Utils.showError(context, translate("error_messages.please_try_again"));
                                          }
                                        });
                                      }
                                      if(orders["orderStatus"]==3){
                                        var orderStatusData={
                                          "Id":orders['id'],
                                          "status":4,
                                        };

                                        Navigator.pop(context);
                                        Network_Operations.changeOrderStatus(context, token, orderStatusData).then((value){
                                          if(value){
                                            setState(() {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                            });
                                            Utils.showSuccess(context, translate("error_messages.order_status_changed"));
                                          }else{
                                            Utils.showError(context, translate("error_messages.please_try_again"));
                                          }
                                        });
                                      }
                                      if(orders["orderStatus"]==4){
                                        var orderStatusData={
                                          "Id":orders['id'],
                                          "status":5,
                                        };
                                        Navigator.pop(context);
                                        Network_Operations.changeOrderStatus(context, token, orderStatusData).then((value){
                                          if(value){
                                            setState(() {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                            });
                                            Utils.showSuccess(context, translate("error_messages.order_status_changed"));
                                          }else{
                                            Utils.showError(context, translate("error_messages.please_try_again"));
                                          }
                                        });
                                      }
                                      if(orders["orderStatus"]==5){
                                        if(orders["orderType"]==1||orders["orderType"]==2){
                                          Navigator.pop(context);
                                          showDialog(
                                              context: context,
                                              builder: (context){
                                                return Dialog(
                                                  backgroundColor: Colors.transparent,
                                                  child: Container(
                                                    width: 400,
                                                    height: 370,
                                                    child: payoutDialog(orders),
                                                  ),
                                                );
                                              }
                                          );
                                        }else{
                                          Navigator.pop(context);
                                          showDialog(
                                              context: context,
                                              builder: (context){
                                                return Dialog(
                                                  backgroundColor: Colors.transparent,
                                                  child: Container(
                                                    width: 400,
                                                    height: 350,
                                                    child: AssignRiderDialog(orders),
                                                  ),
                                                );
                                              }
                                          );
                                        }
                                      }
                                      if(orders["orderStatus"]==6){
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (context){
                                              return Dialog(
                                                backgroundColor: Colors.transparent,
                                                child: Container(
                                                  width: 400,
                                                  height: 370,
                                                  child: payoutDialog(orders),
                                                ),
                                              );
                                            }
                                        );
                                      }
                                    },
                                  ):Container(),

                                  orders["orderStatus"]==1?InkWell(
                                    child: FaIcon(FontAwesomeIcons.solidTimesCircle, color: blueColor, size: 25,),
                                    onTap: (){
                                      Network_Operations.cancelOrder(context, token, orders['id'], 2).then((value){
                                        if(value){
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                          Navigator.pop(context);
                                          Utils.showSuccess(context, translate("in_app_errors.order_cancelled"));
                                        }else{
                                          Utils.showError(context, translate("error_messages.please_try_again"));
                                        }
                                      });
                                    },
                                  ):Container(),
                                  Padding(
                                    padding: const EdgeInsets.only(left:8.0),
                                    child: InkWell(
                                        onTap: (){
                                          Utils.buildInvoice(orders,widget.store,customerName);
                                        },
                                        child: FaIcon(FontAwesomeIcons.print, color: blueColor, size: 25,)),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3,),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        //height: 180,
                        //color: yellowColor,
                        child: ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex:2,
                                    child: Container(
                                      width: 90,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: yellowColor,
                                        border: Border.all(color: yellowColor, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: AutoSizeText(
                                          translate("unpaid_today_orders_popup.items"),
                                          style: TextStyle(
                                              color: BackgroundColor,
                                              fontSize: 16,
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
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: yellowColor, width: 2),
                                        //color: BackgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child:
                                      Center(
                                        child: Text(orders['orderItems'].length.toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: PrimaryColor,
                                              fontWeight: FontWeight.bold
                                          ),
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
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: yellowColor,
                                        border: Border.all(color: yellowColor, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: AutoSizeText(
                                          translate("unpaid_today_orders_popup.total"),
                                          style: TextStyle(
                                              color: BackgroundColor,
                                              fontSize: 16,
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
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: yellowColor, width: 2),
                                        //color: BackgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child:
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            //"Dine-In",
                                            widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+": ":" ",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor
                                            ),
                                          ),
                                          Text(
                                            //"Dine-In",
                                            orders["grossTotal"].toStringAsFixed(0),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Center(
                                      //   child: AutoSizeText(
                                      //     widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":" ",
                                      //     style: TextStyle(
                                      //         color: blueColor,
                                      //         fontSize: 22,
                                      //         fontWeight: FontWeight.bold
                                      //     ),
                                      //     maxLines: 2,
                                      //   ),
                                      // ),
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
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: yellowColor,
                                        border: Border.all(color: yellowColor, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: AutoSizeText(
                                          translate("unpaid_today_orders_popup.status"),
                                          style: TextStyle(
                                              color: BackgroundColor,
                                              fontSize: 16,
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
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: yellowColor, width: 2),
                                        //color: BackgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child:
                                      Center(
                                        child: Text( getStatus(orders!=null?orders['orderStatus']:null),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: PrimaryColor,
                                              fontWeight: FontWeight.bold
                                          ),
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
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: yellowColor,
                                        border: Border.all(color: yellowColor, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: AutoSizeText(
                                          translate("unpaid_today_orders_popup.waiter"),
                                          style: TextStyle(
                                              color: BackgroundColor,
                                              fontSize: 16,
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
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: yellowColor, width: 2),
                                        //color: BackgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child:
                                      Center(
                                        child: Text( waiterName,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: PrimaryColor,
                                              fontWeight: FontWeight.bold
                                          ),
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
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: yellowColor,
                                        border: Border.all(color: yellowColor, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: AutoSizeText(
                                          translate("unpaid_today_orders_popup.customer"),
                                          style: TextStyle(
                                              color: BackgroundColor,
                                              fontSize: 16,
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
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: yellowColor, width: 2),
                                        //color: BackgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child:
                                      Center(
                                        child: Text( orders["visitingCustomer"]!=null?orders["visitingCustomer"]:customerName,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: PrimaryColor,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Visibility(
                              visible: orders['orderType']==1,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex:2,
                                      child: Container(
                                        width: 90,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: yellowColor,
                                          border: Border.all(color: yellowColor, width: 2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: AutoSizeText(
                                            translate("unpaid_today_orders_popup.table_number"),
                                            style: TextStyle(
                                                color: BackgroundColor,
                                                fontSize: 16,
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
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: yellowColor, width: 2),
                                          //color: BackgroundColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child:
                                        Center(
                                          child: Text(orders['tableId']!=null?getTableName(orders['tableId']).toString():" N/A ",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: PrimaryColor,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex:2,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            border: Border.all(color: yellowColor)
                        ),
                        //color: yellowColor,
                        child: ListView.builder(
                            itemCount: orders == null ? 0:orders['orderItems'].length,
                            itemBuilder: (context, i){
                              topping=[];

                              for(var items in orders['orderItems'][i]['orderItemsToppings']){
                                topping.add(items==[]?"-":items['additionalItem']['stockItemName']+" (${widget.store["currencyCode"].toString()+items["price"].toStringAsFixed(0)})   x${items['quantity'].toString()+"    "+widget.store["currencyCode"].toString()+": "+items["totalPrice"].toStringAsFixed(0)} \n");
                              }
                              return InkWell(
                                onTap: (){
                                  if(orders['orderItems'][i]['isDeal'] == true){
                                    print(orders['id']);
                                    showAlertDialog(context,orders['id']);
                                  }
                                },
                                child: Card(
                                  elevation: 8,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: yellowColor,
                                            //border: Border.all(color: yellowColor, width: 2),
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight:Radius.circular(4)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              orders['orderItems']!=null?orders['orderItems'][i]['name']:"",
                                              style: TextStyle(
                                                  color: BackgroundColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                              ),
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
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    //color: yellowColor,
                                                    border: Border.all(color: yellowColor, width: 2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: AutoSizeText(
                                                      translate("unpaid_today_orders_popup.unit_price"),
                                                      style: TextStyle(
                                                          color: yellowColor,
                                                          fontSize: 16,
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
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: yellowColor, width: 2),
                                                    //color: BackgroundColor,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: AutoSizeText(
                                                      orders["orderItems"][i]["price"].toStringAsFixed(0),
                                                      //cartList[index].sizeName!=null?cartList[index].sizeName:"N/A",
                                                      style: TextStyle(
                                                          color: blueColor,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                      maxLines: 1,
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
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    //color: yellowColor,
                                                    border: Border.all(color: yellowColor, width: 2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: AutoSizeText(
                                                      translate("unpaid_today_orders_popup.quantity"),
                                                      style: TextStyle(
                                                          color: yellowColor,
                                                          fontSize: 16,
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
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: yellowColor, width: 2),
                                                    //color: BackgroundColor,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: AutoSizeText(
                                                      orders['orderItems'][i]['quantity'].toString(),
                                                      //cartList[index].sizeName!=null?cartList[index].sizeName:"N/A",
                                                      style: TextStyle(
                                                          color: blueColor,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                      maxLines: 1,
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
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    //color: yellowColor,
                                                    border: Border.all(color: yellowColor, width: 2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: AutoSizeText(
                                                      translate("unpaid_today_orders_popup.size"),
                                                      style: TextStyle(
                                                          color: yellowColor,
                                                          fontSize: 16,
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
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: yellowColor, width: 2),
                                                    //color: BackgroundColor,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: AutoSizeText(
                                                      orders['orderItems'][i]['sizeName']!=null?orders['orderItems'][i]['sizeName'].toString():"-",
                                                      //cartList[index].sizeName!=null?cartList[index].sizeName:"N/A",
                                                      style: TextStyle(
                                                          color: blueColor,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                      maxLines: 1,
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
                                            child:
                                            //orders['orderItems'].isNotEmpty&&orders[i].topping!=null?
                                            topping!=null&&topping.length>0?
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // Expanded(
                                                //   flex:2,
                                                //   child: Container(
                                                //
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
                                                //             fontSize: 20,
                                                //             fontWeight: FontWeight.bold
                                                //         ),
                                                //         maxLines: 2,
                                                //       ),
                                                //     ),
                                                //   ),
                                                // ),
                                                //SizedBox(width: 2,),
                                                Expanded(
                                                  flex:3,
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: yellowColor, width: 2),
                                                        //color: BackgroundColor,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          AutoSizeText(
                                                            translate("unpaid_today_orders_popup.extras"),
                                                            style: TextStyle(
                                                                color: yellowColor,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold
                                                            ),
                                                            maxLines: 1,
                                                          ),
                                                          Center(
                                                            child: Text(
                                                              //'Extra Large',
                                                              topping != null
                                                                  ? topping
                                                                  .toString()
                                                                  .replaceAll("[", "- ")
                                                                  .replaceAll(",", "- ")
                                                                  .replaceAll("]", "")
                                                                  :"N/A",
                                                              style: TextStyle(
                                                                  color: blueColor,
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.bold
                                                              ),
                                                              maxLines: 20,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  ),
                                                ),

                                              ],
                                            )
                                                :Container(),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: yellowColor,
                                            //border: Border.all(color: yellowColor, width: 2),
                                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight:Radius.circular(4)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  translate("unpaid_today_orders_popup.price"),
                                                  style: TextStyle(
                                                    color: BackgroundColor,
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.w800,
                                                    //fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      //"Dine-In",
                                                      widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+": ":" ",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: PrimaryColor
                                                      ),
                                                    ),
                                                    Text(
                                                      orders['orderItems'][i]['totalPrice']!=null?orders['orderItems'][i]['totalPrice'].toStringAsFixed(0):"-",
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        //fontStyle: FontStyle.italic,
                                                      ),
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
                              );
                            }),
                      ),
                    ),
                    SizedBox(height: 10),
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
                              translate("unpaid_today_orders_popup.sub_total"),
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
                                  orders["netTotal"].toStringAsFixed(0),
                                  //overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(0)+"/-":"0.0/-",
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                            width: MediaQuery.of(
                                context)
                                .size
                                .width,

                            decoration: BoxDecoration(
                              border: Border.all(color: yellowColor),
                              //borderRadius: BorderRadius.circular(8)
                            ),
                            child: ListView.builder(
                                itemCount:orders["orderTaxes"]!=null? orders["orderTaxes"].length:0,

                                itemBuilder: (context, index){
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
                                          orders["orderTaxes"][index]["taxName"],
                                          //orders["orderTaxes"][index].percentage!=null&&orders["orderTaxes"][index].percentage!=0.0?orders["orderTaxes"][index]["taxName"]+" (${typeBasedTaxes[index].percentage.toStringAsFixed(0)})":typeBasedTaxes[index].name,
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
                                            Text(
                                              widget.store["currencyCode"].toString()+" "+
                                                  orders["orderTaxes"][index]["amount"].toStringAsFixed(0),
                                              //typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0?widget.store["currencyCode"].toString()+" "+typeBasedTaxes[index].price.toStringAsFixed(0):typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1?widget.store["currencyCode"].toString()+": "+(overallTotalPriceWithTax/100*typeBasedTaxes[index].percentage).toStringAsFixed(0):widget.store["currencyCode"].toString()+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(0),
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
                              translate("unpaid_today_orders_popup.total"),
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
                                  orders["grossTotal"].toStringAsFixed(0),
                                  //priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(0)+"/-":overallTotalPriceWithTax.toStringAsFixed(0)+"/-",
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
              );
            }

        )

    );


  }
  Widget ordersDetailPopupLayoutHorizontal(dynamic orders) {
    print("Orders Response"+orders.toString());
    if(orders["discountedPrice"]!=null&&orders["discountedPrice"]!=0.0){
      if(orders["orderTaxes"].where((element)=>element["taxName"]=="Discount").toList()!=null&&orders["orderTaxes"].where((element)=>element["taxName"]=="Discount").toList().length>0){
        orders["orderTaxes"].remove(orders["orderTaxes"].last);
      }
      orders["orderTaxes"].add({"taxName":"Discount","amount":orders["discountedPrice"]});
    }
    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.1),
        body: StatefulBuilder(
          builder: (context,innerSetstate){
            if(orders!=null&&orders["customerId"]!=null) {
              Network_Operations.getCustomerById(
                  context, token, orders["customerId"]).then((customerInfo) {
                innerSetstate(() {
                  customerName=customerInfo["firstName"];
                  print("Customer Name "+customerName);
                });
              });
            }
            if(orders!=null&&orders["employeeId"]!=null){
              Network_Operations.getCustomerById(
                  context, token, orders["employeeId"]).then((waiterInfo) {
                innerSetstate(() {
                  waiterName=waiterInfo["firstName"]+""+waiterInfo["lastName"];
                  print("employee Name "+waiterName);
                });
              });
            }
            return Container(
                height:450,
                width: 750,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/bb.jpg'),
                    )
                ),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: yellowColor
                        ),
                        child:  Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  orders["orderType"]==1? FaIcon(FontAwesomeIcons.utensils, color: blueColor, size:30):orders["orderType"]==2?FaIcon(FontAwesomeIcons.shoppingBag, color: blueColor,size:30):FaIcon(FontAwesomeIcons.biking, color: blueColor,size:30),
                                ],
                              ),

                              Row(
                                children: [
                                  Text(translate("unpaid_today_orders.order_id")+": ",
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  ),
                                  Text(orders['id']!=null?orders['id'].toString():"",
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: blueColor,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  orders["orderStatus"]!=7?Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0,right: 8.0,left: 8.0),
                                    child: InkWell(
                                      child: FaIcon(FontAwesomeIcons.history, color: blueColor, size: 30,),
                                      onTap: (){
                                        if(orders["orderStatus"]==1){
                                          var orderStatusData={
                                            "Id":orders['id'],
                                            "status":3,
                                          };
                                          Navigator.pop(context);
                                          Network_Operations.changeOrderStatus(context, token, orderStatusData).then((value){
                                            if(value){
                                              setState(() {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                              });
                                              Utils.showSuccess(context, translate("error_messages.order_status_changed"));
                                            }else{
                                              Utils.showError(context, translate("error_messages.please_try_again"));
                                            }
                                          });
                                        }
                                        if(orders["orderStatus"]==3){
                                          var orderStatusData={
                                            "Id":orders['id'],
                                            "status":4,
                                          };

                                          Navigator.pop(context);
                                          Network_Operations.changeOrderStatus(context, token, orderStatusData).then((value){
                                            if(value){
                                              setState(() {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                              });
                                              Utils.showSuccess(context, translate("error_messages.order_status_changed"));
                                            }else{
                                              Utils.showError(context, translate("error_messages.please_try_again"));
                                            }
                                          });
                                        }
                                        if(orders["orderStatus"]==4){
                                          var orderStatusData={
                                            "Id":orders['id'],
                                            "status":5,
                                          };
                                          Navigator.pop(context);
                                          Network_Operations.changeOrderStatus(context, token, orderStatusData).then((value){
                                            if(value){
                                              setState(() {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                              });
                                              Utils.showSuccess(context, translate("error_messages.order_status_changed"));
                                            }else{
                                              Utils.showError(context, translate("error_messages.please_try_again"));
                                            }
                                          });
                                        }
                                        if(orders["orderStatus"]==5){
                                          if(orders["orderType"]==1||orders["orderType"]==2){
                                            Navigator.pop(context);
                                            showDialog(
                                                context: context,
                                                builder: (context){
                                                  return Dialog(
                                                    backgroundColor: Colors.transparent,
                                                    child: Container(
                                                      width: 400,
                                                      height: 370,
                                                      child: payoutDialog(orders),
                                                    ),
                                                  );
                                                }
                                            );
                                          }else{
                                            Navigator.pop(context);
                                            showDialog(
                                                context: context,
                                                builder: (context){
                                                  return Dialog(
                                                    backgroundColor: Colors.transparent,
                                                    child: Container(
                                                      width: 400,
                                                      height: 350,
                                                      child: AssignRiderDialog(orders),
                                                    ),
                                                  );
                                                }
                                            );
                                          }
                                        }
                                        if(orders["orderStatus"]==6){
                                          Navigator.pop(context);
                                          showDialog(
                                              context: context,
                                              builder: (context){
                                                return Dialog(
                                                  backgroundColor: Colors.transparent,
                                                  child: Container(
                                                    width: 400,
                                                    height: 370,
                                                    child: payoutDialog(orders),
                                                  ),
                                                );
                                              }
                                          );
                                        }
                                      },
                                    ),
                                  )
                                      :Container(),
                                  orders["orderStatus"]==1?InkWell(
                                    child: FaIcon(FontAwesomeIcons.solidTimesCircle, color: blueColor, size: 30,),
                                    onTap: (){
                                      Network_Operations.cancelOrder(context, token, orders['id'], 2).then((value){
                                        if(value){
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                          Navigator.pop(context);
                                          Utils.showSuccess(context, translate("in_app_errors.order_cancelled"));
                                        }else{
                                          Utils.showError(context, translate("error_messages.please_try_again"));
                                        }
                                      });
                                    },
                                  ):Container(),
                                  Padding(
                                    padding: const EdgeInsets.only(left:8.0),
                                    child: InkWell(
                                        onTap: (){
                                          Utils.buildInvoice(orders,widget.store,customerName);
                                        },
                                        child: FaIcon(FontAwesomeIcons.print, color: blueColor, size: 30,)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3,),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 385,
                            //color: yellowColor,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex:2,
                                        child: Container(
                                          width: 90,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: yellowColor,
                                            border: Border.all(color: yellowColor, width: 2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: AutoSizeText(
                                              translate("unpaid_today_orders_popup.items"),
                                              style: TextStyle(
                                                  color: BackgroundColor,
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
                                          height: 30,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: yellowColor, width: 2),
                                            //color: BackgroundColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child:
                                          Center(
                                            child: Text(orders['orderItems'].length.toString(),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: PrimaryColor,
                                                  fontWeight: FontWeight.bold
                                              ),
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
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: yellowColor,
                                            border: Border.all(color: yellowColor, width: 2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: AutoSizeText(
                                              translate("unpaid_today_orders_popup.total"),
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
                                      SizedBox(width: 2,),
                                      Expanded(
                                        flex:3,
                                        child: Container(
                                          width: 90,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: yellowColor, width: 2),
                                            //color: BackgroundColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child:
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                //"Dine-In",
                                                widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+": ":" ",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: blueColor
                                                ),
                                              ),
                                              Text(
                                                //"Dine-In",
                                                orders["grossTotal"].toStringAsFixed(0),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: blueColor
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Center(
                                          //   child: AutoSizeText(
                                          //     widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":" ",
                                          //     style: TextStyle(
                                          //         color: blueColor,
                                          //         fontSize: 22,
                                          //         fontWeight: FontWeight.bold
                                          //     ),
                                          //     maxLines: 2,
                                          //   ),
                                          // ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                // Row(
                                //   children: [
                                //     Container(),
                                //
                                //     Text('Total: ',
                                //       style: TextStyle(
                                //           fontSize: 20,
                                //           fontWeight: FontWeight.bold,
                                //           color: yellowColor
                                //       ),
                                //     ),
                                //     Padding(
                                //       padding: EdgeInsets.only(left: 2.5),
                                //     ),
                                //     Row(
                                //       children: [
                                //         Text(
                                //           //"Dine-In",
                                //           widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+":":" ",
                                //           style: TextStyle(
                                //               fontSize: 20,
                                //               fontWeight: FontWeight.bold,
                                //               color: PrimaryColor
                                //           ),
                                //         ),
                                //         Text(
                                //           //"Dine-In",
                                //           orders['grossTotal'].toStringAsFixed(0),
                                //           style: TextStyle(
                                //               fontSize: 20,
                                //               fontWeight: FontWeight.bold,
                                //               color: PrimaryColor
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ],
                                // ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex:2,
                                        child: Container(
                                          width: 90,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: yellowColor,
                                            border: Border.all(color: yellowColor, width: 2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: AutoSizeText(
                                              translate("unpaid_today_orders_popup.status"),
                                              style: TextStyle(
                                                  color: BackgroundColor,
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
                                          height: 30,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: yellowColor, width: 2),
                                            //color: BackgroundColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child:
                                          Center(
                                            child: Text( getStatus(orders!=null?orders['orderStatus']:null),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: PrimaryColor,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(2.0),
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       Expanded(
                                //         flex:2,
                                //         child: Container(
                                //           width: 90,
                                //           height: 30,
                                //           decoration: BoxDecoration(
                                //             color: yellowColor,
                                //             border: Border.all(color: yellowColor, width: 2),
                                //             borderRadius: BorderRadius.circular(8),
                                //           ),
                                //           child: Center(
                                //             child: AutoSizeText(
                                //               'Type:',
                                //               style: TextStyle(
                                //                   color: BackgroundColor,
                                //                   fontSize: 22,
                                //                   fontWeight: FontWeight.bold
                                //               ),
                                //               maxLines: 1,
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //       SizedBox(width: 2,),
                                //       Expanded(
                                //         flex:3,
                                //         child: Container(
                                //           width: 90,
                                //           height: 30,
                                //           decoration: BoxDecoration(
                                //             border: Border.all(color: yellowColor, width: 2),
                                //             //color: BackgroundColor,
                                //             borderRadius: BorderRadius.circular(8),
                                //           ),
                                //           child:
                                //           Center(
                                //             child: Text( getOrderType(orders['orderType']),
                                //               style: TextStyle(
                                //                   fontSize: 20,
                                //                   color: PrimaryColor,
                                //                   fontWeight: FontWeight.bold
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       )
                                //     ],
                                //   ),
                                // ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex:2,
                                        child: Container(
                                          width: 90,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: yellowColor,
                                            border: Border.all(color: yellowColor, width: 2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: AutoSizeText(
                                              translate("unpaid_today_orders_popup.waiter"),
                                              style: TextStyle(
                                                  color: BackgroundColor,
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
                                          height: 30,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: yellowColor, width: 2),
                                            //color: BackgroundColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child:
                                          Center(
                                            child: Text( waiterName,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: PrimaryColor,
                                                  fontWeight: FontWeight.bold
                                              ),
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
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: yellowColor,
                                            border: Border.all(color: yellowColor, width: 2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: AutoSizeText(
                                                translate("unpaid_today_orders_popup.customer"),
                                              style: TextStyle(
                                                  color: BackgroundColor,
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
                                          height: 30,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: yellowColor, width: 2),
                                            //color: BackgroundColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child:
                                          Center(
                                            child: Text( orders["visitingCustomer"]!=null?orders["visitingCustomer"]:customerName,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: PrimaryColor,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: orders['orderType']==1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex:2,
                                          child: Container(
                                            width: 90,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: yellowColor,
                                              border: Border.all(color: yellowColor, width: 2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: AutoSizeText(
                                                translate("unpaid_today_orders_popup.table_number"),
                                                style: TextStyle(
                                                    color: BackgroundColor,
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
                                            height: 30,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: yellowColor, width: 2),
                                              //color: BackgroundColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child:
                                            Center(
                                              child: Text(orders['tableId']!=null?getTableName(orders['tableId']).toString():" N/A ",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: PrimaryColor,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 3,),
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
                                                translate("unpaid_today_orders_popup.sub_total"),
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
                                                    orders["netTotal"].toStringAsFixed(0),
                                                    //overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(0)+"/-":"0.0/-",
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
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Container(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width,

                                              decoration: BoxDecoration(
                                                border: Border.all(color: yellowColor),
                                                //borderRadius: BorderRadius.circular(8)
                                              ),
                                              child: ListView.builder(
                                                  itemCount:orders["logicallyArrangedTaxes"]!=null? orders["logicallyArrangedTaxes"].length:0,

                                                  itemBuilder: (context, index){
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
                                                            orders["logicallyArrangedTaxes"][index]["taxName"],
                                                            //orders["orderTaxes"][index].percentage!=null&&orders["orderTaxes"][index].percentage!=0.0?orders["orderTaxes"][index]["taxName"]+" (${typeBasedTaxes[index].percentage.toStringAsFixed(0)})":typeBasedTaxes[index].name,
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
                                                              Text(
                                                                widget.store["currencyCode"].toString()+" "+
                                                                    orders["logicallyArrangedTaxes"][index]["amount"].toStringAsFixed(0),
                                                                //typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0?widget.store["currencyCode"].toString()+" "+typeBasedTaxes[index].price.toStringAsFixed(0):typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1?widget.store["currencyCode"].toString()+": "+(overallTotalPriceWithTax/100*typeBasedTaxes[index].percentage).toStringAsFixed(0):widget.store["currencyCode"].toString()+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(0),
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
                                                translate("unpaid_today_orders_popup.total"),
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
                                                    orders["grossTotal"].toStringAsFixed(0),
                                                    //priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(0)+"/-":overallTotalPriceWithTax.toStringAsFixed(0)+"/-",
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
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 385,
                            child: ListView.builder(
                                itemCount: orders == null ? 0:orders['orderItems'].length,
                                itemBuilder: (context, i){
                                  topping=[];

                                  for(var items in orders['orderItems'][i]['orderItemsToppings']){
                                    topping.add(items==[]?"-":items['additionalItem']['stockItemName']+" (${widget.store["currencyCode"].toString()+items["price"].toStringAsFixed(0)})   x${items['quantity'].toString()+"    "+widget.store["currencyCode"].toString()+": "+items["totalPrice"].toStringAsFixed(0)} \n");
                                  }
                                  return InkWell(
                                    onTap: (){
                                      if(orders['orderItems'][i]['isDeal'] == true){
                                        print(orders['id']);
                                        showAlertDialog(context,orders['id']);
                                      }
                                    },
                                    child: Card(
                                      elevation: 8,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: Column(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: yellowColor,
                                                //border: Border.all(color: yellowColor, width: 2),
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight:Radius.circular(4)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  orders['orderItems']!=null?orders['orderItems'][i]['name']:"",
                                                  style: TextStyle(
                                                      color: BackgroundColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 22
                                                  ),
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
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        //color: yellowColor,
                                                        border: Border.all(color: yellowColor, width: 2),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          translate("unpaid_today_orders_popup.unit_price"),
                                                          style: TextStyle(
                                                              color: yellowColor,
                                                              fontSize: 20,
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
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: yellowColor, width: 2),
                                                        //color: BackgroundColor,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          orders["orderItems"][i]["price"].toStringAsFixed(0),
                                                          //cartList[index].sizeName!=null?cartList[index].sizeName:"N/A",
                                                          style: TextStyle(
                                                              color: blueColor,
                                                              fontSize: 20,
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
                                            Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex:2,
                                                    child: Container(
                                                      width: 90,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        //color: yellowColor,
                                                        border: Border.all(color: yellowColor, width: 2),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          translate("unpaid_today_orders_popup.quantity"),
                                                          style: TextStyle(
                                                              color: yellowColor,
                                                              fontSize: 20,
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
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: yellowColor, width: 2),
                                                        //color: BackgroundColor,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          orders['orderItems'][i]['quantity'].toString(),
                                                          //cartList[index].sizeName!=null?cartList[index].sizeName:"N/A",
                                                          style: TextStyle(
                                                              color: blueColor,
                                                              fontSize: 20,
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
                                            Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex:2,
                                                    child: Container(
                                                      width: 90,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        //color: yellowColor,
                                                        border: Border.all(color: yellowColor, width: 2),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          translate("unpaid_today_orders_popup.size"),
                                                          style: TextStyle(
                                                              color: yellowColor,
                                                              fontSize: 20,
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
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: yellowColor, width: 2),
                                                        //color: BackgroundColor,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          orders['orderItems'][i]['sizeName']!=null?orders['orderItems'][i]['sizeName'].toString():"-",
                                                          //cartList[index].sizeName!=null?cartList[index].sizeName:"N/A",
                                                          style: TextStyle(
                                                              color: blueColor,
                                                              fontSize: 20,
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
                                                child:
                                                //orders['orderItems'].isNotEmpty&&orders[i].topping!=null?
                                                topping!=null&&topping.length>0?
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    // Expanded(
                                                    //   flex:2,
                                                    //   child: Container(
                                                    //
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
                                                    //             fontSize: 20,
                                                    //             fontWeight: FontWeight.bold
                                                    //         ),
                                                    //         maxLines: 2,
                                                    //       ),
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    //SizedBox(width: 2,),
                                                    Expanded(
                                                      flex:3,
                                                      child: Container(
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: yellowColor, width: 2),
                                                            //color: BackgroundColor,
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              AutoSizeText(
                                                                translate("unpaid_today_orders_popup.extras"),
                                                                style: TextStyle(
                                                                    color: yellowColor,
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.bold
                                                                ),
                                                                maxLines: 2,
                                                              ),
                                                              Center(
                                                                child: Text(
                                                                  //'Extra Large',
                                                                  topping != null
                                                                      ? topping
                                                                      .toString()
                                                                      .replaceAll("[", "- ")
                                                                      .replaceAll(",", "- ")
                                                                      .replaceAll("]", "")
                                                                      :"N/A",
                                                                  style: TextStyle(
                                                                      color: blueColor,
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.bold
                                                                  ),
                                                                  maxLines: 20,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                      ),
                                                    ),

                                                  ],
                                                )
                                                    :Container(),
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: yellowColor,
                                                //border: Border.all(color: yellowColor, width: 2),
                                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight:Radius.circular(4)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      translate("unpaid_today_orders_popup.price"),
                                                      style: TextStyle(
                                                        color: BackgroundColor,
                                                        fontSize: 25,
                                                        fontWeight: FontWeight.w800,
                                                        //fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          //"Dine-In",
                                                          widget.store["currencyCode"].toString()!=null?widget.store["currencyCode"].toString()+": ":" ",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: PrimaryColor
                                                          ),
                                                        ),
                                                        Text(
                                                          orders['orderItems'][i]['totalPrice']!=null?orders['orderItems'][i]['totalPrice'].toStringAsFixed(0):"-",
                                                          style: TextStyle(
                                                            color: blueColor,
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                            //fontStyle: FontStyle.italic,
                                                          ),
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
                                  );
                                }),
                            //color: blueColor,
                          ),
                        ),

                      ],
                    ),

                    // Row(
                    //     children: [
                    //       Expanded(
                    //         child: Container(
                    //           color: yellowColor,
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: Container(
                    //           color: blueColor,
                    //         ),
                    //       ),
                    //     ],
                    // )
                  ],
                )
            );



            ///

            ///
          },
        )
    );
  }


  final formKey= GlobalKey<FormState>();
  TextEditingController amountPaid=TextEditingController();
  Widget payoutDialog(dynamic orders){
    int totalAmount=int.parse(orders["grossTotal"].toStringAsFixed(0));

    int balance= 0;
    return Scaffold(
      body: StatefulBuilder(
          builder: (context,innersetState){
            return ListView(
              children: [
                Center(
                  child: Container(
                    width: 500,
                    height: 400,
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
                            child: Center(child: Text(translate("unpaid_today_orders_popup.payout"),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: BackgroundColor),)),

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
                                    Text(translate("unpaid_today_orders_popup.total_amount"),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: yellowColor),),
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
                                  hintText: translate("unpaid_today_orders_popup.amount_paid"),hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
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
                                    Text(translate("unpaid_today_orders_popup.balance"),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: yellowColor),),
                                    Text(balance.toStringAsFixed(0),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: PrimaryColor),),
                                  ],
                                ),
                              ),
                            ),

                          ),
                          InkWell(
                            onTap: (){
                              Navigator.pop(context);
                              if(!formKey.currentState.validate()){

                              }else{
                                var payCash ={
                                  "orderid": orders["id"],
                                  "CashPay": orders["grossTotal"],
                                  "Balance": orders["grossTotal"],
                                  "Comment": null,
                                  "PaymentType": 1,
                                  "OrderStatus": 7,
                                };
                                Network_Operations.payCashOrder(this.context,token, payCash).then((isPaid){
                                  if(isPaid){
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                    Utils.showSuccess(this.context, translate("in_app_errors.payment_successful"));
                                  }else{
                                    Utils.showError(this.context, translate("in_app_errors.problem_in_making_payment"));
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
                                child: Center(child: Text(translate("unpaid_today_orders_popup.payout"),style: TextStyle(color: BackgroundColor, fontWeight: FontWeight.bold, fontSize: 30),)),
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
  TextEditingController assignRider=TextEditingController();
  Widget AssignRiderDialog(dynamic orders){
    return Scaffold(
      body: StatefulBuilder(
          builder: (context,innersetState){
            return ListView(
              children: [
                Center(
                  child: Container(
                    width: 400,
                    height: 350,
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
                            child: Center(child: Text( translate("unpaid_today_orders_popup.assign_rider"),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: BackgroundColor),)),

                          ),
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top:16.0,left:16.0,right:16.0),
                                  child: TextFormField(
                                    controller: assignRider,
                                    textInputAction: TextInputAction.go,
                                    keyboardType: TextInputType.number,
                                    autofocus: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Estimated Time is Required';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: translate("unpaid_today_orders_popup.estimated_time"),hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: DropdownButtonFormField<Vendors>(
                                    decoration: InputDecoration(
                                      labelText: translate("unpaid_today_orders_popup.select_driver"),
                                      alignLabelWithHint: true,
                                      labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                      enabledBorder: OutlineInputBorder(
                                      ),
                                      focusedBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(color:yellowColor),
                                      ),
                                    ),

                                    value: selectedRider,
                                    onChanged: (value) {
                                      innersetState(() {
                                        this.selectedRider=value;
                                      });
                                    },
                                    items: riderList.map((value) {
                                      return  DropdownMenuItem<Vendors>(
                                        value: value,
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              value.user.firstName+" "+value.user.lastName.toString(),
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
                                InkWell(
                                  onTap: (){
                                    if(!formKey.currentState.validate()){

                                    }else{
                                      var orderStatusData={
                                        "Id":orders['id'],
                                        "status":6,
                                        "driverId": selectedRider.user.id,
                                        "EstimatedDeliveryTime":int.parse(assignRider.text),
                                        //  "EstimatedPrepareTime":20,
                                        //  "ActualPrepareTime": 15,
                                        "ActualDriverDepartureTime":DateTime.now().toString().substring(11,16)
                                      };
                                      Navigator.pop(context);
                                      Network_Operations.changeOrderStatus(context, token, orderStatusData).then((value){
                                        if(value){
                                          setState(() {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                          });
                                          Utils.showSuccess(context, translate("error_messages.order_status_changed"));
                                        }else{
                                          Utils.showError(context, translate("error_messages.please_try_again"));
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
                                      child: Center(child: Text(translate("unpaid_today_orders_popup.proceed"),style: TextStyle(color: BackgroundColor, fontWeight: FontWeight.bold, fontSize: 30),)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

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
}

import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:exabistro_pos/Screens/LoadingScreen.dart';
import 'package:exabistro_pos/Screens/Orders/HistoryTabsComponents.dart';
import 'package:exabistro_pos/Screens/OrdersHistoryTab/Components/Screens/KitchenOrdersDetails.dart';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:exabistro_pos/model/ComplaintTypes.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../LoginScreen.dart';
import '../../../POSMainScreenUI1.dart';
import '../PaidTabsComponents.dart';



class PaidOrdersScreenForTab extends StatefulWidget {
  var store;

  PaidOrdersScreenForTab(this.store);

  @override
  _KitchenTabViewState createState() => _KitchenTabViewState();
}

class _KitchenTabViewState extends State<PaidOrdersScreenForTab>{

  String token,discountService,waiveOffService,email;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final formKey= GlobalKey<FormState>();
  // bool isVisible=false;
  List orderList = [];
  List itemsList=[],toppingName =[];
  List topping = [];
  List<dynamic> foodList = [];
  List<Map<String,dynamic>> foodList1 = [];
  bool isListVisible = false,isLoad;
  List allTables=[];
  bool selectedCategory = false;
  List<bool> _selected = [];
  int quantity=5;
  bool isLoading=false;
  List<ComplaintType> types=[];
  List<String> complainTypes=[];
  @override
  void initState() {

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        this.token = prefs.getString("token");
        this.discountService=prefs.getString("discountService");
        this.waiveOffService=prefs.getString("waiveOffService");
        this.email=prefs.getString("email");
      });
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

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
      return "-";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        drawer: widget.store["payOut"]!=null&&widget.store["payOut"]==true?Drawer(
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
                        email.toString(),
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
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>POSMainScreenUI1(store:widget.store)), (route) => false);
                  },
                  title: Text(
                    "Home",
                    style: TextStyle(
                        color: blueColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  trailing: Icon(Icons.dashboard,color: yellowColor,),
                ),
                Divider(color: yellowColor, thickness: 1,),
                ListTile(
                  onTap: (){
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>OrdersHistoryTabsScreen(storeId:widget.store)), (route) => false);
                  },
                  title: Text(
                    "Order History",
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
                    Network_Operations.getAllDailySessionByStoreId(context, token,widget.store["id"]).then((value){
                      if(value!=null&&value.length>0){
                        showDialog(
                            context: context,
                            builder:(context){
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  width: 400,
                                  height: 130,
                                  child: Utils.shiftReportDialog(context,value.last),
                                ),
                              ) ;
                            }
                        );

                      }
                    });
                  },
                  title: Text(
                    "Shift Report",
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
                    "Logout",
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
        ):Container(),
        appBar: widget.store["payOut"]!=null&&widget.store["payOut"]==true&&!isLoading? AppBar(
          title: Text(
            'Today Orders',
            style: TextStyle(
                color: yellowColor,
                fontWeight: FontWeight.bold,
                fontSize: 30),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(
              color: blueColor
          ),
          backgroundColor: BackgroundColor,
        ):null,
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: (){
            return Utils.check_connectivity().then((result){
              if(result){
                setState(() {
                  isLoading=true;
                });
                orderList.clear();
                complainTypes.clear();
                Network_Operations.getComplainTypeListByStoreId(context, token, widget.store["id"]).then((complaintTypes){
                  setState(() {
                    types=complaintTypes;
                    for(int i=0;i<types.length;i++){
                      complainTypes.add(types[i].name);
                    }
                  });
                });
                Network_Operations.getAllOrders(context, token,widget.store["id"]).then((value) {
                  setState(() {
                    isLoading=false;
                    if(value!=null&&value.length>0){
                      //value=value.reversed.toList();
                      print(value.toString());
                      for(var order in value){
                        String createdOn=DateFormat("yyyy-MM-dd").parse(order["createdOn"]).toString().split(" ")[0].trim();
                        String todayDate=DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day).toIso8601String().replaceAll("T00:00:00.000","").trim();

                        if(createdOn.contains(todayDate)&&order["cashPay"]!=null&&order["orderStatus"]!=2){
                          orderList.add(order);
                        }
                      }
                    }
                    //orderList = value;
                  });
                });
                Network_Operations.getTableList(context,token,widget.store["id"])
                    .then((value) {
                  setState(() {
                    this.allTables = value;
                    print(allTables);
                  });
                });
              }else{
                setState(() {
                  isLoading=false;
                });
                Utils.showError(context, "Network Error");
              }
            });

          },

          child: isLoading?LoadingScreen():Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                height: 50,
                                //color: Colors.black38,
                                child: Center(
                                  child: _buildChips(),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Card(
                                      elevation:8,
                                      child: Container(
                                        width: 250,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: yellowColor, width: 2),
                                          //color: yellowColor,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 14, right: 14),
                                          child: Row(
                                            children: [
                                              Text("Total Orders: ",
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
                                        ),
                                        //child:  _buildChips()
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height / 1.45,
                            width: MediaQuery.of(context).size.width,
                            child:GridView.builder(
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 420,
                                    // childAspectRatio: MediaQuery.of(context).size.height<900?3:4,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    mainAxisExtent: 100
                                ),
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
                                                    height: 450,
                                                    width: 750,
                                                    child: ordersDetailPopupLayoutHorizontal(orderList[index])
                                                )
                                            );

                                          });
                                    },
                                    child: Card(
                                        elevation: 8,
                                        child: Container(
                                          height: MediaQuery.of(context).size.height / 4,
                                          width: 350,
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
                                                                  fontSize: 30,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.white
                                                              ),
                                                            ),
                                                            Text(
                                                              //"01",
                                                              orderList[index]['id']!=null?orderList[index]['id'].toString():"",
                                                              style: TextStyle(
                                                                  fontSize: 30,
                                                                  color: blueColor,
                                                                  fontWeight: FontWeight.bold
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            orderList[index]["grossTotal"]==0.0||orderList[index]["netTotal"]==0.0?FaIcon(FontAwesomeIcons.handHoldingUsd, color: blueColor, size:30):FaIcon(FontAwesomeIcons.biking, color: yellowColor,size:30),
                                                            SizedBox(width: 7,),
                                                            orderList[index]["orderType"]==1? FaIcon(FontAwesomeIcons.utensils, color: blueColor, size:30):orderList[index]["orderType"]==2?FaIcon(FontAwesomeIcons.shoppingBag, color: blueColor,size:30):FaIcon(FontAwesomeIcons.biking, color: blueColor,size:30)

                                                          ],
                                                        ),
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
                                                        Text('Total: ',
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
                                                          Text('Table:',
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
                          print(order["cashPay"]!=null);
                          if(createdOn.contains(todayDate)&&order["cashPay"]!=null&&order["orderStatus"]!=2){
                            orderList.add(order);
                          }
                        }
                      }


                    });
                  });
                }else{
                  Utils.showError(context, "Network Error");
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
        //barrierColor: Colors.black45,

        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext,
            Animation animation,
            Animation secondaryAnimation) {
          return Center(
            child: Container(
              width: 450,
              height:350,

              //color: Colors.black54,
              child: DealsDetailsForKitchen(orderId)

            ),
          );
        });


  }
  String getComplaintTypeById(int id){
    String name;
    if(id!=null&&types!=null){
      for(int i=0;i<types.length;i++){
        if(types[i].id == id) {
          name = types[i].name;
        }
      }
      return name!=null?name:"-";
    }else
      return "-";
  }
  String waiterName="-",customerName="-";
  Widget ordersDetailPopupLayoutHorizontal(dynamic orders) {
    debugPrint(orders.toString());
    print("ComplaintTypeId"+orders["complaintTypeId"].toString());
    if(orders["discountedPrice"]!=null&&orders["discountedPrice"]!=0.0){
      if(orders["orderTaxes"].where((element)=>element["taxName"]=="Discount").toList()!=null&&orders["orderTaxes"].where((element)=>element["taxName"]=="Discount").toList().length>0){
        orders["orderTaxes"].remove(orders["orderTaxes"].last);
      }
      orders["orderTaxes"].add({"taxName":"Discount","amount":orders["discountedPrice"]});
    }
    if(orders["orderTaxes"].where((element)=>element["taxName"]=="Refunded Amount").toList()!=null&&orders["orderTaxes"].where((element)=>element["taxName"]=="Refunded Amount").toList().length>0){
      orders["orderTaxes"].remove(orders["orderTaxes"].last);
    }
    var refundedPrice=0.0;
    if(orders["orderItems"]!=null){
      for(int i=0;i<orders["orderItems"].length;i++)
      {
        if(orders["orderItems"][i]["isRefunded"]!=null&&orders["orderItems"][i]["isRefunded"]==true){
          refundedPrice=refundedPrice+=orders["orderItems"][i]["totalPrice"];
        }
      }
    }
    if(refundedPrice!=0.0){
      orders["orderTaxes"].add({"taxName":"Refunded Amount","amount":refundedPrice});
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
                              orders["orderType"]==1? FaIcon(FontAwesomeIcons.utensils, color: blueColor, size:30):orders["orderType"]==2?FaIcon(FontAwesomeIcons.shoppingBag, color: blueColor,size:30):FaIcon(FontAwesomeIcons.biking, color: blueColor,size:30),
                              Row(
                                children: [
                                  Text('Order ID: ',
                                    style: TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  ),
                                  Text(orders['id']!=null?orders['id'].toString():"",
                                    style: TextStyle(
                                        fontSize: 35,
                                        color: blueColor,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                waiveOffService!="null"&&waiveOffService=="true"&&orders["grossTotal"]!=0.0&&orders["netTotal"]!=0.0?Padding(
                                    padding: const EdgeInsets.only(left: 8.0,right:8.0),
                                    child: InkWell(

                                        onTap: (){
                                          Navigator.pop(context);
                                          showDialog(
                                              context: context,
                                              builder:(BuildContext context){
                                                return Dialog(
                                                    backgroundColor: Colors.transparent,
                                                    child: Container(
                                                        height: 500,
                                                        width: 400,
                                                        child: refundOrderItemsPopup(orders["orderItems"].where((element)=>element["isRefunded"]==null||element["isRefunded"]==false).toList(),orders["id"])
                                                    )
                                                );

                                              });
                                        },
                                        child: FaIcon(FontAwesomeIcons.handHoldingUsd, color: blueColor, size: 30,)),
                                  ):Container(),
                                  InkWell(
                                      onTap: (){
                                        //Utils.printReceiptByWifiPrinter("192.168.10.15", this.context, widget.store, orders, getTableName(orders["tableId"]));
                                        Utils.buildInvoice(orders,widget.store,customerName);
                                      },
                                      child: FaIcon(FontAwesomeIcons.print, color: blueColor, size: 30,)),
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
                                              'Total: ',
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
                                              'Status:',
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
                                              'Waiter:',
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
                                              'Customer:',
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
                                                'Table#:',
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
                                Visibility(
                                  visible: orders["refundReason"]!=null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: InkWell(
                                      onTap: (){
                                        showDialog(
                                          context: context,
                                          builder: (cotext){
                                            return AlertDialog(
                                              title: Text("Refund Reason Detail"),
                                              content: Text(orders["refundReason"]!=null?orders["refundReason"]:"N/A"),
                                            );
                                          }
                                        );
                                      },
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
                                                  'Refund Reason',
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
                                                child: Text(orders["complaintTypeId"]!=null?getComplaintTypeById(orders["complaintTypeId"]):"N/A",
                                                  style: TextStyle(
                                                      fontSize: 15,
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
                                                "SubTotal: ",
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
                                                "Total: ",
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
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    FaIcon(FontAwesomeIcons.handHoldingUsd, color: yellowColor,),
                                                    Text(
                                                      orders['orderItems']!=null?orders['orderItems'][i]['name']:"",
                                                      style: TextStyle(
                                                          color: BackgroundColor,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 22
                                                      ),
                                                    ),
                                                orders['orderItems'][i]["isRefunded"]!=null&&orders['orderItems'][i]["isRefunded"]==true?FaIcon(FontAwesomeIcons.handHoldingUsd, color: blueColor,):Container(),
                                                  ],
                                                ),
                                              )
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
                                                          'Unit Price: ',
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
                                                          'Quantity: ',
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
                                                          'Size: ',
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
                                                                'Extras: ',
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
                                                      'Price: ',
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
  TextEditingController refundReason=TextEditingController();
  Widget refundOrderItemsPopup(List<dynamic> orderItems,int orderId){
    List<bool> inputs = new List<bool>();
    refundReason.clear();
    var complaintTypeId=0;
    String selectedComplaintType;
  //  List<String> refundReasonTypes=["Wilted Food","Expired Food","Smelly Food","Food was Delivered Late","Relative","Other Reason"];
    String selectedRefundReason;
    for (int i = 0; i < orderItems.length; i++) {
      inputs.add(false);
    }
    return Scaffold(
      body: StatefulBuilder(
        builder: (context,innerSetstate){

          return ListView(
            children: [
              Container(
              width: 400,
              height: 500,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/bb.jpg'),
                  )
              ),
              child:Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    color: yellowColor,
                    child: Center(child: Text("Refund Items",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: BackgroundColor),)),

                  ),

                  Form(
                      key: formKey,
                      child:Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "Select Reason Type",
                                alignLabelWithHint: true,
                                labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                enabledBorder: OutlineInputBorder(
                                ),
                                focusedBorder:  OutlineInputBorder(
                                  borderSide: BorderSide(color:yellowColor),
                                ),
                              ),

                              value: selectedComplaintType,
                              onChanged: (value) {
                                innerSetstate(() {
                                  complaintTypeId=types.where((element) => element.name==value).toList()[0].id;
                                  selectedComplaintType=value;
                                });
                              },
                              items: complainTypes.map((value) {
                                return  DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        value,
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
                          Visibility(
                            visible: selectedComplaintType!=null,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: refundReason,
                                validator: (value){
                                  if(value==null||value.isEmpty){
                                    return "Please Specify Reason for Refund";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Reason of Refund",hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                          itemCount: orderItems.length,
                          itemBuilder: (context,index){
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
                                    new CheckboxListTile(
                                        value: inputs[index],
                                        title: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            new Text(orderItems[index]["name"]+" "+"(${orderItems[index]["sizeName"]!=null?orderItems[index]["sizeName"]:"Deal"})" ,style: TextStyle(color: yellowColor, fontSize: 17, fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                        controlAffinity: ListTileControlAffinity.leading,
                                        onChanged: (bool val) {
                                          innerSetstate(() {
                                            if(inputs[index]){
                                              inputs[index]=false;
                                            }else {
                                              inputs[index] = true;
                                            }
                                          });
                                        })
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: (){
                        innerSetstate(() {
                          List<String> orderItemsIds=[];
                          // Navigator.pop(context);
                          for(int i=0;i<inputs.length;i++){
                            if(inputs[i]){
                              orderItemsIds.add(orderItems[i]["id"].toString());
                            }
                          }
                          if(orderItemsIds.length>0&&formKey.currentState.validate()&&selectedComplaintType!=null){
                            Network_Operations.refundOrder(context: this.context,token: token, orderItemsId: orderItemsIds, orderId: orderId,refundReason: refundReason.text,ComplaintTypeId: complaintTypeId).then((value){
                              Navigator.pop(this.context);
                              if(value){
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                Utils.showSuccess(this.context,"Refunded Successfully");
                              }else{
                                Utils.showError(this.context,"Unable to Rwfund due to some error");
                              }
                            });
                          }else{
                            Utils.showError(this.context, "Provide Required Information");
                          }

                        });
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
                          child: Center(child: Text("Refund",style: TextStyle(color: BackgroundColor, fontWeight: FontWeight.bold, fontSize: 30),)),
                        ),
                      ),
                    ),
                  ),
                ],
              )

          )
            ],
          ) ;

        },
      ),
    );
  }
}

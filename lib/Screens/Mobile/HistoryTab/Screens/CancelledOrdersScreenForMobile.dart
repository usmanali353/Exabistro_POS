import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:exabistro_pos/Screens/LoadingScreen.dart';
import 'package:exabistro_pos/Screens/LoginScreen.dart';
import 'package:exabistro_pos/Screens/Mobile/OrdersTab/Screens/KitchenOrdersDetails.dart';
import 'package:exabistro_pos/Utils/Utils.dart';

import 'package:exabistro_pos/model/Categories.dart';
import 'package:exabistro_pos/model/OrderById.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';

import '../../../../Utils/constants.dart';


class CancelledOrdersScreenForMobile extends StatefulWidget {
  var store;

  CancelledOrdersScreenForMobile(this.store);

  @override
  _KitchenTabViewState createState() => _KitchenTabViewState();
}

class _KitchenTabViewState extends State<CancelledOrdersScreenForMobile> with TickerProviderStateMixin {

  AnimationController _controller;
  int levelClock = 900;

  String userId="";
  // PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  // List<PrinterBluetooth> printer=[];
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  String token;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  // bool isVisible=false;
  List<Categories> categoryList=[];
  List orderList = [];
  List itemsList=[],toppingName =[];
  List topping = [];
  List<dynamic> foodList = [];
  List<Map<String,dynamic>> foodList1 = [];
  bool isListVisible = true;
  List allTables=[];
  bool selectedCategory = true;
  List<bool> _selected = [];
  // PaperSize paper = PaperSize.mm58;
  // BluetoothManager bluetoothManager = BluetoothManager.instance;
  //List<Categories> allCategories = [];

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    // if (Platform.isAndroid) {
    //   bluetoothManager.state.listen((val) {
    //     print('state = $val');
    //     if (!mounted) return;
    //     if (val == 12) {
    //       print('on');
    //       printerManager.startScan(Duration(seconds: 2));
    //       printerManager.scanResults.listen((printers) {
    //         setState(() {
    //           this.printer=printers;
    //         });
    //       });
    //     } else if (val == 10) {
    //       print('off');
    //     }
    //   });
    // } else {
    //   printerManager.startScan(Duration(seconds: 2));
    //   printerManager.scanResults.listen((printers) {
    //     setState(() {
    //       this.printer=printers;
    //     });
    //   });
    // }


    SharedPreferences.getInstance().then((value) {
      setState(() {
        this.token = value.getString("token");
        this.userId = value.getString("nameid");
      });
    });

    _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: levelClock,) // gameData.levelClock is a user entered number elsewhere in the applciation
    );

    _controller.forward();
    // TODO: implement initState
    super.initState();
  }

  String getTableName(int id){
    String name;
    if(id!=null&&allTables!=null){
      for(int i=0;i<allTables.length;i++){
        if(allTables[i]['id'] == id) {
          //setState(() {
          name = allTables[i]['name'];
          // price = sizes[i].price;
          // });

        }
      }
      return name!=null?name:"-";
    }else
      return "empty";
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // appBar:!isListVisible? AppBar(
      //   automaticallyImplyLeading: true,
      //   actions: [
      //     IconButton(
      //       icon:  FaIcon(FontAwesomeIcons.signOutAlt, color: blueColor, size: 25,),
      //       onPressed: (){
      //         SharedPreferences.getInstance().then((value) {
      //           value.remove("token");
      //           Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>LoginScreen()), (route) => false);
      //         } );
      //       },
      //     ),
      //   ],
      //   title: Text(
      //     'Orders History',
      //
      //     style: TextStyle(
      //         color: yellowColor,
      //         fontWeight: FontWeight.bold,
      //         fontSize: 30),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: BackgroundColor,
      // ):null,
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: (){
            return Utils.check_connectivity().then((result){
              if(result){
                print("Height "+MediaQuery.of(context).size.height.toString());
                print("Width "+MediaQuery.of(context).size.width.toString());
                orderList.clear();
                Network_Operations.getAllOrdersWithItemsByOrderStatusId(context, token, 2,widget.store["id"]).then((value) {
                  setState(() {
                    orderList = value;
                    print("Orderlist "+orderList.toString());
                    print("OrderTaxes"+orderList[0]["orderTaxes"].toString());
                  });
                });
                Network_Operations.getTableList(context,token,widget.store["id"])
                    .then((value) {
                  setState(() {
                    isListVisible=false;
                    this.allTables = value;
                  });
                });
              }else{
                setState(() {
                  isListVisible=false;
                });
                Utils.showError(context, translate("error_messages.not_connected_to_internet"));
              }
            });
          },

          child:Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/bb.jpg'),
                  )
              ),
              child: new Container(
                  child: Column(
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
                              Text(translate("cancelled_orders_history.total_orders"),
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
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                              height: MediaQuery.of(context).size.height-80,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  itemCount: orderList!=null?orderList.length:0,
                                  itemBuilder: (context, index){
                                    return InkWell(
                                      onTap: () {
                                        showDialog(
                                          //barrierDismissible: false,
                                            context: context,
                                            builder:(BuildContext context){
                                              return Dialog(
                                                //backgroundColor: Colors.transparent,
                                                  child: Container(
                                                      height:800,
                                                      width: 600,
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: AssetImage('assets/bb.jpg'),
                                                          )
                                                      ),
                                                      child: orderDetailPopup(orderList[index])
                                                    //ordersDetailPopupLayout(orderList[index])
                                                  )
                                              );

                                            });
                                      },
                                      child: Card(
                                          elevation: 8,
                                          child: Container(
                                            height: 100,
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
                                                          Text(translate("cancelled_orders_history.total"),
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
                                                            Text(translate("cancelled_orders_history.table"),
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
                                  })
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
  String getOrderItemStatus(int id){
    String itemStatus;
    if(id!=null){
      if(id ==0){
        itemStatus = "Pending";
      }else if(id ==1){
        itemStatus = "Preparing";
      }else if(id ==2){
        itemStatus = "Ready";
      }
      return itemStatus;
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
                          if(order["orderStatus"]==2&&order["tableId"]!=null&&order["tableId"]==allTables[i]["id"]){
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
                              orders["orderType"]==1? FaIcon(FontAwesomeIcons.utensils, color: blueColor, size:30):orders["orderType"]==2?FaIcon(FontAwesomeIcons.shoppingBag, color: blueColor,size:30):FaIcon(FontAwesomeIcons.biking, color: blueColor,size:30),
                              Row(
                                children: [
                                  Text('Order ID: ',
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
                                  SizedBox(width: 15,),
                                  InkWell(
                                      onTap: (){
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
                    SizedBox(
                      height: 3,
                    ),
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
                                          translate("cancelled_orders_history_popup.items"),
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
                                          translate("cancelled_orders_history_popup.total"),
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
                                          translate("cancelled_orders_history_popup.status"),
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
                                          translate("cancelled_orders_history_popup.waiter"),
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
                                          translate("cancelled_orders_history_popup.customer"),
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
                                            translate("cancelled_orders_history_popup.table_number"),
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
                        //height: 300,
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
                                          child:
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  orders['orderItems']!=null?orders['orderItems'][i]['name']:"",
                                                  style: TextStyle(
                                                      color: BackgroundColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16
                                                  ),
                                                ),
                                                orders['orderItems'][i]["isRefunded"]!=null&&orders['orderItems'][i]["isRefunded"]==true?FaIcon(FontAwesomeIcons.handHoldingUsd, color: blueColor,):Container(),
                                              ],

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
                                                      translate("cancelled_orders_history_popup.unit_price"),
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
                                                      translate("cancelled_orders_history_popup.quantity"),
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
                                                      translate("cancelled_orders_history_popup.size"),
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
                                                            translate("cancelled_orders_history_popup.extras"),
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
                                                  translate("cancelled_orders_history_popup.price"),
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
                              translate("cancelled_orders_history_popup.sub_total"),
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
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          //height: 80,
                          decoration: BoxDecoration(
                              border: Border.all(color: yellowColor)
                          ),
                          //color: yellowColor,
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
                              translate("cancelled_orders_history_popup.total"),
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
                                  SizedBox(width: 15,),
                                  InkWell(
                                      onTap: (){
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
                                              translate("cancelled_orders_history_popup.items"),
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
                                              translate("cancelled_orders_history_popup.total"),
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
                                              translate("cancelled_orders_history_popup.status"),
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
                                              translate("cancelled_orders_history_popup.waiter"),
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
                                              translate("cancelled_orders_history_popup.customer"),
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
                                                translate("cancelled_orders_history_popup.table_number"),
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
                                                translate("cancelled_orders_history_popup.sub_total"),
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
                                                translate("cancelled_orders_history_popup.total"),
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
                                                          translate("cancelled_orders_history_popup.unit_price"),
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
                                                          translate("cancelled_orders_history_popup.quantity"),
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
                                                          translate("cancelled_orders_history_popup.size"),
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
                                                                translate("cancelled_orders_history_popup.extras"),
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
                                                      translate("cancelled_orders_history_popup.price"),
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
}


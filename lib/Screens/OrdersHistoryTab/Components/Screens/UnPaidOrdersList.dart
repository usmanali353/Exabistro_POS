import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:exabistro_pos/model/OrderById.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'KitchenOrdersDetails.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';


class UnPaidOrdersScreenForTab extends StatefulWidget {
  var store;

  UnPaidOrdersScreenForTab(this.store);

  @override
  _KitchenTabViewState createState() => _KitchenTabViewState();
}

class _KitchenTabViewState extends State<UnPaidOrdersScreenForTab>{

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


  

  @override
  void initState() {

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    SharedPreferences.getInstance().then((value) {
      setState(() {
        this.token = value.getString("token");
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
                orderList.clear();
                Network_Operations.getAllOrders(context, token,widget.store["id"]).then((value) {
                  setState(() {
                    if(value!=null&&value.length>0){
                      //value=value.reversed.toList();
                      for(var order in value){
                        String createdOn=DateFormat("yyyy-MM-dd").parse(order["createdOn"]).toString().split(" ")[0].trim();
                        String todayDate=DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day).toIso8601String().replaceAll("T00:00:00.000","").trim();
                        if(createdOn.contains(todayDate)&&order["cashPay"]==null&&order["orderStatus"]!=2){
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
                Utils.showError(context, "Network Error");
              }
            });
          },

          child: Container(
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
                                    // childAspectRatio: 4 ,
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
                                                              widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":" ",
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: PrimaryColor
                                                              ),
                                                            ),
                                                            Text(
                                                              //"Dine-In",
                                                              orderList[index]['grossTotal'].toStringAsFixed(1),
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
                                                          Text('Table: ',
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
  Widget ordersDetailPopupLayout(dynamic orders) {
     print( orders["visitingCustomer"].toString());
    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.1),
        body: StatefulBuilder(

          builder: (context,innerSetstate){
            if(orders!=null&&orders["visitingCustomer"]==null&&orders["customerId"]!=null) {
              Network_Operations.getCustomerById(
                  context, token, orders["customerId"]).then((customerInfo) {

                        innerSetstate(() {
                          customerName=customerInfo["firstName"];
                        });


              });
            }
            if(orders!=null&&orders["employeeId"]!=null){
              Network_Operations.getCustomerById(
                  context, token, orders["employeeId"]).then((waiterInfo) {

                      innerSetstate(() {
                        waiterName=waiterInfo["firstName"];
                      });

              });
            }
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height:700,
                      width: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        //border: Border.all(color: yellowColor, width: 2),
                        color: BackgroundColor,
                      ),
                      //color: Colors.black38,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 175,
                              //color: Colors.white12,
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
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                                              Text(orders['id']!=null?orders['id'].toString():"",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: yellowColor,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2),
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
                                                  widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":" ",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: PrimaryColor
                                                  ),
                                                ),
                                                Text(
                                                  //"Dine-In",
                                                  orders['grossTotal'].toStringAsFixed(1),
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
                                        Row(
                                          children: [
                                            Text("Status: ", style: TextStyle(
                                                fontSize: 20,
                                                color: yellowColor,
                                                fontWeight: FontWeight.bold
                                            ),
                                            ),
                                            Text( getStatus(orders!=null?orders['orderStatus']:null),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: PrimaryColor,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ],
                                        ),



                                        // Row(
                                        //   children: [
                                        //     Text('Priority: ',
                                        //       style: TextStyle(
                                        //           fontSize: 20,
                                        //           fontWeight: FontWeight.bold,
                                        //           color: yellowColor
                                        //       ),
                                        //     ),
                                        //     Text(getOrderPriority(orders['orderPriorityId']),
                                        //       //orderList[index]['orderItems'].length.toString(),
                                        //       style: TextStyle(
                                        //           fontSize: 20,
                                        //           fontWeight: FontWeight.bold,
                                        //           color: PrimaryColor
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 2, left: 5, right: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Type: ',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: yellowColor
                                              ),
                                            ),
                                            Text(getOrderType(orders['orderType']),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: PrimaryColor
                                              ),
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                          visible: orders['orderType']==1,
                                          child: Row(
                                            children: [
                                              Text('Table#: ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: yellowColor
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left: 2.5),
                                              ),
                                              Text(orders['tableId']!=null?getTableName(orders['tableId']).toString():" - ",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: PrimaryColor
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Row(
                                        //   children: [
                                        //     Padding(
                                        //       padding: const EdgeInsets.only(right: 5),
                                        //       child: FaIcon(FontAwesomeIcons.calendarAlt, color: yellowColor, size: 20,),
                                        //     ),
                                        //     Text(orders['createdOn'].toString().replaceAll("T", " || ").substring(0,19), style: TextStyle(
                                        //         fontSize: 20,
                                        //         color: PrimaryColor,
                                        //         fontWeight: FontWeight.bold
                                        //     ),
                                        //     ),
                                        //   ],
                                        // )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8, bottom: 2, left: 5, right: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Waiter: ',
                                              style: TextStyle(
                                                color: yellowColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                //fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            Text(
                                              waiterName,
                                              //userDetail!=null?userDetail['firstName'].toString():"",
                                              style:TextStyle(
                                                color: blueColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                //fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Items: ',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: yellowColor
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 2.5),
                                            ),
                                            Text(orders['orderItems'].length.toString(),
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
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5, top: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Customer: ',
                                              style: TextStyle(
                                                color: yellowColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                //fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            Text(
                                              orders["visitingCustomer"]!=null?orders["visitingCustomer"]:customerName,
                                              //userDetail!=null?userDetail['firstName'].toString():"",
                                              style:TextStyle(
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
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 1,
                            color: yellowColor,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                //color: Colors.transparent,
                                child: ListView.builder(
                                    padding: EdgeInsets.all(4),
                                    scrollDirection: Axis.vertical,
                                    itemCount:orders == null ? 0:orders['orderItems'].length,
                                    itemBuilder: (context,int i){
                                      topping=[];

                                      for(var items in orders['orderItems'][i]['orderItemsToppings']){
                                        topping.add(items==[]?"-":items['additionalItem']['stockItemName']+" x${items['quantity'].toString()} \n");
                                      }
                                      return InkWell(
                                        onTap: () {
                                          if(orders['orderItems'][i]['isDeal'] == true){
                                            showAlertDialog(context,orders['id']);
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Card(
                                            elevation: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: BackgroundColor,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: yellowColor, width: 2),
                                                // boxShadow: [
                                                //   BoxShadow(
                                                //     color: Colors.grey.withOpacity(0.5),
                                                //     spreadRadius: 5,
                                                //     blurRadius: 5,
                                                //     offset: Offset(0, 3), // changes position of shadow
                                                //   ),
                                                // ],
                                              ),
                                              width: MediaQuery.of(context).size.width,
                                              child: Padding(
                                                padding: const EdgeInsets.all(6.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            Text(orders['orderItems']!=null?orders['orderItems'][i]['name']:"", style: TextStyle(
                                                                color: yellowColor,
                                                                fontSize: 22,
                                                                fontWeight: FontWeight.bold
                                                            ),
                                                            ),
                                                            //SizedBox(width: 195,),
                                                            // Text("-"+foodList1[index]['sizeName'].toString()!=null?foodList1[index]['sizeName'].toString():"empty", style: TextStyle(
                                                            //     color: yellowColor,
                                                            //     fontSize: 20,
                                                            //     fontWeight: FontWeight.bold
                                                            // ),)
                                                          ],
                                                        ),

                                                      ],
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 15),
                                                          child: Row(
                                                            children: [
                                                              Text("Size: ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: yellowColor,),),
                                                              Text(orders['orderItems'][i]['sizeName']!=null?orders['orderItems'][i]['sizeName'].toString():"-",
                                                                //"-"+foodList1[index]['sizeName'].toString()!=null?foodList1[index]['sizeName'].toString():"empty",
                                                                style: TextStyle(
                                                                    color: PrimaryColor,
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.bold
                                                                ),),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(right: 15),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: [
                                                              Text("Qty: ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: yellowColor,),),
                                                              //SizedBox(width: 10,),
                                                              Text(orders['orderItems'][i]['quantity'].toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: PrimaryColor,),),

                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 35),
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 15),
                                                          child: Text(
                                                            "Additional Toppings",
                                                            style: TextStyle(
                                                                color: yellowColor,
                                                                fontSize: 17,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 35),
                                                      child: Text(
                                                        topping != null
                                                            ? topping
                                                            .toString()
                                                            .replaceAll("[", "- ")
                                                            .replaceAll(",", "- ")
                                                            .replaceAll("]", "")
                                                            :"-",
                                                        style: TextStyle(
                                                            color: PrimaryColor,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500
                                                        ),
                                                      ),
                                                    ),
                                                    // Padding(
                                                    //   padding: const EdgeInsets.only(left: 15),
                                                    //   child: Text("Additional Toppings", style: TextStyle(
                                                    //       color: PrimaryColor,
                                                    //       fontSize: 20,
                                                    //       fontWeight: FontWeight.bold
                                                    //   ),
                                                    //   ),
                                                    // ),
                                                    // Padding(
                                                    //   padding: const EdgeInsets.only(left: 35),
                                                    //   child: Text(topping.toString().replaceAll("[", "-").replaceAll(",", "").replaceAll("]", "")
                                                    //     //       (){
                                                    //     //   topping.clear();
                                                    //     //   topping = (orderList[index]['orderItems'][i]['orderItemsToppings']);
                                                    //     //   print(topping.toString());
                                                    //     //
                                                    //     //   if(topping.length == 0){
                                                    //     //     return "-";
                                                    //     //   }
                                                    //     //   for(int i=0;i<topping.length;i++) {
                                                    //     //     if(topping[i].length==0){
                                                    //     //       return "-";
                                                    //     //     }else{
                                                    //     //       return (topping==[]?"-":topping[i]['name'] + "   x" +
                                                    //     //           topping[i]['quantity'].toString() + "   -\$ "+topping[i]['price'].toString() + "\n");
                                                    //     //     }
                                                    //     //
                                                    //     //   }
                                                    //     //   return "";
                                                    //     // }()
                                                    //     // toppingName!=null?toppingName.toString().replaceAll("[", "- ").replaceAll(",", "- ").replaceAll("]", ""):""
                                                    //     , style: TextStyle(
                                                    //         color: yellowColor,
                                                    //         fontSize: 16,
                                                    //         fontWeight: FontWeight.bold
                                                    //       //fontWeight: FontWeight.bold
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width,
                                                      height: 1,
                                                      color: yellowColor,
                                                    ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Price: ',
                                                          style: TextStyle(
                                                            color: yellowColor,
                                                            fontSize: 25,
                                                            fontWeight: FontWeight.w800,
                                                            //fontStyle: FontStyle.italic,
                                                          ),
                                                        ),
                                                        Text(
                                                          //"Dine-In",
                                                          widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":" ",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: PrimaryColor
                                                          ),
                                                        ),
                                                        Text(
                                                          orders['orderItems'][i]['totalPrice']!=null?orders['orderItems'][i]['totalPrice'].toStringAsFixed(1):"-",
                                                          style: TextStyle(
                                                            color: blueColor,
                                                            fontSize: 25,
                                                            fontWeight: FontWeight.w500,
                                                            //fontStyle: FontStyle.italic,
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                  ],
                                                ),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width,
                                                      height: 1,
                                                      color: yellowColor,
                                                    ),
                                              ]),
                                            ),
                                          ),
                                        ),
                                      ));
                                    }),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 1,
                            color: yellowColor,
                          ),

                          Container(
                            // width: MediaQuery.of(context).size.width,
                            // height: MediaQuery.of(context).size.height /8,
                            // color: Colors.white12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                orders["orderStatus"]>=5?InkWell(
                                  onTap: (){
                                    var payCash ={
                                      "orderid": orders["id"],
                                      "CashPay": orders["grossTotal"],
                                      "Balance": orders["grossTotal"],
                                      "Comment": null,
                                      "PaymentType": 1,
                                      "OrderStatus": 7,
                                    };
                                    Network_Operations.payCashOrder(this.context,token, payCash).then((isPaid){
                                      Navigator.pop(context);
                                      if(isPaid){
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                        Utils.showSuccess(this.context,"Payment Successful");
                                      }else{
                                        Utils.showError(this.context,"Problem in Making Payment");
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: yellowColor),
                                        borderRadius: BorderRadius.all(Radius.circular(10)) ,
                                        color: yellowColor,
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,

                                      child: Center(
                                        child: Text('Mark as Paid',style: TextStyle(color: BackgroundColor,fontSize: 25,fontWeight: FontWeight.bold),),
                                      ),
                                    ),
                                  ),
                                ):Container(),
                                InkWell(
                                  onTap: ()async{
                                    print(orders.toString());
                                    // await Utils.printRecieptByWifiPrinter("192.168.10.17", this.context,widget.store,orders,getTableName(orders["tableId"]));
                                     await Utils.printReceiptKitchenByWifiPrinter("192.168.10.17", this.context,widget.store,orders,getTableName(orders["tableId"]));
                                    //buildInvoice(orders);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: yellowColor),
                                        borderRadius: BorderRadius.all(Radius.circular(10)) ,
                                        color: yellowColor,
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,

                                      child: Center(
                                        child: Text('Print',style: TextStyle(color: BackgroundColor,fontSize: 25,fontWeight: FontWeight.bold),),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ))
            );
          },
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
                                    orders["orderStatus"]==1?InkWell(
                                      child: FaIcon(FontAwesomeIcons.solidTimesCircle, color: blueColor, size: 30,),
                                      onTap: (){
                                        Network_Operations.cancelOrder(context, token, orders['id'], 2).then((value){
                                          if(value){
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                            Navigator.pop(context);
                                            Utils.showSuccess(context, "Order has been Canceled");
                                          }else{
                                            Utils.showError(context, "Please Try Again");
                                          }
                                        });
                                      },
                                    ):Container(),
                                    orders["orderStatus"]>=5?InkWell(
                                        onTap: (){
                                          var payCash ={
                                            "orderid": orders["id"],
                                            "CashPay": orders["grossTotal"],
                                            "Balance": orders["grossTotal"],
                                            "Comment": null,
                                            "PaymentType": 1,
                                            "OrderStatus": 7,
                                          };
                                          Network_Operations.payCashOrder(this.context,token, payCash).then((isPaid){
                                            Navigator.pop(context);
                                            if(isPaid){
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                              Navigator.pop(context);
                                              Utils.showSuccess(this.context,"Payment Successful");
                                            }else{
                                              Navigator.pop(context);
                                              Utils.showError(this.context,"Problem in Making Payment");
                                            }
                                          });
                                        },
                                        child: FaIcon(FontAwesomeIcons.cashRegister, color: blueColor, size: 30,)):Container(),
                                    SizedBox(width: 15,),
                                    InkWell(
                                        onTap: (){
                                          buildInvoice(orders);
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
                                              'Items:',
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
                                                widget.store["currencyCode"]!=null?widget.store["currencyCode"]+": ":" ",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: blueColor
                                                ),
                                              ),
                                              Text(
                                                //"Dine-In",
                                                orders["discountedPrice"]!=null&&orders["discountedPrice"]!=0.0?(orders["grossTotal"]-orders["discountedPrice"]).toStringAsFixed(1):orders["grossTotal"].toStringAsFixed(1),
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
                                          //     widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":" ",
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
                                //           widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":" ",
                                //           style: TextStyle(
                                //               fontSize: 20,
                                //               fontWeight: FontWeight.bold,
                                //               color: PrimaryColor
                                //           ),
                                //         ),
                                //         Text(
                                //           //"Dine-In",
                                //           orders['grossTotal'].toStringAsFixed(1),
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
                                                    widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":" ",
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
                                                    orders["netTotal"].toStringAsFixed(1),
                                                    //overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(1)+"/-":"0.0/-",
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
                                                            //orders["orderTaxes"][index].percentage!=null&&orders["orderTaxes"][index].percentage!=0.0?orders["orderTaxes"][index]["taxName"]+" (${typeBasedTaxes[index].percentage.toStringAsFixed(1)})":typeBasedTaxes[index].name,
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
                                                                widget.store["currencyCode"]+" "+
                                                                    orders["orderTaxes"][index]["amount"].toStringAsFixed(1),
                                                                //typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0?widget.store["currencyCode"]+" "+typeBasedTaxes[index].price.toStringAsFixed(1):typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1?widget.store["currencyCode"]+": "+(overallTotalPriceWithTax/100*typeBasedTaxes[index].percentage).toStringAsFixed(1):widget.store["currencyCode"]+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(1),
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
                                                    widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":"",
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
                                                    orders["discountedPrice"]!=null&&orders["discountedPrice"]!=0.0?(orders["grossTotal"]-orders["discountedPrice"]).toStringAsFixed(1):orders["grossTotal"].toStringAsFixed(1),
                                                    //priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(1)+"/-":overallTotalPriceWithTax.toStringAsFixed(1)+"/-",
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
                                    topping.add(items==[]?"-":items['additionalItem']['stockItemName']+" (${widget.store["currencyCode"]+items["price"].toStringAsFixed(1)})   x${items['quantity'].toString()+"    "+widget.store["currencyCode"]+": "+items["totalPrice"].toStringAsFixed(1)} \n");
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
                                                          orders["orderItems"][i]["price"].toStringAsFixed(1),
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
                                                          widget.store["currencyCode"]!=null?widget.store["currencyCode"]+": ":" ",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: PrimaryColor
                                                          ),
                                                        ),
                                                        Text(
                                                          orders['orderItems'][i]['totalPrice']!=null?orders['orderItems'][i]['totalPrice'].toStringAsFixed(1):"-",
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

  buildInvoice(dynamic order)async{
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
    List<OrderItem> orderitems=OrderItem.listOrderitemFromJson(jsonEncode(order["orderItems"]));
    var invoiceData=orderitems.map((cartItems){
      return [
        cartItems.name.toString(),
        cartItems.price.toStringAsFixed(1),
        "x "+cartItems.quantity.toString(),
        cartItems.totalPrice.toStringAsFixed(1),
      ];
    }).toList();
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      // pageFormat: PdfPageFormat.a4,
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
                            pw.Text(widget.store["name"].toString(),style: pw.TextStyle(fontSize:20,fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 1 * PdfPageFormat.mm),
                            pw.Text(widget.store["address"].toString()),
                          ]
                      ),
                      pw.Container(
                          width: 50,
                          height:50,
                          child: pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: "http://dev.exabistro.com/#/storeMenu/${widget.store["id"]}"
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
                      pw.Text(widget.store["address"].toString())
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
                      pw.Text(widget.store["cellNo"].toString())
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
                      pw.Table.fromTextArray(
                          headers: ["Name","Unit Price","Quantity","Total"],
                          data:invoiceData,
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
                                                    order["netTotal"].toStringAsFixed(1),
                                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                                )
                                              ]
                                          )
                                      ),
                                      pw.Container(
                                          width: double.infinity,
                                          child: pw.Row(
                                              children: [
                                                pw.Expanded(
                                                    child: pw.Text("Tax",style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                                ),
                                                pw.Text(
                                                    (order["grossTotal"]-order["netTotal"]).toStringAsFixed(1),
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
                                                    order["grossTotal"].toStringAsFixed(1),
                                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                                )
                                              ]
                                          )
                                      ),
                                      order["discountedPrice"]!=null&&order["discountedPrice"]!=0.0?pw.Container(
                                          width: double.infinity,
                                          child: pw.Row(
                                              children: [
                                                pw.Expanded(
                                                    child: pw.Text("Discount",style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                                ),
                                                pw.Text(
                                                    order["discountedPrice"].toStringAsFixed(1),
                                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                                )
                                              ]
                                          )
                                      ):pw.Container(),
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
                                      order["discountedPrice"]!=null&&order["discountedPrice"]!=0.0?pw.Container(
                                          width: double.infinity,
                                          child: pw.Row(
                                              children: [
                                                pw.Expanded(
                                                    child: pw.Text("Total",style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                                ),
                                                pw.Text(
                                                    (order["grossTotal"]-order["discountedPrice"]).toStringAsFixed(1),
                                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                                )
                                              ]
                                          )
                                      ):pw.Container(),
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

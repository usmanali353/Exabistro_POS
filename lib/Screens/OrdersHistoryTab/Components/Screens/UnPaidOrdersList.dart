import 'dart:ui';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UnPaidOrdersScreenForTab extends StatefulWidget {
  var storeId;

  UnPaidOrdersScreenForTab(this.storeId);

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
      return name;
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
                Network_Operations.getAllOrders(context, token,widget.storeId).then((value) {
                  setState(() {
                    if(value!=null&&value.length>0){
                      value=value.reversed.toList();
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
                Network_Operations.getTableList(context,token,widget.storeId)
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

          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
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
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              //color: Colors.black38,
                              child: Center(
                                child: _buildChips(),
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Card(
                                    elevation:8,
                                    child: Container(
                                      width: 230,
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height / 1.45,
                              width: MediaQuery.of(context).size.width,
                              child:GridView.builder(
                                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 420,
                                      childAspectRatio: 4 ,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10
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
                                                      height: MediaQuery.of(context).size.height / 1.35,
                                                      width: MediaQuery.of(context).size.width / 3.2,
                                                      child: ordersDetailPopupLayout(orderList[index])
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
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text('Order ID: ',
                                                              style: TextStyle(
                                                                  fontSize: 35,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.white
                                                              ),
                                                            ),
                                                            Text(
                                                              //"01",
                                                              orderList[index]['id']!=null?orderList[index]['id'].toString():"",
                                                              style: TextStyle(
                                                                  fontSize: 35,
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
                                                SizedBox(height: 5,),
                                                Padding(
                                                  padding: const EdgeInsets.all(4),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text('Order Type: ',
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
                                                            //"Dine-In",
                                                            getOrderType(orderList[index]['orderType']),
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.bold,
                                                                color: PrimaryColor
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Visibility(
                                                        visible: orderList[index]['orderType']==1,
                                                        child: Row(
                                                          children: [
                                                            Text('Table No#: ',
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
                          )

                        ],
                      )

                  )
              ),
            ],
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
            _selected[i] = selected;
            if(_selected[i]){
              Utils.check_connectivity().then((result){
                if(result){
                  orderList.clear();
                  Network_Operations.getOrdersByTableId(context, token,allTables[i]["id"],widget.storeId).then((value) {
                    setState(() {
                      if(value!=null&&value.length>0){
                        for(var order in value){
                          String createdOn=DateFormat("yyyy-MM-dd").parse(order["createdOn"]).toString().split(" ")[0].trim();
                          String todayDate=DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day).toIso8601String().replaceAll("T00:00:00.000","").trim();
                          print(order["cashPay"]==null);
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
        barrierColor: Colors.black45,

        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext,
            Animation animation,
            Animation secondaryAnimation) {
          return Center(
            child: Container(
              width: 350,
              height:300,
              padding: EdgeInsets.all(20),
              color: Colors.black54,
              //child: DealsDetailsForKitchen(orderId)

            ),
          );
        });


  }

  Widget ordersDetailPopupLayout(dynamic orders) {
    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.1),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height:MediaQuery.of(context).size.height -250,
                  width: MediaQuery.of(context).size.width / 3,
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
                          height: MediaQuery.of(context).size.height / 5,
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
                                          "Rasheed Ahmed Tarar",
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
                                          "Rasheed Ahmed Tarar",
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
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          height: 310,
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
                                      print(orders['id']);
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
                                              Padding(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Text("Additional Toppings", style: TextStyle(
                                                    color: PrimaryColor,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold
                                                ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 35),
                                                child: Text(topping.toString().replaceAll("[", "-").replaceAll(",", "").replaceAll("]", "")
                                                  //       (){
                                                  //   topping.clear();
                                                  //   topping = (orderList[index]['orderItems'][i]['orderItemsToppings']);
                                                  //   print(topping.toString());
                                                  //
                                                  //   if(topping.length == 0){
                                                  //     return "-";
                                                  //   }
                                                  //   for(int i=0;i<topping.length;i++) {
                                                  //     if(topping[i].length==0){
                                                  //       return "-";
                                                  //     }else{
                                                  //       return (topping==[]?"-":topping[i]['name'] + "   x" +
                                                  //           topping[i]['quantity'].toString() + "   -\$ "+topping[i]['price'].toString() + "\n");
                                                  //     }
                                                  //
                                                  //   }
                                                  //   return "";
                                                  // }()
                                                  // toppingName!=null?toppingName.toString().replaceAll("[", "- ").replaceAll(",", "- ").replaceAll("]", ""):""
                                                  , style: TextStyle(
                                                      color: yellowColor,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold
                                                    //fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
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
                          children: [
                            InkWell(
                              onTap: (){
                                //  _showDialog(orderList[index]['id']);
                                var orderStatusData={
                                  "Id":orders['id'],
                                  "status":4,
                                  "EstimatedPrepareTime":10,
                                };
                                print(orderStatusData);
                                Network_Operations.changeOrderStatus(context, token, orderStatusData).then((res) {
                                  if(res){
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                  }
                                  //print(value);
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
                                  height: 40,

                                  child: Center(
                                    child: Text('Mark as Paid',style: TextStyle(color: BackgroundColor,fontSize: 25,fontWeight: FontWeight.bold),),
                                  ),
                                ),
                              ),
                            ),

                            InkWell(
                              onTap: (){
                                // Utils.urlToFile(context,_store.image).then((value){
                                //   Navigator.push(context, MaterialPageRoute(builder: (context)=>PDFLaout(orderList[index]['id'],orderList[index]['orderItems'],orderList[index]['orderType'],orderList[index]['storeName'],value.readAsBytesSync())));
                                // });
                                //Navigator.push(context, MaterialPageRoute(builder: (context)=>PDFLaout(orderList[index]['id'],orderList[index]['orderItems'],orderList[index]['orderType'],orderList[index]['storeName'])));
                                //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SplashScreen()), (route) => false);
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
                                  height: 40,

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
        )
    );
  }



}

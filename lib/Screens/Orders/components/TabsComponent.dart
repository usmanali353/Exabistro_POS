import 'package:exabistro_pos/Screens/Orders/PreparingOrdersForKitchen(Tab).dart';
import 'package:exabistro_pos/Screens/Orders/ReadyOrdersForTablet.dart';
import 'package:exabistro_pos/Screens/LoginScreen.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ReceivedOrdersForKitchen(Tab).dart';


class AdminTabletTabsScreen extends StatefulWidget {
  var storeId,roleId,restaurantId;

  AdminTabletTabsScreen({this.storeId, this.roleId, this.restaurantId});

  @override
  State<StatefulWidget> createState() {
    return new KitchenWidgetState();
  }
}

class KitchenWidgetState extends State<AdminTabletTabsScreen> with SingleTickerProviderStateMixin{
  var totalItems;
  String token;
  var recievedOrders, preparingOrders , readyOrders ;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        this.token = value.getString("token");
      });
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            actions: [
              IconButton(
                icon:  FaIcon(FontAwesomeIcons.signOutAlt, color: PrimaryColor, size: 25,),
                onPressed: (){
                  SharedPreferences.getInstance().then((value) {
                    value.remove("token");
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
                  } );
                },
              ),
            ],
            backgroundColor: BackgroundColor,
            title: Text("Dashboard", style: TextStyle(
                color: yellowColor, fontSize: 25, fontWeight: FontWeight.bold
            ),
            ),
            elevation: 6,
            bottom: TabBar(
               isScrollable: true,
                unselectedLabelColor: yellowColor,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: ShapeDecoration(
                    color: yellowColor,
                    shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: yellowColor,
                        )
                    )
                ),
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Received Orders",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold
                                //color: Color(0xff172a3a)
                              ),
                            ),
                            // Badge(
                            //   showBadge: true,
                            //   borderRadius: 10,
                            //   badgeContent: Center(child: Text(recievedOrders!=null?recievedOrders.toString():"0"
                            //     ,style: TextStyle(color: BackgroundColor,fontWeight: FontWeight.bold),)),
                            //   child: InkWell(
                            //     onTap: () {
                            //       //Navigator.push(context, MaterialPageRoute(builder: (context) => MyCartScreen(ishome: false,),));
                            //     },
                            //     child: Padding(
                            //       padding: const EdgeInsets.all(8.0),
                            //       child: Icon(Icons.fastfood, color: PrimaryColor, size: 20,),
                            //     ),
                            //   ),
                            // ),
                          ],),
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Preparing",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                              //color: Color(0xff172a3a)
                            ),
                          ),
                          // Badge(
                          //   showBadge: true,
                          //   borderRadius: 10,
                          //   badgeContent: Center(child: Text(preparingOrders!=null?preparingOrders.toString():"0"
                          //     ,style: TextStyle(color: BackgroundColor,fontWeight: FontWeight.bold),)),
                          //   child: InkWell(
                          //     onTap: () {
                          //       //Navigator.push(context, MaterialPageRoute(builder: (context) => MyCartScreen(ishome: false,),));
                          //     },
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Icon(Icons.access_time, color: PrimaryColor, size: 20,),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Ready",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                              //color: Color(0xff172a3a)
                            ),
                          ),
                          // Badge(
                          //   showBadge: true,
                          //   borderRadius: 10,
                          //   badgeContent: Center(child: Text(readyOrders!=null?readyOrders.toString():"0"
                          //     ,style: TextStyle(color: BackgroundColor,fontWeight: FontWeight.bold),)),
                          //   child: InkWell(
                          //     onTap: () {
                          //       //Navigator.push(context, MaterialPageRoute(builder: (context) => MyCartScreen(ishome: false,),));
                          //     },
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Icon(Icons.done_all, color: PrimaryColor, size: 20,),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  // Tab(
                  //   child: Align(
                  //     alignment: Alignment.center,
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Text("Dashboard",
                  //           style: TextStyle(
                  //               fontSize: 17,
                  //               fontWeight: FontWeight.bold
                  //             //color: Color(0xff172a3a)
                  //           ),
                  //         ),
                  //         // Badge(
                  //         //   showBadge: true,
                  //         //   borderRadius: 10,
                  //         //   badgeContent: Center(child: Text(readyOrders!=null?readyOrders.toString():"0"
                  //         //     ,style: TextStyle(color: BackgroundColor,fontWeight: FontWeight.bold),)),
                  //         //   child: InkWell(
                  //         //     onTap: () {
                  //         //       //Navigator.push(context, MaterialPageRoute(builder: (context) => MyCartScreen(ishome: false,),));
                  //         //     },
                  //         //     child: Padding(
                  //         //       padding: const EdgeInsets.all(8.0),
                  //         //       child: Icon(Icons.done_all, color: PrimaryColor, size: 20,),
                  //         //     ),
                  //         //   ),
                  //         // ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ]),
          ),
          body: TabBarView(children: [
            ReadyOrdersScreenForTab(widget.storeId),
            PreparingOrdersScreenForTab(widget.storeId),
            ReceivedOrdersScreenForTab(widget.storeId),
           // POSMainScreen()
          ]),
        )
    );
  }
}
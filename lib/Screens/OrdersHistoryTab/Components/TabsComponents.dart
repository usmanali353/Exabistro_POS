import 'package:exabistro_pos/Screens/LoginScreen.dart';
import 'package:exabistro_pos/Screens/Orders/PreparingOrdersForKitchen(Tab).dart';
import 'package:exabistro_pos/Screens/Orders/ReadyOrdersForTablet.dart';
import 'package:exabistro_pos/Screens/Orders/ReceivedOrdersForKitchen(Tab).dart';
import 'package:exabistro_pos/Screens/OrdersHistoryTab/DeliveredScreenForTablet.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OrderListsTabsScreen extends StatefulWidget {
  var restaurantId,storeId,roleId;
  OrderListsTabsScreen({this.restaurantId,this.storeId,this.roleId});


  @override
  State<StatefulWidget> createState() {
    return new OrderListsTabsWidgetState();
  }
}

class OrderListsTabsWidgetState extends State<OrderListsTabsScreen> with SingleTickerProviderStateMixin{
  var totalItems;
  String token;
  var recievedOrders, preparingOrders , readyOrders ;

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      setState(() {
        this.token = value.getString("token");
      });
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return DefaultTabController(

        length: 3,
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
                color: Colors.white
            ),
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
            title: Text("Orders", style: TextStyle(color: yellowColor, fontWeight: FontWeight.bold, fontSize: 30),),
            centerTitle: true,
            backgroundColor: BackgroundColor,
            elevation: 0,
            bottom: TabBar(
                isScrollable: false,
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
                      child: Text("Received Orders",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold
                          //color: Color(0xff172a3a)
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Preparing",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold
                          //color: Color(0xff172a3a)
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Ready",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold
                          //color: Color(0xff172a3a)
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
          body: TabBarView(children: [
            ReceivedOrdersScreenForTab(widget.storeId),
            PreparingOrdersScreenForTab(widget.storeId),
            ReadyOrdersScreenForTab(widget.storeId),
          ]),
        )
    );
  }
}
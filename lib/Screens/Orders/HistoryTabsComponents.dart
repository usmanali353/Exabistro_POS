import 'package:exabistro_pos/Screens/LoginScreen.dart';
import 'package:exabistro_pos/Screens/Orders/CancelledOrdersScreenForTablet.dart';
import 'package:exabistro_pos/Screens/Orders/DeliveredScreenForTablet.dart';
import 'package:exabistro_pos/Screens/OrdersHistoryTab/Components/Screens/PaidOrdersList.dart';
import 'package:exabistro_pos/Screens/OrdersHistoryTab/Components/Screens/UnPaidOrdersList.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OrdersHistoryTabsScreen extends StatefulWidget {
  var restaurantId,storeId,roleId;
  OrdersHistoryTabsScreen({this.restaurantId,this.storeId,this.roleId});


  @override
  State<StatefulWidget> createState() {
    return new PaidTabsWidgetState();
  }
}

class PaidTabsWidgetState extends State< OrdersHistoryTabsScreen> with SingleTickerProviderStateMixin{


  @override
  void initState() {


    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return DefaultTabController(

        length: 2,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon:  FaIcon(FontAwesomeIcons.signOutAlt, color: blueColor, size: 25,),
                onPressed: (){
                  SharedPreferences.getInstance().then((value) {
                    value.remove("token");
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>LoginScreen()), (route) => false);
                  } );
                },
              ),
            ],
            iconTheme: IconThemeData(
                color: blueColor
            ),
            title: Text("Orders History", style: TextStyle(color: yellowColor, fontWeight: FontWeight.bold, fontSize: 30),),
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
                      child: Text("Delivered Orders",
                        style: TextStyle(
                          //color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,

                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Cancelled Orders",
                        style: TextStyle(
                          fontSize: 20,
                          //color: Colors.white,
                          fontWeight: FontWeight.bold,

                          //color: Color(0xff172a3a)
                        ),
                      ),
                    ),
                  ),

                ]),
          ),
          body: TabBarView(children: [

            // AllOrders(),
            DeliveredScreenForTablet(widget.storeId),
            CancelledOrdersScreenForTablet(widget.storeId),
          ]),
        )
    );
  }
}
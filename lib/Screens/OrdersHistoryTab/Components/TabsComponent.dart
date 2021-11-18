import 'package:exabistro_pos/Screens/Orders/ReceivedOrdersForKitchen(Tab).dart';
import 'package:exabistro_pos/Screens/OrdersHistoryTab/DeliveredScreenForTablet.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/services.dart';


class OrderRecordTabsScreen extends StatefulWidget {
  var restaurantId,storeId,roleId;
OrderRecordTabsScreen({this.restaurantId,this.storeId,this.roleId});


  @override
  State<StatefulWidget> createState() {
    return new OrderRecordTabsWidgetState();
  }
}

class OrderRecordTabsWidgetState extends State<OrderRecordTabsScreen> with SingleTickerProviderStateMixin{


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
            iconTheme: IconThemeData(
                color: Colors.white
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
                      child: Text("Active Orders",
                        style: TextStyle(
                          fontSize: 20,
                            //color: Colors.white,
                            fontWeight: FontWeight.bold,

                        //color: Color(0xff172a3a)
                      ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Previous Orders",
                        style: TextStyle(
                          //color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,

                        ),
                      ),
                    ),
                  ),
                ]),
          ),
          body: TabBarView(children: [
            ReceivedOrdersScreenForTab(widget.storeId),
            // AllOrders(),
            DeliveredScreenForTablet(widget.storeId),
          ]),
        )
    );
  }
}
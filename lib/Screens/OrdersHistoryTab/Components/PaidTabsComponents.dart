import 'package:exabistro_pos/Screens/OrdersHistoryTab/Components/Screens/PaidOrdersList.dart';
import 'package:exabistro_pos/Screens/OrdersHistoryTab/Components/Screens/UnPaidOrdersList.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/services.dart';


class PaidTabsScreen extends StatefulWidget {
  var restaurantId,storeId,roleId;
  PaidTabsScreen({this.restaurantId,this.storeId,this.roleId});


  @override
  State<StatefulWidget> createState() {
    return new PaidTabsWidgetState();
  }
}

class PaidTabsWidgetState extends State<PaidTabsScreen> with SingleTickerProviderStateMixin{


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
                      child: Text("UnPaid Orders",
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
                      child: Text("Paid Orders",
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
            UnPaidOrdersScreenForTab(widget.storeId),
            PaidOrdersScreenForTab(widget.storeId),
          ]),
        )
    );
  }
}
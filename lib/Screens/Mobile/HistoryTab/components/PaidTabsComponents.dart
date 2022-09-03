import 'package:exabistro_pos/Screens/LoginScreen.dart';
import 'package:exabistro_pos/Screens/Mobile/HistoryTab/Screens/CancelledOrdersScreenForMobile.dart';
import 'package:exabistro_pos/Screens/Mobile/HistoryTab/Screens/DeliveredOrdersScreenForMobile.dart';
import 'package:exabistro_pos/Screens/Mobile/HistoryTab/Screens/DiscountedOrdersScreenForMobile.dart';
import 'package:exabistro_pos/Screens/Mobile/HistoryTab/Screens/RefundedOrdersScreenForMobile.dart';
import 'package:exabistro_pos/Screens/Mobile/OrdersTab/Screens/PaidOrdersListScreenForMobile.dart';
import 'package:exabistro_pos/Screens/Mobile/OrdersTab/components/PaidTabsComponents.dart';
import 'package:exabistro_pos/Screens/Mobile/POSTabs/ForMobile/components/POSTabsComponent.dart';
import 'package:exabistro_pos/Utils/Utils.dart';

import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utils/constants.dart';


class OrdersHistoryTabsScreenForMobile extends StatefulWidget {
  var restaurantId,storeId,roleId;
  OrdersHistoryTabsScreenForMobile({this.restaurantId,this.storeId,this.roleId});


  @override
  State<StatefulWidget> createState() {
    return new PaidTabsWidgetState();
  }
}

class PaidTabsWidgetState extends State< OrdersHistoryTabsScreenForMobile> with SingleTickerProviderStateMixin{

  String token,email;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SharedPreferences.getInstance().then((prefs){
      setState(() {
        this.token=prefs.getString("token");
        this.email=prefs.getString("email");
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return DefaultTabController(

        length: 4,
        child: Scaffold(
          drawer: Drawer(
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
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>POSMobileScreenTab(store:widget.storeId)), (route) => false);
                    },
                    title: Text(
                      translate("drawer_items.home"),
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
                      //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>PaidTabsScreenForMobile(storeId:widget.store)), (route) => false);

                      if(widget.storeId["payOut"]!=null&&widget.storeId["payOut"]==true){
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>PaidOrdersScreenForMobile(widget.storeId)), (route) => false);
                      }else {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>PaidTabsScreenForMobile(storeId:widget.storeId)), (route) => false);
                      }
                    },
                    // onTap: (){
                    //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>PaidTabsScreenForMobile(storeId:widget.storeId)), (route) => false);
                    //
                    //   // if(widget.storeId["payOut"]!=null&&widget.storeId["payOut"]==true){
                    //   //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>PaidOrdersScreenForMobile(widget.storeId)), (route) => false);
                    //   // }else {
                    //   //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>PaidTabsScreenForMobile(storeId:widget.storeId)), (route) => false);
                    //   // }
                    // },
                    title: Text(
                      translate("drawer_items.today_orders"),
                      style: TextStyle(
                          color: blueColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    trailing: FaIcon(FontAwesomeIcons.utensils,color: yellowColor,),
                  ),
                  Divider(color: yellowColor, thickness: 1,),
                  ListTile(
                    onTap: (){
                      Network_Operations.getAllDailySessionByStoreId(context, token,widget.storeId["id"]).then((value){
                        if(value!=null&&value.length>0){
                          showDialog(
                              context: context,
                              builder:(context){
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    width: 400,
                                    height: LocalizedApp.of(context).delegate.currentLocale.languageCode=="ur"||LocalizedApp.of(context).delegate.currentLocale.languageCode=="ar"?166:130,
                                    child: Utils.shiftReportDialog(context,value.last),
                                  ),
                                ) ;
                              }
                          );

                        }
                      });
                    },
                    title: Text(
                      translate("drawer_items.shift_report"),
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
                      translate("drawer_items.logout"),
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
          ),
          appBar: AppBar(
            iconTheme: IconThemeData(
                color: blueColor
            ),
            title: Text(translate("drawer_items.orders_history"), style: TextStyle(color: yellowColor, fontWeight: FontWeight.bold, fontSize: 30),),
            centerTitle: true,
            backgroundColor: BackgroundColor,
            elevation: 0,
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
                      child: Text(translate("delivered_orders_history.delivered_orders_label"),
                        style: TextStyle(
                          //color: blueColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,

                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(translate("cancelled_orders_history.cancelled_orders_label"),
                        style: TextStyle(
                          fontSize: 18,
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
                      child: Text( translate("discounted_orders_history.discounted_orders_label"),
                        style: TextStyle(
                          fontSize: 18,
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
                      child: Text( translate("refunded_orders_history.refunded_orders_label"),
                        style: TextStyle(
                          fontSize: 18,
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
            DeliveredScreenForMobile(widget.storeId),
            CancelledOrdersScreenForMobile(widget.storeId),
            DiscountedOrdersScreenForMobile(widget.storeId),
            RefundedOrdersScreenForMobile(widget.storeId),
          ]),
        )
    );
  }
}
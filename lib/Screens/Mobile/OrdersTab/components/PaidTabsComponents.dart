import 'package:exabistro_pos/Screens/LoginScreen.dart';
import 'package:exabistro_pos/Screens/Mobile/HistoryTab/components/PaidTabsComponents.dart';
import 'package:exabistro_pos/Screens/Mobile/OrdersTab/Screens/PaidOrdersListScreenForMobile.dart';
import 'package:exabistro_pos/Screens/Mobile/OrdersTab/Screens/UnpaidOrdersListScreenForMobile.dart';
import 'package:exabistro_pos/Screens/Mobile/POSTabs/ForMobile/components/POSTabsComponent.dart';
import 'package:exabistro_pos/Screens/Orders/HistoryTabsComponents.dart';
import 'package:exabistro_pos/Screens/OrdersHistoryTab/Components/Screens/PaidOrdersList.dart';
import 'package:exabistro_pos/Screens/OrdersHistoryTab/Components/Screens/UnPaidOrdersList.dart';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../POSMainScreenUI1.dart';


class PaidTabsScreenForMobile extends StatefulWidget {
  var restaurantId,storeId,roleId;
  PaidTabsScreenForMobile({this.restaurantId,this.storeId,this.roleId});


  @override
  State<StatefulWidget> createState() {
    return new PaidTabsWidgetState();
  }
}

class PaidTabsWidgetState extends State<PaidTabsScreenForMobile> with SingleTickerProviderStateMixin{

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

        length: 2,
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
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>OrdersHistoryTabsScreenForMobile(storeId:widget.storeId)), (route) => false);
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
                      Network_Operations.getAllDailySessionByStoreId(context, token,widget.storeId["id"]).then((value){
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
          ),
          appBar: AppBar(
            iconTheme: IconThemeData(
                color: blueColor
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
                      child: Text("Unpaid Orders",
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
            UnPaidOrdersScreenForMobile(widget.storeId),
            PaidOrdersScreenForMobile(widget.storeId),
          ]),
        )
    );
  }
}
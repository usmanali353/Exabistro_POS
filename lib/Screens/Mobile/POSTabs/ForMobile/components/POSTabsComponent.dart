
import 'dart:async';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:exabistro_pos/Screens/Mobile/HistoryTab/components/PaidTabsComponents.dart';
import 'package:exabistro_pos/Screens/Mobile/OrdersTab/Screens/PaidOrdersListScreenForMobile.dart';
import 'package:exabistro_pos/Screens/Mobile/OrdersTab/components/PaidTabsComponents.dart';
import 'package:exabistro_pos/Screens/Mobile/POSTabs/ForMobile/Screens/DealsScreen.dart';
import 'package:exabistro_pos/Screens/Mobile/POSTabs/ForMobile/Screens/ProductsScreen.dart';
import 'package:exabistro_pos/Utils/Utils.dart';

import 'package:exabistro_pos/model/CartItems.dart';
import 'package:exabistro_pos/model/Categories.dart';
import 'package:exabistro_pos/model/Orderitems.dart';
import 'package:exabistro_pos/model/Orders.dart';
import 'package:exabistro_pos/model/Products.dart';
import 'package:exabistro_pos/model/Tax.dart';
import 'package:exabistro_pos/model/orderItemTopping.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Utils/constants.dart';
import '../../../../LoginScreen.dart';



class POSMobileScreenTab extends StatefulWidget {
  var store;
  POSMobileScreenTab({this.store});

//  KitchenMobileScreenTab({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new POSWidgetState();
  }
}

class POSWidgetState extends State<POSMobileScreenTab> with SingleTickerProviderStateMixin{
  List<Categories> subCategories = [];
  List<dynamic> dealsList = [],taxesList=[];
  List<Products> products = [];
  String categoryName = "",userId="";
  bool isLoading = true;
  List<String> menuTypeDropdownItems = ["Products", "Deals"];
  List<String> discountTypeDropdownItems = ["Percentage", "Cash"];
  String selectedMenuType;
  var overallTotalPrice=0.0,overallTotalPriceWithTax=0.0,totalTax=0.0;
  List<CartItems> cartList = [];
  TimeOfDay pickingTime;
  Order finalOrder;
  List<Orderitem> orderitem = [];
  List<Orderitemstopping> itemToppingList = [];
  List<Tax> orderTaxes=[],typeBasedTaxes=[];
  dynamic ordersList;
  List<dynamic> toppingList = [], orderItems = [],tables=[];
  List<String> topping = [];
  double totalprice = 0.00, applyVoucherPrice;
  TextEditingController addnotes, applyVoucher;
  String orderType;
  int orderTypeId;
  var voucherValidity,currentDailySession;
  APICacheDBModel offlineData;
  var selectedOrderType,selectedOrderTypeId,selectedWaiter,selectedWaiterId,selectedTable,selectedTableId;
  TextEditingController timePickerField,customerName,customerPhone,customerEmail,customerAddress,discountValue;
  String token,discountService,waiveOffService;
  List<int> cartCounter=[];
  final formKey= GlobalKey<FormState>();
  Timer t;

  @override
  void initState() {
    timePickerField=TextEditingController();
    customerName=TextEditingController();
    customerAddress=TextEditingController();
    customerEmail=TextEditingController();
    customerPhone=TextEditingController();
    discountValue=TextEditingController();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SharedPreferences.getInstance().then((prefs){
      setState(() {
        this.token=prefs.getString("token");
        this.discountService=prefs.getString("discountService");
        this.waiveOffService=prefs.getString("waiveOffService");
      });


      Network_Operations.getDailySessionByStoreId(context, prefs.getString("token"),widget.store["id"]).then((dailySession){
        setState(() {
          currentDailySession=dailySession;
          print("Current Daily Session"+currentDailySession.toString());
        });
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
                          "staff@mailinator.com",
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
                      //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>PaidTabsScreenForMobile(storeId:widget.store)), (route) => false);

                      if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>PaidOrdersScreenForMobile(widget.store)), (route) => false);
                      }else {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>PaidTabsScreenForMobile(storeId:widget.store)), (route) => false);
                      }
                    },
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
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>OrdersHistoryTabsScreenForMobile(storeId:widget.store)), (route) => false);
                    },
                    title: Text(
                      translate("drawer_items.orders_history"),
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
                      this.isLoading=true;
                      Network_Operations.getAllDailySessionByStoreId(context, token,widget.store["id"]).then((value){
                        this.isLoading=false;
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
            centerTitle: true,
            backgroundColor: BackgroundColor,
            title: Text("Exabistro - POS", style: TextStyle(
                color: yellowColor, fontSize: 25, fontWeight: FontWeight.bold
            ),
            ),
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
                      child: Text(translate("main_screen.products_tab"),
                        style: TextStyle(
                          fontSize: 18,
                            fontWeight: FontWeight.bold
                        //color: Color(0xff172a3a)
                      ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(translate("main_screen.deals_tab"),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          //color: Color(0xff172a3a)
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
          body: TabBarView(children: [
           ProductsScreen(store:widget.store),
           DealsScreen(store:widget.store)

          ]),
        )
    );

  }
}
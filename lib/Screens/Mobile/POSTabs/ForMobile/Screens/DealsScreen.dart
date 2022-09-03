import 'dart:async';
import 'package:exabistro_pos/Screens/Mobile/Cart/NewPOSCartScreen.dart';
import 'package:exabistro_pos/Screens/Mobile/Cart/POSCartScreenForMobile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:exabistro_pos/Utils/Utils.dart';

import 'package:exabistro_pos/model/CartItems.dart';
import 'package:exabistro_pos/model/Categories.dart';
import 'package:exabistro_pos/model/Orderitems.dart';
import 'package:exabistro_pos/model/Orders.dart';
import 'package:exabistro_pos/model/Products.dart';
import 'package:exabistro_pos/model/Tax.dart';
import 'package:exabistro_pos/model/orderItemTopping.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:exabistro_pos/networks/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_counter/flutter_counter.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:icon_badge/icon_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Utils/constants.dart';


class DealsScreen extends StatefulWidget {
  var store;
  DealsScreen({this.store});
  @override
  _DealsScreenState createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  List<Categories> subCategories = [];
  List<dynamic> dealsList = [],
      taxesList = [];
  List<Products> products = [];
  String categoryName = "",
      userId = "";
  bool isLoading = true;
  List<String> menuTypeDropdownItems = ["Products", "Deals"];
  List<String> discountTypeDropdownItems = ["Percentage", "Cash"];
  String selectedMenuType;
  var overallTotalPrice = 0.0,
      overallTotalPriceWithTax = 0.0,
      totalTax = 0.0;
  List<CartItems> cartList = [];
  TimeOfDay pickingTime;
  Order finalOrder;
  List<Orderitem> orderitem = [];
  List<Orderitemstopping> itemToppingList = [];
  List<Tax> orderTaxes = [],
      typeBasedTaxes = [];
  dynamic ordersList;
  List<dynamic> toppingList = [],
      orderItems = [],
      tables = [];
  List<String> topping = [];
  double totalprice = 0.00,
      applyVoucherPrice;
  TextEditingController addnotes, applyVoucher;
  String orderType;
  int orderTypeId;
  var voucherValidity, currentDailySession;
  APICacheDBModel offlineData;
  var selectedOrderType, selectedOrderTypeId, selectedWaiter, selectedWaiterId,
      selectedTable, selectedTableId;
  TextEditingController timePickerField, customerName, customerPhone,
      customerEmail, customerAddress, discountValue;
  String token, discountService, waiveOffService;
  List<int> cartCounter = [];
  final formKey = GlobalKey<FormState>();
  List allMenu = [];
  bool selectedCategory = true;
  List<bool> _selected = [];
  PaperSize paper = PaperSize.mm58;
  BluetoothManager bluetoothManager = BluetoothManager.instance;


  @override
  void initState() {
    timePickerField = TextEditingController();
    customerName = TextEditingController();
    customerAddress = TextEditingController();
    customerEmail = TextEditingController();
    customerPhone = TextEditingController();
    discountValue = TextEditingController();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);


    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        this.token = prefs.getString("token");
        this.userId = prefs.getString("userId");
        this.discountService = prefs.getString("discountService");
        this.waiveOffService = prefs.getString("waiveOffService");
      });

      Network_Operations.getAllDeals(
          context, prefs.getString("token"), widget.store["id"],
          endDate: DateTime.now(),
          startDate: DateTime.now().subtract(Duration(days: 365)))
          .then((deals) {
        setState(() {
          List<String> lst = prefs.getStringList("reordereddeals${widget.store["id"].toString()}");
          if(lst!=null&&lst.length>0&&deals!=null&&deals.length>0){
            try{
              this.dealsList= lst.map(
                    (String indx) => deals
                    .where((dynamic item) => int.parse(indx) == item["id"])
                    .first,
              ).toList();
              if(deals.length>dealsList.length){
                int additionalElements=deals.length-dealsList.length;
                var reversedList =  List.from(deals.reversed);

                for(int i= 0;i<additionalElements;i++){
                  dealsList.add(reversedList[i]);
                }
              }
            }catch(e){
              this.dealsList.addAll(deals);
            }

          }else{
            if (deals.length > 0) {
              this.dealsList.addAll(deals);
            }
          }
          sqlite_helper().getcart1().then((value) {
            setState(() {
              cartList.clear();
              cartCounter.clear();
              cartList = value;
              if (cartList.length > 0) {
                for (CartItems item in cartList) {
                  cartCounter.add(item.quantity);
                }
              }
            });
          });
        });
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: new FloatingActionButton(
          elevation: 5.0,
          child:  IconBadge(
            top: 2,
            right: 0,
            icon: Icon(Icons.add_shopping_cart_rounded, color: blueColor, size: 25,),
            itemCount: cartList.length,
            badgeColor: Colors.red.shade600,
            itemColor: Colors.white,
            maxCount: 99,
            hideZero: true,
            onTap: (){
              print("test");
              Navigator.push(context, MaterialPageRoute(builder: (context) =>NewPOSCartScreenForMobile(store:widget.store)));
            },
          ),
          backgroundColor: yellowColor,
          onPressed: (){
            print("test");
            Navigator.push(context, MaterialPageRoute(builder: (context) =>NewPOSCartScreenForMobile(store:widget.store)));
          }
      ),
      body: Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/bb.jpg'),
            )
        ),
        child: ReorderableListView.builder(
            onReorder: (oldIndex,newIndex){
              if (newIndex > oldIndex) {
                newIndex = newIndex - 1;
              }
              final element = dealsList.removeAt(oldIndex);
              dealsList.insert(newIndex, element);
              print("reordereddeals${widget.store["id"].toString()}");
              SharedPreferences.getInstance().then((prefs){
                prefs.setStringList("reordereddeals${widget.store["id"].toString()}", dealsList.map((m) => m["id"].toString()).toList());
              });
            },
          //scrollDirection: Axis.horizontal,
            itemCount: dealsList != null ? dealsList.length : 0,
            itemBuilder: (context, index) {
              return InkWell(
                key: ValueKey(dealsList[index]["id"]),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          //backgroundColor: Colors.transparent,
                            child: Container(
                                height: 470,
                                width: 500,
                                child: dealsPopupLayout(dealsList[index])
                            )
                        );
                      });
                },
                child: Card(
                  elevation: 4,
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: 90,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        image: DecorationImage(
                          image: NetworkImage(dealsList[index]["image"] != null
                              ? dealsList[index]["image"]
                              : "http://anokha.world/images/not-found.png"),
                          fit: BoxFit.cover,
                        )),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: AutoSizeText(
                          dealsList != null && dealsList.length > 0 &&
                              dealsList[index]["name"] != null
                              ? dealsList[index]["name"]
                              : "",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                          ),
                          maxLines: 1,
                        ),
                      ),
                      // Center(
                      //   child: Text(
                      //     "CATEGORY",
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(
                      //         fontSize: 19,
                      //         color: Colors.white,
                      //         fontWeight: FontWeight.bold),
                      //   ),
                      // ),
                    ),

                  ),
                ),
              );
            }),
      ),
    );

  }

  Widget dealsPopupLayout(dynamic deal) {
    var count = 1;
    debugPrint(deal.toString());
    var price = 0.0,actualPrice=0.0;
    var updatedPrice = 0.0,updatedActualPrice=0.0;
    List<String> dealProducts = [];
    if (deal["productDeals"] != null && deal["productDeals"].length > 0) {
      for (var pd in deal["productDeals"]) {
        if (pd["product"] != null && pd["size"] != null) {
          dealProducts.add(pd["product"]["name"] +
              " (" +
              pd["size"]["name"] +
              ") x" +
              pd["quantity"].toString());
        }
      }
    }
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
          builder: (thisLowerContext, innerSetState) {
            if (deal != null) {
              innerSetState(() {
                price = deal["price"];
                actualPrice = deal["actualPrice"];
                print("Actual Deal Price $actualPrice");
              });
            }
            return Center(
              child: Container(
                height: 470,
                width: 500,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                      image: AssetImage('assets/bb.jpg'),
                    )),
                child: Column(
                  children: [

                    Card(
                      elevation: 8,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        color: yellowColor,
                        child: Center(
                          child: Text(
                            deal["name"],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          //height: 80,
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        translate("deals_popup.discounted_price"),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: yellowColor),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            widget.store["currencyCode"]+": ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: yellowColor),
                                          ),
                                          Text(
                                            updatedPrice.toString() == "0.0"
                                                ? price.toString()
                                                : updatedPrice.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: blueColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        translate("deals_popup.actual_price"),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: yellowColor),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            widget.store["currencyCode"]+": ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: yellowColor),
                                          ),
                                          Text(
                                            updatedActualPrice.toString()=="0.0"? actualPrice.toString():updatedActualPrice.toString(),
                                            style: TextStyle(
                                                decoration: TextDecoration.lineThrough,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: blueColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )
                          )),
                    ),
                    Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: ListTile(
                          title: Text(
                            translate("deals_popup.products"),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: yellowColor,
                                fontSize: 22),
                          ),
                          subtitle: Text(
                            dealProducts
                                .toString()
                                .replaceAll("[", "")
                                .replaceAll("]", ""),
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: blueColor,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  translate("deals_popup.quantity"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: yellowColor),
                                ),
                                Counter(
                                    initialValue: count,
                                    minValue: 1,
                                    maxValue: 10,
                                    onChanged: (value) {
                                      innerSetState(() {
                                        count = value;
                                        updatedPrice = 0.0;
                                        updatedPrice = price * count;
                                        updatedActualPrice = actualPrice * count;
                                      });
                                    },
                                    step: 1,
                                    decimalPlaces: 0),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    InkWell(
                      onTap: () {
                        print(dealProducts.toString());
                        sqlite_helper().dealCheckAlreadyExists(deal["id"]).then((foundDeals){
                          if(foundDeals!=null&&foundDeals.length>0){
                            var tempDeals=CartItems(
                                id: foundDeals[0]["id"],
                                productId: null,
                                productName: deal["name"],
                                isDeal: 1,
                                dealId: deal["id"],
                                sizeId: null,
                                sizeName: null,
                                price: deal["price"],
                                totalPrice: updatedPrice == 0.0 ? price : updatedPrice,
                                quantity: count,
                                dealProducts: dealProducts.toString(),
                                storeId: deal["storeId"],
                                topping: null);
                            sqlite_helper().updateCart(tempDeals).then((updatedEntries){
                              sqlite_helper().getcart1().then((value) {
                                setState(() {
                                  cartList.clear();
                                  cartCounter.clear();
                                  cartList = value;
                                  if (cartList.length > 0) {
                                    for(CartItems item in cartList){
                                      cartCounter.add(item.quantity);
                                    }
                                  }
                                });
                              });
                              sqlite_helper().gettotal().then((value){
                                setState(() {
                                  overallTotalPrice=value[0]["SUM(totalPrice)"];
                                });
                              });
                            });
                            Navigator.of(context).pop();
                            Utils.showSuccess(context, "Updated to Cart successfully");
                          }else{
                            sqlite_helper()
                                .create_cart(CartItems(
                                productId: null,
                                productName: deal["name"],
                                isDeal: 1,
                                dealId: deal["id"],
                                sizeId: null,
                                sizeName: null,
                                price: deal["price"],
                                totalPrice: updatedPrice == 0.0 ? price : updatedPrice,
                                quantity: count,
                                dealProducts: dealProducts.toString(),
                                storeId: deal["storeId"],
                                topping: null))
                                .then((isInserted) {
                              if (isInserted > 0) {
                                innerSetState(() {

                                  sqlite_helper().getcart1().then((value) {
                                    setState(() {
                                      cartCounter.clear();
                                      cartList.clear();
                                      cartList = value;
                                      if (cartList.length > 0) {
                                        for(CartItems item in cartList){
                                          cartCounter.add(item.quantity);
                                        }
                                      }
                                    });
                                  });
                                  sqlite_helper().gettotal().then((value){
                                    setState(() {
                                      overallTotalPrice=value[0]["SUM(totalPrice)"];
                                    });
                                  });
                                });
                                Navigator.of(context).pop();
                                Utils.showSuccess(
                                    context, "Added to Cart successfully");
                              } else {
                                Navigator.of(context).pop();
                                Utils.showError(context, "Some Error Occur");
                              }
                            });
                          }
                        });

                      },
                      child: Card(
                        elevation: 8,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 65,
                          decoration: BoxDecoration(
                              color: yellowColor,
                              borderRadius: BorderRadius.circular(4)),
                          child: Center(
                            child: Text(
                              translate("deals_popup.addToCard_btn"),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

}

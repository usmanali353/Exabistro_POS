import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:exabistro_pos/Screens/LoadingScreen.dart';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:exabistro_pos/model/Additionals.dart';
import 'package:exabistro_pos/model/CartItems.dart';
import 'package:exabistro_pos/model/Categories.dart';
import 'package:exabistro_pos/model/Orderitems.dart';
import 'package:exabistro_pos/model/Orders.dart';
import 'package:exabistro_pos/model/Products.dart';
import 'package:exabistro_pos/model/Tax.dart';
import 'package:exabistro_pos/model/Toppings.dart';
import 'package:exabistro_pos/model/orderItemTopping.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:exabistro_pos/networks/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_counter/flutter_counter.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class POSMainScreen extends StatefulWidget {
  int storeId;
  @override
  _POSMainScreenState createState() => _POSMainScreenState();

  POSMainScreen({this.storeId});
}

class _POSMainScreenState extends State<POSMainScreen> {
  List<Categories> subCategories = [];
  List<dynamic> dealsList = [];
  List<Products> products = [];
  String categoryName = "";
  bool isLoading = true;
  List<String> menuTypeDropdownItems = ["Products", "Deals"];
  List<String> discountTypeDropdownItems = ["Percentage", "Cash"];
  String selectedMenuType;
  var overallTotalPrice=0.0,overallTotalPricewitOoutTax=0.0;
  List<CartItems> cartList = [];

  Order finalOrder;
  List<Orderitem> orderitem = [];
  List<Orderitemstopping> itemToppingList = [];
  List<Map> orderitem1 = [];
  List<Tax> orderTaxes=[];
  dynamic ordersList;
  List<dynamic> toppingList = [], orderItems = [];
  List<String> topping = [];
  double totalprice = 0.00, applyVoucherPrice;
  TextEditingController addnotes, applyVoucher;
  String orderType;
  int orderTypeId;
  var voucherValidity;
  List orderTypeList = ["Dine-In", "TakeAway"];

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    Utils.check_connectivity().then((isConnected) {
      if (isConnected) {
        Network_Operations.getSubcategories(context, widget.storeId)
            .then((sub) {
          setState(() {
            if (sub != null && sub.length > 0) {
              subCategories.addAll(sub);
              categoryName = subCategories[0].name;
              Network_Operations.getProduct(
                      context,
                      subCategories[0].categoryId,
                      subCategories[0].id,
                      widget.storeId,
                      "")
                  .then((p) {
                setState(() {
                  if (p != null && p.length > 0) {
                    isLoading = false;
                    products.addAll(p);
                  } else
                    isLoading = false;
                  SharedPreferences.getInstance().then((prefs) {
                    Network_Operations.getAllDeals(
                            context, prefs.getString("token"), widget.storeId)
                        .then((dealsList) {
                      setState(() {
                        if (dealsList.length > 0) {
                          this.dealsList.addAll(dealsList);
                        }
                      });
                    });
                  });

                  sqlite_helper().getcart1().then((value) {
                    setState(() {
                      cartList.clear();
                      cartList = value;
                      if (cartList.length > 0) {
                        print(cartList.toString());
                      }
                    });
                  });
                  Network_Operations.getTaxListByStoreId(context,widget.storeId).then((taxes){
                    setState(() {
                      this.orderTaxes=taxes;
                      sqlite_helper().gettotal().then((value){
                        setState(() {
                          overallTotalPrice=value[0]["SUM(totalPrice)"];
                          overallTotalPricewitOoutTax=value[0]["SUM(totalPrice)"];
                          var taxes=orderTaxes.where((element) => element.takeAway);
                          if(taxes!=null&&taxes.length>0) {
                            for (var t in taxes.toList()) {
                              if(t.price!=null&&t.price!=0.0){
                                overallTotalPrice=overallTotalPrice+t.price;
                              }else if(t.percentage!=null&&t.percentage!=0.0){
                                var percentTax=t.percentage/100*overallTotalPrice;
                                overallTotalPrice=overallTotalPrice+percentTax;
                              }
                            }
                          }

                        });
                      });
                    });
                  });
                });
              });
            } else {
              isLoading = false;
              Utils.showError(context, "No Categories Found");
            }
          });
        });
      } else {
        isLoading = false;
        Navigator.pop(context);
        Utils.showError(context, "Network Error");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              title: Text(
                'Exabistro - POS',
                style: TextStyle(
                    color: yellowColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              ),
              centerTitle: true,
              backgroundColor: BackgroundColor,
              automaticallyImplyLeading: false,
            ),
            body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.cover,
                  //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                  image: AssetImage('assets/bb.jpg'),
                )),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  color: yellowColor,
                                  child: Center(
                                    child: Text(
                                      "Categories ",
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 140,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: subCategories.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: InkWell(
                                            onTap: () {
                                              Network_Operations.getProduct(
                                                      context,
                                                      subCategories[index]
                                                          .categoryId,
                                                      subCategories[index].id,
                                                      widget.storeId,
                                                      "")
                                                  .then((p) {
                                                setState(() {
                                                  if (p != null &&
                                                      p.length > 0) {
                                                    categoryName =
                                                        subCategories[index]
                                                            .name;
                                                    products.clear();
                                                    products.addAll(p);
                                                  }
                                                });
                                              });
                                            },
                                            child: Card(
                                              elevation: 8,
                                              child: CachedNetworkImage(
                                                imageUrl: subCategories[index]
                                                            .image !=
                                                        null
                                                    ? subCategories[index].image
                                                    : "http://anokha.world/images/not-found.png",
                                                placeholder: (context, url) =>
                                                    Container(
                                                        width: 100,
                                                        height: 100,
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                          color: Colors.amber,
                                                        ))),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                                imageBuilder:
                                                    (context, imageProvider) {
                                                  return Container(
                                                    height: 150,
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        )),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.black38,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          subCategories[index]
                                                              .name,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 50,
                                    color: yellowColor,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            categoryName,
                                            style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: Card(
                                            color: yellowColor,
                                            elevation: 8,
                                            child: DropdownButton(
                                                isDense: true,
                                                value: selectedMenuType == null
                                                    ? menuTypeDropdownItems[0]
                                                    : selectedMenuType, //actualDropdown,
                                                onChanged: (String value) {
                                                  setState(() {
                                                    this.selectedMenuType =
                                                        value;
                                                  });
                                                },
                                                items: menuTypeDropdownItems
                                                    .map((String title) {
                                                  return DropdownMenuItem(
                                                    value: title,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              3.0),
                                                      child: Text(title,
                                                          style: TextStyle(
                                                              color: blueColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14.0)),
                                                    ),
                                                  );
                                                }).toList()),
                                          ),
                                        )
                                      ],
                                    )),
                                Container(
                                    //color: Colors.teal,
                                    width: MediaQuery.of(context).size.width,
                                    height: 460,
                                    child: selectedMenuType == "Products" ||
                                            selectedMenuType == null
                                        ?
                                    //listViewLayout()
                                    productsLayout()
                                        : dealsLayout())
                              ],
                            ),
                          )),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                          flex: 2,
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  color: yellowColor,
                                  child: Center(
                                    child: Text(
                                      "Current Order For Cash Register",
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Container(
                                  //color: Colors.teal,
                                  width: MediaQuery.of(context).size.width,
                                  height: 410,
                                  child: cartListLayout(),
                                ),
                             //    Container(
                             //      //color: Colors.teal,
                             //      width: MediaQuery.of(context).size.width,
                             //      height: 175,
                             //      child: Column(
                             //        children: [
                             //          Container(
                             //            width: MediaQuery.of(context).size.width,
                             //            height: 40,
                             //            color: yellowColor,
                             //            child: Center(
                             //              child: Text(
                             //                "Add Discount",
                             //                style: TextStyle(
                             //                    fontSize: 22,
                             //                    color: Colors.white,
                             //                    fontWeight: FontWeight.bold),
                             //              ),
                             //            ),
                             //          ),
                             //          SizedBox(
                             //            height: 8,
                             //          ),
                             //          Container(
                             //            width: MediaQuery.of(context).size.width,
                             //            height: 120,
                             //            child: ListView(
                             //              children: [
                             //                Padding(
                             //                  padding: const EdgeInsets.all(4.0),
                             //                  child: DropdownButtonFormField<String>(
                             //                    decoration: InputDecoration(
                             //                      labelText: "Select Discount Type",
                             //                      alignLabelWithHint: true,
                             //                      labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                             //                      enabledBorder: OutlineInputBorder(
                             //                      ),
                             //                      focusedBorder:  OutlineInputBorder(
                             //                        borderSide: BorderSide(color:yellowColor),
                             //                      ),
                             //                    ),
                             //
                             //                    value: discountTypeDropdownItems[0],
                             //                    onChanged: (value) {
                             //                      setState(() {
                             //
                             //                      });
                             //                    },
                             //                    items: discountTypeDropdownItems.map((value) {
                             //                      return  DropdownMenuItem<String>(
                             //                        value: value,
                             //                        child: Row(
                             //                          children: <Widget>[
                             //                            Text(
                             //                              value,
                             //                              style:  TextStyle(color: yellowColor,fontSize: 13),
                             //                            ),
                             //                            //user.icon,
                             //                            //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                             //                          ],
                             //                        ),
                             //                      );
                             //                    }).toList(),
                             //                  ),
                             //                ),
                             //                Padding(
                             //                  padding: const EdgeInsets.all(4.0),
                             //                  child: TextFormField(
                             //                    decoration: const InputDecoration(
                             //                        suffixIcon: Icon(Icons.add_task_outlined,color: yellowColor,size: 35,),
                             //                        border: OutlineInputBorder(),
                             //                        hintText: 'Enter Value'
                             //
                             //                    ),
                             //                  ),
                             //                )
                             //              ],
                             //            ),
                             //          )
                             //
                             //        ],
                             //      )
                             // //      ListView(
                             // //        children: [
                             // //          Container(
                             // //            width: MediaQuery.of(context).size.width,
                             // //            height: 40,
                             // //            color: yellowColor,
                             // //            child: Center(
                             // //              child: Text(
                             // //                "Add Discount",
                             // //                style: TextStyle(
                             // //                    fontSize: 22,
                             // //                    color: Colors.white,
                             // //                    fontWeight: FontWeight.bold),
                             // //              ),
                             // //            ),
                             // //          ),
                             // //          DropdownButtonFormField<String>(
                             // //            decoration: InputDecoration(
                             // //              labelText: "Select Discount Type",
                             // //              alignLabelWithHint: true,
                             // //              labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                             // //              enabledBorder: OutlineInputBorder(
                             // //              ),
                             // //              focusedBorder:  OutlineInputBorder(
                             // //                borderSide: BorderSide(color:yellowColor),
                             // //              ),
                             // //            ),
                             // //
                             // //            value: discountTypeDropdownItems[0],
                             // //            onChanged: (value) {
                             // //              setState(() {
                             // //
                             // //              });
                             // //            },
                             // //            items: discountTypeDropdownItems.map((value) {
                             // //              return  DropdownMenuItem<String>(
                             // //                value: value,
                             // //                child: Row(
                             // //                  children: <Widget>[
                             // //                    Text(
                             // //                      value,
                             // //                      style:  TextStyle(color: yellowColor,fontSize: 13),
                             // //                    ),
                             // //                    //user.icon,
                             // //                    //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                             // //                  ],
                             // //                ),
                             // //              );
                             // //            }).toList(),
                             // //          ),
                             // //
                             // //  TextField(
                             // //  decoration: const InputDecoration(
                             // //  border: OutlineInputBorder(),
                             // //  hintText: 'Enter Value'
                             // //  ),
                             // // )
                             // //        ],
                             // //      ),
                             //    ),
                                Container(
                                  color: Colors.white,
                                  width: MediaQuery.of(context).size.width,
                                  height: 330,
                                  child: Column(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 40,
                                        color: yellowColor,
                                        child: Center(
                                          child: Text(
                                            "Order Summary",
                                            style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 210,
                                          color: blueColor,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 140,
                                                color: Colors.white,
                                                child: ListView(
                                                  children: [
                                                    Card(
                                                      elevation: 8,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 60,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                "SubTotal: ",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        25,
                                                                    color:
                                                                        yellowColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    "Rs: ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            25,
                                                                        color:
                                                                            yellowColor,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    overallTotalPricewitOoutTax!=null?overallTotalPricewitOoutTax.toString()+"/-":"0.0/-",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            25,
                                                                        color:
                                                                            blueColor,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Card(
                                                      elevation: 6,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 60,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                "Tax: ",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        25,
                                                                    color:
                                                                        yellowColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    "Rs: ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            25,
                                                                        color:
                                                                            yellowColor,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    "120/- ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            25,
                                                                        color:
                                                                            blueColor,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                color: blueColor,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 70,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "TOTAL: ",
                                                        style: TextStyle(
                                                            fontSize: 25,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Rs: ",
                                                            style: TextStyle(
                                                                fontSize: 25,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          Text(
                                                            overallTotalPrice!=null?overallTotalPrice.toString()+"/-":"0.0/-",
                                                            style: TextStyle(
                                                                fontSize: 25,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                      Card(
                                        elevation: 12,
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(context: context, builder:(BuildContext context){
                                              return Dialog(
                                                //backgroundColor: Colors.transparent,
                                                  child: Container(
                                                      height:MediaQuery.of(context).size.height -200,
                                                      width: MediaQuery.of(context).size.width / 3,
                                                      child: finalizingOrderPopUp()
                                                  )
                                              );
                                            });
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                200,
                                            height: 60,
                                            decoration: BoxDecoration(
                                                color: yellowColor,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Center(
                                              child: Text(
                                                "Create An Order ",
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold),
                                              ),
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
                    ],
                  ),
                )),
          );
  }

  //List's
  Widget dealsLayout() {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: dealsList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              // Navigator.push(context,MaterialPageRoute(builder: (context)=>CustomDialog().))
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                        child: Container(
                            height: MediaQuery.of(context).size.height / 1.25,
                            width: MediaQuery.of(context).size.width / 2.7,
                            child: dealsPopupLayout(dealsList[index])
                        )
                    );
                  });
            },
            child: Card(
              elevation: 8,
              child: CachedNetworkImage(
                imageUrl: dealsList[index]["image"] != null
                    ? dealsList[index]["image"]
                    : "http://anokha.world/images/not-found.png",
                placeholder: (context, url) => Container(
                    width: 85,
                    height: 85,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: Colors.amber,
                    ))),
                errorWidget: (context, url, error) => Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: 150,
                    width: 190,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          dealsList[index]["name"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 19,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  Widget listViewLayout(){
    return ListView.builder(itemCount: 10,itemBuilder: (context, index){
      return Card(
        elevation: 8,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 120,
          child: Row(
            children: [
              Container(
                width: 340,
                height: 120,
                decoration: BoxDecoration(
                  color: yellowColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget productsLayout() {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder:(BuildContext context){
                return productsPopupLayout(products[index]);
              });
            },
            child: Card(
              elevation: 8,
              child: CachedNetworkImage(
                imageUrl: products[index].image != null
                    ? products[index].image
                    : "http://anokha.world/images/not-found.png",
                placeholder: (context, url) => Container(
                    width: 85,
                    height: 85,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: Colors.amber,
                    ))),
                errorWidget: (context, url, error) => Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: 150,
                    width: 190,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          products[index].name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 19,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  Widget cartListLayout() {
    return ListView.builder(
        padding: EdgeInsets.all(4),
        scrollDirection: Axis.vertical,
        itemCount: cartList == null ? 0 : cartList.length,
        itemBuilder: (context, int index) {
          topping.clear();
          // toppingList.clear();
          if (cartList[index].topping != null) {
            if (jsonDecode(cartList[index].topping) != null) {
              for (int i = 0;
                  i < jsonDecode(cartList[index].topping).length;
                  i++) {
                topping.add(jsonDecode(cartList[index].topping)[i]['name'] +
                    "  x" +
                    jsonDecode(cartList[index].topping)[i]['quantity']
                        .toString() +
                    "    \$" +
                    jsonDecode(cartList[index].topping)[i]['price'].toString() +
                    "\n");
              }
            }
          }
          return Card(
            color: BackgroundColor,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                cartList[index].productName != null
                                    ? cartList[index].productName
                                    : "",
                                style: TextStyle(
                                    color: yellowColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: Icon(Icons.delete),
                                color: PrimaryColor,
                                onPressed: () {
                                  print(cartList[index].id);
                                  sqlite_helper()
                                      .deleteProductsById(cartList[index].id);
                                  Utils.showSuccess(context, "item deleted");
                                  sqlite_helper().getcart1().then((value) {
                                    setState(() {
                                      cartList.clear();
                                      cartList = value;
                                    });
                                  });
                                  sqlite_helper().gettotal().then((value){
                                    setState(() {
                                      overallTotalPrice=value[0]["SUM(totalPrice)"];
                                      overallTotalPricewitOoutTax=value[0]["SUM(totalPrice)"];
                                      var taxes=orderTaxes.where((element) => element.takeAway);
                                      if(taxes!=null&&taxes.length>0) {
                                        for (var t in taxes.toList()) {
                                          if(t.price!=null&&t.price!=0.0){
                                            overallTotalPrice=overallTotalPrice+t.price;
                                          }else if(t.percentage!=null&&t.percentage!=0.0){
                                            var percentTax=t.percentage/100*overallTotalPrice;
                                            print("Percent Tax "+percentTax.toString());
                                            overallTotalPrice=overallTotalPrice+percentTax;
                                          }
                                        }
                                      }

                                    });
                                  });
                                }),
                            IconButton(
                                icon: Icon(Icons.edit),
                                color: PrimaryColor,
                                onPressed: () {
                                  print(cartList[index].id.toString());
                                  sqlite_helper()
                                      .checkIfAlreadyExists(cartList[index].id)
                                      .then((cartitem) {
                                    // if(cartList[index].isDeal ==0) {
                                    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UpdateDetails(
                                    //     pId: cartitem[0]['id'],
                                    //     productId: cartitem[0]['productId'],
                                    //     name: cartitem[0]['productName'],
                                    //     sizeId: cartitem[0]['sizeId'],
                                    //     //baseSelection: cartitem[0]['baseSelection'],
                                    //     productPrice: cartitem[0]['price'],
                                    //     quantity: cartitem[0]['quantity'],
                                    //
                                    //     storeId: cartList[0].storeId,
                                    //     //baseSelectionName: cartitem[0]['baseSelectionName'],
                                    //   ),));
                                    //   print(cartitem[0]);
                                    // }else{
                                    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UpdateCartDeals(
                                    //     cartitem[0]['id'], cartitem[0]['productId'], cartitem[0]['productName'],
                                    //     cartitem[0]['price'],cartList[0].storeId,
                                    //   ),));
                                    //
                                    //
                                    // }
                                  });
                                }),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            "Size ",
                            style: TextStyle(
                                color: yellowColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          cartList[index].sizeName == null
                              ? ""
                              : "-" + cartList[index].sizeName,
                          style: TextStyle(
                              color: PrimaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            "Additional Toppings",
                            style: TextStyle(
                                color: yellowColor,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Qty: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: yellowColor,
                              ),
                            ),
                            //SizedBox(width: 10,),
                            Text(
                              cartList[index].quantity.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: PrimaryColor,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 35),
                      child: Text(
                        topping != null
                            ? topping
                                .toString()
                                .replaceAll("[", "- ")
                                .replaceAll(",", "- ")
                                .replaceAll("]", "")
                            :"-",
                        style: TextStyle(
                          color: PrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              "Price",
                              style: TextStyle(
                                  color: yellowColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              // FaIcon(FontAwesomeIcons.dollarSign,
                              //   color: Colors.amberAccent, size: 20,),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                cartList[index].totalPrice != null
                                    ? cartList[index]
                                        .totalPrice
                                        .toStringAsFixed(2)
                                    : "",
                                style: TextStyle(
                                    color: PrimaryColor,
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  //Popup's
  Widget dealsPopupLayout(dynamic deal) {
    var count = 1;
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
      body: StatefulBuilder(builder: (thisLowerContext, innerSetState) {
        if (deal != null) {
          innerSetState(() {
            price = deal["price"];
            actualPrice = deal["actualPrice"];
            print("Actual Deal Price $actualPrice");
          });
        }
        return Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 1.25,
            width: MediaQuery.of(context).size.width / 2.7,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                  image: AssetImage('assets/bb.jpg'),
                )),
            child: Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6)),
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(deal["image"]))),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0, right: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 40,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ),
                      ),
                    )),
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
                                  "Discounted Price: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: yellowColor),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Rs: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: yellowColor),
                                    ),
                                    Text(
                                      updatedPrice.toString() == "0.0"
                                          ? price.toString()
                                          : updatedPrice.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
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
                                  "Actual Price: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: yellowColor),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Rs: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: yellowColor),
                                    ),
                                    Text(
                                     updatedActualPrice.toString()=="0.0"? actualPrice.toString():updatedActualPrice.toString(),
                                      style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
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
                        "Products",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: yellowColor,
                            fontSize: 28),
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
                              "Quantity: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
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
                  height: 15,
                ),
                InkWell(
                  onTap: () {
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
                            storeId: deal["storeId"],
                            topping: null);
                        sqlite_helper().updateCart(tempDeals).then((updatedEntries){
                          sqlite_helper().getcart1().then((value) {
                            setState(() {
                              cartList.clear();
                              cartList = value;
                              if (cartList.length > 0) {
                                print(cartList.toString());
                              }
                            });
                          });
                          sqlite_helper().gettotal().then((value){
                            setState(() {
                              overallTotalPrice=value[0]["SUM(totalPrice)"];
                              overallTotalPricewitOoutTax=value[0]["SUM(totalPrice)"];
                              var taxes=orderTaxes.where((element) => element.takeAway);
                              if(taxes!=null&&taxes.length>0) {
                                for (var t in taxes.toList()) {
                                  if(t.price!=null&&t.price!=0.0){
                                    overallTotalPrice=overallTotalPrice+t.price;
                                  }else if(t.percentage!=null&&t.percentage!=0.0){
                                    var percentTax=t.percentage/100*overallTotalPrice;
                                    overallTotalPrice=overallTotalPrice+percentTax;
                                  }
                                }
                              }

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
                            storeId: deal["storeId"],
                            topping: null))
                            .then((isInserted) {
                          if (isInserted > 0) {
                            innerSetState(() {

                              sqlite_helper().getcart1().then((value) {
                                setState(() {
                                  cartList.clear();
                                  cartList = value;
                                  if (cartList.length > 0) {
                                    print(cartList.toString());
                                  }
                                });
                              });
                              sqlite_helper().gettotal().then((value){
                                setState(() {
                                  overallTotalPrice=value[0]["SUM(totalPrice)"];
                                  overallTotalPricewitOoutTax=value[0]["SUM(totalPrice)"];
                                  var taxes=orderTaxes.where((element) => element.takeAway);
                                  if(taxes!=null&&taxes.length>0) {
                                    for (var t in taxes.toList()) {
                                      if(t.price!=null&&t.price!=0.0){
                                        overallTotalPrice=overallTotalPrice+t.price;
                                      }else if(t.percentage!=null&&t.percentage!=0.0){
                                        var percentTax=t.percentage/100*overallTotalPrice;
                                        overallTotalPrice=overallTotalPrice+percentTax;
                                      }
                                    }
                                  }

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
                          "Add To Cart",
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

  Widget finalizingOrderPopUp(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
              image: AssetImage('assets/bb.jpg'),
            )
        ),
        height:MediaQuery.of(context).size.height -200,
        width: MediaQuery.of(context).size.width / 3,
        child: Column(

          children: [
            Container(
              width:
              MediaQuery.of(context).size.width,
              height: 50,
              color: yellowColor,
              child: Center(
                child: Text(
                  "Order Summary",
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ///Order Type
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Order Type",

                  alignLabelWithHint: true,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                  enabledBorder: OutlineInputBorder(
                  ),
                  focusedBorder:  OutlineInputBorder(
                    borderSide: BorderSide(color:yellowColor),
                  ),
                ),

                value: orderType,
                onChanged: (Value) {
                  setState(() {
                    orderType = Value;
                    orderTypeId = orderTypeList.indexOf(orderType)+1;
                    print(orderTypeId);
                  });
                  //taxList.clear();
                  // networksOperation.getTaxListByStoreIdWithOrderType(context, widget.storeId, orderType=="Dine In"?1:orderType=="Take Away"?2:orderType=="Delivery"?3:0).then((value) {
                  //   setState(() {
                  //     taxList = value;
                  //     print(taxList.toString()+"mnbvcxz");
                  //     totalPercentage=0.0;
                  //     totalTaxPrice =0.0;
                  //     orderTaxList.clear();
                  //     for(int i=0;i<taxList.length;i++){
                  //       totalTaxPrice += taxList[i].price;
                  //       totalPercentage += taxList[i].percentage;
                  //       orderTaxList.add({
                  //         "TaxId": taxList[i].id
                  //       });
                  //     }
                  //     print(orderTaxList.toString());
                  //   });
                  // });
                },
                items: orderTypeList.map((value) {
                  return  DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: <Widget>[
                        Text(
                          value,
                          style:  TextStyle(color: yellowColor,fontSize: 13),
                        ),
                        //user.icon,
                        //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            ///Set Tables & Chairs
            // Visibility(
            //   visible: orderType=="Dine In",
            //   child: Card(
            //     elevation: 5,
            //     //color: Colors.white24,
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color:BackgroundColor,
            //           borderRadius: BorderRadius.circular(9),
            //           border: Border.all(color: yellowColor, width: 2)
            //       ),
            //       width: MediaQuery.of(context).size.width*0.98,
            //       padding: EdgeInsets.all(14),
            //       child: DropdownButtonFormField<String>(
            //         decoration: InputDecoration(
            //           labelText: " Tables ",
            //
            //           alignLabelWithHint: true,
            //           labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: yellowColor),
            //           enabledBorder: OutlineInputBorder(
            //             // borderSide: BorderSide(color:
            //             // Colors.white),
            //           ),
            //           focusedBorder:  OutlineInputBorder(
            //             borderSide: BorderSide(color:
            //             yellowColor),
            //           ),
            //         ),
            //
            //         // hint:  Text(translate('add_to_cart_screen.sauce')),
            //         value: tableName,
            //         // onSaved:(Value){
            //         //     orderType = Value;
            //         //     orderTypeId = orderTypeList.indexOf(orderTypeId);
            //         // },
            //         onChanged: (Value) {
            //           setState(() {
            //             tableName = Value;
            //             tableId = tableDDList.indexOf(tableName);
            //           });
            //           networksOperation.getChairsListByTable(context, allTableList[tableId]['id']).then((value) {
            //
            //             if(value!=null){
            //               countList.clear();
            //               allChairList.clear();
            //               for(int i=0;i<value.length;i++){
            //                 countList.add(value[i]['name']);
            //                 allChairList.add(value[i]);
            //
            //               }
            //             }else{
            //
            //             }
            //
            //           });
            //         },
            //         items: tableDDList.map((value) {
            //           return  DropdownMenuItem<String>(
            //             value: value,
            //             child: Row(
            //               children: <Widget>[
            //                 Text(
            //                   value,
            //                   style:  TextStyle(color: yellowColor,fontSize: 15, fontWeight: FontWeight.bold),
            //                 ),
            //                 //user.icon,
            //                 //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
            //               ],
            //             ),
            //           );
            //         }).toList(),
            //       ),
            //     ),
            //   ),
            // ),
            // Visibility(
            //   visible:   countList.length>0 && orderType =="Dine In",
            //   child: Card(
            //     elevation: 5,
            //     color: BackgroundColor,
            //     child: InkWell(
            //       onTap: () async{
            //         _openFilterDialog();
            //       },
            //       child: InputDecorator(
            //         decoration: InputDecoration(
            //           contentPadding: EdgeInsets.all(25),
            //           filled: true,
            //           errorMaxLines: 4,
            //         ),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: <Widget>[
            //             Row(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: <Widget>[
            //                 Expanded(
            //                     child: Text(
            //                       'Select Chairs For Order',
            //                       style: TextStyle(fontSize: 15.0, color:yellowColor,fontWeight: FontWeight.bold),
            //                     )),
            //                 Icon(
            //                   Icons.arrow_drop_down,
            //                   color: Colors.black87,
            //                   size: 25.0,
            //                 ),
            //               ],
            //             ),
            //             orderSelectedChairsList != null && orderSelectedChairsList.length > 0
            //                 ? Wrap(
            //               spacing: 8.0,
            //               runSpacing: 0.0,
            //               children: chairChips,
            //             )
            //                 : new Container(
            //               padding: EdgeInsets.only(top: 4),
            //               child: Text(
            //                 'No Chairs selected',
            //                 style: TextStyle(
            //                   fontSize: 16,
            //                   color: PrimaryColor,
            //                 ),
            //               ),
            //             )
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            ///Adding Voucher
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                          width: 170,
                          child: TextField(
                            controller: applyVoucher,
                            style: TextStyle(color: yellowColor),
                            decoration: InputDecoration(
                              hintText: "Voucher Code",hintStyle: TextStyle(color: yellowColor),
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            //FaIcon(FontAwesomeIcons.dollarSign, color: Colors.amberAccent, size: 30,),
                            InkWell(
                              // onTap: () {
                              //   print(applyVoucher.text);
                              //
                              //   voucherValidity =null;
                              //   networksOperation.checkVoucherValidity(context, applyVoucher.text, totalprice).then((value){
                              //     setState(() {
                              //       applyVoucher.text="";
                              //       voucherValidity = value;
                              //       voucherVisiblity =true;
                              //
                              //     });
                              //   });
                              //   print(voucherVisiblity);
                              // },
                              child: Container(
                                // width: 70,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: yellowColor,
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text("Apply Voucher", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                    ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            ///Picking Time
            // Visibility(
            //   visible: orderType =="Take Away",
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: FormBuilderDateTimePicker(
            //         name: "Estimate Picking time",
            //         style: Theme.of(context).textTheme.bodyText1,
            //         inputType: InputType.time,
            //         validator: FormBuilderValidators.compose( [FormBuilderValidators.required(context)]),
            //         format: DateFormat("hh:mm:ss"),
            //         decoration: InputDecoration(labelText: "Estimate Picking time",labelStyle: TextStyle(color: yellowColor, fontWeight: FontWeight.bold),
            //           border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(9.0),
            //               borderSide: BorderSide(color: yellowColor, width: 2.0)
            //           ),),
            //         onChanged: (value){
            //           setState(() {
            //             this.pickingTime=value;
            //           });
            //         },
            //       ),
            //     ),
            //   ),
            // ),

            ///Payment Method
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //       decoration: BoxDecoration(
            //           color:BackgroundColor,
            //           borderRadius: BorderRadius.circular(9),
            //           border: Border.all(color: yellowColor, width: 2)
            //       ),
            //       child: Column(
            //         children: [
            //           Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: Text('Payment Method',style: TextStyle(color: yellowColor,fontSize: 20,fontWeight: FontWeight.bold),),
            //           ),
            //           Container(
            //             width: MediaQuery.of(context).size.width,
            //             height: 1,
            //             color: yellowColor,
            //           ),
            //
            //           _myRadioButton(
            //             title: orderType=="Dine In"?"Cash ":orderType=="Take Away"?"Cash on Picking ":"Cash On Delivery",
            //             value: 1,
            //             onChanged: (newValue) => setState(() => _groupValue = newValue,
            //             ),
            //           ),
            //           _myRadioButton(
            //               title: "Credit Card",
            //               value: 2,
            //               //  onChanged: (newValue) => setState(() => _groupValue = newValue,
            //               // ),
            //               onChanged: (value)async{
            //                 setState(() async{
            //                   _groupValue = value;
            //
            //                   cardData = await Navigator.push(context, MaterialPageRoute(builder: (context) =>  CardPayment() ));
            //                 });
            //               }
            //           ),
            //         ],
            //       )
            //   ),
            // ),
            SizedBox(height: 10,)
            ///Submit Button
            // InkWell(
            //   onTap: (){
            //     if(orderType == "Dine In" ){
            //       if(tableId==null || tableId.isNaN){
            //         Utils.showError(context, "Please Select Table");
            //       }
            //       else if(_groupValue==2 && cardData==null){
            //         Utils.showError(context, "Please Add Debit / Credit Card");
            //       }
            //       else if(dailySession==null){
            //         Utils.showError(context, "Restaurant can't Accept Order This Time");
            //       }
            //       else{
            //         print("print 1");
            //         var body= Order.OrderToJson(Order(
            //             dailySessionNo: 1,
            //             storeId: widget.storeId,
            //             grosstotal: widget.netTotal,
            //             comment: widget.notes,
            //             netTotal: widget.netTotal,
            //             DeviceToken: deviceId,
            //             deliveryAddress: null,
            //             deliveryLatitude: null,
            //             deliveryLongitude: null,
            //             paymentType: _groupValue,
            //             paymentOptions: 1,
            //             ordertype: 1,
            //             TableId: tableId!=null?allTableList[tableId]['id']:null,
            //             //orderitems: orderitem,//orderItems1!=null?orderItems1:orderitem,
            //             orderChairs: orderSelectedChairsListIds,
            //             orderPayments: selectedChairListForPayment//selectedChairListForPayment
            //         ));
            //         dynamic order = {
            //
            //           // "date":DateFormat("dd:mm:yyyy").format(DateTime.now()),
            //           // "StartTime":DateFormat("HH:mm:ss").format(DateTime.now()),
            //           "DineInEndTime":DateFormat("HH:mm:ss").format(DateTime.now().add(Duration(hours: 1))),
            //           "DailySessionNo": dailySession,
            //           "storeId":widget.storeId,
            //           "DeviceToken":deviceId,
            //           "ordertype": 1,
            //           "NetTotal":widget.netTotal,
            //           //"grosstotal":widget.netTotal,
            //           "comment":widget.notes,
            //           "TableId":tableId!=null?allTableList[tableId]['id']:null,
            //           "DeliveryAddress" : null,
            //           "DeliveryLongitude" : null,
            //           "DeliveryLatitude" : null,
            //           "PaymentType" : _groupValue,
            //           "PaymentOptions": 1,
            //           "orderitems":widget.orderItems,
            //           "OrderChairs": orderSelectedChairsListIds,
            //           //  "OrderPayments": selectedChairListForPayment,
            //           "CardNumber": cardData!=null?cardData['CardNumber']:null,
            //           "CVV": cardData!=null?cardData['CVV']:null,
            //           "ExpiryDate": cardData!=null?cardData['ExpiryDate']:null,
            //           "OrderTaxes":orderTaxList,
            //           "VoucherCode": widget.voucher,
            //           // "MobileNo": "03123456789",
            //           // "CnicLast6Digits": "345678"
            //
            //         };
            //         print(jsonEncode(order));
            //         networksOperation.placeOrder(context, widget.token, order).then((value) {
            //           if(value){
            //             // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ClientNavBar()));
            //             Navigator.pushAndRemoveUntil(context,
            //                 MaterialPageRoute(builder: (context) =>ClientNavBar()), (
            //                     Route<dynamic> route) => false);
            //           }
            //         });
            //       }
            //
            //     }
            //     else if( orderType =="Delivery"){
            //       if(userDetail['latitude']==null && userDetail['longitude']==null && address ==null){
            //         Utils.showError(context, "please select Secondary address");
            //       } else if(dailySession==null){
            //         Utils.showError(context, "Restaurant can't Accept Order This Time");
            //       }
            //       // else if(_groupValue==2){
            //       //   cardData==null??Utils.showError(context, "Please Add Debit / Credit Card");
            //       // }
            //       else {
            //         print("print 3");
            //         dynamic order = {
            //           "DailySessionNo": dailySession,
            //           "StoreId":widget.storeId,
            //           "DeviceToken":deviceId,
            //           "ordertype":3,
            //           "NetTotal":widget.netTotal,
            //           //  "grosstotal":widget.netTotal,
            //           "comment":widget.notes!=null?widget.notes:null,
            //           "TableId":null,
            //           "DeliveryAddress" : secondryAddress.text!=null?secondryAddress.text:address.toString()!=null?address.address:null,
            //           "DeliveryLongitude" : address.longitude==null?userDetail['longitude']!=null?userDetail['longitude']:address.toString()!=null?address.longitude:0.0:0.0,
            //           "DeliveryLatitude" : address.latitude==null?userDetail['latitude']!=null?userDetail['latitude']:address.toString()!=null?address.latitude:0.0:0.0,
            //           "PaymentType" : _groupValue,
            //           "orderitems":widget.orderItems,
            //           "CardNumber": cardData!=null?cardData['CardNumber']:null,
            //           "CVV": cardData!=null?cardData['CVV']:null,
            //           "ExpiryDate": cardData!=null?cardData['ExpiryDate']:null,
            //           "OrderTaxes":orderTaxList,
            //           "VoucherCode": widget.voucher,
            //           // "MobileNo": "03123456789",
            //           // "CnicLast6Digits": "345678"
            //         };
            //         print(jsonEncode(order));
            //         networksOperation.placeOrder(context, widget.token, order).then((value) {
            //           if(value){
            //             Navigator.pushAndRemoveUntil(context,
            //                 MaterialPageRoute(builder: (context) => ClientNavBar()), (
            //                     Route<dynamic> route) => false);
            //             //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ClientNavBar()));
            //
            //           }
            //         });
            //       }
            //     }else if( orderType =="Take Away"){
            //       if(_groupValue==2 && cardData==null){
            //         Utils.showError(context, "Please Add Debit / Credit Card");
            //       }else if(dailySession==null){
            //         Utils.showError(context, "Restaurant can't Accept Order This Time");
            //       }else if(pickingTime==null){
            //         Utils.showError(context, "Please Enter Picking Time");
            //       }
            //       else{
            //         print("print 2");
            //         dynamic order = {
            //           "DailySessionNo": dailySession,
            //           "storeId":widget.storeId,
            //           "DeviceToken":deviceId,
            //           "ordertype":2,
            //           "NetTotal":widget.netTotal,
            //           //  "grosstotal":widget.netTotal,
            //           "comment":widget.notes,
            //           "TableId":null,
            //           "DeliveryAddress" : null,
            //           "DeliveryLongitude" : null,
            //           "DeliveryLatitude" : null,
            //           "PaymentType" : _groupValue,
            //           "orderitems":widget.orderItems,
            //           "CardNumber": cardData!=null?cardData['CardNumber']:null,
            //           "CVV": cardData!=null?cardData['CVV']:null,
            //           "ExpiryDate": cardData!=null?cardData['ExpiryDate']:null,
            //           "EstimatedTakeAwayTime": pickingTime.toString().substring(10,16),
            //           "OrderTaxes":orderTaxList,
            //           "VoucherCode": widget.voucher,
            //           // "MobileNo": "03123456789",
            //           // "CnicLast6Digits": "345678"
            //         };
            //         print(jsonEncode(order));
            //         networksOperation.placeOrder(context, widget.token, order).then((value) {
            //           if(value){
            //             // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ClientNavBar()));
            //             Navigator.pushAndRemoveUntil(context,
            //                 MaterialPageRoute(builder: (context) => ClientNavBar()), (
            //                     Route<dynamic> route) => false);
            //           }
            //         });
            //       }
            //
            //     }
            //     else{
            //       Utils.showError(context, "Please select Order Type");
            //     }
            //
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.all(Radius.circular(10)) ,
            //         color: yellowColor,
            //       ),
            //       width: MediaQuery.of(context).size.width,
            //       height: MediaQuery.of(context).size.height  * 0.08,
            //
            //       child: Center(
            //         child: Text('Submit Order',style: TextStyle(color: BackgroundColor,fontSize: 20,fontWeight: FontWeight.bold),),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      )
    );
  }


  var productPopupHeight=3.5;
  Widget productsPopupLayout(Products product) {
    var count = 1;
    var price=0.0;
    var discountedPrice=0.0;
    var updatedActualPrice=0.0;
    var selectedSizeObj;
    var updatedPrice=0.0;
    int selectedSizeId=0;
    String selectedSizeName="";
    List<Additionals> additionals = [];
    List<Toppings> topping = [];
    int quantity = 1;
    bool isvisible = false;
    List<int> _counter = List();
    StreamController _event = StreamController<int>.broadcast();
    List<bool> inputs = new List<bool>();
    for (int i = 0; i < 20; i++) {
      inputs.add(false);
    }
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context, innersetState) {
          selectedSizeId=product.productSizes[0]["size"]["id"];
          selectedSizeName=product.productSizes[0]["size"]["name"];
          selectedSizeObj=product.productSizes[0];
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.getAdditionals(context, prefs.getString("token"), product.id, product.productSizes[0]["size"]["id"]).then((value){
              innersetState(() {
                additionals=value;
                if(additionals.length>0){
                  innersetState(() {
                    isvisible=true;
                    productPopupHeight=1.20;
                  });
                }else
                  innersetState(() {
                    isvisible=false;
                    productPopupHeight=2.80;
                  });
              });
            });
          });
          innersetState(() {
            price=product.productSizes[0]["price"];
            discountedPrice=product.productSizes[0]["discountedPrice"];
          });
          void ItemChange(bool val, int index) {
            innersetState(() {
              inputs[index] = val;
              if(!val) {
                print("Discounted Price ${discountedPrice}");
                var uncheckedTopping = topping.where((element) =>
                element.additionalitemid == additionals[index].id);
                if (uncheckedTopping != null && uncheckedTopping.length > 0) {
                  if(updatedPrice==0.0){
                    if(discountedPrice!=0.0){
                      updatedPrice=updatedPrice+discountedPrice-uncheckedTopping.toList()[0].totalprice;
                      updatedActualPrice=updatedActualPrice+price-uncheckedTopping.toList()[0].totalprice;
                    }
                    updatedPrice=updatedPrice+price-uncheckedTopping.toList()[0].totalprice;
              }else{
                  updatedPrice=updatedPrice-uncheckedTopping.toList()[0].totalprice;
              }
                  topping.remove(uncheckedTopping.toList()[0]);

                }
              }
            });
          }
          void ItemCount(int qty, int index) {
            innersetState(() {

              _counter[index] = qty;
              _event.add(_counter[index]);
            });
          }
          int _showDialog(int val, int index ) {
            showDialog<int>(
                context: context,
                builder: (BuildContext context) {
                  return  NumberPickerDialog.integer(
                    initialIntegerValue: quantity,
                    minValue: 0,
                    maxValue: 10,

                    title: new Text("Select Quantity"),
                  );
                }
            ).then((int value){
              if(value !=null) {
                innersetState(() {

                  ItemCount(value, index);
                  print(value.toString());
                  var a;
                  if(inputs[index] ){
                    a = _counter[index] * additionals[index].price;
                    print(a.toString());
                    topping.add( Toppings(name: additionals[index].name,quantity: _counter[index],totalprice: a,price: additionals[index].price,additionalitemid: additionals[index].id));
                    if(updatedPrice==0.0){
                      if(selectedSizeObj["discountedPrice"]!=0.0){
                        updatedPrice = updatedPrice + selectedSizeObj["discountedPrice"] + a;
                        updatedActualPrice=updatedActualPrice+price+a;
                      }else {
                        updatedPrice = updatedPrice + price + a;
                      }
                    }else{
                      updatedPrice=updatedPrice+a;
                      updatedActualPrice=updatedActualPrice+a;
                    }
                  }else if(!inputs[index]){
                    topping.removeAt(index);
                  }
                });
                //setState(() => quantity = value);
                print(_counter[index].toString());
                return _counter[index];
              }
            });
          }
          return Center(
              child: Container(
                  height: MediaQuery.of(context).size.height / productPopupHeight,
                  width: MediaQuery.of(context).size.width / 3.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                        image: AssetImage('assets/bb.jpg'),
                      )
                  ),
                child:Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 40,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:16.0,left:16,right:16),
                      child: DropdownButtonFormField<dynamic>(
                        decoration: InputDecoration(
                          labelText: "Select Size",
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                          enabledBorder: OutlineInputBorder(
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color:yellowColor),
                          ),
                        ),

                        value: product.productSizes[0]["size"]["name"],
                        onChanged: (value) {
                          innersetState(() {
                         var selectedSize= product.productSizes.where((element) => element["size"]["name"]==value.toString());
                           selectedSizeId=selectedSize.toList()[0]["size"]["id"];
                         selectedSizeName=selectedSize.toList()[0]["size"]["name"];
                         selectedSizeObj=selectedSize.toList()[0];
                          updatedPrice=selectedSize.toList()[0]["price"];
                           price=selectedSize.toList()[0]["price"];
                           if(selectedSizeObj["discountedPrice"]!=0.0) {
                             updatedPrice = selectedSize.toList()[0]["discountedPrice"];
                             discountedPrice=selectedSize.toList()[0]["discountedPrice"];
                             updatedActualPrice=selectedSize.toList()[0]["price"];
                           }

                         if(selectedSizeId!=0){
                           SharedPreferences.getInstance().then((prefs){
                             Network_Operations.getAdditionals(context, prefs.getString("token"), product.id, selectedSizeId).then((value){
                               innersetState(() {
                                 var totalToppingPrice=0.0;
                                 for(var t in topping){
                                   totalToppingPrice=totalToppingPrice+t.totalprice;
                                 }
                                 topping.clear();
                                 _counter.clear();
                                 additionals.clear();
                                 additionals=value;
                               });
                             });
                           });
                         }
                           //updatedPrice=selectedSizeId=selectedSize.toList()[0]["price"];
                            // priority = Value;
                            // priorityId = priorityList.indexOf(priority);
                          });
                        },
                        items: product.productSizes.map((value) {
                          return  DropdownMenuItem<String>(
                            value: value["size"]["name"],
                            child: Row(
                              children: <Widget>[
                                Text(
                                  value["size"]["name"].toString(),
                                  style:  TextStyle(color: yellowColor,fontSize: 13),
                                ),
                                //user.icon,
                                //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text("Quantity",
                      style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 20
                      ),
                      ),
                      trailing: Counter(
                        color: yellowColor,
                        initialValue: count,
                        maxValue: 10,
                        minValue: 1,
                        step: 1,
                        decimalPlaces: 0,
                        onChanged: (value){
                          innersetState(() {
                            count=value;
                            updatedPrice=0.0;
                            if(topping.length==0) {
                              if(selectedSizeObj["discountedPrice"]!=0.0){
                                updatedPrice = selectedSizeObj["discountedPrice"] * count;
                                updatedActualPrice=selectedSizeObj["price"]*count;
                              }else{
                                updatedPrice = price * count;
                              }
                            }else{
                              var totalToppingPrice=0.0;
                              for(var t in topping){
                                totalToppingPrice=totalToppingPrice+t.totalprice;
                              }
                              if(selectedSizeObj["discountedPrice"]!=0.0){
                                updatedPrice = discountedPrice * count+totalToppingPrice;
                                updatedActualPrice= price * count+totalToppingPrice;
                              }else {
                                updatedPrice = price * count + totalToppingPrice;
                              }
                            }
                          });
                        },
                      ),
                    ),
                    Visibility(
                      visible: isvisible,
                      child: Expanded(
                        child: ListView.builder(
                            itemCount: additionals.length!=null?additionals.length:0,
                            itemBuilder: (BuildContext context, int index) {
                              if (_counter.length < additionals.length) {
                                _counter.add(0);
                              }
                              return Card(
                                elevation: 8,
                                child: new Container(
                                  decoration: BoxDecoration(
                                      color: BackgroundColor,
                                      // borderRadius: BorderRadius.only(
                                      //   bottomRight: Radius.circular(15),
                                      //   topLeft: Radius.circular(15),
                                      // ),
                                      border: Border.all(color: yellowColor, width: 1)
                                  ),
                                  padding: new EdgeInsets.all(10.0),
                                  child: new Column(
                                    children: <Widget>[
                                      new CheckboxListTile(
                                          value: inputs[index],
                                          title: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              new Text(additionals[index].name +
                                                  "  \$" +
                                                  additionals[index].price.toString(),style: TextStyle(color: yellowColor, fontSize: 17, fontWeight: FontWeight.bold),),
                                              Container(
                                                //color: Colors.black12,
                                                height: 30,

                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Text("x"+_counter[index].toString(),style: TextStyle(color: PrimaryColor, fontSize: 17, fontWeight: FontWeight.bold),),
                                                    SizedBox(width: 10,),
                                                    SizedBox(
                                                      width: 25,
                                                      height: 25,
                                                      child: FloatingActionButton(
                                                        onPressed: () {
                                                          if(inputs[index]) {
                                                            _showDialog(quantity, index);
                                                          }
                                                        },
                                                        elevation: 2,
                                                        heroTag: "qwe$index",
                                                        tooltip: 'Add',
                                                        child: Icon(Icons.add, color: Colors.white,),
                                                        backgroundColor: yellowColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          controlAffinity: ListTileControlAffinity.leading,
                                          onChanged: (bool val) {
                                            ItemChange(val, index);
                                            print(inputs[index].toString() +
                                                index.toString());
                                            innersetState(() {
                                              if(!inputs[index]){
                                                _counter[index] = 0;
                                              }
                                            });
                                          })
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                    selectedSizeObj["discountedPrice"]==0.0?
                    Center(
                        child: Text(
                          "Price:  ${updatedPrice==0.0?price.toString():updatedPrice.toString()}",
                          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color:blueColor),)
                      ):Center(
                         child: RichText(
                           textAlign: TextAlign.center,
                           text: (
                            TextSpan(
                              text: "Price",
                              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color:yellowColor),
                              children: [
                                 TextSpan(
                                   text: "  ${updatedActualPrice==0.0?price.toString():updatedActualPrice.toString()}",
                                   style: TextStyle(
                                       fontSize: 30,
                                       fontWeight: FontWeight.bold,
                                       color:blueColor,
                                       decoration: TextDecoration.lineThrough,
                                   ),
                                 ),
                                TextSpan(
                                  text: "  ${updatedPrice==0.0?discountedPrice.toString():updatedPrice.toString()}",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color:blueColor,
                                  ),
                                ),
                              ]
                            )
                           ),
                         ),
                      ),
                    SizedBox(height: 1,),
                    InkWell(
                      onTap: () {
                        sqlite_helper().checkAlreadyExists(product.id).then((foundProducts){
                          if(foundProducts.length>0){
                            var tempCartItem =CartItems(
                                id: foundProducts[0]["id"],
                                productId: product.id,
                                productName: product.name,
                                isDeal: 1,
                                dealId: null,
                                sizeId: selectedSizeId,
                                sizeName: selectedSizeName,
                                price: updatedPrice,
                                totalPrice:selectedSizeObj["discountedPrice"]==0.0&&updatedPrice == 0.0 ? price:selectedSizeObj["discountedPrice"]!=0.0&&updatedPrice == 0.0?selectedSizeObj["discountedPrice"] : updatedPrice,
                                quantity: count,
                                storeId: product.storeId,
                                topping: topping.length>0?jsonEncode(topping):null
                            );
                            sqlite_helper().updateCart(tempCartItem).then((value){
                              sqlite_helper().getcart1().then((value) {
                                setState(() {
                                  cartList.clear();
                                  cartList = value;
                                  sqlite_helper().gettotal().then((value){
                                    setState(() {
                                      overallTotalPrice=value[0]["SUM(totalPrice)"];
                                      overallTotalPricewitOoutTax=value[0]["SUM(totalPrice)"];
                                      var taxes=orderTaxes.where((element) => element.takeAway);
                                      if(taxes!=null&&taxes.length>0) {
                                        for (var t in taxes.toList()) {
                                          if(t.price!=null&&t.price!=0.0){
                                            overallTotalPrice=overallTotalPrice+t.price;
                                          }else if(t.percentage!=null&&t.percentage!=0.0){
                                            var percentTax=t.percentage/100*overallTotalPrice;
                                            overallTotalPrice=overallTotalPrice+percentTax;
                                          }
                                        }
                                      }

                                    });
                                  });
                                });
                              });
                            });
                            Navigator.of(context).pop();
                            Utils.showSuccess(context, "Updated to Cart successfully");
                          }else{
                            sqlite_helper()
                                .create_cart(CartItems(
                                productId: product.id,
                                productName: product.name,
                                isDeal: 1,
                                dealId: null,
                                sizeId: selectedSizeId,
                                sizeName: selectedSizeName,
                                price: updatedPrice,
                                totalPrice:selectedSizeObj["discountedPrice"]==0.0&&updatedPrice == 0.0 ? price:selectedSizeObj["discountedPrice"]!=0.0&&updatedPrice == 0.0?selectedSizeObj["discountedPrice"] : updatedPrice,
                                quantity: count,
                                storeId: product.storeId,
                                topping: topping.length>0?jsonEncode(topping):null))
                                .then((isInserted) {
                              if (isInserted > 0) {
                                innersetState(() {
                                  sqlite_helper().getcart1().then((value) {
                                    setState(() {
                                      cartList.clear();
                                      cartList = value;
                                      sqlite_helper().gettotal().then((value){
                                        setState(() {
                                          overallTotalPrice=value[0]["SUM(totalPrice)"];
                                          overallTotalPricewitOoutTax=value[0]["SUM(totalPrice)"];
                                          var taxes=orderTaxes.where((element) => element.takeAway);
                                          if(taxes!=null&&taxes.length>0) {
                                            for (var t in taxes.toList()) {
                                              if(t.price!=null&&t.price!=0.0){
                                                overallTotalPrice=overallTotalPrice+t.price;
                                              }else if(t.percentage!=null&&t.percentage!=0.0){
                                                var percentTax=t.percentage/100*overallTotalPrice;
                                                print("Percent Tax "+percentTax.toString());
                                                overallTotalPrice=overallTotalPrice+percentTax;
                                              }
                                            }
                                          }

                                        });
                                      });
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
                              "Add To Cart",
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
                )
              )
          );
        },
      ),
    );
  }
}

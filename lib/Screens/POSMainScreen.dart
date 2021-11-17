import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:exabistro_pos/Screens/LoadingScreen.dart';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:exabistro_pos/model/CartItems.dart';
import 'package:exabistro_pos/model/Categories.dart';
import 'package:exabistro_pos/model/Orderitems.dart';
import 'package:exabistro_pos/model/Orders.dart';
import 'package:exabistro_pos/model/Products.dart';
import 'package:exabistro_pos/model/orderItemTopping.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:exabistro_pos/networks/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_counter/flutter_counter.dart';
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
  String selectedMenuType;

  List<CartItems> cartList = [];
  Order finalOrder;
  List<Orderitem> orderitem = [];
  List<Orderitemstopping> itemToppingList = [];
  List<Map> orderitem1 = [];

  dynamic ordersList;
  List<dynamic> toppingList = [], orderItems = [];
  List<String> topping = [];
  double totalprice = 0.00, applyVoucherPrice;
  TextEditingController addnotes, applyVoucher;
  String orderType;
  int orderTypeId;
  var voucherValidity;
  List orderTypeList = ["None", "DineIn ", "TakeAway ", "HomeDelivery "];

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
                                    height: 440,
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
                                  height: 60,
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
                                  height: 360,
                                  child: cartListLayout(),
                                ),
                                Container(
                                  color: Colors.white,
                                  width: MediaQuery.of(context).size.width,
                                  height: 340,
                                  child: Column(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 60,
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
                                                                "Discount: ",
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
                                                            "120/- ",
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
                    return dealsPopupLayout(dealsList[index]);
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
              showDialog(context: context, builder:(BuildContext context){
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
                                      if (cartList.length > 0) {
                                        print(cartList.toString());
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
                            : "-",
                        style: TextStyle(
                          color: PrimaryColor,
                          fontSize: 14,
                          //fontWeight: FontWeight.bold
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
    var price = 0.0;
    var updatedPrice = 0.0;
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
                      height: 60,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Price: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: yellowColor),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Rs: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: yellowColor),
                                ),
                                Text(
                                  updatedPrice.toString() == "0.0"
                                      ? price.toString()
                                      : updatedPrice.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: blueColor),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                    sqlite_helper()
                        .create_cart(CartItems(
                            productId: null,
                            productName: deal["name"],
                            isDeal: 1,
                            dealId: deal["id"],
                            sizeId: null,
                            sizeName: null,
                            price: deal["price"],
                            totalPrice:
                                updatedPrice == 0.0 ? price : updatedPrice,
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
                        });
                        Navigator.of(context).pop();
                        Utils.showSuccess(
                            context, "Added to Cart successfully");
                      } else {
                        Navigator.of(context).pop();
                        Utils.showError(context, "Some Error Occur");
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

  Widget productsPopupLayout(Products product) {
    var count = 1;
    var price=0.0;
    var updatedPrice=0.0;
    int selectedSizeId=0;
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context, innersetState) {
          innersetState(() {
            price=product.productSizes[0]["price"];
          });
          return Center(
              child: Container(
                  height: MediaQuery.of(context).size.height / 3.0,
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
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
                         updatedPrice=selectedSize.toList()[0]["price"];
                           price=selectedSize.toList()[0]["price"];
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
                      title: Text("Quantity"),
                      trailing: Counter(
                        initialValue: count,
                        maxValue: 10,
                        minValue: 1,
                        step: 1,
                        decimalPlaces: 0,
                        onChanged: (value){
                          innersetState(() {
                            count=value;
                            updatedPrice=0.0;
                            updatedPrice=price*count;
                          });
                        },
                      ),
                    ),
                    Center(child: Text("Price:  ${updatedPrice==0.0?price.toString():updatedPrice.toString()}",style: TextStyle(fontSize: 30),))
                  ],
                )
              )
          );
        },
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:exabistro_pos/Screens/Mobile/Cart/NewPOSCartScreen.dart';
import 'package:exabistro_pos/model/Additionals.dart';
import 'package:exabistro_pos/model/Toppings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icon_badge/icon_badge.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Utils/constants.dart';

class ProductsScreen extends StatefulWidget {
  var store;
  ProductsScreen({this.store});
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Categories> subCategories = [],categories=[];
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
  List allMenu=[];
  bool selectedCategory = true;
  List<bool> _selected = [];
  PaperSize paper = PaperSize.mm58;
  BluetoothManager bluetoothManager = BluetoothManager.instance;



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
        this.userId=prefs.getString("userId");
        this.discountService=prefs.getString("discountService");
        this.waiveOffService=prefs.getString("waiveOffService");
      });
      Network_Operations.getCategory(context,prefs.getString("token"),widget.store["id"],"")
          .then((sub) {
        if(sub!=null)
          setState(() {
            if (sub != null && sub.length > 0) {
              for(int i = 0;i<sub.length;i++){
                if((int.parse(sub[i].startTime.substring(0,2)) <= TimeOfDay.now().hour ||
                    int.parse(sub[i].endTime.substring(0,2)) >= TimeOfDay.now().hour) &&
                    int.parse(sub[i].startTime.substring(3,5)) <= TimeOfDay.now().minute){
                  categories.add(sub[i]);
                }
              }
              List<String> lst = prefs.getStringList("reorderedcategories${widget.store["id"].toString()}");
              if(lst!=null&&lst.length>0&&categories!=null&&categories.length>0){
                this.subCategories= lst.map(
                      (String indx) => categories
                      .where((Categories item) => int.parse(indx) == item.id)
                      .first,
                ).toList();
                if(categories.length>subCategories.length){
                  int additionalElements=categories.length-subCategories.length;
                  List<Categories> reversedList =  List.from(categories.reversed);

                  for(int i= 0;i<additionalElements;i++){
                    subCategories.add(reversedList[i]);
                  }
                }
              }else{
                subCategories.addAll(categories);
              }
              categoryName = subCategories[0].name;
              Network_Operations.getProduct(
                  context,
                  subCategories[0].id,
                  widget.store["id"],
                  "")
                  .then((p) {
                setState(() {
                  if (p != null && p.length > 0) {
                    isLoading = false;
                    List<String> lst = prefs.getStringList("reorderedproducts${subCategories[0].id.toString()}");

                    if(lst!=null&&lst.length>0){
                      this.products= lst.map(
                            (String indx) => p
                            .where((Products item) => int.parse(indx) == item.id)
                            .first,
                      ).toList();
                      if(p.length>products.length){
                        int additionalElements=p.length-products.length;
                        List<Products> reversedList =  List.from(p.reversed);

                        for(int i= 0;i<additionalElements;i++){
                          products.add(reversedList[i]);
                        }
                      }
                    }else{
                      products.addAll(p);
                    }
                  } else
                    isLoading = false;
                  setState(() {
                    this.userId=prefs.getString("userId");
                  });
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
                });
              });

            } else {
              isLoading = false;
              Utils.showError(context, "No Categories Found");
            }
          });
      });
    });
    super.initState();
  }
  String getAllMenu(int id){
    String name;
    if(id!=null&&allMenu!=null){
      for(int i=0;i<allMenu.length;i++){
        if(allMenu[i]['id'] == id) {
          //setState(() {
          name = allMenu[i]['name'];
          // price = sizes[i].price;
          // });

        }
      }
      return name!=null?name:"-";
    }else
      return "empty";
  }
  @override
  Widget build(BuildContext context) {

    return
      // isLoading
      //   ? LoadingScreen()
      //   :
    Scaffold(
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
                print('test');
                Navigator.push(context, MaterialPageRoute(builder: (context) =>NewPOSCartScreenForMobile(store:widget.store)));
              },
            ),
            backgroundColor: yellowColor,
            onPressed: (){
              print('test');
              Navigator.push(context, MaterialPageRoute(builder: (context) =>NewPOSCartScreenForMobile(store:widget.store)));
            }
        ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/bb.jpg'),
              )
          ),
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 3,),
                Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    child:  ReorderableListView.builder(
                        onReorder: (oldIndex,newIndex){
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex = newIndex - 1;
                            }
                            final element = subCategories.removeAt(oldIndex);
                            subCategories.insert(newIndex, element);
                            print("reorderedcategories${widget.store["id"].toString()}");
                            SharedPreferences.getInstance().then((prefs){
                              prefs.setStringList("reorderedcategories${widget.store["id"].toString()}", subCategories.map((m) => m.id.toString()).toList());
                            });
                          });
                        },
                        scrollDirection: Axis.horizontal,
                        itemCount:subCategories!=null?subCategories.length:0,
                        itemBuilder: (context, index){
                          return Padding(
                            key: ValueKey(subCategories[index].id),
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: (){
                                Network_Operations.getProduct(
                                    context,
                                    subCategories[index]
                                        .id,
                                    widget.store["id"],
                                    "")
                                    .then((p) {
                                  setState(() {
                                    if (p != null &&
                                        p.length > 0) {
                                      categoryName =
                                          subCategories[index]
                                              .name;
                                      SharedPreferences.getInstance().then((prefs){
                                        List<String> lst = prefs.getStringList("reorderedproducts${subCategories[index].id.toString()}");
                                        products.clear();
                                        if(lst!=null&&lst.length>0){
                                          this.products= lst.map(
                                                (String indx) => p
                                                .where((Products item) => int.parse(indx) == item.id)
                                                .first,
                                          ).toList();
                                          if(p.length>products.length){
                                            int additionalElements=p.length-products.length;
                                            List<Products> reversedList =  List.from(p.reversed);

                                            for(int i= 0;i<additionalElements;i++){
                                              products.add(reversedList[i]);
                                            }
                                          }
                                        }else{
                                          products.addAll(p);
                                        }
                                      });
                                    }
                                  });
                                });
                              },
                              child: Container(
                                width: 150,
                                height: 55,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(subCategories[index]
                                          .image !=
                                          null
                                          ? subCategories[index].image
                                          : "http://anokha.world/images/not-found.png"),
                                      fit: BoxFit.cover,
                                    )),
                                child:  Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child:  Center(
                                    child: AutoSizeText(
                                      subCategories!=null&&subCategories.length>0&&subCategories[index].name!=null?subCategories[index].name:"",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
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
                        })
                ),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  //color: Colors.black38,
                  child: Center(
                    child: _buildChips(),
                  ),
                ),
                Expanded(
                  child: Container(

                      child:  ReorderableGridView.builder(

                          onReorder: (oldIndex,newIndex){
                            setState(() {
                              final element = products.removeAt(oldIndex);
                              products.insert(newIndex, element);
                              int id= subCategories.where((element) => element.name==categoryName).toList()[0].id;
                              print("reorderedproducts${id.toString()}");
                              SharedPreferences.getInstance().then((prefs){
                                prefs.setStringList("reorderedproducts${id.toString()}", products.map((m) => m.id.toString()).toList());
                              });
                            });
                          },
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            //childAspectRatio: 5 / 6,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            //mainAxisExtent: 180
                          ),
                          itemCount: products!=null?products.length:0,
                          itemBuilder: (context, index){
                            return InkWell(
                              key: ValueKey(products[index].id),
                              onTap: (){
                                showDialog(
                                    context: context,
                                    builder:(BuildContext context){
                                      return productsPopupLayout(products[index]);
                                    });
                              },
                              child: Card(
                                elevation: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex:3,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          //height: 130,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8),),
                                              image: DecorationImage(
                                                image: NetworkImage(products[index].image),
                                                fit: BoxFit.cover,
                                              )
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          //height: 35,
                                          color: yellowColor,
                                          child: Center(
                                            child: AutoSizeText(
                                              products[index].name!=null?products[index].name:"",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(

                                                  color: BackgroundColor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold
                                              ),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // AutoSizeText(
                                      //   'Rs: 450.90',
                                      //   style: TextStyle(
                                      //       color: yellowColor,
                                      //       fontSize: 15,
                                      //       fontWeight: FontWeight.bold
                                      //   ),
                                      //   maxLines: 2,
                                      // ),
                                    ],
                                  ),
                                  // height: 250,
                                  // width: 150,
                                ),
                                // child: Container(
                                //   height: 150,
                                //   width: 190,
                                //   decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(8),
                                //       image: DecorationImage(
                                //         image: AssetImage('assets/food11.jpeg'),
                                //         fit: BoxFit.cover,
                                //       )),
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       color: Colors.black38,
                                //       borderRadius: BorderRadius.circular(6),
                                //     ),
                                //     child: Center(
                                //       child: Text(
                                //         "CATEGORY",
                                //         textAlign: TextAlign.center,
                                //         style: TextStyle(
                                //             fontSize: 19,
                                //             color: Colors.white,
                                //             fontWeight: FontWeight.bold),
                                //       ),
                                //     ),
                                //   ),
                                // )

                              ),
                            );
                          })
                  ),
                )
              ],
            ),
          )

      ),
    );


  }
  var productPopupHeight=330.0;
  Widget productsPopupLayout(Products product) {
    print(product.toJson().toString());
    var count = 1;
    var price=0.0;
    var discountedPrice=0.0;
    var updatedActualPrice=0.0;
    var selectedSizeObj;
    var totalprice=0.0;
    int selectedSizeId=0;
    String selectedSizeName="";
    List<Additionals> additionals = [];
    List<Toppings> topping = [];
    bool isvisible = false;
    List<int> _counter = List();
    StreamController _event = StreamController<int>.broadcast();
    selectedSizeId=product.productSizes[0]["size"]["id"];
    selectedSizeName=product.productSizes[0]["size"]["name"];
    selectedSizeObj=product.productSizes[0];
    price=product.productSizes[0]["price"];
    discountedPrice=product.productSizes[0]["discountedPrice"];
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context, innersetState) {

          SharedPreferences.getInstance().then((prefs){
            if(additionals==null||additionals.length==0){
              Network_Operations.getAdditionals(context, prefs.getString("token"), product.id, product.productSizes[0]["size"]["id"]).then((value){
                innersetState(() {
                  additionals=value;
                  if(additionals.length>0){
                    innersetState(() {
                      isvisible=true;
                      productPopupHeight=650.0;
                    });
                  }else
                    innersetState(() {
                      isvisible=false;
                      productPopupHeight=330.0;
                    });
                });


              });
            }

          });
          void ItemCount(int qty, int index) {
            innersetState(() {

              _counter[index] = qty;
              _event.add(_counter[index]);
            });
          }
          return Center(
              child: Container(
                  height: productPopupHeight,
                  width: 400,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                        image: AssetImage('assets/bb.jpg'),
                      )
                  ),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        color: yellowColor,
                        child:  Padding(
                          padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5, top: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              product.allergic_description!=null&&product.allergic_description.isNotEmpty? IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.infoCircle,
                                  size: 35,
                                  color: blueColor,
                                ),
                                onPressed: () {
                                  showDialog(context: context, builder:(BuildContext context){
                                    return AlertDialog(
                                      title:Text(translate("in_app_errors.allergic_description")),
                                      content: Text(product.allergic_description),
                                    );
                                  });
                                },
                              ):Container(),
                              Text(product.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22
                                ),
                              ),
                              IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.times,
                                  size: 35,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:16.0,left:16,right:16),
                        child: DropdownButtonFormField<dynamic>(
                          decoration: InputDecoration(
                            labelText: translate("product_popup.select_size"),
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
                              count=1;
                              price=selectedSize.toList()[0]["price"];
                              if(selectedSizeObj["discountedPrice"]!=0.0) {
                                //updatedPrice = selectedSize.toList()[0]["discountedPrice"];
                                discountedPrice=selectedSize.toList()[0]["discountedPrice"];
                                // updatedActualPrice=selectedSize.toList()[0]["price"];
                              }
                              var totalToppingPrice=0.0;
                              if(selectedSizeId!=0){
                                SharedPreferences.getInstance().then((prefs){
                                  Network_Operations.getAdditionals(context, prefs.getString("token"), product.id, selectedSizeId).then((value){
                                    innersetState(() {
                                      // var totalToppingPrice=0.0;
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
                              if(discountedPrice!=0.0){
                                totalprice = (discountedPrice * count ) + totalToppingPrice;
                                updatedActualPrice=(price * count ) + totalToppingPrice;
                              }else{
                                totalprice = (price * count ) + totalToppingPrice;
                                updatedActualPrice=(price * count ) + totalToppingPrice;
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
                        title: Text(translate("product_popup.quantity"),
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
                              var totalToppingPrice=0.0;
                              for(var t in topping){
                                totalToppingPrice=totalToppingPrice+t.totalprice;
                              }
                              count=value;
                              if(discountedPrice!=0.0){
                                totalprice = (discountedPrice * count ) + totalToppingPrice;
                                updatedActualPrice=(price * count ) + totalToppingPrice;
                              }else{
                                totalprice = (price * count ) + totalToppingPrice;
                                updatedActualPrice=(price * count ) + totalToppingPrice;
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
                                        new ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              new Text( (){
                                                if(_counter[index]!=null&&_counter[index]!=0&&_counter[index]!=1){
                                                  return additionals[index].name +" (${widget.store["currencyCode"].toString()+" "+additionals[index].price.toStringAsFixed(0)})  ${widget.store["currencyCode"].toString()} " +(additionals[index].price*_counter[index]).toStringAsFixed(0);
                                                }
                                                return additionals[index].name +"  ${widget.store["currencyCode"].toString()} "+additionals[index].price.toStringAsFixed(0);
                                              }()
                                                ,style: TextStyle(color: yellowColor, fontSize: 17, fontWeight: FontWeight.bold),),
                                              Container(
                                                //color: Colors.black12,
                                                height: 50,

                                                child: Counter(
                                                  initialValue: _counter[index],
                                                  minValue: 0,
                                                  maxValue: 10,
                                                  decimalPlaces:0,
                                                  color:yellowColor,
                                                  onChanged: (value){
                                                    innersetState(() {

                                                      ItemCount(value, index);
                                                      var a=0.0;
                                                      //a = _counter[index] * additionals[index].price;
                                                      if(value!=0){
                                                        var toppingExists=topping.where((element) => element.additionalitemid==additionals[index].id).toList();
                                                        if(toppingExists!=null&&toppingExists.length>0){
                                                          topping[topping.indexOf(toppingExists[0])].quantity=_counter[index] ;
                                                          topping[topping.indexOf(toppingExists[0])].totalprice=_counter[index] *additionals[index].price;
                                                          // print("Updated Topping "+topping[topping.indexOf(toppingExists[0])].toJson().toString());
                                                          for(Toppings t in topping){
                                                            print("Updated Topping "+t.toJson().toString());
                                                          }
                                                        }else{
                                                          topping.add(Toppings(additionalitemid: additionals[index].id,quantity: _counter[index],price: additionals[index].price,totalprice: _counter[index]*additionals[index].price,name: additionals[index].name));
                                                          //print("added Topping "+Toppings(additionalitemid: additionals[index].id,quantity: _counter[index],price: additionals[index].price,totalprice: _counter[index]*additionals[index].price).toJson().toString());
                                                        }
                                                        print("length of Topping "+topping.length.toString());
                                                        for(Toppings t in topping){
                                                          a+=t.totalprice;
                                                        }
                                                      }else{
                                                        _counter[index]=0;
                                                        topping.removeAt(topping.indexOf(topping.where((element) => element.additionalitemid==additionals[index].id).toList()[0]));
                                                        for(Toppings t in topping){
                                                          print("List after removed Topping "+t.toJson().toString());
                                                        }
                                                        for(Toppings t in topping){
                                                          a+=t.totalprice;
                                                        }
                                                      }
                                                      print("Single Topping Price "+a.toString());
                                                      if(totalprice==0.0){
                                                        if(selectedSizeObj["discountedPrice"]!=0.0){
                                                          if(discountedPrice!=0.0){
                                                            totalprice = (discountedPrice * count ) + a;
                                                            updatedActualPrice=(price * count ) + a;
                                                          }else{
                                                            totalprice = (price * count ) + a;
                                                            updatedActualPrice=(price * count ) + a;
                                                          }
                                                          //  updatedActualPrice=updatedActualPrice+price+a;
                                                        }else {
                                                          totalprice = (price * count ) + a;
                                                          updatedActualPrice=(price * count ) + a;
                                                        }
                                                      }else{
                                                        if(discountedPrice!=0.0){
                                                          totalprice = (discountedPrice * count ) + a;
                                                          updatedActualPrice=(price * count ) + a;
                                                        }else{
                                                          totalprice = (price * count ) + a;
                                                          updatedActualPrice=(price * count ) + a;
                                                        }
                                                        print("in outer else"+a.toString());
                                                      }

                                                    }
                                                    );
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        )
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
                            "Price:  ${totalprice==0.0?price.toString():totalprice.toString()}",
                            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color:blueColor),)
                      ):Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: (
                              TextSpan(
                                  text: translate("product_popup.quantity"),
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
                                      text: "  ${totalprice==0.0?discountedPrice.toString():totalprice.toString()}",
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            print(selectedSizeName);
                            print(selectedSizeId);
                            sqlite_helper().checkAlreadyExists(product.id).then((foundProducts){
                              if(foundProducts.length>0){
                                var tempCartItem =CartItems(
                                    id: foundProducts[0]["id"],
                                    productId: product.id,
                                    productName: product.name,
                                    isDeal: 0,
                                    dealId: null,
                                    sizeId: selectedSizeId,
                                    sizeName: selectedSizeName,
                                    price: selectedSizeObj["discountedPrice"]==0.0? price:selectedSizeObj["discountedPrice"]!=0.0?selectedSizeObj["discountedPrice"] : price,
                                    totalPrice:selectedSizeObj["discountedPrice"]==0.0&&totalprice == 0.0 ? price:selectedSizeObj["discountedPrice"]!=0.0&&totalprice == 0.0?selectedSizeObj["discountedPrice"] : totalprice,
                                    quantity: count,
                                    storeId: product.storeId,
                                    topping: topping.length>0?jsonEncode(topping):null
                                );
                                sqlite_helper().updateCart(tempCartItem).then((value){
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
                                      sqlite_helper().gettotal().then((value){
                                        setState(() {
                                          overallTotalPrice=value[0]["SUM(totalPrice)"];
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
                                    isDeal: 0,
                                    dealId: null,
                                    sizeId: selectedSizeId,
                                    sizeName: selectedSizeName,
                                    price: selectedSizeObj["discountedPrice"]==0.0? price:selectedSizeObj["discountedPrice"]!=0.0?selectedSizeObj["discountedPrice"] : price,
                                    totalPrice:selectedSizeObj["discountedPrice"]==0.0&&totalprice == 0.0 ? price:selectedSizeObj["discountedPrice"]!=0.0&&totalprice == 0.0?selectedSizeObj["discountedPrice"] : totalprice,
                                    quantity: count,
                                    storeId: product.storeId,
                                    topping: topping.length>0?jsonEncode(topping):null))
                                    .then((isInserted) {
                                  if (isInserted > 0) {
                                    innersetState(() {
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
                                          sqlite_helper().gettotal().then((value){
                                            setState(() {
                                              overallTotalPrice=value[0]["SUM(totalPrice)"];
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
                              width: MediaQuery.of(context).size.width - 50,
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
                      ),
                    ],
                  )
              )
          );
        },
      ),
    );
  }
  Widget _buildChips() {
    List<Widget> chips = new List();
    List<String> foodTypes=[translate("in_app_errors.veg"),translate("in_app_errors.non_veg")];
    for (int i = 0; i < 2; i++) {
      _selected.add(false);
      FilterChip filterChip = FilterChip(
        selected: _selected[i],
        label: Text(foodTypes[i], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        // avatar: FlutterLogo(),
        elevation: 10,
        pressElevation: 5,
        //shadowColor: Colors.teal,
        backgroundColor: yellowColor,
        selectedColor: blueColor,
        onSelected: (bool selected) {
          setState(() {
            for(int j=0;j<_selected.length;j++){
              if(_selected[j]){
                _selected[j]=false;
              }
            }
            _selected[i] = selected;
            if(_selected[i]){
              if(i==0){
                print(subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])].id.toString());
                Network_Operations.getProduct(
                    context,
                    subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])]
                        .id,
                    widget.store["id"],
                    "")
                    .then((p) {
                  setState(() {
                    if (p != null && p.length > 0) {
                      products.clear();
                      for(int i=0;i<p.length;i++){
                        if(p[i].isVeg!=null&&p[i].isVeg){
                          products.add(p[i]);
                        }
                      }
                      categoryName = subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])].name;
                      print(categoryName);

                    }
                  });
                });
              }else{
                Network_Operations.getProduct(
                    context,
                    subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])]
                        .id,
                    widget.store["id"],
                    "")
                    .then((p) {
                  setState(() {
                    if (p != null && p.length > 0) {
                      products.clear();
                      for(int i=0;i<p.length;i++){
                        if(p[i].isVeg==null||!p[i].isVeg){
                          products.add(p[i]);
                        }
                      }
                      categoryName = subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])].name;
                      print(categoryName);

                    }
                  });
                });
              }

            }else{
              Network_Operations.getProduct(
                  context,
                  subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])]
                      .id,
                  widget.store["id"],
                  "")
                  .then((p) {
                setState(() {
                  if (p != null && p.length > 0) {
                    SharedPreferences.getInstance().then((prefs){
                      List<String> lst = prefs.getStringList("reorderedproducts${subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])]
                          .id.toString()}");
                      products.clear();
                      if(lst!=null&&lst.length>0){
                        this.products= lst.map(
                              (String indx) => p
                              .where((Products item) => int.parse(indx) == item.id)
                              .first,
                        ).toList();
                        if(p.length>products.length){
                          int additionalElements=p.length-products.length;
                          List<Products> reversedList =  List.from(p.reversed);

                          for(int i= 0;i<additionalElements;i++){
                            products.add(reversedList[i]);
                          }
                        }
                      }else{
                        products.addAll(p);
                      }
                    });
                    categoryName = subCategories[subCategories.indexOf(subCategories.where((element) => element.name==categoryName).toList()[0])].name;
                    print(categoryName);
                  }
                });
              });
            }

          });
        },
      );

      chips.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: filterChip
      ));
    }

    return ListView(
      // This next line does the trick.
      scrollDirection: Axis.horizontal,
      children: chips,
    );
  }
}



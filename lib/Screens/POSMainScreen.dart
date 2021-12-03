import 'dart:async';
import 'dart:convert';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:exabistro_pos/Screens/LoadingScreen.dart';
import 'package:exabistro_pos/Screens/LoginScreen.dart';
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
import 'package:flutter/widgets.dart';
import 'package:flutter_counter/flutter_counter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class POSMainScreen extends StatefulWidget {
  dynamic store;
  @override
  _POSMainScreenState createState() => _POSMainScreenState();

  POSMainScreen({this.store});
}

class _POSMainScreenState extends State<POSMainScreen> {
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
  List<Map> orderitem1 = [];
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
  List orderTypeList = ["Dine-In", "TakeAway","Home Delivery"];
  String token;
  @override
  void initState() {
    timePickerField=TextEditingController();
    customerName=TextEditingController();
    customerAddress=TextEditingController();
    customerEmail=TextEditingController();
    customerPhone=TextEditingController();
    discountValue=TextEditingController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SharedPreferences.getInstance().then((prefs){
      setState(() {
        this.token=prefs.getString("token");
      });
      Network_Operations.getDailySessionByStoreId(context, prefs.getString("token"),widget.store["id"]).then((dailySession){
        setState(() {
          currentDailySession=dailySession;
        });
      });
      Network_Operations.getCategory(context,prefs.getString("token"),widget.store["id"],"")
          .then((sub) {
        setState(() {
          if (sub != null && sub.length > 0) {
            for(int i = 0;i<sub.length;i++){
              if((int.parse(sub[i].startTime.substring(0,2)) <= TimeOfDay.now().hour ||
                  int.parse(sub[i].endTime.substring(0,2)) >= TimeOfDay.now().hour) &&
                  int.parse(sub[i].startTime.substring(3,5)) <= TimeOfDay.now().minute){
                subCategories.add(sub[i]);
              }
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
                  products.addAll(p);
                } else
                  isLoading = false;
                  setState(() {
                    this.userId=prefs.getString("userId");
                  });
                  Network_Operations.getAllDeals(
                      context, prefs.getString("token"), widget.store["id"])
                      .then((dealsList) {
                    setState(() {
                      if (dealsList.length > 0) {
                        this.dealsList.addAll(dealsList);
                      }
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
                Network_Operations.getTaxListByStoreId(context,widget.store["id"]).then((taxes){
                  setState(() {
                    this.orderTaxes=taxes;
                    sqlite_helper().gettotal().then((value){
                      setState(() {
                        overallTotalPrice=value[0]["SUM(totalPrice)"];
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
    });


  }
  buildInvoice()async{
    print("OrdersList "+ordersList.toString());
    final titles = <String>[
      'Order Number:',
      'Order Date:',
      'Order Type:',
      'Items Qty:'
    ];
    final data = <String>[
      ordersList["id"].toString(),
     DateFormat.yMd().format(DateTime.now()).toString(),
    ordersList["result"]["orderType"]==1?"Dine-In":ordersList["result"]["orderType"]==2?"Take-Away":ordersList["result"]["orderType"]==3?"Home Delivery":"None",
      ordersList["result"]["orderItems"].length.toString(),
    ];
    var invoiceData=cartList.map((cartItems){
      return [
        cartItems.productName,
        cartItems.price.toString(),
        "x "+cartItems.quantity.toString(),
        cartItems.totalPrice.toString(),
      ];
    }).toList();
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
     // pageFormat: PdfPageFormat.a4,
       header: (context){
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 1 * PdfPageFormat.cm),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(widget.store["name"].toString(),style: pw.TextStyle(fontSize:20,fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 1 * PdfPageFormat.mm),
                    pw.Text(widget.store["address"].toString()),
                  ]
                ),
                pw.Container(
                  width: 50,
                  height:50,
                  child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: "http://dev.exabistro.com/#/storeMenu/${widget.store["id"]}"
                  )
                )
              ]
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.cm),
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(customerName.text.toString(),style: pw.TextStyle(fontSize: 18,fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 1 * PdfPageFormat.mm),
                        pw.Text(customerPhone.text.toString()),
                      ]
                  ),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: List.generate(titles.length, (index){
                        final title = titles[index];
                        final value = data[index];
                        return pw.Container(
                          width: 200,
                          child: pw.Row(
                              children:[
                                pw.Expanded(
                                    child: pw.Text(title,style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                ),
                                pw.Text(
                                    value,
                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                )
                              ]

                          )
                        );
                      })
                  ),
                ]
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.cm),
          ]
        );
       },
       footer: (context){
         return pw.Column(
           crossAxisAlignment: pw.CrossAxisAlignment.center,
           children: [
             pw.Divider(),
             pw.SizedBox(
                 height: 2 * PdfPageFormat.mm
             ),
             pw.Row(
               mainAxisSize: pw.MainAxisSize.min,
               crossAxisAlignment: pw.CrossAxisAlignment.end,
               children: [
                pw.Text("Address",style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                 pw.SizedBox(
                     width: 2 * PdfPageFormat.mm
                 ),
                 pw.Text(widget.store["address"].toString())
               ]
             ),
             pw.Row(
                 mainAxisSize: pw.MainAxisSize.min,
                 crossAxisAlignment: pw.CrossAxisAlignment.end,
                 children: [
                   pw.Text("Phone",style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                   pw.SizedBox(
                       width: 2 * PdfPageFormat.mm
                   ),
                   pw.Text(widget.store["cellNo"].toString())
                 ]
             ),
           ]
         );
       },
        build: (pw.Context context) {
           return[
            pw.Column(
                 children: [
                   pw.Column(
                       crossAxisAlignment: pw.CrossAxisAlignment.start,
                       children: [
                         pw.Text(
                           "Invoice",
                           style: pw.TextStyle(fontSize: 24,fontWeight: pw.FontWeight.bold),
                         ),
                         pw.SizedBox(
                             height: 20
                         ),
                         pw.Table.fromTextArray(
                             headers: ["Name","Unit Price","Quantity","Total"],
                             data:invoiceData,
                             border: null,
                             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                             headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                             cellHeight: 30,
                             cellAlignments: {
                               0: pw.Alignment.centerLeft,
                               1: pw.Alignment.centerLeft,
                               2: pw.Alignment.centerLeft,
                               3: pw.Alignment.centerLeft
                             }
                         ),
                         pw.Divider(),
                         pw.Container(
                             alignment: pw.Alignment.centerRight,
                             child: pw.Row(
                               children: [
                                 pw.Spacer(flex: 6),
                                 pw.Expanded(
                                   flex:4,
                                   child: pw.Column(
                                       crossAxisAlignment: pw.CrossAxisAlignment.start,
                                       children: [
                                         pw.Container(
                                             width: double.infinity,
                                             child: pw.Row(
                                                 children: [
                                                   pw.Expanded(
                                                       child: pw.Text("SubTotal",style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                                   ),
                                                   pw.Text(
                                                       overallTotalPrice.toString(),
                                                       style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                                   )
                                                 ]
                                             )
                                         ),
                                         pw.Container(
                                             width: double.infinity,
                                             child: pw.Row(
                                                 children: [
                                                   pw.Expanded(
                                                       child: pw.Text("Tax",style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                                   ),
                                                   pw.Text(
                                                       totalTax.toString(),
                                                       style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                                   )
                                                 ]
                                             )
                                         ),
                                        deductedPrice!=0.0?pw.Container(
                                             width: double.infinity,
                                             child: pw.Row(
                                                 children: [
                                                   pw.Expanded(
                                                       child: pw.Text("Discount",style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                                   ),
                                                   pw.Text(
                                                       deductedPrice.toStringAsFixed(1),
                                                       style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                                   )
                                                 ]
                                             )
                                         ):pw.Container(),
                                         pw.Divider(),
                                         pw.Container(
                                             width: double.infinity,
                                             child: pw.Row(
                                                 children: [
                                                   pw.Expanded(
                                                       child: pw.Text("Total",style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                                                   ),
                                                   pw.Text(
                                                      deductedPrice!=0.0?priceWithDiscount.toStringAsFixed(1):overallTotalPriceWithTax.toString(),
                                                       style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                                   )
                                                 ]
                                             )
                                         ),
                                         pw.SizedBox(
                                             height: 2 * PdfPageFormat.mm
                                         ),
                                         pw.Container(
                                             height:1,
                                             color: PdfColors.grey400
                                         ),
                                         pw.SizedBox(
                                             height: 0.5 * PdfPageFormat.mm
                                         ),
                                         pw.Container(
                                             height:1,
                                             color: PdfColors.grey400
                                         ),
                                       ]
                                   ),
                                 )
                               ],
                             )
                         )
                       ]
                   )
                 ],

             )];

        }

    ));
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingScreen()
        : Scaffold(
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
                                Expanded(
                                  child: Container(
                                      //color: Colors.teal,
                                      width: MediaQuery.of(context).size.width,
                                      child: selectedMenuType == "Products" ||
                                              selectedMenuType == null
                                          ?
                                      //listViewLayout()
                                      productsLayout()
                                          : dealsLayout()),
                                )
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
                                Expanded(
                                  child: Container(
                                    //color: Colors.teal,
                                    width: MediaQuery.of(context).size.width,
                                    child: cartListLayout(),
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  width: MediaQuery.of(context).size.width,
                                  height: 230,
                                  child: Column(
                                    children: [
                                      Column(
                                        children: [

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
                                                    "TOTAL ",
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
                                                        widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":"",
                                                        style: TextStyle(
                                                            fontSize: 25,
                                                            color: yellowColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(1)+"/-":"0.0/-",
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
                                      ),

                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 60,
                                        color: yellowColor,
                                        child: Center(
                                          child: Text(
                                            "Create Your Order",
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                overallTotalPriceWithTax=0.0;
                                                totalTax=0.0;
                                                typeBasedTaxes.clear();
                                                taxesList.clear();
                                                orderItems.clear();
                                                discountValue.clear();
                                                priceWithDiscount=0.0;
                                                deductedPrice=0.0;
                                                selectedDiscountType=null;
                                                selectedTable=null;
                                                selectedTableId=null;
                                                customerName.clear();
                                                customerPhone.clear();
                                                overallTotalPriceWithTax=overallTotalPrice;
                                                if(orderTaxes!=null&&orderTaxes.length>0){
                                                  var tempTaxList = orderTaxes.where((element) => element.dineIn);
                                                  if(tempTaxList!=null&&tempTaxList.length>0){
                                                    for(Tax t in tempTaxList.toList()){
                                                      setState(() {
                                                        if(t.percentage!=null&&t.percentage!=0.0){
                                                          var percentTax= overallTotalPrice/100*t.percentage;
                                                          print(percentTax);
                                                          totalTax=totalTax+percentTax;
                                                          overallTotalPriceWithTax=overallTotalPriceWithTax+percentTax;
                                                        }
                                                        if(t.price!=null&&t.price!=0.0){
                                                          overallTotalPriceWithTax=overallTotalPriceWithTax+t.price;
                                                          totalTax=totalTax+t.price;
                                                        }
                                                        typeBasedTaxes.add(t);

                                                        taxesList.add({
                                                          "TaxId": t.id
                                                        });
                                                      });
                                                    }
                                                  }
                                                }

                                              });

                                              SharedPreferences.getInstance().then((prefs){
                                                var reservationData = {
                                                  "Date":DateTime.now().toString().substring(0,10),
                                                  "StartTime":DateTime.now().toString().substring(10,16),
                                                  "EndTime": DateTime.now().add(Duration(hours: 1)).toString().substring(10,16),
                                                  "storeId":widget.store["id"]
                                                };
                                                print(reservationData);
                                               Network_Operations.getAvailableTable(context,prefs.getString("token"), reservationData).then((availableTables){
                                                 if(availableTables!=null&&availableTables.length>0){
                                                   setState(() {
                                                     tables.clear();
                                                     this.tables=availableTables;
                                                   });
                                                   showDialog(context: context, builder:(BuildContext context){
                                                     return Dialog(
                                                         backgroundColor: Colors.transparent,
                                                         // insetPadding: EdgeInsets.all(16),
                                                         child: Container(
                                                             height:MediaQuery.of(context).size.height- 430,
                                                             width: MediaQuery.of(context).size.width/2,
                                                             child: orderPopUpHorizontalDineIn()
                                                         )
                                                     );
                                                   });
                                                 }else{
                                                   Utils.showError(this.context,"No Table is Free for DineIn");
                                                 }
                                               });
                                              });
                                              },
                                            child: Card(
                                              elevation:5,
                                              child: Container(
                                                width: 160,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  color: yellowColor,
                                                  borderRadius: BorderRadius.circular(4)
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Dine-In",
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    overallTotalPriceWithTax=0.0;
                                                    typeBasedTaxes.clear();
                                                    totalTax=0.0;
                                                    typeBasedTaxes.clear();
                                                    taxesList.clear();
                                                    orderItems.clear();
                                                    discountValue.clear();
                                                    customerName.clear();
                                                    customerPhone.clear();
                                                    priceWithDiscount=0.0;
                                                    deductedPrice=0.0;
                                                    selectedDiscountType=null;
                                                    overallTotalPriceWithTax=overallTotalPrice;
                                                    if(orderTaxes!=null&&orderTaxes.length>0){
                                                      var tempTaxList = orderTaxes.where((element) => element.takeAway);
                                                      if(tempTaxList!=null&&tempTaxList.length>0){
                                                        for(Tax t in tempTaxList.toList()){
                                                          setState(() {
                                                            if(t.percentage!=null&&t.percentage!=0.0){
                                                              var percentTax= overallTotalPrice/100*t.percentage;
                                                              print(percentTax);
                                                              overallTotalPriceWithTax=overallTotalPriceWithTax+percentTax;
                                                            }
                                                            if(t.price!=null&&t.price!=0.0){
                                                              overallTotalPriceWithTax=overallTotalPriceWithTax+t.price;
                                                            }
                                                            typeBasedTaxes.add(t);

                                                            taxesList.add({
                                                              "TaxId": t.id
                                                            });
                                                          });
                                                        }
                                                      }
                                                    }
                                                  });

                                                  showDialog(context: context, builder:(BuildContext context){
                                                    return Dialog(
                                                      backgroundColor: Colors.transparent,
                                                        child: Container(
                                                            height:MediaQuery.of(context).size.height - 430,
                                                            width: MediaQuery.of(context).size.width/2,
                                                            child: orderPopupHorizontalTakeAway()
                                                        )
                                                    );
                                                  });
                                                },
                                            child: Card(
                                              elevation:5,
                                              child: Container(
                                                width: 160,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                    color: yellowColor,
                                                    borderRadius: BorderRadius.circular(4)
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Take-Away",
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    overallTotalPriceWithTax=0.0;
                                                    totalTax=0.0;
                                                    typeBasedTaxes.clear();
                                                    taxesList.clear();
                                                    orderItems.clear();
                                                    discountValue.clear();
                                                    customerAddress.clear();
                                                    customerName.clear();
                                                    customerPhone.clear();
                                                    priceWithDiscount=0.0;
                                                    deductedPrice=0.0;
                                                    selectedDiscountType=null;
                                                    overallTotalPriceWithTax=overallTotalPrice;
                                                    if(orderTaxes!=null&&orderTaxes.length>0){
                                                      var tempTaxList = orderTaxes.where((element) => element.delivery);
                                                      if(tempTaxList!=null&&tempTaxList.length>0){
                                                        for(Tax t in tempTaxList.toList()){
                                                          setState(() {
                                                            if(t.percentage!=null&&t.percentage!=0.0){
                                                              var percentTax= overallTotalPrice/100*t.percentage;
                                                              print(percentTax);
                                                              overallTotalPriceWithTax=overallTotalPriceWithTax+percentTax;
                                                            }
                                                            if(t.price!=null&&t.price!=0.0){
                                                              overallTotalPriceWithTax=overallTotalPriceWithTax+t.price;
                                                            }
                                                            typeBasedTaxes.add(t);

                                                            taxesList.add({
                                                              "TaxId": t.id
                                                            });
                                                          });
                                                        }
                                                      }
                                                    }

                                                  });
                                                  showDialog(context: context, builder:(BuildContext context){
                                                    return Dialog(
                                                      backgroundColor: Colors.transparent,
                                                        child: Container(
                                                            height:MediaQuery.of(context).size.height - 430,
                                                            width: MediaQuery.of(context).size.width/2,
                                                            child: orderPopupHorizontalDelivery()
                                                        )
                                                    );
                                                  });
                                                },
                                            child: Card(
                                              elevation:5,
                                              child: Container(
                                                width: 160,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                    color: yellowColor,
                                                    borderRadius: BorderRadius.circular(4)
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Delivery",
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
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: Icon(Icons.delete_forever, color: Colors.red, size: 35,),
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
                                    });
                                  });
                                }),
                            // IconButton(
                            //     icon: Icon(Icons.edit, size: 35,),
                            //     color: PrimaryColor,
                            //     onPressed: () {
                            //       print(cartList[index].id.toString());
                            //       sqlite_helper()
                            //           .checkIfAlreadyExists(cartList[index].id)
                            //           .then((cartitem) {
                            //         // if(cartList[index].isDeal ==0) {
                            //         //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UpdateDetails(
                            //         //     pId: cartitem[0]['id'],
                            //         //     productId: cartitem[0]['productId'],
                            //         //     name: cartitem[0]['productName'],
                            //         //     sizeId: cartitem[0]['sizeId'],
                            //         //     //baseSelection: cartitem[0]['baseSelection'],
                            //         //     productPrice: cartitem[0]['price'],
                            //         //     quantity: cartitem[0]['quantity'],
                            //         //
                            //         //     storeId: cartList[0].storeId,
                            //         //     //baseSelectionName: cartitem[0]['baseSelectionName'],
                            //         //   ),));
                            //         //   print(cartitem[0]);
                            //         // }else{
                            //         //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UpdateCartDeals(
                            //         //     cartitem[0]['id'], cartitem[0]['productId'], cartitem[0]['productName'],
                            //         //     cartitem[0]['price'],cartList[0].storeId,
                            //         //   ),));
                            //         //
                            //         //
                            //         // }
                            //       });
                            //     }),
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
                                  fontSize: 25,
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
                                cartList[index].totalPrice != null&&widget.store["currencyCode"]!=null
                                    ?widget.store["currencyCode"]+": "+cartList[index]
                                        .totalPrice
                                        .toStringAsFixed(1)
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

  Widget orderPopupHorizontalDelivery(){

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context,innersetState){
          return Center(
            child: Container(
                height:MediaQuery.of(context).size.height - 430,
                width: MediaQuery.of(context).size.width/2,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                      image: AssetImage('assets/bb.jpg'),
                    )
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      color: yellowColor,
                      child: Center(
                        child: Text(
                          "Place Order For Delivery",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: customerName,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Customer Name*",hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: customerPhone,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Customer Phone# *",hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerAddress,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Customer Address*",hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DropdownButtonFormField<String>(
                                            decoration: InputDecoration(
                                              labelText: "Select Discount Type",
                                              alignLabelWithHint: true,
                                              labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                              enabledBorder: OutlineInputBorder(
                                              ),
                                              focusedBorder:  OutlineInputBorder(
                                                borderSide: BorderSide(color:yellowColor),
                                              ),
                                            ),

                                            value: selectedDiscountType,
                                            onChanged: (Value) {
                                              innersetState(() {
                                                selectedDiscountType = Value;
                                                priceWithDiscount=overallTotalPriceWithTax;
                                                deductedPrice=0.0;
                                                if(typeBasedTaxes.last.name=="Discount"){
                                                  priceWithDiscount=overallTotalPriceWithTax;
                                                  typeBasedTaxes.remove(typeBasedTaxes.last);
                                                }
                                                if(discountValue.text.isNotEmpty){
                                                  if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                                    var tempPercentage=(overallTotalPriceWithTax/100*double.parse(discountValue.text));
                                                    setState(() {
                                                      deductedPrice=tempPercentage;
                                                    });
                                                    priceWithDiscount=priceWithDiscount-tempPercentage;
                                                    typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(discountValue.text)));
                                                  }else if(selectedDiscountType!=null&&selectedDiscountType=="Cash"){
                                                    setState(() {
                                                      deductedPrice=double.parse(discountValue.text);
                                                    });
                                                    var tempSum=overallTotalPriceWithTax-double.parse(discountValue.text);
                                                    priceWithDiscount=tempSum;
                                                    typeBasedTaxes.add(Tax(name: "Discount",price: double.parse(discountValue.text)));
                                                  }
                                                }
                                              });
                                            },
                                            items: discountType.map((value) {
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
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: discountValue,
                                            onChanged: (value){
                                              innersetState(() {
                                                priceWithDiscount=overallTotalPriceWithTax;
                                                if(typeBasedTaxes.last.name=="Discount"){
                                                  //priceWithDiscount=overallTotalPriceWithTax;
                                                  typeBasedTaxes.remove(typeBasedTaxes.last);
                                                }
                                                if(value.isNotEmpty){
                                                  if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                                    var tempPercentage=(overallTotalPriceWithTax/100*double.parse(value));
                                                    priceWithDiscount=priceWithDiscount-tempPercentage;
                                                    setState(() {
                                                      deductedPrice=tempPercentage;
                                                    });
                                                    typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(value)));
                                                  }else if(selectedDiscountType!=null&&selectedDiscountType=="Cash"){
                                                    var tempSum=overallTotalPriceWithTax-double.parse(value);
                                                    setState(() {
                                                      deductedPrice=double.parse(discountValue.text);
                                                    });
                                                    priceWithDiscount=tempSum;
                                                    typeBasedTaxes.add(Tax(name: "Discount",price: double.parse(value)));
                                                  }
                                                }

                                              });

                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Discount Amount / Percentage",hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  "SubTotal: ",
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":" ",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(1)+"/-":"0.0/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
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
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Container(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width,
                                              height: 125,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: yellowColor),
                                                //borderRadius: BorderRadius.circular(8)
                                              ),

                                              child: ListView.builder(itemCount: typeBasedTaxes.length,itemBuilder: (context, index){
                                                return  Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0?typeBasedTaxes[index].name+" (${typeBasedTaxes[index].percentage.toStringAsFixed(1)})":typeBasedTaxes[index].name,
                                                        style: TextStyle(
                                                            fontSize:
                                                            16,
                                                            color:
                                                            yellowColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0?widget.store["currencyCode"]+" "+typeBasedTaxes[index].price.toStringAsFixed(1):typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1?widget.store["currencyCode"]+": "+(overallTotalPriceWithTax/100*typeBasedTaxes[index].percentage).toStringAsFixed(1):widget.store["currencyCode"]+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(1),style: TextStyle(
                                                              fontSize:
                                                              16,
                                                              color:
                                                              blueColor,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  "Total: ",
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":"",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(1)+"/-":overallTotalPriceWithTax.toStringAsFixed(1)+"/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height:15),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: ()async{
                                    if(customerName.text!=null&&customerName.text.isNotEmpty&&customerAddress.text!=null&&customerAddress.text.isNotEmpty&&customerPhone.text.isNotEmpty){
                                      for(int i=0;i<cartList.length;i++){
                                        orderItems.add({
                                          "dealid":cartList[i].dealId,
                                          "name":cartList[i].productName,
                                          "price":cartList[i].price,
                                          "quantity":cartList[i].quantity,
                                          "totalprice":cartList[i].totalPrice,
                                          "havetopping":cartList[i].topping=="null"||cartList[i].topping==null || cartList[i].topping== "[]" ?false:jsonDecode(cartList[i].topping).length>0?true:false,
                                          "sizeid":cartList[i].sizeId,
                                          "IsDeal": cartList[i].isDeal==0?false:true,
                                          "productid":cartList[i].productId,
                                          "orderitemstoppings":cartList[i].topping==null||cartList[i].topping == "[]"?[]:jsonDecode(cartList[i].topping),
                                        });
                                      }
                                      dynamic order = {
                                        "DailySessionNo": currentDailySession!=null?currentDailySession:7,
                                        "storeId":widget.store["id"],
                                        "DeviceToken":null,
                                        "ordertype":3,
                                        "NetTotal":overallTotalPrice,
                                        //  "grosstotal":widget.netTotal,
                                        "comment":null,
                                        "TableId":null,
                                        "DeliveryAddress" : customerAddress.text,
                                        "DeliveryLongitude" : null,
                                        "DeliveryLatitude" : null,
                                        "PaymentType" : 1,
                                        "orderitems":orderItems,
                                        "CardNumber": null,
                                        "CVV": null,
                                        "ExpiryDate": null,
                                        "OrderTaxes":taxesList,
                                        "VoucherCode": "",
                                        "OrderStatus":7,
                                        "customerName":customerName.text,
                                        "discountedPrice":deductedPrice,
                                        "CustomerContactNo":customerPhone.text,
                                        "employeeId": int.parse(userId),
                                        "IsCashPaid":selectedType=="Create Order"?false:selectedType=="Payment"?true:false,
                                        "CreatedOn":DateTime.now()
                                      };
                                      debugPrint(jsonEncode(order,toEncodable: Utils.myEncode));
                                      var result= await Utils.check_connection();
                                      if(result == ConnectivityResult.none){
                                        var offlineOrderList=[];
                                        //final body = jsonEncode(order,toEncodable: Utils.myEncode);
                                        var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                        if(exists){
                                          print("in if");
                                          offlineData = await Utils.getOfflineData("addOrderStaff");
                                          //print(offlineData.syncData);

                                          for(int i=0;i<jsonDecode(offlineData.syncData).length;i++){
                                            print(jsonDecode(offlineData.syncData)[i]);
                                            offlineOrderList.add(jsonDecode(offlineData.syncData)[i]);
                                          }
                                          offlineOrderList.add(order);
                                        }else
                                          offlineOrderList.add(order);

                                        //offlineOrderList.add(body);
                                        await Utils.addOfflineData("addOrderStaff",jsonEncode(offlineOrderList,toEncodable: Utils.myEncode));
                                        offlineData = await Utils.getOfflineData("addOrderStaff");
                                        Utils.showSuccess(this.context, "Your Order Stored Offline");
                                        Navigator.pop(context);
                                      }
                                      else if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
                                        var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                        if(exists){
                                          offlineData = await Utils.getOfflineData("addOrderStaff");
                                          showAlertDialog(context,offlineData);
                                        }else{
                                          SharedPreferences.getInstance().then((prefs){
                                            setState(() {
                                              isLoading=true;
                                              Navigator.of(context).pop(context);
                                            });
                                            Network_Operations.placeOrder(context, prefs.getString("token"), order).then((orderPlaced){
                                              if(orderPlaced!=null){
                                                orderItems.clear();
                                                sqlite_helper().getcart1().then((value) {
                                                  setState(() {
                                                    cartList.clear();
                                                    cartList = value;
                                                    isLoading=false;
                                                  });
                                                });
                                                sqlite_helper().gettotal().then((value){
                                                  setState(() {
                                                    overallTotalPrice=value[0]["SUM(totalPrice)"];
                                                  });
                                                });
                                                if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
                                                  var payCash ={
                                                    "orderid": jsonDecode(orderPlaced)["id"],
                                                    "CashPay": overallTotalPriceWithTax==0.0?overallTotalPriceWithTax:overallTotalPriceWithTax,
                                                    "Balance": overallTotalPriceWithTax==0.0?overallTotalPriceWithTax:overallTotalPriceWithTax,
                                                    "Comment": null,
                                                    "PaymentType": 1,
                                                    "OrderStatus": 7,
                                                  };
                                                  Network_Operations.payCashOrder(this.context, prefs.getString("token"), payCash).then((isPaid){
                                                    if(isPaid){
                                                      Utils.showSuccess(this.context,"Payment Successful");
                                                    }else{
                                                      Utils.showError(this.context,"Problem in Making Payment");
                                                    }
                                                  });
                                                  buildInvoice();
                                                }
                                                Utils.showSuccess(this.context,"Order Placed successfully");
                                              }else{
                                                setState(() {
                                                  isLoading=false;
                                                });
                                                Utils.showError(this.context,"Unable to Place Order");
                                              }
                                            });
                                          });
                                        }

                                      }
                                    }else{
                                      Utils.showError(this.context,"Provide all Required Information");
                                    }
                                  },
                                  child: Card(
                                    elevation:8,
                                    child: Container(
                                      width: 400,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          color: yellowColor,
                                          borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Submit Order",
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
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
                  ],
                )
            ),
          );
        },
      ),
    );
  }
  var discountType=["Cash","Percentage"];
  var priceWithDiscount=0.0,deductedPrice=0.0;
  String selectedType="Payment",selectedDiscountType;
  Widget orderPopupHorizontalTakeAway(){
    return Scaffold(

      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context,innersetState){
          return Center(
            child: Container(
                height:MediaQuery.of(context).size.height - 430,
                width: MediaQuery.of(context).size.width/2,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                      image: AssetImage('assets/bb.jpg'),
                    )
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      color: yellowColor,
                      child: Center(
                        child: Text(
                          "Place Order For Take-Away",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Expanded(
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.all(8.0),
                                  //     child: DropdownButtonFormField<String>(
                                  //       decoration: InputDecoration(
                                  //         labelText: "Select Type",
                                  //         alignLabelWithHint: true,
                                  //         labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                  //         enabledBorder: OutlineInputBorder(
                                  //         ),
                                  //         focusedBorder:  OutlineInputBorder(
                                  //           borderSide: BorderSide(color:yellowColor),
                                  //         ),
                                  //       ),
                                  //
                                  //       value: selectedType,
                                  //       onChanged: (Value) {
                                  //         innersetState(() {
                                  //           selectedType = Value;
                                  //         });
                                  //       },
                                  //       items: types.map((value) {
                                  //         return  DropdownMenuItem<String>(
                                  //           value: value,
                                  //           child: Row(
                                  //             children: <Widget>[
                                  //               Text(
                                  //                 value,
                                  //                 style:  TextStyle(color: yellowColor,fontSize: 13),
                                  //               ),
                                  //               //user.icon,
                                  //               //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                                  //             ],
                                  //           ),
                                  //         );
                                  //       }).toList(),
                                  //     ),
                                  //   ),
                                  // ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: customerName,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Customer Name*",hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: timePickerField,
                                        decoration: InputDecoration(
                                            labelText: "Select Picking Time*",
                                            border: OutlineInputBorder(),
                                            hintText: "Select Picking Time*",
                                          labelStyle: TextStyle(color: yellowColor, fontWeight: FontWeight.bold)
                                        ),
                                        onTap: ()async{
                                          FocusScope.of(context).requestFocus(new FocusNode());
                                          var time = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now()
                                          );
                                          innersetState(() {
                                            timePickerField.text=time.hour.toString()+":"+time.minute.toString()+":00";
                                            pickingTime=time;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerPhone,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Customer Phone# *",hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DropdownButtonFormField<String>(
                                            decoration: InputDecoration(
                                              labelText: "Select Discount Type",
                                              alignLabelWithHint: true,
                                              labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                              enabledBorder: OutlineInputBorder(
                                              ),
                                              focusedBorder:  OutlineInputBorder(
                                                borderSide: BorderSide(color:yellowColor),
                                              ),
                                            ),

                                            value: selectedDiscountType,
                                            onChanged: (Value) {
                                              innersetState(() {
                                                selectedDiscountType = Value;
                                                priceWithDiscount=overallTotalPriceWithTax;
                                                deductedPrice=0.0;
                                                if(typeBasedTaxes.last.name=="Discount"){
                                                  priceWithDiscount=overallTotalPriceWithTax;
                                                  typeBasedTaxes.remove(typeBasedTaxes.last);
                                                }
                                                if(discountValue.text.isNotEmpty){
                                                  if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                                    var tempPercentage=(overallTotalPriceWithTax/100*double.parse(discountValue.text));
                                                    setState(() {
                                                      deductedPrice=tempPercentage;
                                                    });
                                                    priceWithDiscount=priceWithDiscount-tempPercentage;
                                                    typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(discountValue.text)));
                                                  }else if(selectedDiscountType!=null&&selectedDiscountType=="Cash"){
                                                    setState(() {
                                                      deductedPrice=double.parse(discountValue.text);
                                                    });
                                                    var tempSum=overallTotalPriceWithTax-double.parse(discountValue.text);
                                                    priceWithDiscount=tempSum;
                                                    print("cash Discounted "+priceWithDiscount.toString());
                                                    typeBasedTaxes.add(Tax(name: "Discount",price: double.parse(discountValue.text)));
                                                  }
                                                }
                                              });
                                            },
                                            items: discountType.map((value) {
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
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: discountValue,
                                            onChanged: (value){
                                              innersetState(() {
                                                priceWithDiscount=overallTotalPriceWithTax;
                                                if(typeBasedTaxes.last.name=="Discount"){
                                                  //priceWithDiscount=overallTotalPriceWithTax;
                                                  typeBasedTaxes.remove(typeBasedTaxes.last);
                                                }
                                                if(value.isNotEmpty){
                                                  if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                                    var tempPercentage=(overallTotalPriceWithTax/100*double.parse(value));
                                                    priceWithDiscount=priceWithDiscount-tempPercentage;
                                                    setState(() {
                                                      deductedPrice=tempPercentage;
                                                    });
                                                    typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(value)));
                                                  }else if(selectedDiscountType!=null&&selectedDiscountType=="Cash"){
                                                    var tempSum=overallTotalPriceWithTax-double.parse(value);
                                                    setState(() {
                                                      deductedPrice=double.parse(discountValue.text);
                                                    });
                                                    priceWithDiscount=tempSum;
                                                    print("cash Discounted "+priceWithDiscount.toString());
                                                    typeBasedTaxes.add(Tax(name: "Discount",price: double.parse(value)));
                                                  }
                                                }

                                              });

                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Discount Amount / Percentage",hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  "SubTotal: ",
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":" ",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(1)+"/-":"0.0/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
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
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Container(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width,
                                              height: 125,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: yellowColor),
                                                //borderRadius: BorderRadius.circular(8)
                                              ),

                                              child: ListView.builder(itemCount: typeBasedTaxes.length,itemBuilder: (context, index){
                                                return  Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0?typeBasedTaxes[index].name+" (${typeBasedTaxes[index].percentage.toStringAsFixed(1)})":typeBasedTaxes[index].name,
                                                        style: TextStyle(
                                                            fontSize:
                                                            16,
                                                            color:
                                                            yellowColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0?widget.store["currencyCode"]+" "+typeBasedTaxes[index].price.toStringAsFixed(1):typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1?widget.store["currencyCode"]+": "+(overallTotalPriceWithTax/100*typeBasedTaxes[index].percentage).toStringAsFixed(1):widget.store["currencyCode"]+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(1),style: TextStyle(
                                                              fontSize:
                                                              16,
                                                              color:
                                                              blueColor,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  "Total: ",
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":"",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(1)+"/-":overallTotalPriceWithTax.toStringAsFixed(1)+"/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height:10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: ()async{
                                    if(customerName.text!=null&&customerName.text.isNotEmpty&&customerPhone.text.isNotEmpty&&timePickerField.text.isNotEmpty){
                                      for(int i=0;i<cartList.length;i++){
                                        orderItems.add({
                                          "dealid":cartList[i].dealId,
                                          "name":cartList[i].productName,
                                          "price":cartList[i].price,
                                          "quantity":cartList[i].quantity,
                                          "totalprice":cartList[i].totalPrice,
                                          "havetopping":cartList[i].topping=="null"||cartList[i].topping==null || cartList[i].topping== "[]" ?false:jsonDecode(cartList[i].topping).length>0?true:false,
                                          "sizeid":cartList[i].sizeId,
                                          "IsDeal": cartList[i].isDeal==0?false:true,
                                          "productid":cartList[i].productId,
                                          "orderitemstoppings":cartList[i].topping==null||cartList[i].topping == "[]"?[]:jsonDecode(cartList[i].topping),
                                        });
                                      }
                                      print(taxesList);
                                      dynamic order = {
                                        "DailySessionNo": currentDailySession!=null?currentDailySession:7,
                                        "storeId":widget.store["id"],
                                        "DeviceToken":null,
                                        "ordertype":2,
                                        "NetTotal":overallTotalPrice,
                                        //  "grosstotal":widget.netTotal,
                                        "comment":null,
                                        "TableId":null,
                                        "DeliveryAddress" : null,
                                        "DeliveryLongitude" : null,
                                        "DeliveryLatitude" : null,
                                        "PaymentType" : 1,
                                        "orderitems":orderItems,
                                        "CardNumber": null,
                                        "CVV": null,
                                        "ExpiryDate": null,
                                        "EstimatedTakeAwayTime":pickingTime!=null?DateFormat("hh:mm:ss").format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,pickingTime.hour,pickingTime.minute)).toString():null,
                                        "OrderTaxes":taxesList,
                                        "VoucherCode": "",
                                        "OrderStatus":7,
                                        "customerName":customerName.text,
                                        
                                        "CustomerContactNo":customerPhone.text,
                                        "employeeId": int.parse(userId),
                                        "IsCashPaid":selectedType=="Create Order"?false:selectedType=="Payment"?true:false,
                                        "CreatedOn":DateTime.now(),
                                        "discountedPrice":deductedPrice,
                                      };
                                      var result= await Utils.check_connection();
                                      if(result == ConnectivityResult.none){
                                        var offlineOrderList=[];
                                        //final body = jsonEncode(order,toEncodable: Utils.myEncode);
                                        var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                        if(exists){
                                          offlineData = await Utils.getOfflineData("addOrderStaff");
                                          //print(offlineData.syncData);

                                          for(int i=0;i<jsonDecode(offlineData.syncData).length;i++){
                                            print(jsonDecode(offlineData.syncData)[i]);
                                            offlineOrderList.add(jsonDecode(offlineData.syncData)[i]);
                                          }
                                          offlineOrderList.add(order);
                                        }else
                                          offlineOrderList.add(order);

                                        //offlineOrderList.add(body);
                                        await Utils.addOfflineData("addOrderStaff",jsonEncode(offlineOrderList,toEncodable: Utils.myEncode));
                                        offlineData = await Utils.getOfflineData("addOrderStaff");
                                        Utils.showSuccess(this.context, "Your Order Stored Offline");
                                        Navigator.pop(context);
                                      }
                                      else if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
                                        var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                        if(exists){
                                          offlineData = await Utils.getOfflineData("addOrderStaff");
                                          showAlertDialog(context,offlineData);
                                        }else{
                                          SharedPreferences.getInstance().then((prefs){
                                            setState(() {
                                              isLoading=true;
                                              Navigator.of(context).pop(context);
                                            });
                                            Network_Operations.placeOrder(context, prefs.getString("token"), order).then((orderPlaced){
                                              if(orderPlaced!=null){
                                                orderItems.clear();
                                                sqlite_helper().getcart1().then((value) {
                                                  setState(() {
                                                    cartList.clear();
                                                    cartList = value;
                                                    isLoading=false;
                                                  });
                                                });
                                                sqlite_helper().gettotal().then((value){
                                                  setState(() {
                                                    overallTotalPrice=value[0]["SUM(totalPrice)"];
                                                  });
                                                });
                                                if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
                                                  var payCash ={
                                                    "orderid": jsonDecode(orderPlaced)["id"],
                                                    "CashPay": overallTotalPriceWithTax==0.0?overallTotalPriceWithTax:overallTotalPriceWithTax,
                                                    "Balance": overallTotalPriceWithTax==0.0?overallTotalPriceWithTax:overallTotalPriceWithTax,
                                                    "Comment": null,
                                                    "PaymentType": 1,
                                                    "OrderStatus": 7,
                                                  };
                                                  Network_Operations.payCashOrder(this.context, prefs.getString("token"), payCash).then((isPaid){
                                                    if(isPaid){
                                                      Utils.showSuccess(this.context,"Payment Successful");
                                                    }else{
                                                      Utils.showError(this.context,"Problem in Making Payment");
                                                    }
                                                  });
                                                  buildInvoice();
                                                }
                                                Utils.showSuccess(this.context,"Order Placed successfully");
                                              }else{
                                                Utils.showError(this.context,"Unable to Place Order");
                                              }
                                            });
                                          });
                                        }

                                      }
                                    }else{
                                      Utils.showError(this.context,"Provide all Required Information");
                                    }
                                  },
                                  child: Card(
                                    elevation:8,
                                    child: Container(
                                      width: 400,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          color: yellowColor,
                                          borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Submit Order",
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
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
                  ],
                )
            ),
          );
        },
      ),
    );
  }

  Widget orderPopUpHorizontalDineIn(){

    return Scaffold(
        resizeToAvoidBottomInset:false,
      backgroundColor: Colors.white.withOpacity(0.1),
      body: StatefulBuilder(
        builder: (context,innersetState){
          return Center(
            child: Container(
                height:MediaQuery.of(context).size.height - 430,
                width: MediaQuery.of(context).size.width/2,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                      image: AssetImage('assets/bb.jpg'),
                    )
                ),
                child: Column(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        color: yellowColor,
                        child: Center(
                          child: Text(
                            "Place Order For Dine-In",
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Expanded(
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.all(8.0),
                                  //     child: DropdownButtonFormField<String>(
                                  //       decoration: InputDecoration(
                                  //         labelText: "Select Type",
                                  //         alignLabelWithHint: true,
                                  //         labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                  //         enabledBorder: OutlineInputBorder(
                                  //         ),
                                  //         focusedBorder:  OutlineInputBorder(
                                  //           borderSide: BorderSide(color:yellowColor),
                                  //         ),
                                  //       ),
                                  //
                                  //       value: selectedType,
                                  //       onChanged: (Value) {
                                  //         innersetState(() {
                                  //           selectedType = Value;
                                  //         });
                                  //       },
                                  //       items: types.map((value) {
                                  //         return  DropdownMenuItem<String>(
                                  //           value: value,
                                  //           child: Row(
                                  //             children: <Widget>[
                                  //               Text(
                                  //                 value,
                                  //                 style:  TextStyle(color: yellowColor,fontSize: 13),
                                  //               ),
                                  //               //user.icon,
                                  //               //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                                  //             ],
                                  //           ),
                                  //         );
                                  //       }).toList(),
                                  //     ),
                                  //   ),
                                  // ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          hintText: "Select Table *",
                                          labelText: "Select Table *",
                                          labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                          enabledBorder: OutlineInputBorder(
                                          ),
                                          focusedBorder:  OutlineInputBorder(
                                            borderSide: BorderSide(color:yellowColor),
                                          ),
                                        ),

                                        value: selectedTable,
                                        onChanged: (Value) {
                                          innersetState(() {
                                            selectedTable=Value;
                                            selectedTableId=tables[tables.indexOf(tables.where((element) =>element["name"]==selectedTable).toList()[0])]["id"];
                                          });
                                        },
                                        items: tables.map((value) {
                                          return  DropdownMenuItem<String>(
                                            value: value["name"],
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  value["name"],
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
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: customerName,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Customer Name *",hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: customerPhone,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Customer Phone# *",hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DropdownButtonFormField<String>(
                                            decoration: InputDecoration(
                                              labelText: "Select Discount Type",
                                              alignLabelWithHint: true,
                                              labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                                              enabledBorder: OutlineInputBorder(
                                              ),
                                              focusedBorder:  OutlineInputBorder(
                                                borderSide: BorderSide(color:yellowColor),
                                              ),
                                            ),

                                            value: selectedDiscountType,
                                            onChanged: (Value) {
                                              innersetState(() {
                                                selectedDiscountType = Value;
                                                priceWithDiscount=overallTotalPriceWithTax;
                                                deductedPrice=0.0;
                                                if(typeBasedTaxes.last.name=="Discount"){
                                                  priceWithDiscount=overallTotalPriceWithTax;
                                                  typeBasedTaxes.remove(typeBasedTaxes.last);
                                                }
                                                if(discountValue.text.isNotEmpty){
                                                  if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                                    var tempPercentage=(overallTotalPriceWithTax/100*double.parse(discountValue.text));
                                                    setState(() {
                                                      deductedPrice=tempPercentage;
                                                    });
                                                    priceWithDiscount=priceWithDiscount-tempPercentage;
                                                    typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(discountValue.text)));
                                                  }else if(selectedDiscountType!=null&&selectedDiscountType=="Cash"){
                                                    setState(() {
                                                      deductedPrice=double.parse(discountValue.text);
                                                    });
                                                    var tempSum=overallTotalPriceWithTax-double.parse(discountValue.text);
                                                    priceWithDiscount=tempSum;
                                                    print("cash Discounted "+priceWithDiscount.toString());
                                                    typeBasedTaxes.add(Tax(name: "Discount",price: double.parse(discountValue.text)));
                                                  }
                                                }
                                              });
                                            },
                                            items: discountType.map((value) {
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
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: discountValue,
                                            onChanged: (value){
                                              innersetState(() {
                                                priceWithDiscount=overallTotalPriceWithTax;
                                                if(typeBasedTaxes.last.name=="Discount"){
                                                  //priceWithDiscount=overallTotalPriceWithTax;
                                                  typeBasedTaxes.remove(typeBasedTaxes.last);
                                                }
                                                if(value.isNotEmpty){
                                                  if(selectedDiscountType!=null&&selectedDiscountType=="Percentage"){
                                                    var tempPercentage=(overallTotalPriceWithTax/100*double.parse(value));
                                                    priceWithDiscount=priceWithDiscount-tempPercentage;
                                                    setState(() {
                                                      deductedPrice=tempPercentage;
                                                    });
                                                    typeBasedTaxes.add(Tax(name: "Discount",percentage: double.parse(value)));
                                                  }else if(selectedDiscountType!=null&&selectedDiscountType=="Cash"){
                                                    var tempSum=overallTotalPriceWithTax-double.parse(value);
                                                    setState(() {
                                                      deductedPrice=double.parse(discountValue.text);
                                                    });
                                                    priceWithDiscount=tempSum;
                                                    print("cash Discounted "+priceWithDiscount.toString());
                                                    typeBasedTaxes.add(Tax(name: "Discount",price: double.parse(value)));
                                                  }
                                                }

                                              });

                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Discount Amount / Percentage",hintStyle: TextStyle(color: yellowColor, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  "SubTotal: ",
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":" ",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      overallTotalPrice!=null?overallTotalPrice.toStringAsFixed(1)+"/-":"0.0/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
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
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Container(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width,
                                              height: 125,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: yellowColor),
                                                //borderRadius: BorderRadius.circular(8)
                                              ),

                                              child: ListView.builder(itemCount: typeBasedTaxes.length,itemBuilder: (context, index){
                                                return  Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0?typeBasedTaxes[index].name+" (${typeBasedTaxes[index].percentage.toStringAsFixed(1)})":typeBasedTaxes[index].name,
                                                        style: TextStyle(
                                                            fontSize:
                                                            16,
                                                            color:
                                                            yellowColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            typeBasedTaxes[index].price!=null&&typeBasedTaxes[index].price!=0.0?widget.store["currencyCode"]+" "+typeBasedTaxes[index].price.toStringAsFixed(1):typeBasedTaxes[index].percentage!=null&&typeBasedTaxes[index].percentage!=0.0&&selectedDiscountType=="Percentage"&&discountValue.text.isNotEmpty&&index==typeBasedTaxes.length-1?widget.store["currencyCode"]+": "+(overallTotalPriceWithTax/100*typeBasedTaxes[index].percentage).toStringAsFixed(1):widget.store["currencyCode"]+": "+(overallTotalPrice/100*typeBasedTaxes[index].percentage).toStringAsFixed(1),style: TextStyle(
                                                              fontSize:
                                                              16,
                                                              color:
                                                              blueColor,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          color: yellowColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  "Total: ",
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      color:
                                                      Colors.white,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.store["currencyCode"]!=null?widget.store["currencyCode"]+":":"",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      priceWithDiscount!=null&&priceWithDiscount!=0.0?priceWithDiscount.toStringAsFixed(1)+"/-":overallTotalPriceWithTax.toStringAsFixed(1)+"/-",
                                                      style: TextStyle(
                                                          fontSize:
                                                          20,
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height:10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: ()async{
                                    if(customerName.text!=null&&customerName.text.isNotEmpty&&selectedTableId!=null&&customerPhone.text.isNotEmpty){
                                      for(int i=0;i<cartList.length;i++){
                                        orderItems.add({
                                          "dealid":cartList[i].dealId,
                                          "name":cartList[i].productName,
                                          "price":cartList[i].price,
                                          "quantity":cartList[i].quantity,
                                          "totalprice":cartList[i].totalPrice,
                                          "havetopping":cartList[i].topping=="null"||cartList[i].topping==null || cartList[i].topping== "[]" ?false:jsonDecode(cartList[i].topping).length>0?true:false,
                                          "sizeid":cartList[i].sizeId,
                                          "IsDeal": cartList[i].isDeal==0?false:true,
                                          "productid":cartList[i].productId,
                                          "orderitemstoppings":cartList[i].topping==null||cartList[i].topping == "[]"?[]:jsonDecode(cartList[i].topping),
                                        });
                                      }

                                      dynamic order = {
                                        "DineInEndTime":DateFormat("HH:mm:ss").format(DateTime.now().add(Duration(hours: 1))),
                                        "DailySessionNo": currentDailySession!=null?currentDailySession:7,
                                        "TableId":selectedTableId!=null?selectedTableId:null,
                                        "storeId":widget.store["id"],
                                        "DeviceToken":null,
                                        "ordertype":1,
                                        "NetTotal":overallTotalPrice,
                                        //  "grosstotal":widget.netTotal,
                                        "comment":null,
                                        "DeliveryAddress" : null,
                                        "DeliveryLongitude" : null,
                                        "DeliveryLatitude" : null,
                                        "PaymentType" : 1,
                                        "orderitems":orderItems,
                                        "CardNumber": null,
                                        "CVV": null,
                                        "ExpiryDate": null,
                                        "OrderTaxes":taxesList,
                                        "VoucherCode": "",
                                        "OrderStatus":1,
                                        "discountedPrice":deductedPrice,
                                        "customerName":customerName.text,
                                        "CustomerContactNo":customerPhone.text,
                                        "employeeId": int.parse(userId),
                                        "IsCashPaid":selectedType=="Create Order"?false:selectedType=="Payment"?true:false,
                                        "CreatedOn":DateTime.now(),
                                      };
                                      debugPrint(jsonEncode(order,toEncodable: Utils.myEncode));
                                      var result= await Utils.check_connection();
                                      if(result == ConnectivityResult.none){
                                        var offlineOrderList=[];
                                        //final body = jsonEncode(order,toEncodable: Utils.myEncode);
                                        var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                        if(exists){
                                          print("in if");
                                          offlineData = await Utils.getOfflineData("addOrderStaff");
                                          //print(offlineData.syncData);

                                          for(int i=0;i<jsonDecode(offlineData.syncData).length;i++){
                                            print(jsonDecode(offlineData.syncData)[i]);
                                            offlineOrderList.add(jsonDecode(offlineData.syncData)[i]);
                                          }
                                          offlineOrderList.add(order);
                                        }else
                                          offlineOrderList.add(order);

                                        //offlineOrderList.add(body);
                                        await Utils.addOfflineData("addOrderStaff",jsonEncode(offlineOrderList,toEncodable: Utils.myEncode));
                                        offlineData = await Utils.getOfflineData("addOrderStaff");
                                        Utils.showSuccess(this.context, "Your Order Stored Offline");
                                        Navigator.pop(context);
                                      }
                                      else if(result == ConnectivityResult.mobile||result == ConnectivityResult.wifi){
                                        var exists = await Utils.checkOfflineDataExists("addOrderStaff");
                                        if(exists){
                                          offlineData = await Utils.getOfflineData("addOrderStaff");
                                          showAlertDialog(context,offlineData);
                                        }else{
                                          SharedPreferences.getInstance().then((prefs){
                                            setState(() {
                                              isLoading=true;
                                              Navigator.of(context).pop(context);
                                            });
                                            Network_Operations.placeOrder(context, prefs.getString("token"), order).then((orderPlaced){
                                              if(orderPlaced!=null){
                                                orderItems.clear();
                                                sqlite_helper().getcart1().then((value) {
                                                  setState(() {
                                                    cartList.clear();
                                                    cartList = value;
                                                    isLoading=false;
                                                  });
                                                });
                                                sqlite_helper().gettotal().then((value){
                                                  setState(() {
                                                    overallTotalPrice=value[0]["SUM(totalPrice)"];
                                                  });
                                                });
                                                if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
                                                  var payCash ={
                                                    "orderid": jsonDecode(orderPlaced)["id"],
                                                    "CashPay": overallTotalPriceWithTax==0.0?overallTotalPriceWithTax:overallTotalPriceWithTax,
                                                    "Balance": overallTotalPriceWithTax==0.0?overallTotalPriceWithTax:overallTotalPriceWithTax,
                                                    "Comment": null,
                                                    "PaymentType": 1,
                                                    "OrderStatus": 7,
                                                  };
                                                  Network_Operations.payCashOrder(this.context, prefs.getString("token"), payCash).then((isPaid){
                                                    if(isPaid){
                                                      Utils.showSuccess(this.context,"Payment Successful");
                                                    }else{
                                                      Utils.showError(this.context,"Problem in Making Payment");
                                                    }
                                                  });
                                                  buildInvoice();
                                                }
                                                Utils.showSuccess(this.context,"Order Placed successfully");
                                              }else{
                                                Utils.showError(this.context,"Unable to Place Order");
                                              }
                                            });
                                          });
                                        }

                                      }
                                    }else{
                                      Utils.showError(this.context,"Provide all Required Information");
                                    }
                                  },
                                  child: Card(
                                    elevation:8,
                                    child: Container(
                                      width: 400,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          color: yellowColor,
                                          borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Submit Order",
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
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
                  ],
                )
            ),
          );
        },
      ),
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
                                isDeal: 0,
                                dealId: null,
                                sizeId: selectedSizeId,
                                sizeName: selectedSizeName,
                                price: selectedSizeObj["discountedPrice"]==0.0? price:selectedSizeObj["discountedPrice"]!=0.0?selectedSizeObj["discountedPrice"] : price,
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
  showAlertDialog(BuildContext context,APICacheDBModel data) {

    // set up the buttons
    Widget remindButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Delete"),
      onPressed:  () async{
        Utils.deleteOfflineData("addOrderStaff");
        Navigator.pop(context);
      },
    );
    Widget launchButton = TextButton(
      child: Text("Add From Cache"),
      onPressed:  () {
        print(jsonDecode(data.syncData).length);
        for(int i=0;i<jsonDecode(data.syncData).length;i++)
        {
          Network_Operations.placeOrder(context,token,jsonDecode(data.syncData)[i]).then((value){
            if(value!=null){
             if(widget.store["payOut"]!=null&&widget.store["payOut"]==true){
               var payCash ={
                 "orderid": jsonDecode(data.syncData)[i]["id"],
                 "CashPay": overallTotalPriceWithTax==0.0?overallTotalPriceWithTax:overallTotalPriceWithTax,
                 "Balance": overallTotalPriceWithTax==0.0?overallTotalPriceWithTax:overallTotalPriceWithTax,
                 "Comment": null,
                 "PaymentType": 1,
                 "OrderStatus": 7,
               };
               Network_Operations.payCashOrder(this.context, token, payCash).then((isPaid){
                 if(isPaid){
                   Utils.showSuccess(this.context,"Payment Successful");
                 }else{
                   Utils.showError(this.context,"Problem in Making Payment");
                 }
               });
             }
            }
          });
        }
        Utils.deleteOfflineData("addOrderStaff");
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Notice"),
      content: Text("Data is Available in your Cache do you want to add?"),
      actions: [
        remindButton,
        cancelButton,
        launchButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

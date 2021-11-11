// import 'dart:convert';
// import 'dart:ui';
// import 'package:exabistro_pos/Utils/Utils.dart';
// import 'package:exabistro_pos/components/constants.dart';
// import 'package:exabistro_pos/model/CartItems.dart';
// import 'package:exabistro_pos/model/Orderitems.dart';
// import 'package:exabistro_pos/model/Orders.dart';
// import 'package:exabistro_pos/model/orderItemTopping.dart';
// import 'package:exabistro_pos/networks/sqlite_helper.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class MyCartScreen extends StatefulWidget {
//   var ishome;
//   MyCartScreen({this.ishome});
//
//   @override
//   _MyCartScreenState createState() => _MyCartScreenState();
// }
//
// class _MyCartScreenState extends State<MyCartScreen> {
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
//   var storeId;
//   bool isvisible =false,voucherVisiblity=false;
//  Color headingColor2 = Colors.white;
//  Color textColor1 = Colors.white;
//  Color backgroundColor = Colors.blue;
//   List<CartItems> cartList =[];
//   Order finalOrder;
//   List<Orderitem> orderitem = [];
//   List<Orderitemstopping> itemToppingList = [];
//   List<Map> orderitem1 = [];
//
//   dynamic ordersList;
//   List<dynamic> toppingList=[],orderItems=[];
//   List<String> topping=[];
//   double totalprice=0.00,applyVoucherPrice;
//   TextEditingController addnotes,applyVoucher;
//   String orderType;int orderTypeId;
//   var voucherValidity;
//   List orderTypeList = ["None","DineIn ","TakeAway ","HomeDelivery "];
//
//   String token,tableId;
//
//   @override
//   void initState() {
//     SharedPreferences.getInstance().then((value) {
//       setState(() {
//         this.token = value.getString("token");
//         this.tableId = value.getString("tableId");
//       });
//     });
//     setState(() {
//       addnotes = TextEditingController();
//       applyVoucher = TextEditingController();
//       sqlite_helper().getcart1().then((value) {
//         setState(() {
//           cartList.clear();
//           cartList = value;
//           if(cartList.length>0){
//             print(cartList.toString());
//             isvisible = true;
//           }else{
//             isvisible = false;
//           }
//         });
//       });
//
//       sqlite_helper().gettotal().then((value) {
//         setState(() {
//           totalprice = value[0]['SUM(totalPrice)'];
//           print(value[0]['SUM(price)'].toString());
//         });
//       });
//       // TODO: implement initState
//       super.initState();
//     });
//   }
//   String getCustomerName(int id){
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:   AppBar(
//         iconTheme: IconThemeData(
//             color: yellowColor
//         ),
//         backgroundColor: BackgroundColor ,
//         title: Text('My Cart',
//           style: TextStyle(
//               color: yellowColor,
//               fontSize: 22,
//               fontWeight: FontWeight.bold
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           Visibility(
//             visible: isvisible,
//             child: IconButton(tooltip: "Delete Whole Cart",icon: Icon(Icons.delete_forever,semanticLabel: "Delete Cart", color: PrimaryColor,), onPressed: (){
//               sqlite_helper().deletecart().then((value) {
//                 print(value.toString());
//                 if(value==1){
//                   Utils.showSuccess(context, "Order Deleted");
//                   WidgetsBinding.instance
//                       .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
//                 }else{
//                   Utils.showError(context, "Order not Deleted");
//                   WidgetsBinding.instance
//                       .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
//                 }
//               });
//             }),
//           ),
//           Visibility(
//             visible: tableId!=null,
//
//             child: IconButton(tooltip: "Delete Scan/Selected Table",icon: Icon(Icons.delete_sweep,semanticLabel: "delete scanning Table", color: PrimaryColor,), onPressed: (){
//               SharedPreferences.getInstance().then((value) {
//                 value.remove("tableId");
//                 WidgetsBinding.instance
//                     .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
//               });
//             }),
//           ),
//         ],
//         //centerTitle: true,
//       ),
//
//       body: RefreshIndicator(
//         key: _refreshIndicatorKey,
//         onRefresh: (){
//           return sqlite_helper().getcart1().then((value) {
//                 setState(() {
//                   cartList.clear();
//                   cartList = value;
//                   if(cartList!=null&&cartList.length>0){
//                     setState(() {
//                       isvisible = true;
//                       print(cartList.toString()+"qwertuiop");
//                     });
//                   }else{
//                     isvisible = false;
//                   }
//                 });
//                 sqlite_helper().gettotal().then((value) {
//                   setState(() {
//                     totalprice = value[0]['SUM(totalPrice)'];
//                     print(value[0]['SUM(price)'].toString());
//                   });
//                 });
//               });
//
//           //   }else{
//           //     Utils.showError(context, "Network Error");
//           //   }
//           // });
//         },
//         child: cartList.length>0?Container(
//           decoration: BoxDecoration(
//               image: DecorationImage(
//                 fit: BoxFit.cover,
//                 image: AssetImage('assets/bb.jpg'),
//               )
//           ),
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           child: Column(
//             children: <Widget>[
//               Expanded(
//                 child: ListView.builder(padding: EdgeInsets.all(4), scrollDirection: Axis.vertical,
//                     itemCount:cartList ==null?0:cartList.length, itemBuilder: (context,int index) {
//                       topping.clear();
//                       // toppingList.clear();
//                       if(cartList[index].topping!=null){
//                       if(jsonDecode(cartList[index].topping) !=null){
//
//                         for(int i=0;i<jsonDecode(cartList[index].topping).length;i++){
//                           topping.add(jsonDecode(cartList[index].topping)[i]['name']+"  x"+jsonDecode(cartList[index].topping)[i]['quantity'].toString()+"    \$"+jsonDecode(cartList[index].topping)[i]['price'].toString()+"\n");
//                         }
//                       }
//                       }
//                       return Card(
//                         color: BackgroundColor,
//                         elevation: 3,
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Container(
//                             width: MediaQuery.of(context).size.width,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: <Widget>[
//                                     Row(
//                                       children: <Widget>[
//                                         Padding(
//                                           padding: const EdgeInsets.only(left: 15),
//                                           child: Text(cartList[index].productName!=null?cartList[index].productName:"", style: TextStyle(
//                                               color: yellowColor,
//                                               fontSize: 20,
//                                               fontWeight: FontWeight.bold
//                                           ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         IconButton(icon: Icon(Icons.delete),color: PrimaryColor, onPressed: (){
//                                           print(cartList[index].id);
//                                           sqlite_helper().deleteProductsById(cartList[index].id);
//                                           Utils.showError(context, "item deleted");
//                                           WidgetsBinding.instance
//                                               .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
//                                         }),
//                                         IconButton(icon: Icon(Icons.edit),color: PrimaryColor, onPressed: (){
//                                           print(cartList[index].id.toString());
//                                           sqlite_helper().checkIfAlreadyExists(cartList[index].id).then((cartitem) {
//                                              if(cartList[index].isDeal ==0) {
//                                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UpdateDetails(
//                                                        pId: cartitem[0]['id'],
//                                                        productId: cartitem[0]['productId'],
//                                                        name: cartitem[0]['productName'],
//                                                        sizeId: cartitem[0]['sizeId'],
//                                                        //baseSelection: cartitem[0]['baseSelection'],
//                                                        productPrice: cartitem[0]['price'],
//                                                        quantity: cartitem[0]['quantity'],
//
//                                                        storeId: cartList[0].storeId,
//                                                        //baseSelectionName: cartitem[0]['baseSelectionName'],
//                                                       ),));
//                                                        print(cartitem[0]);
//                                              }else{
//                                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UpdateCartDeals(
//                                                  cartitem[0]['id'], cartitem[0]['productId'], cartitem[0]['productName'],
//                                                   cartitem[0]['price'],cartList[0].storeId,
//                                                ),));
//
//
//                                                    }
//                                              });
//                                         }),
//                                       ],
//                                     ),
//
//                                   ],
//                                 ),
//                                 SizedBox(height: 10,),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 15),
//                                       child: Text("Size ", style: TextStyle(
//                                           color: yellowColor,
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold
//                                       ),
//                                       ),
//                                     ),
//                                     SizedBox(width: 20,),
//                                     Text(cartList[index].sizeName==null?"":"-"+cartList[index].sizeName, style: TextStyle(
//                                         color: PrimaryColor,
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold
//                                     ),)
//                                   ],
//                                 ),
//                                 SizedBox(height: 10,),
//                                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 15),
//                                       child: Text("Additional Toppings", style: TextStyle(
//                                           color: yellowColor,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.bold
//                                       ),
//                                       ),
//                                     ),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                       children: [
//                                         Text("Qty: ",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 20,color: yellowColor,),),
//                                         //SizedBox(width: 10,),
//                                         Text(cartList[index].quantity.toString(),style: TextStyle(fontWeight: FontWeight.w900,fontSize: 20,color: PrimaryColor,),),
//
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 35),
//                                   child: Text(topping!=null?topping.toString().replaceAll("[", "- ").replaceAll(",", "- ").replaceAll("]", ""):"-", style: TextStyle(
//                                     color: PrimaryColor,
//                                     fontSize: 14,
//                                     //fontWeight: FontWeight.bold
//                                   ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 15,),
//                                 Padding(
//                                   padding: const EdgeInsets.all(2.0),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: <Widget>[
//                                       Padding(
//                                         padding: const EdgeInsets.only(left: 12),
//                                         child: Text(
//                                           translate('mycart_screen.price'), style: TextStyle(
//                                             color: yellowColor,
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold
//                                         ),
//                                         ),
//                                       ),
//                                       Row(
//                                         children: <Widget>[
//                                           // FaIcon(FontAwesomeIcons.dollarSign,
//                                           //   color: Colors.amberAccent, size: 20,),
//                                           SizedBox(width: 2,),
//                                           Text(cartList[index].totalPrice!=null?cartList[index].totalPrice.toStringAsFixed(2):"", style: TextStyle(
//                                               color: PrimaryColor,
//                                               fontSize: 23,
//                                               fontWeight: FontWeight.bold
//                                           ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//
//                     }),
//               ),
//               Visibility(
//                 visible: isvisible,
//                 child: Card(
//                   elevation: 8,
//                   color: BackgroundColor,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Container(
//                       width: MediaQuery.of(context).size.width,
// //                  height: MediaQuery.of(context).size.height/4,
//
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//
//                           Padding(
//                             padding: const EdgeInsets.all(2.0),
//                             child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 SizedBox(
//                                   height: 30,
//                                   width: 170,
//                                   child: TextField(
//                                     controller: applyVoucher,
//                                     style: TextStyle(color: yellowColor),
//                                     decoration: InputDecoration(
//                                       hintText: "Apply Voucher",hintStyle: TextStyle(color: yellowColor),
//                                     ),
//                                   ),
//                                 ),
//                                 Row(
//                                   children: <Widget>[
//                                     //FaIcon(FontAwesomeIcons.dollarSign, color: Colors.amberAccent, size: 30,),
//                                     InkWell(
//                                       onTap: () {
//                                         print(applyVoucher.text);
//
//                                         voucherValidity =null;
//                                         networksOperation.checkVoucherValidity(context, applyVoucher.text, totalprice).then((value){
//                                           setState(() {
//                                             applyVoucher.text="";
//                                             voucherValidity = value;
//                                             voucherVisiblity =true;
//
//                                           });
//                                         });
//                                         print(voucherVisiblity);
//                                       },
//                                       child: Text("Apply Voucher", style: TextStyle(
//                                           color: yellowColor,
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold
//                                       ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Visibility(
//                 visible: isvisible,
//                 child: Card(
//                   color: BackgroundColor,
//                   elevation: 8,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Container(
//
//                       width: MediaQuery.of(context).size.width,
// //                  height: MediaQuery.of(context).size.height/4,
//
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Padding(
//                             padding: const EdgeInsets.all(2.0),
//                             child: Column(mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 Row(
//                                   children: <Widget>[
//                                     //FaIcon(FontAwesomeIcons.dollarSign, color: Colors.amberAccent, size: 30,),
//                                     Text("Additional Notes", style: TextStyle(
//                                         color: yellowColor,
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold
//                                     ),
//                                     ),
//                                   ],
//                                 ),
//                                 TextField(
//                                   maxLines: 1,
//                                   style: TextStyle(color: PrimaryColor, ),
//                                   controller: addnotes,
//                                   decoration: InputDecoration(
//                                       hintText: ''
//                                   ),
//                                 ),
//                                 // ),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Visibility(
//                 visible: isvisible,
//                 child: Padding(
//                   padding: const EdgeInsets.all(5.0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.all(Radius.circular(10)) ,
//                       color: BackgroundColor,
//                     ),
//                     width: MediaQuery.of(context).size.width,
//                     height: 90,
//
//                     child: Center(
//                         child: Padding(
//                           padding: const EdgeInsets.all(10.0),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: <Widget>[
//                                   Text("SubTotal",style: TextStyle(color: yellowColor,fontSize: 17,fontWeight: FontWeight.w400),),
//
//                                   Padding(
//                                     padding: const EdgeInsets.only(left: 70),
//                                     child: Text("${totalprice!=null?totalprice.toStringAsFixed(2):""}",style:TextStyle(color: PrimaryColor,fontSize: 17,fontWeight: FontWeight.w400),),
//                                   ),
//
//                                 ],
//                               ),
//                               Visibility(
//                                 visible:  voucherVisiblity,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: <Widget>[
//                                     Row(
//                                       children: [
//                                         Text(voucherValidity!=null?voucherValidity['result']['code']:"-",style: TextStyle(color: yellowColor,fontSize: 17,fontWeight: FontWeight.w400),),
//                                         SizedBox(width: 8,),
//                                         InkWell(
//                                             onTap: () {
//                                               setState(() {
//                                                 voucherValidity = null;
//                                                 voucherVisiblity =false;
//                                               });
//                                             },
//                                             child: Icon(Icons.delete_outline,color: blueColor,)),
//                                       ],
//                                     ),
//
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 70),
//                                       child: Text(voucherValidity!=null?"-"+voucherValidity['message']:"",style:TextStyle(color: PrimaryColor,fontSize: 17,fontWeight: FontWeight.w400),),
//                                     ),
//
//                                   ],
//                                 ),
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: <Widget>[
//                                   Text("Total",style: TextStyle(color: yellowColor,fontSize: 20,fontWeight: FontWeight.bold),),
//
//                                   Padding(
//                                     padding: const EdgeInsets.only(left: 70),
//                                     child: Text(
//                                           (){
//                                       if(voucherValidity!=null){
//                                         if(voucherValidity['result']!={}){
//                                           var grossTotal = totalprice - double.parse(voucherValidity['message'].toString());
//                                           applyVoucherPrice = totalprice - double.parse(voucherValidity['message'].toString());
//                                           print(grossTotal.toString()+"dfghjklkjvc");
//                                           if(grossTotal!=null)
//                                             return grossTotal!=null?grossTotal.toStringAsFixed(2):"";
//                                           else
//                                             return totalprice!=null?totalprice.toStringAsFixed(2):"";
//                                         }
//                                       }else{
//                                         applyVoucherPrice =null;
//                                          return totalprice!=null?totalprice.toStringAsFixed(2):"";
//                                       }
//                                     }()
//                                       ,style:TextStyle(color: PrimaryColor,fontSize: 20,fontWeight: FontWeight.bold),),
//                                   ),
//
//                                 ],
//                               ),
//                             ],
//                           ),
//                         )
//                     ),
//                   ),
//                 ),
//               ),
//               Visibility(
//                 visible: isvisible,
//                 child: InkWell(
//                   onTap: (){
//                     print(cartList[0].topping.runtimeType);
//
//                     orderItems.clear();
//                     setState(() {
//                       storeId = cartList!=null?cartList[0].storeId:"";
//                       for(int i=0;i<cartList.length;i++){
//                         orderItems.add({
//                           "dealid":cartList[i].dealId,
//                           "name":cartList[i].productName,
//                           "price":cartList[i].price,
//                           "quantity":cartList[i].quantity,
//                           "totalprice":cartList[i].totalPrice,
//                           "havetopping":cartList[i].topping=="null"||cartList[i].topping==null || cartList[i].topping== "[]" ?false:jsonDecode(cartList[i].topping).length>0?true:false,
//                           "sizeid":cartList[i].sizeId,
//                           "IsDeal": cartList[i].isDeal==0?false:true,
//                           "productid":cartList[i].productId,
//                           "orderitemstoppings":cartList[i].topping==null||cartList[i].topping == "[]"?[]:jsonDecode(cartList[i].topping),
//                         });
//                         if(cartList[i].topping == "[]" || cartList[i].topping == null) {
//                           print(cartList[i].topping);
//                         }
//                       }
//                       ordersList={
//                         //"ordertype":orderTypeId,
//                         "grosstotal":totalprice,
//                         "comment": addnotes.text,
//                         "orderitems":orderItems
//                       };
//                     });
//                     if(cartList!=null) {
//                       storeId = cartList[0].storeId;
//
//                       print(orderItems);
//                          if(tableId!=null){
//                            print(tableId.toString());
//                            Navigator.push(context, MaterialPageRoute(builder: (context) => CheckedoutWithTable(orderItems,totalprice,applyVoucherPrice,addnotes.text,voucherValidity!=null?voucherValidity['result']['code']:null,token,storeId,tableId)));
//
//                          }else{
//                            SharedPreferences.getInstance().then((prefs){
//                              print(prefs.getString("token"));
//                             // orderItems,totalprice,addnotes.text,voucherValidity[],prefs.getString("token"),storeId
//                              Navigator.push(context, MaterialPageRoute(builder: (context) => CheckedoutDetails(orderItems: orderItems,netTotal: totalprice,applyVoucherPrice: applyVoucherPrice,notes:addnotes.text,
//                              voucher: voucherValidity!=null?voucherValidity['result']['code']:null,token: prefs.getString("token"),storeId: storeId,)));
//                              // networksOperation.placeOrder(context, prefs.getString("token"), ordersList);
//
//                              WidgetsBinding.instance
//                                  .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
//                            });
//                          }
//
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.all(Radius.circular(10)) ,
//                         color: yellowColor,
//                       ),
//                       width: MediaQuery.of(context).size.width,
//                       height: 50,
//
//                       child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: <Widget>[
//                                 Text(translate('buttons.checkout'),style: TextStyle(color: BackgroundColor,fontSize: 20,fontWeight: FontWeight.bold),),
//
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 15),
//                                   child: FaIcon(FontAwesomeIcons.angleRight, color: BackgroundColor, size: 30,),
//                                 ),
//                               ],
//                             ),
//                           )
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//            Visibility(
//             visible: !isvisible && widget.ishome!=null,
//              child: InkWell(
//             onTap: (){
//             print(widget.ishome.toString());
//             if(widget.ishome!=null){
//             if(!widget.ishome)
//             Navigator.pop(context);
//             else {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => ClientNavBar(),));
//             }
//             }else {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => ClientNavBar(),));
//             }
//           },
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                  decoration: BoxDecoration(
//                 borderRadius: BorderRadius.all(Radius.circular(10)) ,
//                 color: yellowColor,
//               ),
//               width: MediaQuery.of(context).size.width,
//               height: 50,
//
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Padding(
//                         padding: const EdgeInsets.only(right: 35),
//                         child: FaIcon(Icons.arrow_back, color: BackgroundColor, size: 20,),
//                       ),
//                       Text("Back",style: TextStyle(color: BackgroundColor,fontSize: 20,fontWeight: FontWeight.bold),),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           ),
//         )
//             ],
//           ),
//         ):Center(
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: 320,
//             decoration: BoxDecoration(
//               //color: Colors.white60,
//                 image: DecorationImage(
//                   fit: BoxFit.cover,
//                   image: AssetImage('assets/emptycart.png'),
//                 )
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   showAlertDialog(BuildContext context) {
//     AlertDialog alert = AlertDialog(
//       title: Text("Add SubCategory / Product"),
//       // content: StatefulBuilder(
//       //   builder: (context, setState) {
//       //     return Column(
//       //       mainAxisSize: MainAxisSize.min,
//       //       children: <Widget>[
//       //         FlatButton(
//       //           child: Text("Add SubCategory"),
//       //           onPressed: () {
//       //             Navigator.push(context,MaterialPageRoute(builder: (context)=>add_Subcategory(id)));
//       //
//       //           },
//       //         ),
//       //         FlatButton(
//       //           child: Text("Add Product"),
//       //           onPressed: () {
//       //             Navigator.push(context,MaterialPageRoute(builder: (context)=>addProduct(widget.storeId, id, null,)));
//       //           },
//       //         )
//       //       ],
//       //     );
//       //   },
//       // ),
//     );
//
//     // show the dialog
//     showDialog(
//
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
// }

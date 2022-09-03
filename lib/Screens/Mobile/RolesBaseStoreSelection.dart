import 'dart:convert';
import 'dart:ui';

import 'package:exabistro_pos/model/Stores.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/constants.dart';
import '../LoginScreen.dart';
import 'Cart/POSCartScreenForMobile.dart';
import 'POSTabs/ForMobile/components/POSTabsComponent.dart';






class RoleBaseStoreSelectionForMobile extends StatefulWidget {
  List roles=[];

  RoleBaseStoreSelectionForMobile(
      this.roles); //StoreList(this.restaurantId); // StoreList({this.categoryId, this.subCategoryId});

  @override
  _categoryListPageState createState() => _categoryListPageState();
}


class _categoryListPageState extends State<RoleBaseStoreSelectionForMobile>{
  String token;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  // bool isVisible=false;
  List<Store> storeList=[];
  List rolesList=[],restaurantList=[];
 bool isVisible =false;
  @override
  void initState() {
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());

      restaurantList.clear();
      for(int i=0;i<widget.roles.length;i++){
      if(widget.roles[i]['restaurant']!=null){
        restaurantList.add(widget.roles[i]['restaurant']);
      }
      // if(widget.roles[i]['roleId'] == 2){
      //   isVisible =true;
      // }
    }

    Network_Operations.getRoles(context).then((value) {
      setState(() {
        rolesList = value;
      });
    });
    // TODO: implement initState
    super.initState();
  }
  String getRoleName (int id){
    String roleName;
    if(id!=null && rolesList!=null){
      for(int i=0;i<rolesList.length;i++){
        if(rolesList[i]['id'] == id){
            roleName = rolesList[i]['name'];
        }
      }
      return roleName;
    }else{
      return "";
    }

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor:  BackgroundColor,
          title: Text(translate("store_screen.appbar_title"), style: TextStyle(
              color: yellowColor,
              fontSize: 25,
            fontWeight: FontWeight.bold
          ),
          ),
          actions: [
            IconButton(
              icon:  FaIcon(FontAwesomeIcons.signOutAlt, color: blueColor, size: 25,),
              onPressed: (){
                SharedPreferences.getInstance().then((value) {
                  value.remove("token");
                  value.remove("roles");
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>LoginScreen()), (route) => false);
                } );
              },
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return _buildNormalContainers();
            } else {
              return _buildNormalContainers();
            }
          },
        ),
    );
  }
  // showAlertDialog(BuildContext context,int productId) {
  //   // set up the buttons
  //   Widget cancelButton = FlatButton(
  //     child: Text("Cancel"),
  //     onPressed: () {
  //       Navigator.pop(context);
  //     },
  //   );
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text("Add Size/Topping"),
  //     content: StatefulBuilder(
  //       builder: (context, setState) {
  //         return Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             FlatButton(
  //               child: Text("Add Sizes"),
  //               onPressed: () {
  //                // Navigator.push(context,MaterialPageRoute(builder: (context)=>add_Sizes()));
  //               },
  //             ),
  //             FlatButton(
  //               child: Text("Add Toppings"),
  //               onPressed: () {
  //                 Navigator.push(context,MaterialPageRoute(builder: (context)=>AddToppings(productId)));
  //               },
  //             )
  //           ],
  //         );
  //       },
  //     ),
  //     actions: [
  //       cancelButton,
  //       // SizeList,
  //       //  ToppingList
  //     ],
  //   );
  //
  //   // show the dialog
  //   showDialog(
  //
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  Widget _buildNormalContainers() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.2), BlendMode.dstATop),
            image: AssetImage('assets/bb.jpg'),
          ),
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: new Container(
        //decoration: new BoxDecoration(color: Colors.black.withOpacity(0.3)),
        child: ListView.builder(scrollDirection: Axis.vertical, itemCount:widget.roles == null ? 0:widget.roles.length, itemBuilder: (context,int index){
          return InkWell(
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder:(context)=> POSMobileScreenTab(store: widget.roles[index]['store'],)));
            },
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Card(
                elevation: 5,
                color: yellowColor,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  //height: 220,
                  decoration: BoxDecoration(
                      color: yellowColor,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                        elevation: 4,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            //border: Border.all(color: yellowColor)
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 3,),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      //image: AssetImage('assets/food6.jpeg',),
                                      image: NetworkImage(widget.roles[index]['restaurant']!=null&&widget.roles[index]['restaurant']["image"]!=null?widget.roles[index]['restaurant']["image"]:'http://www.4motiondarlington.org/wp-content/uploads/2013/06/No-image-found.jpg',),
                                    ),
                                    color: yellowColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: yellowColor, width: 1.5)
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: VerticalDivider(color: yellowColor,),
                              ),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 3,),
                                    Text(
                                      //"The Grand Paratha",
                                      "${widget.roles[index]['restaurant']!=null?widget.roles[index]['restaurant']['name']:" - "}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: yellowColor
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(translate("store_screen.store"),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: yellowColor
                                          ),
                                        ),
                                        Text(
                                          //"12345678",
                                          widget.roles[index]['store']!=null?widget.roles[index]['store']['name']:"",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:18,
                                              color: blueColor
                                          ),
                                        )
                                      ],
                                    ),

                                  ]
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        elevation: 4,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          //height: 180,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white)
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 2,),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    //borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: yellowColor)
                                ),
                                child:Row(
                                  children: [
                                    Container(
                                      width: 125,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: yellowColor,
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                                        //border: Border.all(color: yellowColor)
                                      ),
                                      child: Center(
                                        child: Text(translate("store_screen.role"), style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        ),),
                                      ),
                                    ),
                                    SizedBox(width: 2,),
                                    Text(
                                      //"The Grand Deals",
                                      "${getRoleName(widget.roles[index]['roleId'])}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: blueColor
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2,),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    //borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: yellowColor)
                                ),
                                child:Row(
                                  children: [
                                    Container(
                                      width: 125,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: yellowColor,
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                                        //border: Border.all(color: yellowColor)
                                      ),
                                      child: Center(
                                        child: Text(translate("store_screen.city"), style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        ),),
                                      ),
                                    ),
                                    SizedBox(width: 2,),
                                    Text(
                                      //"The Grand Deals",
                                      "${widget.roles[index]['store']['city']!=null?widget.roles[index]['store']['city']:""}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: blueColor
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2,),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    //borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: yellowColor)
                                ),
                                child:Row(
                                  children: [
                                    Container(
                                      width: 125,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: yellowColor,
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                                        //border: Border.all(color: yellowColor)
                                      ),
                                      child: Center(
                                        child: Text(translate("store_screen.open"), style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        ),),
                                      ),
                                    ),
                                    SizedBox(width: 2,),
                                    Text(
                                      //"The Grand Deals",
                                      "${widget.roles[index]['store']!=null?widget.roles[index]['store']['openTime']:""}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: blueColor
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2,),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    //borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: yellowColor)
                                ),
                                child:Row(
                                  children: [
                                    Container(
                                      width: 125,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: yellowColor,
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                                        //border: Border.all(color: yellowColor)
                                      ),
                                      child: Center(
                                        child: Text(translate("store_screen.close"), style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        ),),
                                      ),
                                    ),
                                    SizedBox(width: 2,),
                                    Text(
                                      //"The Grand Deals",
                                      "${widget.roles[index]['store']!=null?widget.roles[index]['store']['closeTime']:""}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: blueColor
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ) ,
                ),
              ),
            ),
          );
          // return InkWell(
          //   onTap: () {
          //     if(widget.roles[index]['roleId'] == 3||widget.roles[index]['roleId'] == 4) {
          //       Navigator.pushAndRemoveUntil(context,
          //           MaterialPageRoute(builder: (context) => AdminNavBar(storeId: widget.roles[index]['storeId'],roleId:widget.roles[index]['roleId'])), (
          //               Route<dynamic> route) => false);
          //     }else if(widget.roles[index]['roleId'] == 10 ) {
          //
          //       Navigator.pushAndRemoveUntil(context,
          //           MaterialPageRoute(builder: (context) => DeliveryBoyNavBar(widget.roles[index]['storeId'],widget.roles[index]['userId'])), (
          //               Route<dynamic> route) => false);
          //     }
          //     else if(widget.roles[index]['roleId'] == 7) {
          //       Navigator.pushAndRemoveUntil(context,
          //           MaterialPageRoute(builder: (context) => KitchenDashboard(widget.roles[index]['storeId'])), (
          //               Route<dynamic> route) => false);
          //     }
          //     else if(widget.roles[index]['roleId'] == 5) {
          //       Navigator.pushAndRemoveUntil(context,
          //           MaterialPageRoute(builder: (context) => StaffNavBar(widget.roles[index]['storeId'])), (
          //               Route<dynamic> route) => false);
          //     }
          //     else if(widget.roles[index]['roleId'] == 9){
          //       Navigator.pushAndRemoveUntil(context,
          //           MaterialPageRoute(builder: (context) => ClientNavBar()), (
          //               Route<dynamic> route) => false);
          //     }
          //   },
          //   child: Card(
          //     elevation: 8,
          //     //color: Colors.white24,
          //     child: Container(
          //       //height: 140,
          //       width: MediaQuery.of(context).size.width,
          //       decoration: BoxDecoration(
          //         //border: Border.all(color: yellowColor, width: 2),
          //         borderRadius: BorderRadius.circular(9)
          //       ),
          //       child: Column(
          //         children: [
          //           Row(
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.only(top: 8, left: 5, right: 1, bottom: 5),
          //                 child: Container(
          //                   width: 120,
          //                   height: 120,
          //                   decoration: BoxDecoration(
          //                       image: DecorationImage(
          //                         fit: BoxFit.fill,
          //                         image: NetworkImage(widget.roles[index]['image']!=null?widget.roles[index].image:'http://www.4motiondarlington.org/wp-content/uploads/2013/06/No-image-found.jpg',),
          //                       ),
          //                       //color: Colors.lightGreen,
          //                       borderRadius: BorderRadius.circular(10)
          //                   ),
          //                 ),
          //               ),
          //               Padding(
          //                 padding: const EdgeInsets.only(top: 8, left: 3, right: 2, bottom: 5),
          //                 child: Container(
          //                   width: 1,
          //                   height: 120,
          //                   color: Colors.grey.shade300,
          //                 ),
          //               ),
          //               Padding(
          //                 padding: const EdgeInsets.only(top: 8, left: 3, right: 2, bottom: 5),
          //                 child: Container(
          //                   width: MediaQuery.of(context).size.width/1.7,
          //                 //  height: 120,
          //                   color: Colors.white,
          //                   child: Column(
          //                     children: [
          //                       Row(
          //                         children: [
          //                           Padding(
          //                             padding: const EdgeInsets.only(right: 3),
          //                             child: FaIcon(FontAwesomeIcons.utensils, color: PrimaryColor, size: 17,),
          //                           ),
          //                           Container(width: MediaQuery.of(context).size.width/2,child: Text(" ${widget.roles[index]['restaurant']!=null?"Restaurant: "+widget.roles[index]['restaurant']['name']:" - "}",maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: yellowColor),)),
          //                         ],
          //                       ),
          //                       SizedBox(height: 5,),
          //                       Row(
          //                         children: [
          //                           Padding(
          //                             padding: const EdgeInsets.only(right: 1),
          //                             child: FaIcon(FontAwesomeIcons.storeAlt, color: PrimaryColor, size: 13,),
          //                           ),
          //                           Text(widget.roles[index]['store']!=null?"Branch: "+widget.roles[index]['store']['name']:"",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: yellowColor),),
          //                         ],
          //                       ),
          //                       SizedBox(height: 5,),
          //                       Row(
          //                         children: [
          //                           Padding(
          //                             padding: const EdgeInsets.only(right: 1),
          //                             child: FaIcon(FontAwesomeIcons.city, color: PrimaryColor, size: 13,),
          //                           ),
          //                           Text("City: ${widget.roles[index]['store']['city']!=null?widget.roles[index]['store']['city']:""}",style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold, fontSize: 17),),
          //                         ],
          //                       ),
          //                       SizedBox(height: 5,),
          //                       Row(
          //                         children: [
          //                           Padding(
          //                             padding: const EdgeInsets.only(right: 4),
          //                             child: FaIcon(FontAwesomeIcons.userTie, color: PrimaryColor, size: 13,),
          //                           ),
          //                           Text("Role: ${getRoleName(widget.roles[index]['roleId'])}",style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold, fontSize: 17),),
          //                         ],
          //                       ),
          //                       SizedBox(height: 3.5,),
          //                       Row(
          //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                         children: [
          //                           Row(
          //                             children: [
          //                               Padding(
          //                                 padding: const EdgeInsets.only(right: 3),
          //                                 child: FaIcon(FontAwesomeIcons.clock, color: PrimaryColor, size: 16,),
          //                               ),
          //                               Text("Open: ",style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold),),
          //                               Text("${widget.roles[index]['store']!=null?widget.roles[index]['store']['openTime']:""}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold),),
          //                             ],
          //                           ),
          //
          //                         ],
          //                       ),
          //                       Row(
          //                         children: [
          //                           Padding(
          //                             padding: const EdgeInsets.only(right: 3),
          //                             child: FaIcon(FontAwesomeIcons.clock, color: PrimaryColor, size: 16,),
          //                           ),
          //                           Text("Close: ",style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold),),
          //                           Text("${widget.roles[index]['store']!=null?widget.roles[index]['store']['closeTime']:""}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold),),
          //                         ],
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          // );
        }),
      ),
    );
  }
  // Widget _buildWideContainers() {
  //   return Container(
  //       decoration: BoxDecoration(
  //             image: DecorationImage(
  //               fit: BoxFit.cover,
  //               //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
  //               image: AssetImage('assets/bb.jpg'),
  //             )
  //         ),
  //     height: MediaQuery.of(context).size.height,
  //     width: MediaQuery.of(context).size.width,
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: GridView.builder(
  //           scrollDirection: Axis.horizontal,
  //           gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
  //               maxCrossAxisExtent: 500,
  //               childAspectRatio: 2 / 2,
  //               crossAxisSpacing: 20,
  //               mainAxisSpacing: 20),
  //           itemCount: widget.roles == null ? 0:widget.roles.length,
  //           itemBuilder: (context,int index){
  //             return Card(
  //               color: BackgroundColor,
  //               elevation: 8,
  //               child: InkWell(
  //                 onTap: () {
  //
  //                 },
  //                 child: Container(
  //                   //alignment: Alignment.center,
  //                   decoration: BoxDecoration(
  //                    // border: Border.all(color: yellowColor, width: 2),
  //                       borderRadius: BorderRadius.circular(4)),
  //                   child: Column(
  //                     children: [
  //                       Container(
  //                         decoration: BoxDecoration(
  //                             border: Border.all(color: yellowColor, width: 2),
  //                             image: DecorationImage(
  //                               fit: BoxFit.fill,
  //                               image: NetworkImage(widget.roles[index]['image']!=null?widget.roles[index].image:'http://www.4motiondarlington.org/wp-content/uploads/2013/06/No-image-found.jpg',),
  //                             ),
  //                             //color: Colors.lightGreen,
  //                             borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft:  Radius.circular(15) )),
  //                         width: MediaQuery.of(context).size.width,
  //                         height: 210,
  //                         //child: Image.network(widget.roles[index]['image']!=null?widget.roles[index].image:'http://www.4motiondarlington.org/wp-content/uploads/2013/06/No-image-found.jpg',fit: BoxFit.fill),
  //                       ),
  //                       Padding(padding: EdgeInsets.all(2),),
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 8, bottom: 5),
  //                         child: Row(
  //                           children: [
  //                             Padding(
  //                               padding: const EdgeInsets.only(right: 11),
  //                               child: FaIcon(FontAwesomeIcons.utensils, color: PrimaryColor, size: 15,),
  //                             ),
  //                             Text("Restaurant: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: yellowColor),),
  //                             Text("${widget.roles[index]['restaurant']!=null?widget.roles[index]['restaurant']['name']:" - "}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: PrimaryColor),),
  //                           ],
  //                         ),
  //                       ),
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 8, bottom: 2),
  //                         child: Row(
  //                           children: [
  //                             Padding(
  //                               padding: const EdgeInsets.only(right: 5),
  //                               child: FaIcon(FontAwesomeIcons.storeAlt, color: PrimaryColor, size: 15,),
  //                             ),
  //                             Text("Store: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: yellowColor),),
  //                             Text(widget.roles[index]['store']!=null?widget.roles[index]['store']['name']:" - ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: PrimaryColor),),
  //                           ],
  //                         ),
  //                       ),
  //                       Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Row(
  //                               children: [
  //                                 Padding(
  //                                   padding: const EdgeInsets.only(right: 7),
  //                                   child: FaIcon(FontAwesomeIcons.city, color: PrimaryColor, size: 15,),
  //                                 ),
  //                                 Text("City: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: yellowColor),),
  //                                 Text("${widget.roles[index]['store']['city']}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold, fontSize: 17),),
  //                               ],
  //                             ),
  //                             Row(
  //                                 children: [
  //                                   Padding(
  //                                       padding: const EdgeInsets.only(right: 5),
  //                                       child: FaIcon(FontAwesomeIcons.userTie, color: PrimaryColor, size: 20,),
  //                                   ),
  //                                   Text("Role: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: yellowColor),),
  //                                   Text("${getRoleName(widget.roles[index]['roleId'])}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold, fontSize: 17),),
  //                                 ],
  //                               ),
  //                           ],
  //                         ),
  //                       ),
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 4, right: 4),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Row(
  //                               children: [
  //                                 Padding(
  //                                   padding: const EdgeInsets.all(2.0),
  //                                   child: FaIcon(FontAwesomeIcons.clock, color: PrimaryColor),
  //                                 ),
  //                                 Text("Open: ",style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold),),
  //                                 Text("${widget.roles[index]['store']!=null?widget.roles[index]['store']['openTime']:""}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold),),
  //                               ],
  //                             ),
  //                             Row(
  //                               children: [
  //                                 Padding(
  //                                   padding: const EdgeInsets.all(2.0),
  //                                   child: FaIcon(FontAwesomeIcons.clock, color: PrimaryColor),
  //                                 ),
  //                                 Text("Close: ",style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold),),
  //                                 Text("${widget.roles[index]['store']!=null?widget.roles[index]['store']['closeTime']:""}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold),),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             );
  //           }),
  //     ),
  //   );
  // }
}


import 'dart:ui';
import 'package:exabistro_pos/Screens/AdminNavbarForTablet.dart';
import 'package:exabistro_pos/Screens/LoginScreen.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/constants.dart';
import '../model/Stores.dart';






class RoleBaseStoreSelection extends StatefulWidget {
  List roles=[];

  RoleBaseStoreSelection(
      this.roles); //StoreList(this.restaurantId); // StoreList({this.categoryId, this.subCategoryId});

  @override
  _categoryListPageState createState() => _categoryListPageState();
}


class _categoryListPageState extends State<RoleBaseStoreSelection>{
  String token;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  // bool isVisible=false;
  List<Store> storeList=[];
  List rolesList=[],restaurantList=[];
 bool isVisible =false;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    print(widget.roles[0]['store']);
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
          centerTitle: true,
          backgroundColor:  BackgroundColor,
          title: Text("Select Branch", style: TextStyle(
              color: yellowColor,
              fontSize: 25,
            fontWeight: FontWeight.bold
          ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return _buildWideContainers();
            }
            return _buildWideContainers();
          },
        ),
    );
  }


  Widget _buildWideContainers() {
    return Container(
        decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                image: AssetImage('assets/bb.jpg'),
              )
          ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 1,
            itemBuilder: (context, index){
              return Padding(
                padding: const EdgeInsets.only(top: 70.0, bottom: 70, left: 8, right: 8),
                child: InkWell(
                            onTap: () {
                              Navigator.push(context,MaterialPageRoute(builder:(context)=>AdminNavBarForTablet(store: widget.roles[index]['store'],)));
                            },
                  child: Container(
                    height: 310,
                    width: 420,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(75), bottomLeft: Radius.circular(75)),
                        //borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/bb.jpg")
                        )
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          //height: 550,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(75), bottomLeft: Radius.circular(75)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 7,
                                blurRadius: 6,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                            //color: yellowColor,
                          ),
                          child: Column(
                            children: [
                              Container(
                                color: yellowColor,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 250,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(35), bottomLeft: Radius.circular(35)),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(widget.roles[index]['restaurant']["image"]!=null?widget.roles[index]['restaurant']["image"]:'http://www.4motiondarlington.org/wp-content/uploads/2013/06/No-image-found.jpg',),
                                      )
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: yellowColor,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Text(
                                                //'Riyaal',
                                                "${widget.roles[index]['store']['currencyCode']}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  //fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Row(
                                          //   mainAxisSize: MainAxisSize.min,
                                          //   children: List.generate(5, (i) {
                                          //     // return Icon(
                                          //     //   //i < int.parse(storeList[index].overallRating.toString().replaceAll(".0", "")) ? Icons.star : Icons.star_border,color: yellowColor,
                                          //     // );
                                          //   }),
                                          // ),
                                        ],
                                      ),
                                      SizedBox(height: 170,),
                                      Row(
                                        children: [
                                          SizedBox(width: 5,),
                                          Visibility(
                                            visible: widget.roles[index]['store']['dineIn']!=null&&widget.roles[index]['store']['dineIn'],
                                            child: Container(
                                              width: 105,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: yellowColor,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Dine-In',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    //fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Visibility(
                                            visible: widget.roles[index]['store']['takeAway']!=null&&widget.roles[index]['store']['takeAway'],
                                            child: Container(
                                              width: 105,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: yellowColor,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Take-Away',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    //fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Visibility(
                                            visible: widget.roles[index]['store']['delivery']!=null&&widget.roles[index]['store']['delivery'],
                                            child: Container(
                                              width: 105,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: yellowColor,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Delivery',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    //fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: yellowColor,
                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(35), bottomLeft: Radius.circular(35)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      //"Palatial Hotel",
                                      "${widget.roles[index]['restaurant']!=null?widget.roles[index]['restaurant']['name']:" - "}",
                                      style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: yellowColor,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(35), bottomLeft: Radius.circular(35)),
                                  ),
                                  child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Store: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: yellowColor),),
                                      Text(widget.roles[index]['store']!=null?widget.roles[index]['store']['name']:" - ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: PrimaryColor),),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: yellowColor,
                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(35), bottomLeft: Radius.circular(35)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("City: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.white),),
                                      Text("${widget.roles[index]['store']['city']}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold, fontSize: 22),),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                color: yellowColor,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(35), bottomLeft: Radius.circular(35)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Role: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: yellowColor),),
                                      Text("${getRoleName(widget.roles[index]['roleId'])}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold, fontSize: 22),),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: yellowColor,
                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(35), bottomLeft: Radius.circular(35)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.clock, color: PrimaryColor, size: 25,),
                                      SizedBox(width: 10,),
                                      Text("${widget.roles[index]['store']!=null?widget.roles[index]['store']['openTime']:""}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 25),),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(35), bottomLeft: Radius.circular(35)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.clock, color: PrimaryColor, size: 25,),
                                      SizedBox(width: 10,),
                                      Text("${widget.roles[index]['store']!=null?widget.roles[index]['store']['closeTime']:""}",style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold, fontSize: 25),),
                                    ],
                                  ),
                                ),
                              ),
                              // Container(
                              //   color: yellowColor,
                              //   child: Container(
                              //     width: MediaQuery.of(context).size.width,
                              //     height: 60,
                              //     decoration: BoxDecoration(
                              //       color: yellowColor,
                              //       borderRadius: BorderRadius.only(bottomRight: Radius.circular(35), bottomLeft: Radius.circular(35)),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
        // child: GridView.builder(
        //     scrollDirection: Axis.horizontal,
        //     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        //         maxCrossAxisExtent: 400,
        //         childAspectRatio: 2 / 3,
        //         crossAxisSpacing: 20,
        //         mainAxisSpacing: 20),
        //     itemCount: widget.roles == null ? 0:widget.roles.length,
        //     itemBuilder: (context,int index){
        //       return Card(
        //         color: BackgroundColor,
        //         elevation: 8,
        //         child: InkWell(
        //           onTap: () {
        //             Navigator.push(context,MaterialPageRoute(builder:(context)=>AdminNavBarForTablet(store: widget.roles[index]['store'],)));
        //           },
        //           child: Container(
        //             child: Row(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Container(
        //                   height: 400,
        //                   width: 250,
        //                   decoration: BoxDecoration(
        //                     color: yellowColor,
        //                     borderRadius: BorderRadius.circular(4),
        //                                 image: DecorationImage(
        //                                   fit: BoxFit.fill,
        //                                   image: NetworkImage(widget.roles[index]['restaurant']["image"]!=null?widget.roles[index]['restaurant']["image"]:'http://www.4motiondarlington.org/wp-content/uploads/2013/06/No-image-found.jpg',),
        //                                 ),
        //                   ),
        //                 ),
        //                 VerticalDivider(),
        //                 Column(
        //                   children: [
        //                     SizedBox(height: 5,),
        //                     Card(
        //                       elevation: 6,
        //                       child: Container(
        //                         width: 314,
        //                         height: 60,
        //                         decoration: BoxDecoration(
        //                           color: yellowColor,
        //                           borderRadius: BorderRadius.circular(4),
        //                         ),
        //                         child: Center(child: Text("${widget.roles[index]['restaurant']!=null?widget.roles[index]['restaurant']['name']:" - "}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.white),)),
        //                       ),
        //                     ),
        //                     Card(
        //                       elevation: 6,
        //                       child: Container(
        //                         width: 314,
        //                         height: 50,
        //                         child: Padding(
        //                           padding: const EdgeInsets.all(4.0),
        //                           child: Row(
        //                             children: [
        //                               Text("Store: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: yellowColor),),
        //                               Text(widget.roles[index]['store']!=null?widget.roles[index]['store']['name']:" - ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: PrimaryColor),),
        //                                       ],
        //                                     ),
        //                         ),
        //                       ),
        //                     ),
        //                     Card(
        //                       elevation: 6,
        //                       child: Container(
        //                         width: 314,
        //                         height: 50,
        //                         child: Padding(
        //                           padding: const EdgeInsets.all(4.0),
        //                           child: Row(
        //                             children: [
        //                               Text("City: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: yellowColor),),
        //                               Text("${widget.roles[index]['store']['city']}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold, fontSize: 22),),
        //                             ],
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                     Card(
        //                       elevation: 6,
        //                       child: Container(
        //                         width: 314,
        //                         height: 50,
        //                         child: Padding(
        //                           padding: const EdgeInsets.all(4.0),
        //                           child: Row(
        //                             children: [
        //                               Text("Role: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: yellowColor),),
        //                               Text("${getRoleName(widget.roles[index]['roleId'])}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold, fontSize: 22),),
        //                             ],
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                     SizedBox(height: 5,),
        //                     Card(
        //                       elevation: 6,
        //                       color: yellowColor,
        //                       child: Container(
        //                         width: 314,
        //                         height: 40,
        //                         color: yellowColor,
        //                         child: Padding(
        //                           padding: const EdgeInsets.all(4.0),
        //                           child: Row(
        //                             mainAxisAlignment: MainAxisAlignment.center,
        //                             children: [
        //                               FaIcon(FontAwesomeIcons.clock, color: PrimaryColor, size: 25,),
        //                               SizedBox(width: 10,),
        //                               Text("${widget.roles[index]['store']!=null?widget.roles[index]['store']['openTime']:""}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 25),),
        //                             ],
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                     Padding(
        //                       padding: const EdgeInsets.all(4.0),
        //                       child: Center(child: Text("- To -",style: TextStyle(color: blueColor,fontWeight: FontWeight.bold, fontSize: 25),)),
        //                     ),
        //                     Card(
        //                       elevation: 6,
        //                       color: yellowColor,
        //                       child: Container(
        //                         width: 314,
        //                         height: 40,
        //                         color: yellowColor,
        //                         child: Padding(
        //                           padding: const EdgeInsets.all(4.0),
        //                           child: Row(
        //                             mainAxisAlignment: MainAxisAlignment.center,
        //                             children: [
        //                               FaIcon(FontAwesomeIcons.clock, color: PrimaryColor, size: 25,),
        //                               SizedBox(width: 10,),
        //                               Text("${widget.roles[index]['store']!=null?widget.roles[index]['store']['closeTime']:""}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 25),),
        //                             ],
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ],
        //             )
        //           )
        //         ),
        //       );
        //     }),
      ),
    );
  }
}


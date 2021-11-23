import 'dart:ui';
import 'package:exabistro_pos/Screens/AdminNavbarForTablet.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    print(widget.roles[0]['restaurant']);
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
        child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20),
            itemCount: widget.roles == null ? 0:widget.roles.length,
            itemBuilder: (context,int index){
              return Card(
                color: BackgroundColor,
                elevation: 8,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,MaterialPageRoute(builder:(context)=>AdminNavBarForTablet(store: widget.roles[index]['store'],)));
                  },
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: 250,
                          decoration: BoxDecoration(
                            color: yellowColor,
                            borderRadius: BorderRadius.circular(4),
                                        image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: NetworkImage(widget.roles[index]['restaurant']["image"]!=null?widget.roles[index]['restaurant']["image"]:'http://www.4motiondarlington.org/wp-content/uploads/2013/06/No-image-found.jpg',),
                                        ),
                          ),
                        ),
                        VerticalDivider(),
                        Column(
                          children: [
                            SizedBox(height: 5,),
                            Card(
                              elevation: 6,
                              child: Container(
                                width: MediaQuery.of(context).size.width /4,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: yellowColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(child: Text("${widget.roles[index]['restaurant']!=null?widget.roles[index]['restaurant']['name']:" - "}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.white),)),
                              ),
                            ),
                            Card(
                              elevation: 6,
                              child: Container(
                                width: MediaQuery.of(context).size.width /4,
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      Text("Store: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: yellowColor),),
                                      Text(widget.roles[index]['store']!=null?widget.roles[index]['store']['name']:" - ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: PrimaryColor),),
                                              ],
                                            ),
                                ),
                              ),
                            ),
                            Card(
                              elevation: 6,
                              child: Container(
                                width: MediaQuery.of(context).size.width /4,
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      Text("City: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: yellowColor),),
                                      Text("${widget.roles[index]['store']['city']}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold, fontSize: 22),),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              elevation: 6,
                              child: Container(
                                width: MediaQuery.of(context).size.width /4,
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      Text("Role: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: yellowColor),),
                                      Text("${getRoleName(widget.roles[index]['roleId'])}",style: TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold, fontSize: 22),),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5,),
                            Card(
                              elevation: 6,
                              color: yellowColor,
                              child: Container(
                                width: MediaQuery.of(context).size.width /4,
                                height: 40,
                                color: yellowColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Center(child: Text("- To -",style: TextStyle(color: blueColor,fontWeight: FontWeight.bold, fontSize: 25),)),
                            ),
                            Card(
                              elevation: 6,
                              color: yellowColor,
                              child: Container(
                                width: MediaQuery.of(context).size.width /4,
                                height: 40,
                                color: yellowColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.clock, color: PrimaryColor, size: 25,),
                                      SizedBox(width: 10,),
                                      Text("${widget.roles[index]['store']!=null?widget.roles[index]['store']['closeTime']:""}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 25),),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  )
                ),
              );
            }),
      ),
    );
  }
}


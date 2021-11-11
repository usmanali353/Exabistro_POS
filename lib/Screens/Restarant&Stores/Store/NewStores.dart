import 'package:exabistro_pos/Screens/Orders/components/TabsComponent.dart';
import 'package:exabistro_pos/Screens/POSMainScreen.dart';
import 'package:exabistro_pos/Screens/Restarant&Stores/AdminNavBar(Tablet).dart';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:exabistro_pos/model/Stores.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewStores extends StatefulWidget {
  var restaurant,roleId;


  NewStores(this.restaurant,this.roleId);


  @override
  _NewStoresState createState() => _NewStoresState();
}

class _NewStoresState extends State<NewStores> {
  String token;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<Store> storeList=[];

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    SharedPreferences.getInstance().then((value) {
      setState(() {
        this.token = value.getString("token");
      });
    });

    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.add, color: yellowColor,size:25,),
        //     onPressed: (){
        //       Navigator.push(context, MaterialPageRoute(builder: (context)=> AddStore(widget.restaurant)));
        //     },
        //   ),
        // ],
        iconTheme: IconThemeData(
            color: yellowColor
        ),
        centerTitle: true,
        backgroundColor:  BackgroundColor,
        title: Text("Store List", style: TextStyle(
            color: yellowColor, fontSize: 25, fontWeight: FontWeight.bold
        ),
        ),
      ),
      body:  LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeRight,
              DeviceOrientation.landscapeLeft,
            ]);
            return _buildWideContainers();
          }
          return _buildWideContainers();
        },
      ),
    );
  }



  Widget _buildWideContainers() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: (){
        return Utils.check_connectivity().then((result){
          if(result){
            var storeData={
              "RestaurantId": widget.restaurant['id'],
              "IsProduct": false,

            };
            Network_Operations.getAllStoresByRestaurantId(context,storeData).then((value){
              setState(() {
                storeList = value;

              });
            });
          }else{
            Utils.showError(context, "Network Error");
          }
        });
      },
      child: Container(
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
                  maxCrossAxisExtent: 500,
                  childAspectRatio: 2 / 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20),
              itemCount: storeList == null ? 0:storeList.length,
              itemBuilder: (context,int index){
                return Card(
                  color: BackgroundColor,
                  elevation: 8,
                  child: InkWell(
                   onTap: (){

                     Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminNavBarForTablet(storeId: storeList[index].id,)));
                   },
                    child: Container(
                      //alignment: Alignment.center,
                      decoration: BoxDecoration(
                        // border: Border.all(color: yellowColor, width: 2),
                          borderRadius: BorderRadius.circular(4)),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                //border: Border.all(color: yellowColor, width: 2),
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                      storeList[index].image!=null?storeList[index].image:"http://www.4motiondarlington.org/wp-content/uploads/2013/06/No-image-found.jpg"
                                  ),
                                ),
                                //color: Colors.lightGreen,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft:  Radius.circular(8) )),
                            width: MediaQuery.of(context).size.width,
                            height: 210,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 125,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(4),
                                //border: Border.all(color: Colors.orange, width: 1)
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: yellowColor,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Text(
                                              //'Riyaal',
                                              "${storeList[index].currencyCode!=null?storeList[index].currencyCode:'-'}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                //fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(5, (i) {
                                            return Icon(
                                              i < int.parse(storeList[index].overallRating.toString().replaceAll(".0", "")) ? Icons.star : Icons.star_border,color: yellowColor,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 140,),
                                  Row(
                                    children: [
                                      SizedBox(width: 5,),
                                      Visibility(
                                        visible: storeList[index].dineIn!=null?storeList[index].dineIn:false,
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
                                        visible: storeList[index].takeAway!=null?storeList[index].takeAway:false,
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
                                        visible: storeList[index].delivery!=null?storeList[index].delivery:false,
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
                            //child: Image.network(widget.roles[index]['image']!=null?widget.roles[index].image:'http://www.4motiondarlington.org/wp-content/uploads/2013/06/No-image-found.jpg',fit: BoxFit.fill),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 35,
                            color: yellowColor,
                            child: Center(
                              child: Text(
                                //'Store Name',
                                "${storeList[index].name}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  //fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  //color: yellowColor,
                                  borderRadius: BorderRadius.circular(8),
                                  //border: Border.all(color: Colors.orange, width: 5)
                                ),
                                child: Center(child: FaIcon(FontAwesomeIcons.mapMarkerAlt, size: 22, color: yellowColor,)),
                              ),
                              SizedBox(width: 8,),
                              Container(
                                width: 310,
                                child: Text(
                                  //'Kashmir Plaza, Ramtalai Road, Gujrat',
                                  "${storeList[index].address}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: blueColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    //fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  //color: yellowColor,
                                  borderRadius: BorderRadius.circular(8),
                                  //border: Border.all(color: Colors.orange, width: 5)
                                ),
                                child: Center(child: FaIcon(FontAwesomeIcons.mobileAlt, size: 22, color: yellowColor,)),
                              ),
                              SizedBox(width: 8,),
                              Text(
                                //'0096 5522 8882 2211',
                                "${storeList[index].cellNo}",
                                style: TextStyle(
                                  color: blueColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  //fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: FaIcon(FontAwesomeIcons.clock, color: PrimaryColor),
                                    ),
                                    Text("Open: ",style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold),),
                                    Text(
                                      // '00:00:00',
                                      storeList[index]. openTime!=null?storeList[index]. openTime:"-",style: TextStyle(  color: blueColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,),

                                    ),                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: FaIcon(FontAwesomeIcons.clock, color: PrimaryColor),
                                    ),
                                    Text("Close: ",style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold),),
                                    Text(
                                      //'00:00:00',
                                      storeList[index].closeTime!=null?storeList[index].closeTime:"-",style: TextStyle(  color: blueColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,),
                                    ),                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
// class TrapeziumClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(size.width * 2/3, 0.0);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0.0, size.height);
//     path.close();
//     return path;
//   }
//   @override
//   bool shouldReclip(TrapeziumClipper oldClipper) => false;
// }
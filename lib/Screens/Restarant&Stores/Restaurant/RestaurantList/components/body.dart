
import 'package:exabistro_pos/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../LoginScreen.dart';
import '../../../Store/NewStores.dart';
import '../constants.dart';
import 'product_card.dart';


class RestaurantBody extends StatefulWidget {
  List restaurant=[];var roleId;

  RestaurantBody(this.restaurant,this.roleId);

  @override
  _BodyState createState() => _BodyState(restaurant);
}

class _BodyState extends State<RestaurantBody> {
  List requestList=[];

  _BodyState(this.requestList);

  var selectedPreference;

  var token;


  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      setState(() {
        this.token = value.getString("token");
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Stack(
            children: [
              Positioned(
                  top: 10,right: 15,
                  child: InkWell(
                      child: FaIcon(FontAwesomeIcons.signOutAlt,color: blueColor,),onTap: () {
                    SharedPreferences.getInstance().then((value) {
                      value.remove("token");
                      value.remove("reviewToken");
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
                    } );
                  })),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text("Restaurants", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: BackgroundColor),),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          // SearchBox(onChanged: (value) {}),
          // CategoryList(),

          Expanded(
            child: Stack(
              children: <Widget>[
                // Our background
                Container(
                  margin: EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    image: DecorationImage(
                    fit: BoxFit.cover,
                    //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                    image: AssetImage('assets/bb.jpg'),
                    ),

                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                ),
                ListView.builder(
                  // here we use our demo procuts list
                  itemCount: requestList!=null?requestList.length:0,
                  itemBuilder: (context, index) => ProductCard(
                    itemIndex: index,
                    product: requestList[index],
                    press: () {
                      if(requestList[index]['statusId'] == 1){
                       /// Navigator.push(context, MaterialPageRoute(builder: (context) => StoresTabsScreen(requestList[index],widget.roleId),),);
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => CustomTabApp(requestList[index],widget.roleId),),);
                         Navigator.push(context, MaterialPageRoute(builder: (context) => NewStores( requestList[index],widget.roleId),),);
                      }
                    //  showAlertDialog(context,requestList[index]['id']);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}


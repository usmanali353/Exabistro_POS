
import 'package:exabistro_pos/Screens/LoginScreen.dart';
import 'package:exabistro_pos/Screens/Restarant&Stores/Store/NewStores.dart';
import 'package:exabistro_pos/Screens/Restarant&Stores/Store/stores_list.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RestaurantsListForTablet extends StatefulWidget {
  List restaurant =[];var roleId;


  RestaurantsListForTablet(this.restaurant,this.roleId);

  @override
  _RestaurantsListForTabletState createState() => _RestaurantsListForTabletState(restaurant);
}

class _RestaurantsListForTabletState extends State<RestaurantsListForTablet> {
  List requestList=[];
  _RestaurantsListForTabletState(this.requestList);
  var selectedPreference;
  var token;
  var product;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        this.token = value.getString("token");
      });
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon:  FaIcon(FontAwesomeIcons.signOutAlt, color: yellowColor, size: 25,),
            onPressed: (){
              SharedPreferences.getInstance().then((value) {
                value.remove("token");
                value.remove("reviewToken");
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
              } );
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: BackgroundColor,
        title: Text("Restaurants", style: TextStyle(
            color: yellowColor,
            fontSize: 25,
            fontWeight: FontWeight.bold
        ),
        ),
      ),
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
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
                itemCount: requestList!=null?requestList.length:0,
                //widget.roles == null ? 0:widget.roles.length,
                itemBuilder: (context, index) => StoresCard(
                  itemIndex: index,
                  product: requestList[index],
                  press: () {
                    print("gh");
                    if(requestList[index]['statusId'] == 1){
                      /// Navigator.push(context, MaterialPageRoute(builder: (context) => StoresTabsScreen(requestList[index],widget.roleId),),);
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => CustomTabApp(requestList[index],widget.roleId),),);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NewStores( requestList[index],widget.roleId),),);
                    }
                    //  showAlertDialog(context,requestList[index]['id']);
                  },
                ),
            ),
          )
      ),
    );
  }
}

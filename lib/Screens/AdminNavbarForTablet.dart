import 'package:exabistro_pos/Screens/OrdersHistoryTab/Components/TabsComponent.dart';
import 'package:exabistro_pos/Screens/OrdersHistoryTab/Components/TabsComponents.dart';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/components/paint/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart';
import 'POSMainScreen.dart';




class AdminNavBarForTablet extends StatefulWidget {
  var storeId,roleId,resturantId;

  AdminNavBarForTablet({this.resturantId,this.storeId,this.roleId});

  @override
  _AdminNavBarState createState() => _AdminNavBarState();
}

class _AdminNavBarState extends State<AdminNavBarForTablet> {
  int currentPage = 0
  ;
  GlobalKey bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    print(widget.storeId);
    SharedPreferences.getInstance().then((prefs) {
      var claims = Utils.parseJwt(prefs.getString('token'));
      print(claims['nameid'].toString());
      print(DateTime.now());
      print(DateTime.fromMillisecondsSinceEpoch(
          int.parse(claims['exp'].toString() + "000")));
      if (DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString() + "000")).isBefore(DateTime.now())) {
        Utils.showError(context, "Token Expire Please Login Again");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      } else {
        // Utils.showError(context, "Error Found: ");
      }
    });

    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text("Fancy Bottom Navigation"),
//      ),

      body: Container(
        //decoration: BoxDecoration(color: Colors.white),
        child: Center(
          child: _getPage(currentPage),
        ),
      ),
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(
            iconData:Icons.view_quilt_outlined,
            title: "POS Dashboard",
          ),
          TabData(
              iconData: Icons.fastfood,
              title: "Orders"
          ),
          TabData(
              iconData: Icons.access_time,
              title: "History"
          ),
        ],
        initialSelection: 0,
        key: bottomNavigationKey,
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
          });
        },
      ),
    );
  }


  _getPage(int page) {
    switch (page) {
      case 0:
        return POSMainScreen(storeId:widget.storeId);
    //return AdminProfile(widget.storeId,widget.roleId);
      case 1:
        return OrderListsTabsScreen(storeId:widget.storeId);
      case 2:
        return OrderRecordTabsScreen(storeId:widget.storeId);
        //return OrderListsTabsScreen(storeId:widget.storeId);
      default:
        return POSMainScreen(storeId: widget.storeId);
    }
  }
}
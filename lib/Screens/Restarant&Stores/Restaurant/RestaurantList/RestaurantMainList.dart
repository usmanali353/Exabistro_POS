import 'package:exabistro_pos/Screens/Restarant&Stores/Restaurant/RestaurantList(Tablet).dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'components/body.dart';
import 'constants.dart';

class RestaurantScreen extends StatelessWidget {
  List restaurant =[];var roleId;

  RestaurantScreen(this.restaurant,this.roleId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      //appBar: buildAppBar(),
      backgroundColor: kPrimaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
        return RestaurantsListForTablet(restaurant,roleId);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return  RestaurantBody(restaurant,roleId);
      }
    },
    ),
    );
  }
}

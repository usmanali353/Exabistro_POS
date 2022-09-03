import 'dart:convert';
import 'dart:ui';
import 'package:exabistro_pos/Screens/LoadingScreen.dart';
import 'package:exabistro_pos/Screens/Mobile/RolesBaseStoreSelection.dart';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/Utils/constants.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RolesBaseStoreSelection.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var responseJson;
  TextEditingController email,password,admin;
  bool isVisible= true;
  bool isLogin = false;
  bool isLoading=false;
  bool isTablet;
  List rolesAndStores =[],restaurantList=[];
  @override
  void initState(){

    this.email=TextEditingController();
    this.password=TextEditingController();
    this.admin=TextEditingController();

          SharedPreferences.getInstance().then((instance) {
            var token = instance.getString("token");
            if(token!=null&&token.isNotEmpty){
              var claims = Utils.parseJwt(token);
              if(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")).isBefore(DateTime.now())){
                Utils.showSuccess(context, translate("error_messages.token_expire_please_login_again"));
              }else{
                setState(() {
                  email.text = instance.getString("email");
                  password.text = instance.getString('password');
                  List decoded= jsonDecode(instance.getString("roles"));
                  for(int i=0;i<decoded.length;i++){
                    rolesAndStores.add(decoded[i]);
                    restaurantList.add(decoded[i]['restaurant']);
                  }
                  var shortestSide = MediaQuery.of(context).size.shortestSide;
                  final bool useMobileLayout = shortestSide < 600;
                  if(!useMobileLayout){
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) =>
                            RoleBaseStoreSelection(rolesAndStores)), (
                            Route<dynamic> route) => false);
                  }else{
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) =>
                            RoleBaseStoreSelectionForMobile(rolesAndStores)), (
                            Route<dynamic> route) => false);
                  }

                });
              }

            }
          });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {

              isTablet=true;
              print("isTablet "+isTablet.toString());

            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeRight,
              DeviceOrientation.landscapeLeft,
            ]);
            return _buildWideContainers();
          }else{
              isTablet=false;
              print("isTablet "+isTablet.toString());
            return _buildSmallContainers();
          }

        },
      ),
    );
  }

  Widget _buildWideContainers() {
    return isLoading?LoadingScreen():Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
            image: AssetImage('assets/bb.jpg'),
          )
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          new Container(
            //decoration: new BoxDecoration(color: Colors.black.withOpacity(0.3)),
            child: Column(
              children: <Widget>[
                SizedBox(height: 70,),
                // Padding(
                //   padding: const EdgeInsets.only(top: 40),
                //   child: Row(
                //     //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: <Widget>[
                //       IconButton(
                //         icon: Icon(Icons.arrow_back, color: yellowColor,size:30),
                //         onPressed: (){
                //           Navigator.pop(context);
                //         },
                //       ),
                //     ],
                //   ),
                // ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height / 2.9,
                      child: Center(child: Image.asset(
                        "assets/caspian11.png",
                        fit: BoxFit.fill,
                      ),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)) ,
                        border: Border.all(color: yellowColor, width: 2),
                        color: Colors.white24,
                      ),
                      height: LocalizedApp.of(context).delegate.currentLocale.languageCode=="ar"||LocalizedApp.of(context).delegate.currentLocale.languageCode=="ur"?370:330,
                      width: 510,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Text(translate('SignIn_screen.welcom_title'),style: TextStyle(
                                color: yellowColor,
                                fontSize: 35,
                                fontWeight: FontWeight.bold
                            )),
                          ),
                          Center(
                            child: Text(translate('SignIn_screen.title2'),style: TextStyle(
                                color: PrimaryColor,
                                fontSize: 25
                            )),
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: email,
                              style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold),
                              obscureText: false,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: yellowColor, width: 1.0)
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: PrimaryColor, width: 1.0)
                                ),
                                labelText: translate('SignIn_screen.emailTitle'),
                                labelStyle: TextStyle(color: yellowColor, fontWeight: FontWeight.bold),
                                suffixIcon: Icon(Icons.email,color: yellowColor,size: 27,),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: password,
                              style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold),
                              obscureText: isVisible,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: yellowColor, width: 1.0)
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: PrimaryColor, width: 1.0)
                                ),
                                labelText: translate('SignIn_screen.passwordTitle'),
                                labelStyle: TextStyle(color: yellowColor, fontWeight: FontWeight.bold),
                                suffixIcon: IconButton(icon: Icon(isVisible?Icons.visibility:Icons.visibility_off,color: yellowColor,size: 27),onPressed: () {
                                  setState(() {
                                    if(isVisible){
                                      isVisible= false;
                                    }else{
                                      isVisible= true;
                                    }
                                  });


                                },),//Icon(Icons.https,color: yellowColor,size: 27,)
                              ),

                            ),
                          ),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: (){
                              if(email.text==null||email.text.isEmpty){
                                Utils.showError(context, translate("in_app_errors.email_is_required") );
                              }else if(!Utils.validateEmail(email.text)){
                                Utils.showError(context, translate("in_app_errors.email_format_is_invalid") );
                              }
                              else if(password.text==null||password.text.isEmpty){
                                Utils.showError(context, translate("in_app_errors.password_is_Required") );
                              }else if(!Utils.validateStructure(password.text)){
                                Utils.showError(context, translate("in_app_errors.Password must contain atleast one lower case,Upper case and special characters") );
                              }else{
                                setState(() {
                                  isLoading=true;
                                });
                                Network_Operations.signIn(context, email.text, password.text,isTablet).then((value){
                                  setState(() {
                                    isLoading=false;
                                  });
                                });
                                // Utils.check_connectivity().then((isConnected){
                                //   if(isConnected){
                                //
                                //   }else{
                                //     setState(() {
                                //       Utils.showError(context,"Network Problem");
                                //       isLoading=false;
                                //     });
                                //   }
                                //
                                // });


                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)) ,
                                  color: yellowColor,
                                ),
                                height: 70,
                                width: 500,

                                child: Center(
                                  child: Text(translate('buttons.signIn'),style: TextStyle(color: BackgroundColor,fontSize: 20,fontWeight: FontWeight.bold),),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),

                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 70, top: 10),
            child: InkWell(
              onTap: (){
                onActionSheetPress(context);
              },

              child: Center(
                child: Text(translate("button.change_language"),
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: PrimaryColor,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallContainers() {
    return isLoading?LoadingScreen():Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
            image: AssetImage('assets/bb.jpg'),
          )
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: new Container(
          //decoration: new BoxDecoration(color: Colors.black.withOpacity(0.3)),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      child: IconButton(
                        icon:  FaIcon(FontAwesomeIcons.language, color: yellowColor, size: 40,),
                        onPressed: () => onActionSheetPress(context),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height / 2.9,
                    child: Center(child: Image.asset(
                      "assets/caspian11.png",
                      fit: BoxFit.fill,
                    ),
                    ),
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)) ,
                      border: Border.all(color: yellowColor, width: 2),
                      color: Colors.white24,
                    ),
                    height: LocalizedApp.of(context).delegate.currentLocale.languageCode=="ur"||LocalizedApp.of(context).delegate.currentLocale.languageCode=="ar"?360:340,
                    width: 510,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text(translate('SignIn_screen.welcom_title'),style: TextStyle(
                              color: yellowColor,
                              fontSize: 35,
                              fontWeight: FontWeight.bold
                          )),
                        ),
                        Center(
                          child: Text(translate('SignIn_screen.title2'),style: TextStyle(
                              color: PrimaryColor,
                              fontSize: 25
                          )),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: email,
                            style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold),
                            obscureText: false,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: yellowColor, width: 1.0)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: PrimaryColor, width: 1.0)
                              ),
                              labelText: translate('SignIn_screen.emailTitle'),
                              labelStyle: TextStyle(color: yellowColor, fontWeight: FontWeight.bold),
                              suffixIcon: Icon(Icons.email,color: yellowColor,size: 27,),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: password,
                            style: TextStyle(color: yellowColor,fontWeight: FontWeight.bold),
                            obscureText: isVisible,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: yellowColor, width: 1.0)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: PrimaryColor, width: 1.0)
                              ),
                              labelText: translate('SignIn_screen.passwordTitle'),
                              labelStyle: TextStyle(color: yellowColor, fontWeight: FontWeight.bold),
                              suffixIcon: IconButton(icon: Icon(isVisible?Icons.visibility:Icons.visibility_off,color: yellowColor,size: 27),onPressed: () {
                                setState(() {
                                  if(isVisible){
                                    isVisible= false;
                                  }else{
                                    isVisible= true;
                                  }
                                });


                              },),//Icon(Icons.https,color: yellowColor,size: 27,)
                            ),

                          ),
                        ),
                        SizedBox(height: 5),
                        InkWell(
                          onTap: (){
                            if(email.text==null||email.text.isEmpty){
                              Utils.showError(context, translate("in_app_errors.email_is_required") );
                            }else if(!Utils.validateEmail(email.text)){
                              Utils.showError(context, translate("in_app_errors.email_format_is_invalid") );
                            }
                            else if(password.text==null||password.text.isEmpty){
                              Utils.showError(context, translate("in_app_errors.password_is_Required") );
                            }else if(!Utils.validateStructure(password.text)){
                              Utils.showError(context, translate("in_app_errors.Password must contain atleast one lower case,Upper case and special characters") );
                            }else{
                              setState(() {
                                isLoading=true;
                              });
                              Network_Operations.signIn(context, email.text, password.text,isTablet).then((value){
                                setState(() {
                                  isLoading=false;
                                });
                              });
                              // Utils.check_connectivity().then((isConnected){
                              //   if(isConnected){
                              //
                              //   }else{
                              //     setState(() {
                              //       Utils.showError(context,"Network Problem");
                              //       isLoading=false;
                              //     });
                              //   }
                              //
                              // });


                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)) ,
                                color: yellowColor,
                              ),
                              height: 70,
                              width: 500,

                              child: Center(
                                child: Text(translate('buttons.signIn'),style: TextStyle(color: BackgroundColor,fontSize: 20,fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void showDemoActionSheet({BuildContext context, Widget child}) {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => child).then((String value)
    {
      setState(() {
        changeLocale(context, value);
      });
    });
  }
  void onActionSheetPress(BuildContext context) {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
        title: Text(translate('language.selection.title')),
        message: Text(translate('language.selection.message')),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(translate('language.name.en')),
            onPressed: () => Navigator.pop(context, 'en_US'),
          ),
          CupertinoActionSheetAction(
            child: Text(translate('language.name.ur')),
            onPressed: () => Navigator.pop(context, 'ur'),
          ),
          CupertinoActionSheetAction(
            child: Text(translate('language.name.ar')),
            onPressed: () => Navigator.pop(context, 'ar'),
          ),
          CupertinoActionSheetAction(
            child: Text(translate('language.name.da')),
            onPressed: () => Navigator.pop(context, 'da'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(translate('button.cancel')),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, null),
        ),
      ),
    );
  }

}

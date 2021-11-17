import 'dart:ui';
import 'package:exabistro_pos/Screens/LoadingScreen.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/Utils.dart';


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
  @override
  void initState(){

    this.email=TextEditingController();
    this.password=TextEditingController();
    this.admin=TextEditingController();

          SharedPreferences.getInstance().then((instance) {
            var token = instance.getString("token");
            if(token.isNotEmpty){
            setState(() {
            email.text = instance.getString("email");
            password.text = instance.getString('password');
                });
            }
          });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
                    height: 340,
                    width: 510,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text("Welcome",style: TextStyle(
                              color: yellowColor,
                              fontSize: 35,
                              fontWeight: FontWeight.bold
                          )),
                        ),
                        Center(
                          child: Text("Sign In to Continue",style: TextStyle(
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
                              labelText: "Email",
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
                                labelText: "Password",
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
                              Scaffold.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("Email is Required"),
                              ));
                            }else if(!Utils.validateEmail(email.text)){
                              Scaffold.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("Email Format is Invalid"),
                              ));
                            }
                            else if(password.text==null||password.text.isEmpty){
                              Scaffold.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("Password is Required"),
                              ));
                            }else if(!Utils.validateStructure(password.text)){
                              Scaffold.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("Password must contain atleast one lower case,Upper case and special characters"),
                              ));
                            }else{
                              setState(() {
                                isLoading=true;
                              });
                              Utils.check_connectivity().then((isConnected){
                                if(isConnected){
                                  Network_Operations.signIn(context, email.text, password.text,admin.text).then((value){
                                    setState(() {
                                      isLoading=false;
                                    });
                                  });
                                }else{
                                  setState(() {
                                    isLoading=false;
                                  });
                                }

                              });


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
                                child: Text("Sign In",style: TextStyle(color: BackgroundColor,fontSize: 20,fontWeight: FontWeight.bold),),
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
}

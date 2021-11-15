import 'package:cached_network_image/cached_network_image.dart';
import 'package:exabistro_pos/Screens/Deals/DealsList.dart';
import 'package:exabistro_pos/Screens/Deals/DealsDetailsPopup.dart';
import 'package:exabistro_pos/Screens/LoadingScreen.dart';
import 'package:exabistro_pos/Screens/Products/ProductsList.dart';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:exabistro_pos/model/Categories.dart';
import 'package:exabistro_pos/model/Products.dart';
import 'package:exabistro_pos/networks/Network_Operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class POSMainScreen extends StatefulWidget {
 int storeId;
  @override
  _POSMainScreenState createState() => _POSMainScreenState();

  POSMainScreen({this.storeId});
}

class _POSMainScreenState extends State<POSMainScreen> {
  List<Categories> subCategories=[];
  List<dynamic> dealsList=[];
  List<Products> products=[];
  String categoryName="";
  bool isLoading=true;
  List<String> menuTypeDropdownItems = ["Products","Deals"];
  String selectedMenuType;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    Utils.check_connectivity().then((isConnected){
      if(isConnected){
        Network_Operations.getSubcategories(context, widget.storeId).then((sub){
          setState(() {
            if(sub!=null&&sub.length>0){
              subCategories.addAll(sub);
              categoryName=subCategories[0].name;
              Network_Operations.getProduct(context, subCategories[0].categoryId, subCategories[0].id, widget.storeId,"").then((p){
                setState(() {
                  if(p!=null&&p.length>0){
                    isLoading=false;
                    products.addAll(p);
                  }else
                    isLoading=false;
                  SharedPreferences.getInstance().then((prefs){
                    Network_Operations.getAllDeals(context, prefs.getString("token"), widget.storeId).then((dealsList){
                      setState(() {
                        if(dealsList.length>0){
                          this.dealsList.addAll(dealsList);
                        }
                      });
                    });
                  });
                });

              });
            }else{
              isLoading=false;
              Utils.showError(context,"No Categories Found");
            }
          });

        });
      }else{
        isLoading=false;
        Navigator.pop(context);
        Utils.showError(context,"Network Error");
      }
    });

  }



  @override
  Widget build(BuildContext context) {
    return isLoading?LoadingScreen():Scaffold(
      appBar:AppBar(
        title: Text('Exabistro - POS',
          style: TextStyle(
              color: yellowColor,
              fontWeight: FontWeight.bold,
              fontSize: 35
          ),
        ),
        centerTitle: true,
        backgroundColor: BackgroundColor,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
              image: AssetImage('assets/bb.jpg'),
            )
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                  child: Container(
                    color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      color: yellowColor,
                      child: Center(
                        child: Text("Categories ", style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                   Container(
                     height: 140,
                     width: MediaQuery.of(context).size.width,
                     color: Colors.white,
                     child: ListView.builder(
                         scrollDirection: Axis.horizontal,
                         itemCount: subCategories.length,
                         itemBuilder: (context, index){
                       return Padding(
                         padding: const EdgeInsets.all(4.0),
                         child: InkWell(
                           onTap: (){
                             Network_Operations.getProduct(context, subCategories[index].categoryId, subCategories[index].id, widget.storeId,"").then((p){
                               setState(() {
                                 if(p!=null&&p.length>0){
                                   categoryName=subCategories[index].name;
                                   products.clear();
                                   products.addAll(p);
                                 }
                               });

                             });
                           },
                           child: Card(
                             elevation: 8,
                            child:CachedNetworkImage(
                              imageUrl: subCategories[index].image!=null?subCategories[index].image:"http://anokha.world/images/not-found.png",
                              placeholder:(context, url)=> Container(width:100,height: 100,child: Center(child: CircularProgressIndicator(color: Colors.amber,))),
                              errorWidget: (context, url, error) => Icon(Icons.error,color: Colors.red,),
                              imageBuilder: (context, imageProvider){
                                return Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      )
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        subCategories[index].name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,

                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                           ),
                         ),
                       );
                     }),
                   ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      color: yellowColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(categoryName, style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Card(
                              color: yellowColor,
                              elevation: 8,
                              child: DropdownButton(
                                  isDense: true,
                                  value: selectedMenuType==null?menuTypeDropdownItems[0]:selectedMenuType,//actualDropdown,
                                  onChanged: (String value){
                                    setState(() {
                                      this.selectedMenuType=value;
                                    });
                                  },
                                  items: menuTypeDropdownItems.map((String title)
                                  {
                                    return DropdownMenuItem
                                      (
                                      value: title,
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Text(title, style: TextStyle(color: blueColor, fontWeight: FontWeight.bold, fontSize: 14.0)),
                                      ),
                                    );
                                  }).toList()
                              ),
                            ),
                          )
                        ],
                      )
                    ),
                    Container(
                      //color: Colors.teal,
                      width: MediaQuery.of(context).size.width,
                      height: 440,
                      child: selectedMenuType=="Products"||selectedMenuType==null?ProductsList(products):DealsList(dealsList)
                    )
                  ],
                ),
              )),
              SizedBox(width: 5,),
              Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          color: yellowColor,
                          child: Center(
                            child: Text("Current Order For Cash Register", style: TextStyle(
                                fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),),
                          ),
                        ),
                        Container(
                          //color: Colors.teal,
                          width: MediaQuery.of(context).size.width,
                          height: 360,
                          child: ListView.builder(
                            itemCount: 12,
                              itemBuilder: (context, index){
                            return Card(
                              elevation: 8,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 80,
                              ),
                            );
                          }),
                        ),
                        Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          height: 340,
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 60,
                                color: yellowColor,
                                child: Center(
                                  child: Text("Order Summary", style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 210,
                                color: blueColor,
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 140,
                                      color: Colors.white,
                                      child: ListView(
                                        children: [
                                          Card(
                                            elevation:8,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 60,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("SubTotal: ", style: TextStyle(
                                                        fontSize: 25,
                                                        color: yellowColor,
                                                        fontWeight: FontWeight.bold
                                                    ),),
                                                    Row(
                                                      children: [
                                                        Text("Rs: ", style: TextStyle(
                                                            fontSize: 25,
                                                            color: yellowColor,
                                                            fontWeight: FontWeight.bold
                                                        ),),
                                                        SizedBox(width: 2,),
                                                        Text("120/- ", style: TextStyle(
                                                            fontSize: 25,
                                                            color: blueColor,
                                                            fontWeight: FontWeight.bold
                                                        ),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Card(
                                            elevation:6,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 60,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Discount: ", style: TextStyle(
                                                        fontSize: 25,
                                                        color: yellowColor,
                                                        fontWeight: FontWeight.bold
                                                    ),),
                                                    Row(
                                                      children: [
                                                        Text("Rs: ", style: TextStyle(
                                                            fontSize: 25,
                                                            color: yellowColor,
                                                            fontWeight: FontWeight.bold
                                                        ),),
                                                        SizedBox(width: 2,),
                                                        Text("120/- ", style: TextStyle(
                                                            fontSize: 25,
                                                            color: blueColor,
                                                            fontWeight: FontWeight.bold
                                                        ),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Card(
                                            elevation:6,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 60,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Tax: ", style: TextStyle(
                                                        fontSize: 25,
                                                        color: yellowColor,
                                                        fontWeight: FontWeight.bold
                                                    ),),
                                                    Row(
                                                      children: [
                                                        Text("Rs: ", style: TextStyle(
                                                            fontSize: 25,
                                                            color: yellowColor,
                                                            fontWeight: FontWeight.bold
                                                        ),),
                                                        SizedBox(width: 2,),
                                                        Text("120/- ", style: TextStyle(
                                                            fontSize: 25,
                                                            color: blueColor,
                                                            fontWeight: FontWeight.bold
                                                        ),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      color: blueColor,
                                      width: MediaQuery.of(context).size.width,
                                      height: 70,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("TOTAL: ", style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold
                                            ),),
                                            Row(
                                              children: [
                                                Text("Rs: ", style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold
                                                ),),
                                                SizedBox(width: 2,),
                                                Text("120/- ", style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold
                                                ),),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ),
                              Card(
                                elevation:12,
                                child: Container(
                                  width: MediaQuery.of(context).size.width -200,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: yellowColor,
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Center(
                                    child: Text("Create An Order ", style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          ),
        )
      ),
    );
  }
}

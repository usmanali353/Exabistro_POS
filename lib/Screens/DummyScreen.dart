import 'package:flutter/material.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:flutter/services.dart';

class DummyScreen extends StatefulWidget {

  @override
  _DummyScreenState createState() => _DummyScreenState();
}

class _DummyScreenState extends State<DummyScreen> {
  @override
  void initState(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text("DummyScreen", style: TextStyle(
            color: yellowColor, fontSize: 35, fontWeight: FontWeight.bold
        ),
        ),
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
        child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        childAspectRatio: 4 ,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10
        ),
            itemCount: 6,
            itemBuilder: (context, index){
          return Card(
            elevation: 8,
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              width: 350,
              child: Column(
                children: [
                  Card(
                    elevation:6,
                    color: yellowColor,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: yellowColor
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text('Order ID: ',
                                style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                              Text("01",
                                //orderList[index]['id']!=null?orderList[index]['id'].toString():"",
                                style: TextStyle(
                                    fontSize: 35,
                                    color: blueColor,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: yellowColor,
                  ),
                  SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('Order Type: ',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: yellowColor
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 2.5),
                            ),
                            Text("Dine-In",
                              //getOrderType(orderList[index]['orderType']),
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: PrimaryColor
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          //visible: orderList[index]['orderType']==1,
                          child: Row(
                            children: [
                              Text('Table No#: ',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: yellowColor
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2.5),
                              ),
                              Text("01",
                                //orderList[index]['tableId']!=null?getTableName(orderList[index]['tableId']):"",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: PrimaryColor
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),

                  ),
                ],
              ),
            )
          );
            })
        // ListView.builder(
        //     itemCount:10,
        //     itemBuilder: (context, index){
        //   return ExpansionTile(title: Text(
        //     "A dummmy Tile",
        //     style: TextStyle(
        //       color: blueColor,
        //       fontWeight: FontWeight.bold,
        //       fontSize: 20
        //     ),
        //   ));
        // }),
      ),
    );
  }
}

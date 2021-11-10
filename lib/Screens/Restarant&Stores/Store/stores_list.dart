import 'package:exabistro_pos/components/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoresCard extends StatelessWidget {
  const StoresCard({
    Key key,
    this.itemIndex,
    this.product,
    this.press,
  }) : super(key: key);

  final int itemIndex;
  final dynamic product;
  final Function press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Card(
        elevation:6,
        child: Container(
          width: MediaQuery.of(context).size.width,
          //height: 220,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 180,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image:
                        //AssetImage('assets/emptycart.png')
                      NetworkImage(product['image']!=null?product['image']:"http://www.4motiondarlington.org/wp-content/uploads/2013/06/No-image-found.jpg")
                    )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 30,
                        width: 120,
                        decoration: BoxDecoration(
                            color: yellowColor,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child:
                        Center(
                          child: Text(
                            "${getStatus(product['statusId'])}",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                height: 35,
                color: yellowColor,
                child:  Center(
                  child: Text(
                    product['name'],
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.mapMarkerAlt, color: yellowColor, size: 25,),
                  SizedBox(width:5),
                  Text(
                    product['website'],
                    //"helloossdxadadadADDDFSFDASGG",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172a3a)
                    ),
                  ),
                ],
              ),
            ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.mobileAlt, color: yellowColor, size: 25,),
                    SizedBox(width:5),
                    Text(
                      product['phoneNo'],
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF172a3a)
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.at, color: yellowColor, size: 25,),
                    SizedBox(width:5),
                    Text(
                      product['email'],
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF172a3a)
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
  String getStatus(int id){
    String status;

    if(id!=null){
      if(id==0){
        status = "Pending";
      }
      else if(id ==1){
        status = "Approve";
      }else if(id ==2){
        status = "Reject";
      }

      return status;
    }else{
      return "";
    }
  }
}

import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:exabistro_pos/model/CartItems.dart';
import 'package:exabistro_pos/networks/sqlite_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_counter/flutter_counter.dart';

class DealsDetailsPopup extends StatefulWidget {
 dynamic deal;

 DealsDetailsPopup(this.deal);

  @override
  _DealsDetailsPopupState createState() => _DealsDetailsPopupState();
}

class _DealsDetailsPopupState extends State<DealsDetailsPopup> {
  var count=1;
  var price=0.0;
  var updatedPrice=0.0;
  List<String> dealProducts=[];
  @override
  void initState() {
    if(widget.deal!=null){
      setState(() {
        this.price=widget.deal["price"];
      });
      if(widget.deal["productDeals"]!=null&&widget.deal["productDeals"].length>0){
        for(var pd in widget.deal["productDeals"]){
          if(pd["product"]!=null&&pd["size"]!=null){
            dealProducts.add(pd["product"]["name"]+" ("+pd["size"]["name"]+") x"+pd["quantity"].toString());
          }
        }

      }
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.1),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height /1.25,
          width: MediaQuery.of(context).size.width /2.7,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                fit: BoxFit.cover,
                //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                image: AssetImage('assets/bb.jpg'),
              )
          ),
          child: Column(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6) ),
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(widget.deal["image"])
                      )
                  ),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0, right: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.clear, size: 40, color: Colors.red,),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },

                          )
                        ],
                      ),
                    ),
                  )
              ),
              Card(
                elevation: 8,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  color: yellowColor,
                  child: Center(
                    child: Text(widget.deal["name"],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Card(
                elevation: 8,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Price: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: yellowColor
                            ),
                          ),
                          Row(
                            children: [
                              Text("Rs: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: yellowColor
                                ),
                              ),
                              Text(this.updatedPrice.toString()=="0.0"?price.toString():updatedPrice.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: blueColor
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                ),
              ),
              Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: ListTile(
                    title: Text("Products",style: TextStyle(fontWeight: FontWeight.bold, color: yellowColor, fontSize: 28),),
                    subtitle: Text(dealProducts.toString().replaceAll("[","").replaceAll("]", ""), style: TextStyle(fontWeight: FontWeight.w400, color: blueColor, fontSize: 15),),
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Card(
                elevation: 8,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Quantity: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: yellowColor
                            ),
                          ),
                          Counter(initialValue: count, minValue: 1, maxValue: 10, onChanged:(value){
                            setState(() {
                              this.count=value;
                              updatedPrice=0.0;
                               updatedPrice=price*count;
                            });
                          },step: 1, decimalPlaces: 0),
                        ],
                      ),
                    )
                ),
              ),
              SizedBox(height: 15,),
              InkWell(
                onTap: (){
                  sqlite_helper().create_cart(CartItems(
                      productId: null,
                      productName: widget.deal["name"],
                      isDeal: 1,
                      dealId: widget.deal["id"],
                      sizeId: null,
                      sizeName: null,
                      price: widget.deal["price"],
                      totalPrice: updatedPrice==0.0?price:updatedPrice,
                      quantity: count,
                      storeId: widget.deal["storeId"],
                      topping: null))
                      .then((isInserted) {
                    if (isInserted > 0) {
                      Utils.showSuccess(context, "Added to Cart successfully");
                      Navigator.of(context).pop();
                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ClientNavBar()));
                    }
                    else {
                      Utils.showError(
                          context, "Some Error Occur");
                    }
                  });
                },
                child: Card(
                  elevation: 8,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 65,
                    decoration: BoxDecoration(
                        color: yellowColor,
                        borderRadius: BorderRadius.circular(4)
                    ),
                    child: Center(
                      child: Text("Add To Cart",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white
                        ),
                      ),
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

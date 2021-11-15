import 'package:cached_network_image/cached_network_image.dart';
import 'package:exabistro_pos/Screens/Deals/DealsDetailsPopup.dart';
import 'package:flutter/material.dart';

class DealsList extends StatefulWidget {
 List<dynamic> dealsList=[];

 DealsList(this.dealsList);

  @override
  _DealsListState createState() => _DealsListState();
}

class _DealsListState extends State<DealsList> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: widget.dealsList.length,
        itemBuilder: (context, index){
          return InkWell(
            onTap: () {
             // Navigator.push(context,MaterialPageRoute(builder: (context)=>CustomDialog().))
              showDialog(context: context, builder:(BuildContext context){
                return LimitedBox(
                    maxHeight: MediaQuery.of(context).size.height /1.25,
                    maxWidth: MediaQuery.of(context).size.width /2.7,
                    child: DealsDetailsPopup(widget.dealsList[index])
                );
              });
            },
            child: Card(
              elevation: 8,
              child: CachedNetworkImage(
                imageUrl: widget.dealsList[index]["image"] != null
                    ? widget.dealsList[index]["image"]
                    : "http://anokha.world/images/not-found.png",
                placeholder: (context, url) =>
                    Container(width: 85,
                        height: 85,
                        child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.amber,))),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error, color: Colors.red,),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: 150,
                    width: 190,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            8),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(
                            6),
                      ),
                      child: Center(
                        child: Text(
                          widget.dealsList[index]["name"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 19,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}

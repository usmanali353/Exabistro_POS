import 'package:cached_network_image/cached_network_image.dart';
import 'package:exabistro_pos/model/Products.dart';
import 'package:flutter/material.dart';

import '../Deals/DealsDetailsPopup.dart';

class ProductsList extends StatefulWidget {
 List<Products> products=[];

 ProductsList(this.products);

  @override
  _ProductsListState createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  @override
  Widget build(BuildContext context) {
     return GridView.builder(
         gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
             maxCrossAxisExtent: 200,
             childAspectRatio: 3 / 2,
             crossAxisSpacing: 10,
             mainAxisSpacing: 10),
         itemCount: widget.products.length,
         itemBuilder: (context, index){
           return InkWell(
             onTap: () {

             },
             child: Card(
               elevation: 8,
               child: CachedNetworkImage(
                 imageUrl: widget.products[index].image != null
                     ? widget.products[index].image
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
                           widget.products[index].name,
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

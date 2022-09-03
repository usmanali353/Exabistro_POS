// import 'Sizes.dart';
//
// class ProductSize {
//   ProductSize({
//     this.size,
//     this.discount,
//     this.price,
//     this.productId,
//     this.sizeId,
//     this.discountId,
//     this.discountedPrice,
//   });
//
//   Sizes size;
//   dynamic discount;
//   double price;
//   int productId;
//   int sizeId;
//   dynamic discountId;
//   int discountedPrice;
//
//   factory ProductSize.fromJson(Map<String, dynamic> json) => ProductSize(
//     size: Sizes.fromJson(json["size"]),
//     discount: json["discount"],
//     price: json["price"].toDouble(),
//     productId: json["productId"],
//     sizeId: json["sizeId"],
//     discountId: json["discountId"],
//     discountedPrice: json["discountedPrice"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "size": size.toJson(),
//     "discount": discount,
//     "price": price,
//     "productId": productId,
//     "sizeId": sizeId,
//     "discountId": discountId,
//     "discountedPrice": discountedPrice,
//   };
// }
//


class ProductSize {
  ProductSize({
    this.sizeId,
    this.price,
  });

  int sizeId;
  double price;

  factory ProductSize.fromJson(Map<String, dynamic> json) => ProductSize(
    sizeId: json["SizeId"],
    price: json["Price"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "SizeId": sizeId,
    "Price": price,
  };
}

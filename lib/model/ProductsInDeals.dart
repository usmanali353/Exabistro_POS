class ProductsInDeals {
  ProductsInDeals({
    this.price,
    this.productId,
    this.sizeId,
    this.totalPrice,
    this.quantity,
  });


  double price,totalPrice;
  int productId;
  int sizeId;
  int quantity;


  factory ProductsInDeals.fromJson(Map<String, dynamic> json) => ProductsInDeals(
    totalPrice: json["totalPrice"],
    price: json["price"].toDouble(),
    productId: json["productId"],
    sizeId: json["sizeId"],
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "totalPrice": totalPrice,
    "price": price,
    "productId": productId,
    "sizeId": sizeId,
    "quantity": quantity,
  };
}
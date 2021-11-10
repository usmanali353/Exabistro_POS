
class Toppings{
  int additionalitemid, quantity;
  double price,totalprice;
  String name;
  Toppings({this.additionalitemid, this.quantity, this.price,this.totalprice,this.name});

  Map<String,dynamic> toJson()=>{

    "quantity":quantity,

    "additionalitemid":additionalitemid,

    "totalprice":totalprice,

    "price":price,

    "name":name,
  };

  Toppings.fromJson(Map<dynamic,dynamic> data){

    name=data['name'];

    additionalitemid=data['additionalitemid'];

    price=data['price'];

    totalprice=data['totalprice'];

    quantity=data['quantity'];
  }
}
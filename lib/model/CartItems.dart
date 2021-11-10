class CartItems{
  int id;
  int productId,dealId;
  String productName;
  double price,totalPrice;
  int quantity;
  int sizeId;
  String sizeName;
  int isDeal;
  String topping;
  int storeId;
  CartItems({
    this.id,
    this.productId,
    this.productName,
    this.price,
    this.totalPrice,
    this.quantity,
    this.sizeId,
    this.sizeName,
    this.isDeal,
    this.dealId,
    this.topping,
    this.storeId,
  });
  Map<String,dynamic> toJson()=>{
    "id":id,

    "productId":productId,

    "productName":productName,

    "price":price,

    "totalPrice":totalPrice,

    "quantity":quantity,

    "sizeId":sizeId,

    "sizeName":sizeName,

    "isDeal":isDeal,

    "dealId":dealId,

    "topping":topping,

    "storeId":storeId,

  };

  CartItems.fromJson(Map<dynamic,dynamic> data){

    productId=data['productId'];

    productName=data['productName'];

    price=data['price'];

    totalPrice=data['totalPrice'];

    quantity=data['quantity'];

    sizeId=data['sizeId'];

    sizeName = data['sizeName'];

    isDeal = data['isDeal'];

    dealId = data['dealId'];

    topping=data['topping'];

    id=data['id'];

    storeId=data["storeId"];


  }
}
class CartItemsWithChair{
  int id;
  int productId,dealId;
  String productName;
  double price,totalPrice;
  int quantity;
  int sizeId;
  String sizeName;
  int isDeal;
  String topping,tableName;
  int storeId;
  int chairId,tableId;
  CartItemsWithChair({
    this.id,
    this.productId,
    this.productName,
    this.price,
    this.totalPrice,
    this.quantity,
    this.sizeId,
    this.sizeName,
    this.isDeal,
    this.dealId,
    this.topping,
    this.storeId,
    this.chairId,
    this.tableName,
    this.tableId
  });
  Map<String,dynamic> toJson()=>{
    "id":id,

    "productId":productId,

    "productName":productName,

    "price":price,

    "totalPrice":totalPrice,

    "quantity":quantity,

    "sizeId":sizeId,

    "sizeName":sizeName,

    "isDeal":isDeal,

    "dealId":dealId,

    "topping":topping,

    "storeId":storeId,

    "chairId":chairId==null?null:chairId,
    "tableName":tableName==null?null:tableName,
    "tableId":tableId==null?null:tableId

  };

  CartItemsWithChair.fromJson(Map<dynamic,dynamic> data){

    productId=data['productId'];

    productName=data['productName'];

    price=data['price'];

    totalPrice=data['totalPrice'];

    quantity=data['quantity'];

    sizeId=data['sizeId'];

    sizeName = data['sizeName'];

    isDeal = data['isDeal'];

    dealId = data['dealId'];

    topping=data['topping'];

    id=data['id'];

    storeId=data["storeId"];

    chairId =data["chairId"]==null?null:data["chairId"];
    tableName =data["tableName"]==null?null:data["tableName"];
    tableId =data["tableId"]==null?null:data["tableId"];

  }
}
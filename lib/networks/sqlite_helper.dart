import 'package:exabistro_pos/model/CartItems.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

// class ToppingDatabaseProvider {
//   ToppingDatabaseProvider._();
//
//   static final ToppingDatabaseProvider db = ToppingDatabaseProvider._();
//   Database _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database;
//     _database = await getDatabaseInstance();
//     return _database;
//   }
//
//   Future<Database> getDatabaseInstance() async {
//     Directory directory = await getApplicationDocumentsDirectory();
//     String path = join(directory.path, "Topping.db");
//     return await openDatabase(path, version: 1,
//         onCreate: (Database db, int version) async {
//           await db.execute("CREATE TABLE Topping ("
//               "id integer primary key AUTOINCREMENT,"
//               "name TEXT,"
//               "city TEXT"
//               ")");
//         });
//   }
//
//   addToppingToDatabase(Topping Topping) async {
//     final db = await database;
//     var raw = await db.insert(
//       "Topping",
//       Topping.toJson(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//     return raw;
//   }
//
//   updateTopping(Topping topping) async {
//     final db = await database;
//     var response = await db.update("Topping", topping.toJson(),
//         where: "id = ?", whereArgs: [topping.id]);
//     return response;
//   }
//
//   Future<Topping> getToppingWithId(int id) async {
//     final db = await database;
//     var response = await db.query("Topping", where: "id = ?", whereArgs: [id]);
//     return response.isNotEmpty ? Topping.fromJson(response.first) : null;
//   }
//
//   Future<List<Topping>> getAllToppings() async {
//     final db = await database;
//     var response = await db.query("Topping");
//     List<Topping> list = response.map((c) => Topping.fromJson(c)).toList();
//     return list;
//   }
//
//   deleteToppingWithId(int id) async {
//     final db = await database;
//     return db.delete("Topping", where: "id = ?", whereArgs: [id]);
//   }
//
//   deleteAllToppings() async {
//     final db = await database;
//     db.delete("Topping");
//   }
// }

class sqlite_helper{
  static Database _db;
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }
  initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'RMS.db');
    var db = await openDatabase(dbPath, version: 1, onCreate: _onCreate);
    return db;
  }
  _onCreate(Database db, int version) async {
    // await db.execute("CREATE TABLE Cart("
    //      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    //      "order_id  INTEGER,"
    //      "customer_id  INTEGER,"
    //      "gross_total  INTEGER,"
    //      "order_type  TEXT,"
    //      "Items TEXT,"
    //       "Topping  TEXT,"
    //     ")");

    await db.execute("CREATE TABLE Cart("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "productId INTEGER,"
        "productName TEXT,"
        "quantity INTEGER,"
        "price DOUBLE,"
        "totalPrice DOUBLE,"
        "sizeId INTEGER,"
        "sizeName TEXT,"
        "isDeal INTEGER,"
        "dealId INTEGER,"
        "storeId INTEGER,"
        "topping TEXT"
        ")");
    await db.execute("CREATE TABLE Cart1("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "productId INTEGER,"
        "productName TEXT,"
        "quantity INTEGER,"
        "price DOUBLE,"
        "totalPrice DOUBLE,"
        "sizeId INTEGER,"
        "sizeName TEXT,"
        "isDeal INTEGER,"
        "dealId INTEGER,"
        "storeId INTEGER,"
        "topping TEXT,"
        "chairId INTEGER,"
        "tableName TEXT,"
        "tableId INTEGER"
        ")");
    // await db.execute("CREATE TABLE Favourite("
    //     "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    //     "productId INTEGER,"
    //     "productName TEXT,"
    //     "price DOUBLE,"
    //     "sizeId INTEGER,"
    //     "sizeName TEXT,"
    //     "storeId INTEGER,"
    //     "Category TEXT,"
    //     "tableName TEXT,"
    //     "tableId INTEGER"
    //     ")");
  }
  //Cart
 Future<int> create_cart(CartItems cartItems) async {
  var dbClient = await db;
   var result = await dbClient.insert("Cart", cartItems.toJson());
   return result;
 }
 Future<int> updateCart(CartItems cartItems) async {
    final dbClient = await db;
    var response = await dbClient.update("Cart", cartItems.toJson(),
        where: "id = ?", whereArgs: [cartItems.id]);
    return response;
  }
  Future<List> getcart() async {
    var dbClient= await db;
    var result = await dbClient.rawQuery('SELECT * FROM Cart');
    return result.toList();
  }
  Future<List<CartItems>> getcart1() async {
    var dbClient= await db;
    var result = await dbClient.rawQuery('SELECT * FROM Cart');
    List<CartItems> cartlist =[];
    cartlist.clear();
    for(int i=0;i<result.length;i++){
      cartlist.add(CartItems(id: result[i]['id'],sizeName: result[i]['sizeName'],productId: result[i]['productId'],productName: result[i]['productName'],
      price: result[i]['price'],quantity: result[i]['quantity'],sizeId: result[i]['sizeId'],topping: result[i]['topping'],
          isDeal: result[i]['isDeal'],dealId: result[i]['dealId'],totalPrice: result[i]['totalPrice'],storeId: result[i]["storeId"]));
    }
    return cartlist;
  }
  Future<int> deletecart() async {
    var dbClient= await db;
    return await dbClient.rawDelete('DELETE FROM Cart');
  }
  Future<int> deleteProductsById(int id) async {

    var dbClient= await db;

    return await dbClient.delete("Cart",where: "id = ?",whereArgs: [id]);

  }
  Future<List> checkAlreadyExists(int productId) async {

    var dbClient= await db;

    var result = await dbClient.query("Cart",where: 'productId = ?',whereArgs: [productId]);

    return result.toList();

  }
  Future<List> dealCheckAlreadyExists(int dealId) async {

    var dbClient= await db;

    var result = await dbClient.query("Cart",where: 'dealId = ?',whereArgs: [dealId]);

    return result.toList();

  }
  Future<List> checkIfAlreadyExists(int id) async {

    var dbClient= await db;

    var result = await dbClient.query("Cart",where: 'id = ?',whereArgs: [id]);

    return result.toList();

  }
  Future<List> gettotal() async {
    var dbClient= await db;
    var result = await dbClient.rawQuery('SELECT SUM(totalPrice) FROM Cart');
    return result;
  }
  Future<int> getcount() async {
    var dbClient= await db;
    var result = await dbClient.rawQuery('SELECT * FROM Cart');
    return result.toList().length;
  }





  Future<int> create_cartStaff(CartItemsWithChair cartItems) async {
    var dbClient = await db;
    var result = await dbClient.insert("Cart1", cartItems.toJson());
    return result;
  }
  updateCartStaff(CartItemsWithChair cartItems) async {
    final dbClient = await db;
    var response = await dbClient.update("Cart1", cartItems.toJson(),
        where: "id = ?", whereArgs: [cartItems.id]);
    return response;
  }
  Future<List> getcartStaff() async {
    var dbClient= await db;
    var result = await dbClient.rawQuery('SELECT * FROM Cart1');
    return result.toList();
  }
  Future<List<CartItemsWithChair>> getcart1Staff() async {
    var dbClient= await db;
    var result = await dbClient.rawQuery('SELECT * FROM Cart1');
    List<CartItemsWithChair> cartlist =[];
    cartlist.clear();
    for(int i=0;i<result.length;i++){
      cartlist.add(CartItemsWithChair(id: result[i]['id'],sizeName: result[i]['sizeName'],productId: result[i]['productId'],productName: result[i]['productName'],
          price: result[i]['price'],quantity: result[i]['quantity'],sizeId: result[i]['sizeId'],topping: result[i]['topping'],
          isDeal: result[i]['isDeal'],dealId: result[i]['dealId'],totalPrice: result[i]['totalPrice'],storeId: result[i]["storeId"],chairId: result[i]['chairId'],tableId: result[i]['tableId'],tableName: result[i]['tableName']));
    }
    return cartlist;
  }
  Future<List<CartItemsWithChair>> getcart1StaffwithTable(int tableId) async {
    var dbClient= await db;
    var result = await dbClient.rawQuery('SELECT * FROM Cart1 Where tableId = $tableId');
    List<CartItemsWithChair> cartlist =[];
    cartlist.clear();
    for(int i=0;i<result.length;i++){
      cartlist.add(CartItemsWithChair(id: result[i]['id'],sizeName: result[i]['sizeName'],productId: result[i]['productId'],productName: result[i]['productName'],
          price: result[i]['price'],quantity: result[i]['quantity'],sizeId: result[i]['sizeId'],topping: result[i]['topping'],
          isDeal: result[i]['isDeal'],dealId: result[i]['dealId'],totalPrice: result[i]['totalPrice'],storeId: result[i]["storeId"],chairId: result[i]['chairId'],tableId: result[i]['tableId'],tableName: result[i]['tableName']));
    }
    return cartlist;
  }
  Future<int> deletecartStaff() async {
    var dbClient= await db;
    return await dbClient.rawDelete('DELETE FROM Cart1');
  }
  Future<int> deletecartStaffByTable(int tableId) async {
    var dbClient= await db;
    return await dbClient.rawDelete('DELETE FROM Cart1 WHERE tableId = ?', [tableId]);
    //return await dbClient.delete('DELETE FROM Cart1 Where tableId = ?',whereArgs: [tableId]);
  }
  Future<int> deleteProductsByIdStaff(int id) async {

    var dbClient= await db;

    return await dbClient.delete("Cart1",where: "id = ?",whereArgs: [id]);

  }
  Future<List> checkAlreadyExistsStaff(int productId) async {

    var dbClient= await db;

    var result = await dbClient.query("Cart1",where: 'productId = ?',whereArgs: [productId]);

    return result.toList();

  }
  Future<List> dealcheckAlreadyExistsStaff(int dealId) async {

    var dbClient= await db;

    var result = await dbClient.query("Cart1",where: 'dealId = ?',whereArgs: [dealId]);

    return result.toList();

  }
  Future<List> checkIfAlreadyExistStaff(int id) async {

    var dbClient= await db;

    var result = await dbClient.query("Cart1",where: 'id = ?',whereArgs: [id]);

    return result.toList();

  }
  Future<List> gettotalStaff(int tableId) async {
    var dbClient= await db;
    var result = await dbClient.rawQuery('SELECT SUM(totalPrice) FROM Cart1 WHERE tableId = ?',[tableId]);
    return result;
  }
  Future<int> getcountStaff() async {
    var dbClient= await db;
    var result = await dbClient.rawQuery('SELECT * FROM Cart1');
    return result.toList().length;
  }

  ///Favourite

  // Future<int> addFavourite(CartItemsWithChair cartItems) async {
  //   var dbClient = await db;
  //   var result = await dbClient.insert("Cart1", cartItems.toJson());
  //   return result;
  // }
  // // updateCartStaff(CartItemsWithChair cartItems) async {
  // //   final dbClient = await db;
  // //   var response = await dbClient.update("Cart1", cartItems.toJson(),
  // //       where: "id = ?", whereArgs: [cartItems.id]);
  // //   return response;
  // // }
  // Future<List> getAllFavourite() async {
  //   var dbClient= await db;
  //   var result = await dbClient.rawQuery('SELECT * FROM Cart1');
  //   return result.toList();
  // }
  // Future<List<CartItemsWithChair>> GetAllFavItems() async {
  //   var dbClient= await db;
  //   var result = await dbClient.rawQuery('SELECT * FROM Cart1');
  //   List<CartItemsWithChair> cartlist =[];
  //   cartlist.clear();
  //   for(int i=0;i<result.length;i++){
  //     cartlist.add(CartItemsWithChair(id: result[i]['id'],sizeName: result[i]['sizeName'],productId: result[i]['productId'],productName: result[i]['productName'],
  //         price: result[i]['price'],quantity: result[i]['quantity'],sizeId: result[i]['sizeId'],topping: result[i]['topping'],
  //         isDeal: result[i]['isDeal'],dealId: result[i]['dealId'],totalPrice: result[i]['totalPrice'],storeId: result[i]["storeId"],chairId: result[i]['chairId'],tableId: result[i]['tableId'],tableName: result[i]['tableName']));
  //   }
  //   return cartlist;
  // }
  // Future<List<CartItemsWithChair>> getFavouriteByCategory(String category) async {
  //   var dbClient= await db;
  //   var result = await dbClient.rawQuery('SELECT * FROM Cart1 Where tableId = $category');
  //   List<CartItemsWithChair> cartlist =[];
  //   cartlist.clear();
  //   for(int i=0;i<result.length;i++){
  //     cartlist.add(CartItemsWithChair(id: result[i]['id'],sizeName: result[i]['sizeName'],productId: result[i]['productId'],productName: result[i]['productName'],
  //         price: result[i]['price'],quantity: result[i]['quantity'],sizeId: result[i]['sizeId'],topping: result[i]['topping'],
  //         isDeal: result[i]['isDeal'],dealId: result[i]['dealId'],totalPrice: result[i]['totalPrice'],storeId: result[i]["storeId"],chairId: result[i]['chairId'],tableId: result[i]['tableId'],tableName: result[i]['tableName']));
  //   }
  //   return cartlist;
  // }
  // Future<int> deleteAllFavourite() async {
  //   var dbClient= await db;
  //   return await dbClient.rawDelete('DELETE FROM Cart1');
  // }
  // // Future<int> deletecartStaffByTable(int tableId) async {
  // //   var dbClient= await db;
  // //   return await dbClient.rawDelete('DELETE FROM Cart1 WHERE tableId = ?', [tableId]);
  // //   //return await dbClient.delete('DELETE FROM Cart1 Where tableId = ?',whereArgs: [tableId]);
  // // }
  // Future<int> deleteFavouriteById(int id) async {
  //
  //   var dbClient= await db;
  //
  //   return await dbClient.delete("Cart1",where: "id = ?",whereArgs: [id]);
  //
  // }
  // Future<List> checkFavouriteAlreadyExist(int productId) async {
  //
  //   var dbClient= await db;
  //
  //   var result = await dbClient.query("Cart1",where: 'productId = ?',whereArgs: [productId]);
  //
  //   return result.toList();
  //
  // }

}



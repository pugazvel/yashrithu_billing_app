import 'dart:convert';

import 'package:retail_bill/item_model.dart';
import 'package:retail_bill/persist/db_helper.dart';

class Bill {
  int? id;
  int? billNumber;
  DateTime? dateTime;
  double? quantity;
  double? amount;
  double? discount;
  List<ItemModel>? items = List.empty(growable: true);
 
  Bill({this.id, this.billNumber, this.dateTime, this.quantity, this.amount, this.items, this.discount});
 
  Bill.fromMap(Map<String, dynamic> map) {
    id = map[DatabaseHelper.columnId];
    billNumber = map[DatabaseHelper.columnBillNumber];
    dateTime = DateTime.fromMillisecondsSinceEpoch(map[DatabaseHelper.columnDatetime]);
    quantity = map[DatabaseHelper.columnQuantity];
    amount = map[DatabaseHelper.columnAmount];
    discount = map[DatabaseHelper.columnDiscount];

    List<dynamic> its = jsonDecode(map[DatabaseHelper.columnItems]);
    items = List.empty(growable: true);
    for(Map<String, dynamic> it in its) {
      ItemModel item = ItemModel.fromMap(it);
      items!.add(item);
    }
    // print(jsonEncode(map));
  }
 
  Map<String, dynamic> toMap() {
    List<Map> its = List.empty(growable: true);
    for(ItemModel item in items!) {
      Map<String, dynamic> it  = item.toMap();
      its.add(it);
    }
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnBillNumber: billNumber,
      DatabaseHelper.columnDatetime: dateTime!.millisecondsSinceEpoch,
      DatabaseHelper.columnQuantity: quantity,
      DatabaseHelper.columnAmount: amount,
      DatabaseHelper.columnDiscount: discount,
      DatabaseHelper.columnItems: jsonEncode(its),
    };
  }

  Map<String, dynamic> toJson() {
    List<Map> its = List.empty(growable: true);
    for(ItemModel item in items!) {
      Map<String, dynamic> it  = item.toJson();
      its.add(it);
    }
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnBillNumber: billNumber,
      DatabaseHelper.columnDatetime: dateTime!.millisecondsSinceEpoch,
      DatabaseHelper.columnQuantity: quantity,
      DatabaseHelper.columnAmount: amount,
      DatabaseHelper.columnDiscount: discount,
      DatabaseHelper.columnItems: jsonEncode(its),
    };
  }

   Bill.clone(Bill source) :
   this.id = source.id, 
      this.billNumber = source.billNumber,
      this.dateTime= source.dateTime,
      this.amount = source.amount,
      this.discount= source.discount,
      this.quantity = source.quantity,
      this.items = source.items!.map((item) => new ItemModel.clone(item)).toList();

}
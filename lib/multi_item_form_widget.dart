import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:retail_bill/item_form_item_widget.dart';
import 'package:retail_bill/item_model.dart';
import 'package:retail_bill/persist/bill.dart';
import 'package:retail_bill/persist/db_helper.dart';
import 'package:retail_bill/print/BillPrinter.dart';
import 'package:retail_bill/services/app_service.dart';

class MultiItemFormWidget extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() {
    return _MultiItemFormWidgetState();
  }
}

class _MultiItemFormWidgetState extends State<MultiItemFormWidget> {
  
  BillPrinter printer = BillPrinter.instance;
  final dbHelper = DatabaseHelper.instance;
  late ValueNotifier<bool> _btConnectedNotifier;
  // double totalQuantity  = 0;
  // double totalPrice  = 0;
  // int billNumber = 0;
  int _selectedIndex = 0;
  List<ItemFormItemWidget> itemForms = List.empty(growable: true);
  late Bill currentBill = new Bill(id: 0, billNumber: 0, amount: 0, quantity: 0);

_MultiItemFormWidgetState() {
  _btConnectedNotifier = printer.connected;
}

  @override
  void initState() {
    super.initState();
    print('init state of form widget');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bill No:${currentBill.billNumber}  Items:${currentBill.quantity}  Price:${currentBill.amount}", style: TextStyle(fontSize: 16),),
        actions: <Widget>[
          AnimatedBuilder(
            animation: _btConnectedNotifier,
            builder: (BuildContext context, Widget? child) {
              return Container(
                color: _btConnectedNotifier.value ? Colors.green : Colors.red,
                child: IconButton(
                  icon: const Icon(Icons.print),
                  tooltip: 'Bluetooth',
                  onPressed: () {
                  },
                )
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          if(index == 0) {
            Navigator.pushNamed(context, '/history');
          // } else if(index == 1) {
          //   onPrint();
          } else if(index == 1) {
            Navigator.pushNamed(context, '/bluetooth');
          }
          // } else if(index == 3) {
          //   onClear(false);
          // }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
            backgroundColor: Colors.green,
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.print),
          //   label: 'Print',
          //   backgroundColor: Colors.green,
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.green,
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.clear),
          //   label: 'Clear',
          //   backgroundColor: Colors.green
          // ),
        ],
        currentIndex: _selectedIndex,
        // selectedItemColor: Colors.amber[800],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.green,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => {onAdd()},
            child: Icon(Icons.add),
            heroTag: "fab1",
          ),
          FloatingActionButton(
            onPressed: () => {onPrint()},
            child: Icon(Icons.print),
            heroTag: "fab2",
          ),
          FloatingActionButton(
            onPressed: () => {onClear(false)},
            child: Icon(Icons.clear),
            heroTag: "fab3",
          ),
          FloatingActionButton(
            onPressed: () => {},
            child: Icon(Icons.discount),
          ),
        ]
      ),
      // floatingActionButton: Stack(
        
      //   children: <Widget>[
      //     Align(
      //       alignment: Alignment.bottomLeft,
      //       child: FloatingActionButton(
      //         backgroundColor: Colors.orange,
      //         child: Icon(Icons.add),
      //         onPressed: () {
      //           print("Tab Floating");
      //           onAdd();
      //         },
      //       ),
      //     ),
      //     Align(
      //       alignment: Alignment.bottomCenter,
      //       child: FloatingActionButton(
      //         backgroundColor: Colors.orange,
      //         child: Icon(Icons.print),
      //         onPressed: () {
      //           onPrint();
      //         },
      //       ),
      //     ),
      //     Align(
      //       alignment: Alignment.bottomRight,
      //       child: FloatingActionButton(
      //         backgroundColor: Colors.orange,
      //         child: Icon(Icons.clear),
      //         onPressed: () {
      //           onClear(false);
      //         },
      //       ),
      //     ),
      //   ],
      // ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.orange,
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     print("Tab Floating");
      //     onAdd();
      //   },
      // ),
      body: itemForms.isNotEmpty
          ? ListView.separated(
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemCount: itemForms.length,
              itemBuilder: (_, index) {
                return itemForms[index];
              })
          : Center(child: Text("Tap on + to Add Item")),
    );
  }

  // onSave() {
  //   bool allValid = true;

  //   itemForms
  //       .forEach((element) => allValid = (allValid && element.isValidated()));

  //   if (allValid) {
  //     List<String> names =
  //         itemForms.map((e) => e.itemModel.name).toList();
  //     debugPrint("$names");
  //   } else {
  //     debugPrint("Form is Not Valid");
  //   }
  // }

  //Delete specific form
  onRemove(ItemModel contact) {
    setState(() {
      int index = itemForms
          .indexWhere((element) => element.itemModel.index == contact.index);

      if (itemForms != null) itemForms.removeAt(index);
      this.calculateTotal();
      // if(itemForms.isEmpty) billNumber-- ;
    });
  }

  //Clear com[plete form
  onClear(bool afterSave) {
    setState(() {
      itemForms.clear();
      this.calculateTotal();
      currentBill.billNumber = 0;
      currentBill.id = null;
    });
    if(!afterSave) {
      AppService.instance.cancelBillCounter();
    }
    
  }

  void onPrint() async {
    Bill bill = await onSave();
    if(bill.items!.length ==0){
      return;
    }
    print('printer state' + printer.isConnected().toString());
    // if(printer.isConnected()) {
      Bill data  = Bill.clone(bill);
      await printer.billPrint(data);
      onClear(true);
  }

  Future<Bill> onSave() async {
    List<ItemModel> items = List.empty(growable: true);
    itemForms
        .forEach((element) => {
          if(element.itemModel.code != null && element.itemModel.price != null)
            items.add(element.itemModel)
    });
    currentBill.dateTime = DateTime.now();
    currentBill.items = items;
    // Bill bill = new Bill(id: null, billNumber: billNumber, dateTime: DateTime.now(), amount: totalPrice, quantity: totalQuantity, items: items);
    if(items.isEmpty) {
      var snackBar = SnackBar(
          content: const Text('Hey! Enter Items for print!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print(jsonEncode(currentBill).toString());
      if(currentBill.id == null || currentBill.id == 0) {
        currentBill.id = null;
        final id = await dbHelper.insert(currentBill);
        print("Saved ID: $id");
        currentBill.id = id;
      } else {
        final id = await dbHelper.update(currentBill);
        print("Updated ID: $id");
      }
      // currentBill = new Bill();
      // billNumber++;
      
    }
    return currentBill;
  }

  onChange(ItemModel item) { 
    this.calculateTotal();
  }

  onEndTab(ItemModel item) { 
    print("Tab ${item.index}");
    if(item.index ==itemForms.length) {
      onAdd();
    } 
  }

  onEdit(ItemModel item) { 
    print("Edit ${item.index}");
    for (var widget in itemForms) {
      if(item.index == widget.index)
        widget.setEditMode(true);
      else
        widget.setEditMode(false);
    }
    if(item.index ==itemForms.length) {
      onAdd();
    } 
  }

  void calculateTotal() {
    double price =0, quantity = 0;
    for (var widget in itemForms) {
      if(widget.itemModel.quantity != null && widget.itemModel.price != null) {
        price += (widget.itemModel.quantity! * widget.itemModel.price!);
        quantity += widget.itemModel.quantity!;
      }
    }
    setState(() {
      currentBill.quantity = quantity;
      currentBill.amount = price;
    });

    print("Total Items: ${currentBill.quantity}");
    print("Total Price: ${currentBill.amount}");
  }

  onAdd() {

    if(itemForms.isEmpty) {
      currentBill.billNumber = AppService.instance.getNextBillCounter();
    }

    for (var widget in itemForms) {
      if(widget.itemModel.quantity == null || widget.itemModel.price == null) {
        var snackBar = SnackBar(
          content: const Text('Hey! Enter missing field!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }

    for (var widget in itemForms) {
      widget.setEditMode(false);
    }

    setState(() {
      ItemModel _itemModel = ItemModel(index: itemForms.length+1, code: 1, name: "Item1");
      ItemFormItemWidget widget = ItemFormItemWidget(
        index: itemForms.length+1,
        itemModel: _itemModel,
        onRemove: () => onRemove(_itemModel),
        onChange: () => onChange(_itemModel),
        onEndTab: () => onEndTab(_itemModel),
        onEdit: () => onEdit(_itemModel),
      );
      // widget.setEditMode(true);
      itemForms.add(widget);
      // widget.setFocus();
    });
  }

}

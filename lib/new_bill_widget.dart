import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:retail_bill/item_form_item_widget.dart';
import 'package:retail_bill/item_model.dart';
import 'package:retail_bill/persist/bill.dart';
import 'package:retail_bill/persist/db_helper.dart';
import 'package:retail_bill/print/BillPrinter.dart';
import 'package:retail_bill/services/app_service.dart';

class NewBillWidget extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() {
    return _NewBillWidgetState();
  }
}

class _NewBillWidgetState extends State<NewBillWidget> {
  
  BillPrinter printer = BillPrinter.instance;
  final dbHelper = DatabaseHelper.instance;
  late ValueNotifier<bool> _btConnectedNotifier;
  // double totalQuantity  = 0;
  // double totalPrice  = 0;
  // int billNumber = 0;
  int _selectedIndex = 0;
  List<ItemFormItemWidget> itemForms = List.empty(growable: true);
  late Bill currentBill = new Bill(id: 0, billNumber: 0, amount: 0, quantity: 0);

  List<Step> _stepList = List.empty(growable: true);
  int _currentStep = 0;
  StepperType stepperType = StepperType.vertical;

_NewBillWidgetState() {
  _btConnectedNotifier = printer.connected;
}

  @override
  void initState() {
    super.initState();
    print('init state of form widget');
  }

  @override
  Widget build(BuildContext context) {


    _stepList.add(addItem());
    _stepList.add(addItem());
    _stepList.add(addItem());

    return Scaffold(
      appBar: AppBar(
        title: Text("Bill No:${currentBill.billNumber}  Items:${currentBill.quantity}  Price:${currentBill.amount}"),
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
      body: Container(
          child: Column(
            children: [
              Expanded(
                child: Stepper(
                  type: stepperType,
                  physics: ScrollPhysics(),
                  currentStep: _currentStep,
                  onStepTapped: (step) {
                    print('tapped callback: ' + step.toString());
                    tapped(step);
                  },
                  onStepContinue:  continued,
                  onStepCancel: cancel,
                  steps: _stepList,
                ),
              ),
            ],
          ),
        ),
    );
  }

  Step addItem() {

    ItemModel _itemModel = ItemModel(index: _stepList.length, code: 1, name: "Item1");
      // BillItemWidget widget = BillItemWidget(
      //   index: _stepList.length,
      //   itemModel: _itemModel,
      //   onRemove: () => onRemove(_itemModel),
      //   onChange: () => onChange(_itemModel),
      //   onEndTab: () => onEndTab(_itemModel)
      // );

int index= _stepList.length;
    return Step(
        title: new Text('Account'),
        content: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Email Address'),
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Password'),
                          ),
                        ],
                      ),
        isActive: _currentStep >= 0,
        state: _currentStep >= _stepList.length ?
        StepState.complete : StepState.disabled,
      );
  }

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
    } else {
      // itemForms[item.index!].setFocus();
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

    // if(itemForms.isEmpty) {
    //   currentBill.billNumber = AppService.instance.getNextBillCounter();
    // }

    // for (var widget in itemForms) {
    //   if(widget.itemModel.quantity == null || widget.itemModel.price == null) {
    //     var snackBar = SnackBar(
    //       content: const Text('Hey! Enter missing field!'),
    //     );
    //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //     return;
    //   }
    // }
    // setState(() {
    //   ItemModel _itemModel = ItemModel(index: itemForms.length+1, code: 1, name: "Item1");
    //   ItemFormItemWidget widget = ItemFormItemWidget(
    //     index: itemForms.length+1,
    //     itemModel: _itemModel,
    //     onRemove: () => onRemove(_itemModel),
    //     onChange: () => onChange(_itemModel),
    //     onEndTab: () => onEndTab(_itemModel)
    //   );
    //   itemForms.add(widget);
    //   // widget.setFocus();
    // });
  }

  switchStepsType() {
    setState(() => stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  tapped(int step){
    print('tapped: $_currentStep');
    setState(() => _currentStep = step);
  }

  continued(){
    print('continued: $_currentStep ${_stepList.length}');
    _currentStep < _stepList.length ?
        setState(() => _currentStep += 1): null;
  }
  cancel(){
    print('cancel: $_currentStep');
    _currentStep > 0 ?
        setState(() => _currentStep -= 1) : null;
  }
}

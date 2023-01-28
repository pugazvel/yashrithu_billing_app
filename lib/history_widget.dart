import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retail_bill/bill_datasource.dart';
import 'package:retail_bill/persist/bill.dart';
import 'package:retail_bill/persist/db_helper.dart';
import 'package:retail_bill/view_bill_widget.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class HistoryWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HistoryWidgetState();
  }
}

class _HistoryWidgetState extends State<HistoryWidget> {

  final DataGridController _controller = DataGridController();
  TextEditingController _startDateController = new TextEditingController();
  TextEditingController _endDateController = new TextEditingController();

  int _selectedIndex = 0;
  late List<Bill> billList = List.empty(growable: true);
  late BillDataSource billDataSource = BillDataSource(bills: List.empty(growable: true));
  final formKey = new GlobalKey<FormState>();
  var lastID = 2;
  final dbHelper = DatabaseHelper.instance;
  int totalBills = 0;
  double totalAmt = 0;

  @override
  void initState() {
    super.initState();
    this.loadData();
  }

  @override
  void dispose() {
    super.dispose();
    // billList.clear();
    //billDataSource.dispose();
  }

  void loadData() async {
      print("History Loading");
      DateTime startDate;
      if(_startDateController.text.isNotEmpty) {
        startDate = DateTime.parse(_startDateController.text);
      } else {
        startDate = DateUtils.dateOnly(DateTime.now());
      }

      DateTime endDate;
      if(_endDateController.text.isNotEmpty) {
       endDate = DateTime.parse(_endDateController.text);
       endDate = endDate.add(Duration(days: 1));
      } else {
        endDate = startDate.add(Duration(days: 1));
      }

      late List<Bill> datas = List.empty(growable: true);
      // print(_startDateController.text);
      // print(_endDateController.text);
      List<Map<String, dynamic>> list = await dbHelper.queryAllRows(startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch);
      print(jsonEncode(list).toString());
      double amt = 0;
      for (var map in list) {
        Bill bill = Bill.fromMap(map);
        datas.add(bill);
        amt = amt + bill.amount!;
      }
      
      // print('Total Bills: '+ list.length.toString());
      setState(() {
        billDataSource = BillDataSource(bills: datas);
        totalBills = datas.length;
        totalAmt = amt;
      });

      billList = datas.map((item) => new Bill.clone(item)).toList();
      // billList = datas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          if(index == 0) {
            Navigator.pop(context);
          } else if(index == 1) {
            // Navigator.pushNamed(context, '/bluetooth');
            
            print('Bill Count: ' + billList.length.toString());
            if(_controller.selectedIndex != -1) { 
              int selectedRowIndex = _controller.selectedIndex;
              // DataGridRow selectedRow = _controller.selectedRow!;
              
              Bill data = billList[selectedRowIndex];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewBillWidget(
                    data: data,
                  )),
              );
            }
          } else if(index == 2) {
            Navigator.pushNamed(context, '/bluetooth');
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_rounded),
            label: 'New Bill',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.read_more),
            label: 'View',
            backgroundColor: Colors.green
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.green
          ),
        ],
        currentIndex: _selectedIndex,
        // selectedItemColor: Colors.amber[800],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.blue,
      ),
      body: ListView(
          children: <Widget>[
            Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                          controller: _startDateController, //editing controller of this TextField
                            decoration: const InputDecoration( 
                                      icon: Icon(Icons.calendar_today), //icon of text field
                                    labelText: "Start Date" //label text of field
                              ),
                            readOnly: true,  // when true user cannot edit text 
                            onTap: () async {
                                    await showAndSelectDate(_startDateController);
                              }
                    ),
                    TextField(
                          controller: _endDateController, //editing controller of this TextField
                            decoration: const InputDecoration( 
                                      icon: Icon(Icons.calendar_today), //icon of text field
                                    labelText: "End Date" //label text of field
                              ),
                            readOnly: true,  // when true user cannot edit text 
                            onTap: () async {
                                    await showAndSelectDate(_endDateController);
                              }
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => {
                          this.loadData()
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              // scrollDirection: Axis.horizontal,
              child: SfDataGrid(source: billDataSource,
              columns: [GridColumn(
                  columnName: 'No',
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      alignment: Alignment.center,
                      child: Text(
                        'No',
                        overflow: TextOverflow.ellipsis,
                      ))),
                GridColumn(
                  columnName: 'Date',
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Date',
                        overflow: TextOverflow.ellipsis,
                      ))),
                GridColumn(
                  columnName: 'Quantity',
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Quantity',
                        overflow: TextOverflow.ellipsis,
                      ))),
                GridColumn(
                  columnName: 'Amount',
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Amount',
                        overflow: TextOverflow.ellipsis,
                      ))),
                GridColumn(
                  columnName: 'Discount',
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Discount',
                        overflow: TextOverflow.ellipsis,
                      ))),
                
                ],
                selectionMode: SelectionMode.single,
                controller: _controller,
              ),
              // child: DataTable(
              //   columns: [
              //     DataColumn(
              //       label: Text("No"),
              //     ),
              //     DataColumn(
              //       label: Text("Date"),
              //     ),
              //     DataColumn(
              //       label: Text("Amount"),
              //     ),
              //     DataColumn(
              //       label: Text("Quantity"),
              //     ),
              //   ],
              //   rows: billList.map(
              //     (p) => DataRow(selected: true,
              //       onSelectChanged: (x) {
              //         setState(() {
              //        // isSelected = x;
              //         });
              //       },cells: [
              //       DataCell(
              //         Text(p.billNumber.toString()),
              //       ),
              //       DataCell(
              //         Text(p.dateTime.toString()),
              //       ),
              //       DataCell(
              //         Text(p.amount.toString()),
              //       ),
              //       DataCell(
              //         Text(p.quantity.toString()),
              //       ),
              //     ]),
              //   ).toList(),
              // ),
            ),
            Text('Total Bills: $totalBills'),
            Text('Total Sales: ₹$totalAmt'),
          ],
        ),
    );
  }

  showAndSelectDate(TextEditingController controller) async {
    //when click we have to show the datepicker
    DateTime? pickedDate = await showDatePicker(
    context: context,
      initialDate: DateTime.now(), //get today's date
    firstDate:DateTime(2000), //DateTime.now() - not to allow to choose before today.
    lastDate: DateTime(2101));
    if(pickedDate != null ){
      print(pickedDate);  //get the picked date in the format => 2022-07-04 00:00:00.000
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
      print(formattedDate); //formatted date output using intl package =>  2022-07-04
        //You can format date as per your need
      setState(() {
        controller.text = formattedDate; //set foratted date to TextField value. 
      });
  }else{
      print("Date is not selected");
  }
  }
}
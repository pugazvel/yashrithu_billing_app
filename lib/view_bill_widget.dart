import 'package:flutter/material.dart';
import 'package:retail_bill/item_datasource.dart';
import 'package:retail_bill/item_model.dart';
import 'package:retail_bill/persist/bill.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ViewBillWidget extends StatelessWidget {
  final Bill ?data;
  late ItemDataSource itemDataSource = ItemDataSource(items: List.empty(growable: true));

  ViewBillWidget({this.data});
  @override
  Widget build(BuildContext context) {
    List<ItemModel> items = List.empty(growable: true);
    if(data!.items != null)
      items = data!.items!;
    itemDataSource = ItemDataSource(items: items);
    return Scaffold(
      appBar: AppBar(
        title: Text('View Bill'),
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Container(
              height: 54.0,
              padding: EdgeInsets.all(12.0),
              child: Text('Bill Details:',
               style: TextStyle(fontWeight: FontWeight.w700))),
            Text('Bill Number: ${data!.billNumber.toString()}'),
            Text('Date: ${data!.dateTime.toString()}'),
            Text('Amount: ${data!.amount}'),
            Text('Quantity: ${data!.quantity}'),
            Text('Discount: ${data!.discount}'),
            SfDataGrid(source: itemDataSource,
              columns: [GridColumn(
                  columnName: 'No',
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerRight,
                      child: Text(
                        'No',
                        overflow: TextOverflow.ellipsis,
                      ))),
                GridColumn(
                  columnName: 'Name',
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Name',
                        overflow: TextOverflow.ellipsis,
                      ))),
                GridColumn(
                  columnName: 'Price',
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Price',
                        overflow: TextOverflow.ellipsis,
                      ))),
                GridColumn(
                  columnName: 'Quantity',
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Quantity',
                        overflow: TextOverflow.ellipsis,
                      ))),
                  GridColumn(
                  columnName: 'Amount',
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Amount',
                        overflow: TextOverflow.ellipsis,
                      ))),
                ],
                selectionMode: SelectionMode.none,
              ),
          ],
        ),
      ),
    );
  }
}
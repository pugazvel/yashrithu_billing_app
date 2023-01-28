import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:retail_bill/persist/bill.dart';

class BillDataSource extends DataGridSource {
  BillDataSource({required List<Bill> bills}) {
    dataGridRows = bills
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'No', value: dataGridRow.billNumber),
              DataGridCell<String>(columnName: 'Date', value: dataGridRow.dateTime!.toIso8601String()),
              DataGridCell<double>(
                  columnName: 'Quantity', value: dataGridRow.quantity),
              DataGridCell<double>(
                  columnName: 'Amount', value: dataGridRow.amount),
              DataGridCell<double>(
                  columnName: 'Discount', value: dataGridRow.discount),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          // alignment: (dataGridCell.columnName == 'No' ||
          //         dataGridCell.columnName == 'Date')
          //     ? Alignment.centerRight
          //     : Alignment.centerLeft,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }
}
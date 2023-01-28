import 'package:flutter/material.dart';
import 'package:retail_bill/item_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';


class ItemDataSource extends DataGridSource {
  ItemDataSource({required List<ItemModel> items}) {
    dataGridRows = items
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'No', value: dataGridRow.index),
              DataGridCell<String>(columnName: 'Name', value: dataGridRow.name.toString()),
              DataGridCell<String>(columnName: 'Price', value: dataGridRow.price.toString()),
              DataGridCell<String>(columnName: 'Quantity', value: dataGridRow.quantity.toString()),
              DataGridCell<double>(
                  columnName: 'Amount', value: (dataGridRow.quantity! * dataGridRow.price!)),
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
          alignment: (dataGridCell.columnName == 'No' ||
                  dataGridCell.columnName == 'Name')
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }
}
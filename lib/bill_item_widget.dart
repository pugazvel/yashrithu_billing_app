// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:math' as math;
// import 'package:retail_bill/item_model.dart';
// import 'package:retail_bill/services/decimal_text_inpiut_formatter.dart';

// class BillItemWidget extends StatefulWidget {
//   BillItemWidget({Key? key, required this.itemModel, required this.onRemove, required this.onChange, required this.onEndTab, this.index})
//       : super(key: key);

//   final index;
//   ItemModel itemModel;
//   final Function onRemove;
//   final Function onChange;
//   final Function onEndTab;
//   // var state;
//   var state = _BillItemWidgetState();

//   @override
//   State<StatefulWidget> createState() {
//     // this.state = new _ItemFormItemWidgetState();
//     return this.state;
//   }

//   // bool isValidated() => state.validate();
//   // void setFocus() => state.setFocus();
// }

// class _BillItemWidgetState extends State<BillItemWidget> {
//   // TextEditingController? _codeController;
//   // TextEditingController? _nameController;
//   TextEditingController? _priceController;
//   TextEditingController? _quantityController;
//   late ItemModel itemModel;

//   @override
//   void initState() {
//     super.initState();
//     _priceController = new TextEditingController(text: widget.itemModel.price != null ? widget.itemModel.price.toString() : "");
//     _quantityController = new TextEditingController(text: widget.itemModel.quantity != null ? widget.itemModel.quantity.toString() : "");
//   }

//   @override
//   void dispose() {
//     // Clean up the focus node when the Form is disposed.
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return  Column(
//       children: <Widget>[
//         TextFormField(
//             inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
//             keyboardType: TextInputType.numberWithOptions(decimal: true),
//             textInputAction: TextInputAction.next,
//             autofocus: true,
//             onChanged: (value) {
//               widget.itemModel.price = double.tryParse(value)?.toDouble();
//               widget.onChange();
//             },
//             onSaved: (value) {
//                 widget.itemModel.price = double.parse(value!);
//             },
//             decoration: InputDecoration(
//               contentPadding: EdgeInsets.symmetric(horizontal: 12),
//               border: OutlineInputBorder(),
//               hintText: "Enter Price",
//               labelText: "Price",
//             ),
//           ),
//           new TextFormField(
//               controller: _quantityController,
//               inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               textInputAction: TextInputAction.next,
//               onChanged: (value) {
//                 widget.itemModel.quantity = double.tryParse(value)?.toDouble();
//                 widget.onChange();
//               },
//               onFieldSubmitted: (value) {
//                 print("submit");
//                 widget.onEndTab();
//                 print("submiting");
//               },
//               onSaved: (value) => {
//                   widget.itemModel.quantity = double.parse(value!),
//               },
//               decoration: InputDecoration(
//                 contentPadding: EdgeInsets.symmetric(horizontal: 12),
//                 border: OutlineInputBorder(),
//                 hintText: "Enter Quantity",
//                 labelText: "Quantity",
//               ),
//             ),
//       ],
//     );
//   }
// }
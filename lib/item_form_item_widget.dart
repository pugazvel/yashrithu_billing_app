import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:retail_bill/item_model.dart';
import 'package:ensure_visible_when_focused/ensure_visible_when_focused.dart';

class ItemFormItemWidget extends StatefulWidget {
  ItemFormItemWidget({Key? key, required this.itemModel, required this.onRemove, required this.onChange, required this.onEndTab, required this.onEdit, this.index})
      : super(key: key);

  final index;
  final ItemModel itemModel;
  final Function onRemove;
  final Function onChange;
  final Function onEndTab;
  final Function onEdit;
  var state;
  bool _editMode = true;

  @override
  State<StatefulWidget> createState() {
    this.state = new _ItemFormItemWidgetState();
    this.state.editMode = _editMode;
    return this.state;
  }

  void setFocus() => state.setFocus();

  void setEditMode(bool mode) {
    _editMode = mode;
    state.setEditMode(mode);
  }
}

class _ItemFormItemWidgetState extends State<ItemFormItemWidget> {
  // final formKey = GlobalKey<FormState>();
  FocusNode? focusNode;

  // TextEditingController? _codeController;
  // TextEditingController? _nameController;
  TextEditingController? _priceController;
  TextEditingController? _quantityController;
  bool _editMode = true;

@override
  void initState() {
    super.initState();
    print("initState called: ${widget.itemModel.index} $_editMode");
    focusNode = FocusNode();
    if(_editMode) {
    focusNode!.requestFocus();
    }
    // _codeController = new TextEditingController(text: widget.itemModel.code.toString());
    // _nameController = new TextEditingController(text: widget.itemModel.name.toString());
    _priceController = new TextEditingController(text: widget.itemModel.price != null ? widget.itemModel.price.toString() : "");
    _quantityController = new TextEditingController(text: widget.itemModel.quantity != null ? widget.itemModel.quantity.toString() : "");
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    focusNode!.dispose();
    super.dispose();
  }

  void setEditMode(bool mode) {
    if(_editMode != mode) {
      setState(() {
        _editMode = mode;
      });
    }
  }

  set editMode(bool mode) { _editMode=mode;}

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Form(
          // key: formKey,
          child: Container(
            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(
                    //   "${widget.index}",
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 16,
                    //       color: Colors.orange),
                    // ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // TextButton(
                        //     onPressed: () {
                        //       setState(() {
                        //         //Clear All forms Data
                        //         widget.itemModel.code = 1;
                        //         widget.itemModel.name = "Item1";
                        //         widget.itemModel.price = 1;
                        //         widget.itemModel.quantity = 1;
                        //         _codeController.clear();
                        //         _nameController.clear();
                        //         _priceController.clear();
                        //         _quantityController.clear();
                        //       });
                        //     },
                        //     child: Text(
                        //       "Clear",
                        //       style: TextStyle(color: Colors.blue),
                        //     )),
                        TextButton(
                            onPressed: () => widget.onRemove(),
                            child: Text(
                              "Remove",
                              style: TextStyle(color: Colors.blue),
                            )),
                      ],
                    ),
                  ],
                ),
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: true,
                  child:  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.index}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange),
                      ),
                      // new Flexible(
                      //   child: new TextFormField(
                      //     controller: _codeController,
                      //     textInputAction: TextInputAction.next,
                      //     onChanged: (value) =>
                      //         widget.itemModel.code = int.parse(value),
                      //     onSaved: (value) => widget.itemModel.code = int.parse(value!),
                      //     validator: (value) => value!.length > 0 ? null : "Enter Code",
                      //     decoration: InputDecoration(
                      //       contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      //       border: OutlineInputBorder(),
                      //       hintText: "Enter Code",
                      //       labelText: "Code",
                      //     ),
                      //   ),
                      // ),
                      // new Flexible(
                      //   child: new TextFormField(
                      //     controller: _nameController,
                      //     enabled: false,
                      //     onChanged: (value) => widget.itemModel.name = value,
                      //     onSaved: (value) => widget.itemModel.name = value,
                      //     decoration: InputDecoration(
                      //       contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      //       border: OutlineInputBorder(),
                      //       hintText: "Enter Name",
                      //       labelText: "Name",
                      //     ),
                      //   ),
                      // ),
                      new Flexible(
                        child:  EnsureVisibleWhenFocused(
                        focusNode: focusNode!,
                        child: new TextFormField(
                            controller: _priceController,
                            inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            textInputAction: TextInputAction.next,
                            autofocus: true,
                            focusNode: focusNode,
                            onChanged: (value) {
                              widget.itemModel.price = double.tryParse(value)?.toDouble();
                              widget.onChange();
                            },
                            onSaved: (value) =>
                                widget.itemModel.price = double.parse(value!),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(),
                              hintText: "Enter Price",
                              labelText: "Price",
                            ),
                          ),
                        )
                      ),
                      new Flexible(
                        child: new TextFormField(
                          controller: _quantityController,
                          inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            widget.itemModel.quantity = double.tryParse(value)?.toDouble();
                            widget.onChange();
                          },
                          onFieldSubmitted: (value) {
                            print("submit");
                            widget.onEndTab();
                            print("submiting");
                          },
                          onSaved: (value) => {
                              widget.itemModel.quantity = double.parse(value!),
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(),
                            hintText: "Enter Quantity",
                            labelText: "Quantity",
                          ),
                        ),
                      ),
                    ]
                  ),
                )
                // TextFormField(
                //   controller: _codeController,
                //   onChanged: (value) =>
                //       widget.itemModel.code = int.parse(value),
                //   onSaved: (value) => widget.itemModel.code = int.parse(value),
                //   validator: (value) => value.length > 0 ? null : "Enter Code",
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.symmetric(horizontal: 12),
                //     border: OutlineInputBorder(),
                //     hintText: "Enter Code",
                //     labelText: "Code",
                //   ),
                // ),
                // SizedBox(
                //   height: 8,
                // ),
                // TextFormField(
                //   controller: _nameController,
                //   enabled: false,
                //   onChanged: (value) => widget.itemModel.name = value,
                //   onSaved: (value) => widget.itemModel.name = value,
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.symmetric(horizontal: 12),
                //     border: OutlineInputBorder(),
                //     hintText: "Enter Name",
                //     labelText: "Name",
                //   ),
                // ),
                // SizedBox(
                //   height: 8,
                // ),
                // TextFormField(
                //   controller: _priceController,
                //   autofocus: true,
                //   focusNode: focusNode,
                //   onChanged: (value) {
                //     widget.itemModel.price = double.tryParse(value)?.toDouble();
                //     widget.onChange();
                //   },
                //   onSaved: (value) =>
                //       widget.itemModel.price = double.parse(value),
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.symmetric(horizontal: 12),
                //     border: OutlineInputBorder(),
                //     hintText: "Enter Price",
                //     labelText: "Price",
                //   ),
                //   keyboardType: TextInputType.numberWithOptions(decimal: true),
                //   inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                // ),
                // SizedBox(
                //   height: 8,
                // ),
                // TextFormField(
                //   controller: _quantityController,
                //   onChanged: (value) {
                //     widget.itemModel.quantity = double.tryParse(value)?.toDouble();
                //     widget.onChange();
                //   },
                //   onSaved: (value) =>
                //       widget.itemModel.quantity = double.parse(value),
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.symmetric(horizontal: 12),
                //     border: OutlineInputBorder(),
                //     hintText: "Enter Quantity",
                //     labelText: "Quantity",
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // bool validate() {
  //   //Validate Form Fields
  //   bool validate = formKey.currentState!.validate();
  //   if (validate) formKey.currentState!.save();
  //   return validate;
  // }

  void setFocus() {
    focusNode!.requestFocus();
    print("set focus called: ${widget.itemModel.index}");
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
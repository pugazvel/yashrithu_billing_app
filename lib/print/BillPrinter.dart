import 'package:flutter/material.dart';
import 'package:retail_bill/item_model.dart';
import 'package:retail_bill/persist/bill.dart';
import 'package:retail_bill/persist/print_settings.dart';
import 'package:retail_bill/print/printerenum.dart' as printenum;
import 'package:flutter/services.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';

///Test printing
class BillPrinter {

  BillPrinter._();
  static BillPrinter _instance = new BillPrinter._();
  static BillPrinter get instance => _instance;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  // bool _connected = false;
  ValueNotifier<bool> connected = ValueNotifier<bool>(false);

  List<BluetoothDevice> get devices => _devices; 
  bool isConnected() {return connected.value; }

  PrintSettings settings = new PrintSettings(header1: 'Vignesh Impon Jwellers',
    header2: '#33 PP Mada Veethi', header3: 'Opposite To Pothys', header4: 'Srivilliputhur', 
    footer1: 'Thank You Visit Again', footer2: '+918838816680', qrCode: 'upi://pay?pa=8838816680@okbizaxis&pn=VIGNESH FANCY AND IMPON JWELLERS');

  Future<void> initPlatformState() async {
    // here add a permission request using permission_handler
    // if permission is not granted, kzaki's thermal print plugin will ask for location permission
    // which will invariably crash the app even if user agrees so we'd better ask it upfront

    // var statusLocation = Permission.location;
    // if (await statusLocation.isGranted != true) {
    //   await Permission.location.request();
    // }
    // if (await statusLocation.isGranted) {
    // ...
    // } else {
    // showDialogSayingThatThisPermissionIsRequired());
    // }
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    bluetooth.onStateChanged().listen((state) {
      bool status = false;
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
            status = true;
            print("bluetooth device state: connected");
          break;
        case BlueThermalPrinter.DISCONNECTED:
            status = false;
            print("bluetooth device state: disconnected");
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
            status = false;
            print("bluetooth device state: disconnect requested");
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
            status = false;
            print("bluetooth device state: bluetooth turning off");
          break;
        case BlueThermalPrinter.STATE_OFF:
            status = false;
            print("bluetooth device state: bluetooth off");
          break;
        case BlueThermalPrinter.STATE_ON:
            status = false;
            print("bluetooth device state: bluetooth on");
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
            status = false;
            print("bluetooth device state: bluetooth turning on");
          break;
        case BlueThermalPrinter.ERROR:
            status = false;
            print("bluetooth device state: error");
          break;
        default:
          print(state);
          break;
      }
      connected.value = status;
      connected.notifyListeners();
      // setState(() => ) ;
      
    });
    
    _devices = devices;

    if (isConnected == true) {
        connected.value = true;
    }
    print('printer status: ' + connected.value.toString());
  }

 Future<void> billPrint(Bill bill) async {
    print("print bill start");

    String noStr  = 'BILL No:' + bill.billNumber!.toString();
    String dateStr  = 'Date:' + DateFormat('dd-MM-yyyy').format(bill.dateTime!);

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printNewLine();
        bluetooth.printCustom(settings.header1!, printenum.Size.small.val, printenum.Align.center.val);
        // bluetooth.printNewLine();
        bluetooth.printCustom(settings.header2!, printenum.Size.small.val, printenum.Align.center.val);
        // bluetooth.printNewLine();
        bluetooth.printCustom(settings.header3!, printenum.Size.small.val, printenum.Align.center.val);
        // bluetooth.printNewLine();
        bluetooth.printCustom(settings.header4!, printenum.Size.small.val, printenum.Align.center.val);
        bluetooth.printNewLine();
        // bluetooth.printNewLine();
        bluetooth.printLeftRight(noStr, dateStr, printenum.Size.small.val);
        bluetooth.print4Column("ITEM", "PRICE", "QTY", "AMOUNT", printenum.Size.small.val);
        print(bill.items!.length);
        for(ItemModel item in bill.items!) {
          // print( jsonEncode(item));
          if(item.quantity != null && item.price != null) {
            double amount = item.quantity! * item.price!;
            bluetooth.print4Column(item.name!, item.price.toString(), item.quantity!.toString(), amount.toString(), printenum.Size.small.val);
          }
        }
        bluetooth.printLeftRight("TOTAL:", bill.amount.toString(), printenum.Size.small.val);
        
        bluetooth.printCustom(settings.footer1!, printenum.Size.small.val, printenum.Align.center.val);
        bluetooth.printCustom(settings.footer2!, printenum.Size.small.val, printenum.Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printQRcode(settings.qrCode!, 200, 200, printenum.Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
        print("print end");
      }
    });
  }
}

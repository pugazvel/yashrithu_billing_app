
import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:retail_bill/persist/db_helper.dart';
import 'package:retail_bill/persist/settings.dart';
import 'package:retail_bill/print/BillPrinter.dart';

class AppService {

  AppService._();
  static AppService _instance = new AppService._();
  static AppService get instance => _instance;

  DatabaseHelper dbHelper = DatabaseHelper.instance;
  BillPrinter printService = BillPrinter.instance;
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  late Settings appSettings = Settings();
  // late bool ?_btConnected;
  late BluetoothDevice _connectedDevice = BluetoothDevice('', '');

  // set btConnected (bool connected)  => _btConnected = connected; 
  // bool get btConnected  => _btConnected!;

  Future<void> onBootUp() async {
    print('on App startup');
    await printService.initPlatformState();
    
    List<Settings> list = await dbHelper.querySettings();
    if(list.isEmpty) {
      appSettings = new Settings();
      // appSettings.id = 1;
      appSettings.billCounter = 1;
      appSettings.connectedBtDevice = '';
      appSettings.lastBackupDate = DateTime.now().subtract(Duration(days: 10));
      // String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      DateTime today = DateUtils.dateOnly(DateTime.now());
      appSettings.billCounterDate = today;
      await dbHelper.insertSettings(appSettings);
      print('Settings initialized and updated db');
    } else {
      print('Settings loaded from db');
      appSettings = list[0];
    }
    print('settings' + appSettings.toMap().toString());
    verifyAndConnectBluetooth();
  }

  verifyAndConnectBluetooth() async {
    if(appSettings.connectedBtDevice != null) {
      print('bt devices size: ' + printService.devices.length.toString());
      for(BluetoothDevice device in printService.devices) {
        print(device.name);
        if(device.name == appSettings.connectedBtDevice) {
          _connectedDevice = device;
          if(_connectedDevice.connected == false) {
            await connectBtDevice(_connectedDevice);
          }
        }
      }
    }
  }

  Future<bool> connectBtDevice(BluetoothDevice device) async {
    bool ?btConnected = await bluetooth.isConnected; 
    if (btConnected == false) {
      await bluetooth.connect(device); 
      btConnected = true;
    }
    return btConnected!;
  }

  setConnectedDevice(BluetoothDevice device) async {
    if(_connectedDevice.name != device.name) {
      _connectedDevice = device;
      appSettings.connectedBtDevice = device.name!;
      print('update settings: ' + jsonEncode(appSettings.toMap()));
      await dbHelper.updateSettings(appSettings);
    }
  }

  int getNextBillCounter() {
    // String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    DateTime today = DateUtils.dateOnly(DateTime.now());
    if(today != appSettings.billCounterDate) {
      appSettings.billCounterDate = today;
      appSettings.billCounter = 1;
    } else {
      appSettings.billCounter = appSettings.billCounter! + 1;
    }
    dbHelper.updateSettings(appSettings);
    return appSettings.billCounter!;
  }

  int cancelBillCounter() {
    DateTime today = DateUtils.dateOnly(DateTime.now());
    
    if(today == appSettings.billCounterDate) {
      appSettings.billCounter = appSettings.billCounter! - 1;
      dbHelper.updateSettings(appSettings);
    } 
    return appSettings.billCounter!;
  }
}

import 'dart:convert';

import 'package:retail_bill/persist/db_helper.dart';

class Settings {
  int? id;
  String? connectedBtDevice;
  int? billCounter;
  DateTime? billCounterDate;
  DateTime? lastBackupDate;

  Settings();

  Settings.fromMap(Map<String, dynamic> map) {
    print('settings: '+ jsonEncode(map).toString());
    id = map[DatabaseHelper.columnId];
    connectedBtDevice = map[DatabaseHelper.columnConnectedBtDevice];
    lastBackupDate = DateTime.fromMillisecondsSinceEpoch(map[DatabaseHelper.columnLastBackupDate]);
    billCounter = map[DatabaseHelper.columnBillCounter];
    billCounterDate = DateTime.fromMillisecondsSinceEpoch(map[DatabaseHelper.columnBillCounterDate]);
  }

   Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnConnectedBtDevice: connectedBtDevice,
      DatabaseHelper.columnLastBackupDate: lastBackupDate!.millisecondsSinceEpoch,
      DatabaseHelper.columnBillCounter: billCounter,
      DatabaseHelper.columnBillCounterDate: billCounterDate!.millisecondsSinceEpoch,
    };
  }
}
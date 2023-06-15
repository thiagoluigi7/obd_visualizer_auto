import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Globals {
  static ValueNotifier<BluetoothDevice?> device = ValueNotifier<BluetoothDevice?>(null);

  static ValueNotifier<bool> configured = ValueNotifier<bool>(false);

  static ValueNotifier<String> engineSpeed = ValueNotifier<String>('');
  static ValueNotifier<String> vehicleSpeed = ValueNotifier<String>('');
  static ValueNotifier<String> fuelLevel = ValueNotifier<String>('');

  static const String configJson = '''
        [
          {
              "command": "AT Z",
              "description": "",
              "status": true
          },
          {
              "command": "AT E0",
              "description": "",
              "status": true
          },
          {
              "command": "AT SP 0",
              "description": "",
              "status": true
          },
          {
              "command": "AT S0",
              "description": "",
              "status": true
          },
          {
              "command": "AT M0",
              "description": "",
              "status": true
          },
          {
              "command": "AT AT 1",
              "description": "",
              "status": true
          },
          {
              "command": "01 00",
              "description": "",
              "status": true
          }
        ]''';

  static const String paramJson = '''
        [
          {
              "PID": "01 0C",
              "length": 2,
              "title": "Engine Speed",
              "unit": "RPM",
              "description": "<double>, (( [0] * 256) + [1] ) / 4",
              "status": true
          },
          {
              "PID": "01 0D",
              "length": 1,
              "title": "Vehicle Speed",
              "unit": "Kh",
              "description": "<int>, [0]",
              "status": true
          },
          {
              "PID": "01 2F",
              "length": 1,
              "title": "Fuel Level",
              "unit": "%",
              "description": "<int>, ( 100 / 255 ) * [0]",
              "status": true
          }
        ]
        ''';
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:obd2_plugin/obd2_plugin.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:obd_visualizer_auto/utils/utils.dart';
import 'package:obd_visualizer_auto/widgets/device_list.widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/globals.dart';
import '../widgets/base.widget.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return MaterialApp(
      title: 'OBD Visualizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'OBD Visualizer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  final Obd2Plugin obd2 = Obd2Plugin();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BluetoothDevice> devices = [];
  late Timer? timer;

  Future<void> _getDevices() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      List<BluetoothDevice> list = await widget.obd2.getPairedDevices;
      _setList(list);
    }
  }

  void _setList(List<BluetoothDevice> list) {
    setState(() => devices = list);
  }

  Future<void> _setAutoFetchData() async {
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (Globals.configured.value) {
        await _getData();
      }
    });
  }

  void _setResponseLogic(command, response, requestCode) {
    debugPrint('$command => $response');
    if (command == 'PARAMETER') {
      var parsedResponses = jsonDecode(response);
      for (final returnedResponse in parsedResponses) {
        String response = returnedResponse['response'] == ''
            ? '-- ${returnedResponse['unit']}'
            : '${double.parse(returnedResponse['response']).toStringAsFixed(2)} ${returnedResponse['unit']}';
        if (returnedResponse['PID'] == '01 0C') {
          Globals.engineSpeed.value = response;
        } else if (returnedResponse['PID'] == '01 0D') {
          Globals.vehicleSpeed.value = response;
        } else if (returnedResponse['PID'] == '01 2F') {
          Globals.fuelLevel.value = response;
        }
      }
    }
  }

  Future<void> _getConnection(BluetoothDevice device) async {
    try {
      Globals.device.value = device;

      await widget.obd2.getConnection(device, (connection) {
        debugPrint('Device ${device.name} selected');
      }, (message) {
        debugPrint('Error: $message');
      });

      await widget.obd2.setOnDataReceived((command, response, requestCode) {
        _setResponseLogic(command, response, requestCode);
      });

      if (await widget.obd2.isListenToDataInitialed) {
        await Future.delayed(Duration(
            milliseconds:
                await widget.obd2.configObdWithJSON(Globals.configJson)));

        Globals.configured.value = true;

        return;
      }

      debugPrint('Not initialized');
    } catch (e) {
      Globals.configured.value = false;
      debugPrint('Error: $e');
      showSnackBar(context, 'Erro na conexão');
    }
  }

  Future<void> _disconnect() async {
    Globals.device.value = null;
    Globals.configured.value = false;
    await widget.obd2.disconnect();
  }

  Future<void> _getData() async {
    try {
      debugPrint('Fetching data...');
      await Future.delayed(Duration(
          milliseconds:
              await widget.obd2.getParamsFromJSON(Globals.paramJson)));
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getDevices();
    _setAutoFetchData();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const SizedBox(height: 10),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    const SizedBox(width: 20),
                    ValueListenableBuilder<BluetoothDevice?>(
                        valueListenable: Globals.device,
                        builder: (context, value, Widget? child) {
                          return Text(
                              Globals.device.value != null
                                  ? 'Conectado a: ${Globals.device.value!.name}'
                                  : 'Não conectado',
                              style: const TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold));
                        }),
                    const SizedBox(width: 350),
                    ValueListenableBuilder<BluetoothDevice?>(
                        valueListenable: Globals.device,
                        builder: (context, value, Widget? child) {
                          return Visibility(
                            visible: Globals.device.value != null,
                            child: OutlinedButton(
                              onPressed: _disconnect,
                              child: const Text('Desconectar'),
                            ),
                          );
                        }),
                  ]),
                ]),
            const SizedBox(height: 50),
            ValueListenableBuilder<BluetoothDevice?>(
                valueListenable: Globals.device,
                builder: (context, value, Widget? child) {
                  return Visibility(
                    visible: Globals.device.value != null,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ValueListenableBuilder<String>(
                              valueListenable: Globals.engineSpeed,
                              builder: (context, value, Widget? child) {
                                return BaseWidget(
                                  name: 'Engine Speed',
                                  parsedValue: value,
                                );
                              }),
                          ValueListenableBuilder<String>(
                              valueListenable: Globals.vehicleSpeed,
                              builder: (context, value, Widget? child) {
                                return BaseWidget(
                                  name: 'Vehicle Speed',
                                  parsedValue: value,
                                );
                              }),
                          ValueListenableBuilder<String>(
                              valueListenable: Globals.fuelLevel,
                              builder: (context, value, Widget? child) {
                                return BaseWidget(
                                  name: 'Fuel Level',
                                  parsedValue: value,
                                );
                              })
                        ]),
                  );
                }),
            ValueListenableBuilder<BluetoothDevice?>(
                valueListenable: Globals.device,
                builder: (context, value, Widget? child) {
                  return Visibility(
                      visible: Globals.device.value == null,
                      child: DeviceList(
                          devices: devices, getConnection: _getConnection));
                }),
          ],
        ),
      ),
    );
  }
}

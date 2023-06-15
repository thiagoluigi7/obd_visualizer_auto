import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceListItem extends StatefulWidget {
  DeviceListItem({
    super.key,
    required this.name,
    required this.address,
    required this.device,
    required this.getConnection,
  });

  String? name;
  String? address;
  BluetoothDevice device;
  Function getConnection;

  @override
  DeviceListItemState createState() => DeviceListItemState();
}

class DeviceListItemState extends State<DeviceListItem> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        widget.getConnection(widget.device);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Nome: ${widget.name}'),
          const SizedBox(height: 10),
          Text('Endereço: ${widget.address}'),
        ],
      ),
    );
  }
}

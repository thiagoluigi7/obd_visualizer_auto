import 'package:flutter/material.dart';

class BaseWidget extends StatefulWidget {
  const BaseWidget({
    super.key,
    required this.name,
    required this.parsedValue,
  });

  final String name;
  final String parsedValue;

  @override
  BaseWidgetState createState() => BaseWidgetState();
}

class BaseWidgetState extends State<BaseWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(alignment: Alignment.center, children: <Widget>[
        Positioned(
            top: 0,
            left: 0,
            child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Color.fromRGBO(217, 217, 217, 1)))),
        Column(children: [
          const SizedBox(height: 6),
          Text(widget.name),
          const SizedBox(height: 6),
          Text(widget.parsedValue),
          // const SizedBox(height: 10),
        ])
      ]),
    );
  }
}

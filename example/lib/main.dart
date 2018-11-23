import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_sensors/flutter_sensors.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _sensorStatus = false;
  List<double> _sensorData = List(3);
  FlutterSensors _flutterSensors = FlutterSensors();

  @override
  void initState() {
    super.initState();
    initSensor();
  }

  Future<void> initSensor() async {
    bool accelerometerEnabled =
        await FlutterSensors.isSensorAvailable(Sensor.ACCELEROMETER);
    if (accelerometerEnabled) {
      var sensorCallback = (sensor, data, accuracy) {
        if (sensor == Sensor.LINEAR_ACCELERATION) {
          setState(() {
            _sensorData = data;
          });
        }
      };
      _flutterSensors.registerSensorListener(
        Sensor.LINEAR_ACCELERATION,
        sensorCallback,
        refreshRate: Duration(
          milliseconds: 250,
        ),
      );
    }
    setState(() {
      _sensorStatus = accelerometerEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Sensors Example'),
        ),
        body: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional.topCenter,
            child: Column(
              children: <Widget>[
                Text(
                  "Sensor Enabled: $_sensorStatus",
                  textAlign: TextAlign.center,
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
                Text(
                  "[0](X) = ${_sensorData[0]}",
                  textAlign: TextAlign.center,
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
                Text(
                  "[1](Y) = ${_sensorData[1]}",
                  textAlign: TextAlign.center,
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
                Text(
                  "[2](Z) = ${_sensorData[2]}",
                  textAlign: TextAlign.center,
                ),
              ],
            )),
      ),
    );
  }
}

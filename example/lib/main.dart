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
  List<double> _sensorData = List.filled(3, 0.0);
  SensorManager _sensorManager = SensorManager();

  @override
  void dispose() {
    _sensorManager.dispose();
    super.dispose();
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
                  "Accelerometer Test",
                  textAlign: TextAlign.center,
                ),
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
                Padding(padding: EdgeInsets.only(top: 16.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    MaterialButton(
                      child: Text("Start"),
                      color: Colors.green,
                      onPressed: () {
                        initSensor();
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    MaterialButton(
                      child: Text("Stop"),
                      color: Colors.red,
                      onPressed: () {
                        _sensorManager.unregisterAllListeners();
                      },
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  Future<void> initSensor() async {
    bool accelerometerEnabled =
        await SensorManager.isSensorAvailable(Sensors.ACCELEROMETER);
    if (accelerometerEnabled) {
      var sensorCallback = (sensor, data, accuracy) {
        if (sensor == Sensors.ACCELEROMETER) {
          setState(() {
            _sensorData = data;
          });
        }
      };
      _sensorManager.registerSensorListener(
        Sensors.ACCELEROMETER,
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
}

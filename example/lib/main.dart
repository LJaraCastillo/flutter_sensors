import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_sensors/flutter_sensors.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _accelerometerStatus = false;
  bool _gyroscopeStatus = false;
  bool _magineticFieldSensorStatus = false;
  bool _linearAccelerationSensorStatus = false;
  bool _lightSensorStatus = false;
  List<double> _accelerometerData = [0.0, 0.0, 0.0];
  List<double> _gyroscopeData = [0.0, 0.0, 0.0];
  var _magineticFieldSensorData;
  var _linearAccelerationSensorData;
  var _lightSensorData;
  FlutterSensors _flutterSensors = FlutterSensors();

  @override
  void initState() {
    super.initState();
    initAccelerometer();
  }

  Future<void> initAccelerometer() async {
    bool accelerometerEnabled =
        await FlutterSensors.isSensorAvailable(Sensor.ACCELEROMETER);
    bool gyroscopeEnabled =
        await FlutterSensors.isSensorAvailable(Sensor.GYROSCOPE);
    var sensorCallback = (sensor, data, accuracy) {
      if (sensor == Sensor.ACCELEROMETER) {
        setState(() {
          _accelerometerData = data;
        });
      } else if (sensor == Sensor.GYROSCOPE) {
        setState(() {
          _gyroscopeData = data;
        });
      }
    };
    _flutterSensors.registerSensorListener(
        Sensor.ACCELEROMETER, sensorCallback);
    _flutterSensors.registerSensorListener(Sensor.GYROSCOPE, sensorCallback);
    setState(() {
      _accelerometerStatus = accelerometerEnabled;
      _gyroscopeStatus = gyroscopeEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Sensors Example'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                _accelerometerStatus
                    ? """
                Accelerometer: $_accelerometerStatus\n
                X=${_accelerometerData[0]}\n
                Y=${_accelerometerData[1]}\n
                Z=${_accelerometerData[2]}"""
                    : "Accelerometer: $_accelerometerStatus",
                textAlign: TextAlign.center,
              ),
              Text(
                _gyroscopeStatus
                    ? """
                Gyroscope: $_gyroscopeStatus
                X=${_gyroscopeData[0]}\n
                Y=${_gyroscopeData[1]}\n
                Z=${_gyroscopeData[2]}"""
                    : "Gyroscope: $_gyroscopeStatus",
                textAlign: TextAlign.center,
              ),
            ],
          )),
    );
  }
}

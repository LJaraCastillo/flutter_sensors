import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_sensors/flutter_sensors.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _accelStatus = false;
  bool _gyroStatus = false;
  List<double> _accelData = List.filled(3, 0.0);
  List<double> _gyroData = List.filled(3, 0.0);
  StreamSubscription _accelSubscription;
  StreamSubscription _gyroSubscription;

  @override
  void dispose() {
    stopAccelerometer();
    stopGyroscope();
    super.dispose();
  }

  Future<void> startAccelerometer() async {
    if (_accelSubscription != null) return;
    bool accelerometerEnabled =
        await SensorManager.isSensorAvailable(Sensors.ACCELEROMETER);
    if (accelerometerEnabled) {
      _accelSubscription = SensorManager.sensorUpdates(SensorRequest(
        Sensors.ACCELEROMETER,
        refreshDelay: Sensors.SENSOR_DELAY_GAME,
      )).listen((sensorEvent) {
        setState(() {
          _accelData = sensorEvent.data;
        });
      });
    }
    setState(() {
      _accelStatus = accelerometerEnabled;
    });
  }

  void stopAccelerometer() {
    if (_accelSubscription == null) return;
    _accelSubscription.cancel();
    _accelSubscription = null;
  }

  Future<void> startGyroscope() async {
    if (_gyroSubscription != null) return;
    bool gyroEnabled = await SensorManager.isSensorAvailable(Sensors.GYROSCOPE);
    if (gyroEnabled) {
      _gyroSubscription =
          SensorManager.sensorUpdates(SensorRequest(Sensors.GYROSCOPE))
              .listen((sensorEvent) {
        setState(() {
          _gyroData = sensorEvent.data;
        });
      });
    }
    setState(() {
      _gyroStatus = gyroEnabled;
    });
  }

  void stopGyroscope() {
    if (_gyroSubscription == null) return;
    _gyroSubscription.cancel();
    _gyroSubscription = null;
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
                "Accelerometer Enabled: $_accelStatus",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[0](X) = ${_accelData[0]}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[1](Y) = ${_accelData[1]}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[2](Z) = ${_accelData[2]}",
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
                      startAccelerometer();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  MaterialButton(
                    child: Text("Stop"),
                    color: Colors.red,
                    onPressed: () {
                      stopAccelerometer();
                    },
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "Gyroscope Test",
                textAlign: TextAlign.center,
              ),
              Text(
                "Gyroscope Enabled: $_gyroStatus",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[0](X) = ${_gyroData[0]}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[1](Y) = ${_gyroData[1]}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[2](Z) = ${_gyroData[2]}",
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
                      startGyroscope();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  MaterialButton(
                    child: Text("Stop"),
                    color: Colors.red,
                    onPressed: () {
                      stopGyroscope();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

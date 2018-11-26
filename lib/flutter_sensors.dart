import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class Sensor {
  static const int ACCELEROMETER = 1;
  static const int GYROSCOPE = 4;
  static const int MAGNETIC_FIELD = 2;
  static const int LINEAR_ACCELERATION = 10;
  static const int STEP_COUNTER = 19;
}

typedef SensorCallback(int sensor, List<double> data, int accuracy);

class FlutterSensors {
  static const MethodChannel _methodChannel = const MethodChannel('flutter_sensors');
  static const EventChannel _eventChannel = const EventChannel('flutter_sensor_update_channel');
  Map<int, SensorCallback> _sensorCallbackMap = Map();
  Stream<dynamic> _updateStream;

  FlutterSensors() {
    initUpdateStream();
  }

  void initUpdateStream(){
    _updateStream = _eventChannel.receiveBroadcastStream();
    _updateStream.listen((resultMap){
      int sensor = resultMap["sensor"];
      int accuracy = resultMap["accuracy"];
      SensorCallback sensorCallback = _sensorCallbackMap[sensor];
      List<double> data = [];
      List<dynamic> resultData = resultMap["data"];
      resultData.forEach((value) {
        data.add(value);
      });
      sensorCallback(sensor, data, accuracy);
    });
  }

  void registerSensorListener(int sensor, SensorCallback sensorCallback,
      {Duration refreshRate}) async {
    if (await isSensorAvailable(sensor)) {
      Map data = {
        "sensor": sensor,
      };
      data.putIfAbsent(
        "rate",
        () => refreshRate != null
            ? Platform.isAndroid
                ? refreshRate.inMicroseconds
                : refreshRate.inSeconds
            : null,
      );
      final bool registed = await _methodChannel.invokeMethod(
        "register_sensor_listener",
        data,
      );
      if (registed) _sensorCallbackMap[sensor] = sensorCallback;
    }
  }

  void unregisterSensorListener(int sensor) async {
    if (_sensorCallbackMap.containsKey(sensor)) {
      final bool unregisted = await _methodChannel.invokeMethod(
        "unregister_sensor_listener",
        {"sensor": sensor},
      );
      if (unregisted) _sensorCallbackMap.remove(sensor);
    }
  }

  static Future<bool> isSensorAvailable(int sensor) async {
    final bool isAvailable = await _methodChannel.invokeMethod(
      'is_sensor_available',
      {"sensor": sensor},
    );
    return isAvailable;
  }
}

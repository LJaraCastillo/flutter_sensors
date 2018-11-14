import 'dart:async';

import 'package:flutter/services.dart';

enum Sensor { ACCELEROMETER, GYROSCOPE, MAGNETIC_FIELD, LIGHT }

typedef SensorCallback(Sensor sensor, List<double> data, int accuracy);

class FlutterSensors {
  static const MethodChannel _channel = const MethodChannel('flutter_sensors');
  Map<Sensor, SensorCallback> _sensorCallbackMap = Map();

  FlutterSensors() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  void registerSensorListener(
      Sensor sensor, SensorCallback sensorCallback) async {
    if (await isSensorAvailable(sensor)) {
      final bool registed = await _channel.invokeMethod(
        "register_sensor_listener",
        {"sensor": sensor.index},
      );
      if (registed) _sensorCallbackMap[sensor] = sensorCallback;
    }
  }

  void unregisterSensorListener(Sensor sensor) async {
    if (_sensorCallbackMap.containsKey(sensor)) {
      final bool unregisted = await _channel.invokeMethod(
        "unregister_sensor_listener",
        {"sensor": sensor.index},
      );
      if (unregisted) _sensorCallbackMap.remove(sensor);
    }
  }

  static Future<bool> isSensorAvailable(Sensor sensor) async {
    final bool isAvailable = await _channel.invokeMethod(
      'is_sensor_available',
      {"sensor": sensor.index},
    );
    return isAvailable;
  }

  Future<String> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "sensor_updated":
        {
          Map resultMap = call.arguments;
          Sensor sensor = Sensor.values[resultMap["sensor"]];
          int accuracy = resultMap["accuracy"];
          SensorCallback sensorCallback = _sensorCallbackMap[sensor];
          List<double> data = [];
          List<dynamic> resultData = resultMap["data"];
          resultData.forEach((value) {
            data.add(value);
          });
          sensorCallback(sensor, data, accuracy);
          return Future.value("");
        }
    }
    return Future.value("");
  }
}

library flutter_sensors;

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

part 'src/sensors.dart';
part 'src/sensor_model.dart';
part 'src/sensor_channel.dart';

class SensorManager {
  static final _SensorChannel _sensorChannel = _SensorChannel();

  static Stream<SensorEvent> sensorUpdates(SensorRequest request) =>
      _sensorChannel.sensorUpdates(request);

  static Future<bool> isSensorAvailable(int sensor) =>
      _SensorChannel.isSensorAvailable(sensor);
}

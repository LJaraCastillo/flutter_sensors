library flutter_sensors;

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

part 'src/sensor_channel.dart';

part 'src/sensor_model.dart';

part 'src/sensors.dart';

class SensorManager {
  static final _SensorChannel _sensorChannel = _SensorChannel();

  /// Opens a stream to receive sensor updates from the desired sensor
  /// defined in the [request].
  static Stream<SensorEvent> sensorUpdates(SensorRequest request) =>
      _sensorChannel.sensorUpdates(request);

  /// Opens a stream to receive sensor updates from the desired sensors.
  /// Requires a list of requests.
  static Stream<SensorEvent> sensorsUpdates(List<SensorRequest> request) =>
      _sensorChannel.sensorsUpdates(request);

  /// Checks if the [sensor] is available in the system or supported by the
  /// plugin.
  static Future<bool> isSensorAvailable(int sensor) =>
      _SensorChannel.isSensorAvailable(sensor);
}

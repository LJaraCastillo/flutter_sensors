library flutter_sensors;

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

part 'src/sensor_channel.dart';

part 'src/sensor_event.dart';

part 'src/sensors.dart';

class SensorManager {
  /// Singleton for the sensor manager.
  static final SensorManager _singleton = SensorManager._internal();

  /// Returns the singleton instance. Builds the instance first if is null.
  factory SensorManager() {
    return _singleton;
  }

  /// Internal constructor of the class.
  SensorManager._internal();

  /// Sensor channel to call the platform methods.
  final _SensorChannel _sensorChannel = _SensorChannel();

  /// Opens a stream to receive sensor updates from the desired sensor
  /// defined in the [request]. Returns the future of a stream because
  /// the sensor event channels are dynamically created and must be
  /// registered before returning the stream for each channel.
  Future<Stream<SensorEvent>> sensorUpdates(
          {required int sensorId, Duration? interval}) =>
      _sensorChannel.sensorUpdates(sensorId: sensorId, interval: interval);

  /// Checks if the [sensorId] is available in the system or supported by the
  /// plugin.
  Future<bool> isSensorAvailable(int sensorId) =>
      _sensorChannel.isSensorAvailable(sensorId);

  /// Updates the interval between updates for an specific sensor.
  Future updateSensorInterval({required int sensorId, Duration? interval}) =>
      _sensorChannel.updateSensorInterval(
          sensorId: sensorId, interval: interval);
}

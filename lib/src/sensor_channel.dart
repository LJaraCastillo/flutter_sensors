part of flutter_sensors;

typedef SensorCallback(int sensor, List<double> data, int accuracy);

class _SensorChannel {
  /// Method channel of the plugin.
  static const MethodChannel _methodChannel =
      const MethodChannel('flutter_sensors/utils');

  /// List of subscriptions to the update event channel.
  final Map<int, EventChannel> _eventChannels = {};

  /// List of subscriptions to the update event channel.
  final Map<int, Stream<SensorEvent>> _sensorStreams = {};

  /// Register a sensor update request.
  Stream<SensorEvent> sensorUpdates({int sensorId, Duration interval}){
    Stream<SensorEvent> sensorStream = _getSensorStream(sensorId);
    if (sensorStream == null) {
      final args = {"interval":_transformDelayDurationToInt(interval)};
      sensorStream =
          _getEventChannel(sensorId).receiveBroadcastStream(args).map((event) {
        return SensorEvent.fromMap(event);
      });
      _sensorStreams.putIfAbsent(sensorId, () => sensorStream);
    }else{
      updateSensorInterval(sensorId: sensorId, interval: interval);
    }
    return sensorStream;
  }

  /// Check if the sensor is available in the device.
  Future<bool> isSensorAvailable(int sensorId) async {
    final bool isAvailable = await _methodChannel.invokeMethod(
      'is_sensor_available',
      {"sensorId": sensorId},
    );
    return isAvailable;
  }

  /// Updates the interval between updates for an specific sensor.
  Future updateSensorInterval({int sensorId, Duration interval}) async {
    return _methodChannel.invokeMethod(
      'update_sensor_interval',
      {"sensorId": sensorId, "interval": _transformDelayDurationToInt(interval)},
    );
  }

  /// Return the stream associated with the given sensor.
  Stream<SensorEvent> _getSensorStream(int sensorId) {
    return _sensorStreams[sensorId];
  }

  /// Return the stream associated with the given sensor.
  EventChannel _getEventChannel(int sensorId) {
    EventChannel eventChannel = _eventChannels[sensorId];
    if (eventChannel == null) {
      eventChannel = EventChannel("flutter_sensors/$sensorId");
      _eventChannels.putIfAbsent(sensorId, () => eventChannel);
    }
    return eventChannel;
  }

  /// Transform the delay duration object to an int value for each platform.
  int _transformDelayDurationToInt(Duration delay) {
    return Platform.isAndroid
        ? delay.inMicroseconds
        : delay.inMicroseconds / 1000000;
  }
}

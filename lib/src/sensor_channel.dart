part of flutter_sensors;

typedef SensorCallback(int sensor, List<double> data, int accuracy);

class _SensorChannel {
  /// Method channel of the plugin.
  static const MethodChannel _methodChannel =
      const MethodChannel('flutter_sensors');

  /// List of subscriptions to the update event channel.
  final Map<int, EventChannel> _eventChannels = {};

  /// List of subscriptions to the update event channel.
  final Map<int, Stream<SensorEvent>> _sensorStreams = {};

  /// Register a sensor update request.
  Future<Stream<SensorEvent>> sensorUpdates(
      {required int sensorId, Duration? interval}) async {
    Stream<SensorEvent>? sensorStream = _getSensorStream(sensorId);
    interval = interval ?? Sensors.SENSOR_DELAY_NORMAL;
    if (sensorStream == null) {
      final args = {"interval": _transformDurationToNumber(interval)};
      final eventChannel =
          await _getEventChannel(sensorId: sensorId, arguments: args);
      sensorStream = eventChannel.receiveBroadcastStream().map((event) {
        return SensorEvent.fromMap(event);
      });
      _sensorStreams.putIfAbsent(sensorId, () => sensorStream!);
    } else {
      await updateSensorInterval(sensorId: sensorId, interval: interval);
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
  Future updateSensorInterval(
      {required int sensorId, Duration? interval}) async {
    return _methodChannel.invokeMethod(
      'update_sensor_interval',
      {"sensorId": sensorId, "interval": _transformDurationToNumber(interval)},
    );
  }

  /// Return the stream associated with the given sensor.
  Stream<SensorEvent>? _getSensorStream(int sensorId) {
    return _sensorStreams[sensorId];
  }

  /// Return the stream associated with the given sensor.
  Future<EventChannel> _getEventChannel(
      {required int sensorId, Map arguments = const {}}) async {
    EventChannel? eventChannel = _eventChannels[sensorId];
    if (eventChannel == null) {
      arguments["sensorId"] = sensorId;
      await _methodChannel.invokeMethod("start_event_channel", arguments);
      eventChannel = EventChannel("flutter_sensors/$sensorId");
      _eventChannels.putIfAbsent(sensorId, () => eventChannel!);
    }
    return eventChannel;
  }

  /// Transform the delay duration object to an int value for each platform.
  num? _transformDurationToNumber(Duration? delay) {
    return Platform.isAndroid ? delay?.inMicroseconds : delay?.inSeconds;
  }
}

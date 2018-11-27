part of flutter_sensors;

typedef SensorCallback(int sensor, List<double> data, int accuracy);

class SensorManager {
  static const MethodChannel _methodChannel =
      const MethodChannel('flutter_sensors');
  static final EventChannel _eventChannel =
      const EventChannel('flutter_sensors_update_channel');
  Map<int, SensorCallback> _sensorCallbackMap = Map();
  StreamSubscription<dynamic> _updateStream;

  SensorManager() {
    _init();
  }

  void _init() {
    _updateStream = _eventChannel.receiveBroadcastStream().listen((resultMap) {
      int sensor = resultMap["sensor"];
      if (_sensorCallbackMap.containsKey(sensor)) {
        int accuracy = resultMap["accuracy"];
        SensorCallback sensorCallback = _sensorCallbackMap[sensor];
        List<double> data = [];
        List<dynamic> resultData = resultMap["data"];
        resultData.forEach((value) {
          data.add(value);
        });
        sensorCallback(sensor, data, accuracy);
      }
    });
  }

  /// Removes all the registered listeners and also cancel the subscription
  /// to the event channel to avoid memory leaks.
  /// Use this function when you are done using this plugin.
  /// This instance is unusable after calling this method.
  void dispose() {
    unregisterAllListeners();
    _updateStream.cancel();
    _updateStream = null;
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
      final bool registered = await _methodChannel.invokeMethod(
        "register_sensor_listener",
        data,
      );
      if (registered) _sensorCallbackMap[sensor] = sensorCallback;
    }
  }

  void unregisterSensorListener(int sensor) async {
    if (_sensorCallbackMap.containsKey(sensor)) {
      final bool unregistered = await _methodChannel.invokeMethod(
        "unregister_sensor_listener",
        {"sensor": sensor},
      );
      if (unregistered) _sensorCallbackMap.remove(sensor);
    }
  }

  void unregisterAllListeners() {
    if (_sensorCallbackMap.isNotEmpty) {
      _methodChannel.invokeMethod("unregister_all_listeners");
      _sensorCallbackMap.clear();
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

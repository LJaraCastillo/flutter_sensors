part of flutter_sensors;

typedef SensorCallback(int sensor, List<double> data, int accuracy);

class _SensorChannel {
  static const MethodChannel _methodChannel =
      const MethodChannel('flutter_sensors');
  static const EventChannel _eventChannel =
      const EventChannel('flutter_sensors_update_channel');
  final Stream<SensorEvent> _updatesStream =
      _eventChannel.receiveBroadcastStream().map((data) {
    return SensorEvent.fromMap(data);
  });
  final List<StreamSubscription> _updatesSubscriptions = [];

  Stream<SensorEvent> sensorUpdates(SensorRequest request) {
    StreamController<SensorEvent> controller;
    request.refreshDelay = request.refreshDelay != null
        ? request.refreshDelay
        : Sensors.SENSOR_DELAY_NORMAL;
    final StreamSubscription<SensorEvent> updatesSubscription =
        _updatesStream.listen((SensorEvent result) {
      if (result.sensor == request.sensor) {
        controller.add(result);
      }
    });
    updatesSubscription.onDone(() {
      _updatesSubscriptions.remove(updatesSubscription);
    });
    _updatesSubscriptions.add(updatesSubscription);
    controller = StreamController<SensorEvent>.broadcast(
      onListen: () {
        _methodChannel.invokeMethod(
            "register_sensor_listener", request.toMap());
      },
      onCancel: () {
        updatesSubscription.cancel();
        _updatesSubscriptions.remove(updatesSubscription);
        _methodChannel.invokeMethod(
          "unregister_sensor_listener",
          {"sensor": request.sensor},
        );
      },
    );
    return controller.stream;
  }

  Stream<SensorEvent> sensorsUpdates(List<SensorRequest> requests) {
    StreamController<SensorEvent> controller;
    // If the delay is null we set it as normal.
    requests.forEach((request) => request.refreshDelay =
        request.refreshDelay != null
            ? request.refreshDelay
            : Sensors.SENSOR_DELAY_NORMAL);
    final StreamSubscription<SensorEvent> updatesSubscription =
        _updatesStream.listen((SensorEvent result) {
      bool valid = requests
          .where((request) => request.sensor == result.sensor)
          .isNotEmpty;
      if (valid) {
        controller.add(result);
      }
    });
    updatesSubscription.onDone(() {
      _updatesSubscriptions.remove(updatesSubscription);
    });
    _updatesSubscriptions.add(updatesSubscription);
    controller = StreamController<SensorEvent>.broadcast(
      onListen: () {
        requests.forEach((request) => _methodChannel.invokeMethod(
            "register_sensor_listener", request.toMap()));
      },
      onCancel: () {
        updatesSubscription.cancel();
        _updatesSubscriptions.remove(updatesSubscription);
        requests.forEach((request) => _methodChannel.invokeMethod(
            "unregister_sensor_listener", {"sensor": request.sensor}));
      },
    );
    return controller.stream;
  }

  static Future<bool> isSensorAvailable(int sensor) async {
    final bool isAvailable = await _methodChannel.invokeMethod(
      'is_sensor_available',
      {"sensor": sensor},
    );
    return isAvailable;
  }
}

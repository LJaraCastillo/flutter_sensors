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
  final List<_SensorUpdateSubscription> _updatesSubscriptions = [];

  Stream<SensorEvent> sensorUpdates(SensorRequest request) {
    StreamController<SensorEvent> controller;
    _SensorUpdateSubscription sensorUpdateSubscription;
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
      _updatesSubscriptions.remove(sensorUpdateSubscription);
    });
    sensorUpdateSubscription = _SensorUpdateSubscription(
      updatesSubscription,
    );
    _updatesSubscriptions.add(sensorUpdateSubscription);
    controller = new StreamController<SensorEvent>.broadcast(
      onListen: () {
        _methodChannel.invokeMethod(
            "register_sensor_listener", request.toMap());
      },
      onCancel: () {
        sensorUpdateSubscription.subscription.cancel();
        _updatesSubscriptions.remove(sensorUpdateSubscription);
        _methodChannel.invokeMethod(
          "unregister_sensor_listener",
          {"sensor": request.sensor},
        );
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

class _SensorUpdateSubscription {
  _SensorUpdateSubscription(this.subscription);

  final StreamSubscription<SensorEvent> subscription;
}

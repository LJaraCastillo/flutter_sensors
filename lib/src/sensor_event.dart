part of flutter_sensors;

/// Class that represents an sensor update event.
class SensorEvent {
  /// Id of the sensor updating.
  int sensorId;

  /// List of data.
  List<double> data;

  /// Accuracy of the reading.
  int accuracy;

  /// Constructor.
  SensorEvent._({
    required this.sensorId,
    required this.data,
    required this.accuracy,
  });

  /// Construct an object from a map.
  factory SensorEvent.fromMap(Map map) {
    final data = <double>[];
    final resultData = map["data"] as List<dynamic>;
    resultData.forEach((value) {
      data.add(value);
    });
    return SensorEvent._(
      sensorId: map["sensorId"],
      accuracy: map["accuracy"],
      data: data,
    );
  }
}

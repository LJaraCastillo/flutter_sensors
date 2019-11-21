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
  SensorEvent(this.sensorId, this.data, this.accuracy);

  /// Construct an object from a map.
  SensorEvent.fromMap(Map map) {
    this.sensorId = map["sensorId"];
    this.accuracy = map["accuracy"];
    List<double> data = [];
    List<dynamic> resultData = map["data"];
    resultData.forEach((value) {
      data.add(value);
    });
    this.data = data;
  }
}

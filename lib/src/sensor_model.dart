part of flutter_sensors;

class SensorRequest {
  /// Id of the sensor.
  int sensor;

  /// Refresh delay for the updates.
  Duration refreshDelay;

  /// Constructor.
  SensorRequest(this.sensor, {this.refreshDelay = Sensors.SENSOR_DELAY_NORMAL});

  /// Return a map representation of the object.
  Map<String, dynamic> toMap() => {
        "sensor": this.sensor,
        "delay": Platform.isAndroid
            ? this.refreshDelay.inMicroseconds
            : this.refreshDelay.inMicroseconds / 1000000
      };
}

/// Class that represents an sensor update event.
class SensorEvent {
  /// Id of the sensor updating.
  int sensor;

  /// List of data.
  List<double> data;

  /// Accuracy of the reading.
  int accuracy;

  /// Constructor.
  SensorEvent(this.sensor, this.data, this.accuracy);

  /// Construct an object from a map.
  SensorEvent.fromMap(Map map) {
    this.sensor = map["sensor"];
    this.accuracy = map["accuracy"];
    List<double> data = [];
    List<dynamic> resultData = map["data"];
    resultData.forEach((value) {
      data.add(value);
    });
    this.data = data;
  }
}

part of flutter_sensors;

class SensorRequest {
  int sensor;
  Duration refreshDelay;

  SensorRequest(this.sensor, {this.refreshDelay = Sensors.SENSOR_DELAY_NORMAL});

  Map<String, dynamic> toMap() => {
        "sensor": this.sensor,
        "delay": Platform.isAndroid
            ? this.refreshDelay.inMicroseconds
            : this.refreshDelay.inMicroseconds / 1000000
      };
}

class SensorEvent {
  int sensor;
  List<double> data;
  int accuracy;

  SensorEvent(this.sensor, this.data, this.accuracy);

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

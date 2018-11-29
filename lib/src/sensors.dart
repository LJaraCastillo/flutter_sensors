part of flutter_sensors;

class Sensors {
  // Sensor types
  static const int ACCELEROMETER = 1;
  static const int GYROSCOPE = 4;
  static const int MAGNETIC_FIELD = 2;
  static const int LINEAR_ACCELERATION = 10;
  static const int STEP_DETECTOR = 18;

  // Sensor delay
  static const Duration SENSOR_DELAY_NORMAL = Duration(microseconds: 200000);
  static const Duration SENSOR_DELAY_UI = Duration(microseconds: 60000);
  static const Duration SENSOR_DELAY_GAME = Duration(microseconds: 20000);
  static const Duration SENSOR_DELAY_FASTEST = Duration(microseconds: 0);

  // Sensor accuracy
  /// This sensor is reporting data with maximum accuracy.
  ///
  /// iOS does not have this kind of value so every event report [SENSOR_STATUS_ACCURACY_HIGH] of accuracy.
  static const int SENSOR_STATUS_ACCURACY_HIGH = 3;

  /// This sensor is reporting data with an average level of accuracy, calibration with the environment may improve the readings.
  ///
  /// iOS does not have this kind of value so every event report [SENSOR_STATUS_ACCURACY_HIGH] of accuracy.
  static const int SENSOR_STATUS_ACCURACY_MEDIUM = 2;

  /// This sensor is reporting data with low accuracy, calibration with the environment is needed.
  ///
  /// iOS does not have this kind of value so every event report [SENSOR_STATUS_ACCURACY_HIGH] of accuracy.
  static const int SENSOR_STATUS_ACCURACY_LOW = 1;
}

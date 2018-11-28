part of flutter_sensors;

class Sensors {
  // Sensor types
  static const int ACCELEROMETER = 1;
  static const int GYROSCOPE = 4;
  static const int MAGNETIC_FIELD = 2;
  static const int LINEAR_ACCELERATION = 10;
  static const int STEP_COUNTER = 19;

  // Sensor delay
  static const Duration SENSOR_DELAY_NORMAL = Duration(microseconds: 200000);
  static const Duration SENSOR_DELAY_UI = Duration(microseconds: 60000);
  static const Duration SENSOR_DELAY_GAME = Duration(microseconds: 20000);
  static const Duration SENSOR_DELAY_FASTEST = Duration(microseconds: 0);
}

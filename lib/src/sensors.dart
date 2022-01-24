part of flutter_sensors;

class Sensors {
  /// Accelerometer sensor.
  /// Sensor that measures the acceleration applied to the device, including the
  /// force of gravity. This sensor returns a 3 axis (x, y & z) list of values.
  /// Consider that the values in Android are (m/s^2) meanwhile iOS uses
  /// G's (Gravitational force).
  ///
  /// Android documentation:
  ///
  /// https://developer.android.com/guide/topics/sensors/sensors_motion#sensors-motion-accel
  ///
  /// iOS documentation:
  ///
  /// https://developer.apple.com/documentation/coremotion/cmacceleration
  static const int ACCELEROMETER = 1;

  /// Gyroscope sensor.
  /// Measures the rotation rate of the device. This sensor returns a 3 axis
  /// (x, y & z) list of values. Both Android and iOS returns this values in
  /// radians/second.
  ///
  /// Android documentation:
  ///
  /// https://developer.android.com/guide/topics/sensors/sensors_motion#sensors-motion-gyro
  ///
  /// iOS documentation:
  ///
  /// https://developer.apple.com/documentation/coremotion/getting_raw_gyroscope_events
  static const int GYROSCOPE = 4;

  /// Geomagnetic field sensor.
  /// Monitors changes in the earth's magnetic field. This sensor returns a 3
  /// axis (x, y & z) list of values. Both Android and iOS returns this values
  /// in μT (microtesla).
  ///
  /// Android documentation:
  ///
  /// https://developer.android.com/guide/topics/sensors/sensors_position#sensors-pos-mag
  ///
  /// iOS documentation:
  ///
  /// https://developer.apple.com/documentation/coremotion/cmdevicemotion/1616140-magneticfield
  static const int MAGNETIC_FIELD = 2;

  /// Linear accelerometer.
  /// The linear acceleration is the acceleration of the device minus the
  /// gravity. This sensor returns a 3 axis (x, y & z) list of values.
  /// Consider that the values in Android are (m/s^2) meanwhile iOS uses
  /// G's (Gravitational force).
  ///
  /// Android documentation:
  ///
  /// https://developer.android.com/guide/topics/sensors/sensors_motion#sensors-motion-linear
  ///
  /// iOS documentation:
  ///
  /// https://developer.apple.com/documentation/coremotion/cmdevicemotion/1616149-useracceleration
  static const int LINEAR_ACCELERATION = 10;

  /// Step detector sensor.
  /// Triggers an event each time the user takes a step. In iOS this plugin
  /// returns the step event and not the count of steps.
  ///
  /// Android documentation:
  ///
  /// https://developer.android.com/guide/topics/sensors/sensors_motion#sensors-motion-stepdetector
  ///
  /// iOS documentation:
  ///
  /// https://developer.apple.com/documentation/coremotion/cmpedometer
  static const int STEP_DETECTOR = 18;

  /// Rotation sensor.
  /// Represent the orientation of the device.
  /// Android: Returns a list of 3 values for each axis (x, y & z). The rotation
  /// matrix an azimuth must be computed manually given that this sensor only
  /// gives the raw values.
  /// iOS: Returns a list but with only one value (index 0) with the azimuth
  /// computed by the system.
  ///
  /// Android documentation:
  ///
  /// https://developer.android.com/guide/topics/sensors/sensors_motion#sensors-motion-rotate
  ///
  /// iOS documentation:
  ///
  /// https://developer.apple.com/documentation/corelocation/clheading
  static const int ROTATION = 11;

  /// Delay of 200000 microseconds between readings.
  /// Rate suitable for screen orientation changes.
  static const Duration SENSOR_DELAY_NORMAL = Duration(microseconds: 200000);

  /// Delay of 60000 microseconds between readings.
  /// Rate suitable for UI related work.
  static const Duration SENSOR_DELAY_UI = Duration(microseconds: 60000);

  /// Delay of 20000 microseconds between readings.
  /// Rate suitable for games.
  static const Duration SENSOR_DELAY_GAME = Duration(microseconds: 20000);

  /// Gets sensor data as fast as possible.
  static const Duration SENSOR_DELAY_FASTEST = Duration(microseconds: 0);

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

# flutter_sensors

Simple sensor event listener plugin for flutter(Android & iOS). iOS 8.0+ is needed.

## Installation

First add the plugin in your project. Copy the following line below dependencies in your **pubspec.yaml** file.

```yaml
dependencies:
     ...
    flutter_sensors: ^0.0.1
```

Then you need to import the dependency.

```dart
import 'package:flutter_sensors/flutter_sensors.dart';
```

### iOS only

You need to add the following key-value pair into your **Info.plist** file inside the **ios/Runner** folder in your project.

```plist
<key>NSMotionUsageDescription</key>
<string>A reason to get the permission</string>
```

## How to use

First initialize an instance of *SensorManager* class.

```dart
class _MyAppState extends State<MyApp> {
  SensorManager _sensorManager = SensorManager();
  ...
```

Then you can register a new listener for an specific sensor.

```dart
_sensorManager.registerSensorListener(
        Sensors.ACCELEROMETER,
        (sensor, data, accuracy) {
            //do stuff here
        },
        refreshRate: Duration(
          milliseconds: 250,
        ),
      );
```

Also, you can check if an specific sensor is available.

```dart
bool accelerometerAvailable =
        await SensorManager.isSensorAvailable(Sensors.ACCELEROMETER);
```

If you want to remove a listener.

```dart
_sensorManager.unregisterSensorListener(Sensors.ACCELEROMETER);
```

or to remove them all.

```dart
_sensorManager.unregisterAllListeners();
```

**Important:** To avoid memory leaks, you must discard the instance so that the platform code removes registered listeners and stops sending updates to the dart layer.

```dart
@override
void dispose() {
    _sensorManager.dispose();
    super.dispose();
}
```

### Android Only

You can give the ID of a sensor without using the **Sensors** class. Example: registering a listener for the **TYPE_LIGHT** sensor.

```dart
int TYPE_LIGHT = 5; // TYPE_LIGHT is equals to 5
// Check if is available.
bool isAvailable = SensorManager.isSensorAvailable(TYPE_LIGHT);
// Registering a listener.
_sensorManager.registerSensorListener(
        TYPE_LIGHT, // TYPE_LIGHT is equals to 5
        (sensor, data, accuracy) {
            // do stuff here
        },
        refreshRate: Duration(
          milliseconds: 250,
        ),
      );
 // Removing the listener.
_sensorManager.unregisterSensorListener(TYPE_LIGHT);
```

You can get the rest of the IDs from [here](https://developer.android.com/reference/android/hardware/Sensor#TYPE_LIGHT).
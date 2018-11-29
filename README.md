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

You register a new listener for an specific sensor.

```dart
_accelSubscription = SensorManager.sensorUpdates(SensorRequest(
        Sensors.ACCELEROMETER, // Desired sensor
        refreshDelay: Sensors.SENSOR_DELAY_GAME, // Refresh delay
      )).listen((sensorEvent) {
        setState(() {
          _accelData = sensorEvent.data;
        });
      });
```

Also, you can check if an specific sensor is available.

```dart
bool accelerometerAvailable =
        await SensorManager.isSensorAvailable(Sensors.ACCELEROMETER);
```

Remember to cancel your **StreamSubscriptions** after you are done with the sensor updates.

```dart
_accelSubscription.cancel();
```

### Android Only

You can give the ID of a sensor without using the **Sensors** class. Example: registering a listener for the **TYPE_LIGHT** sensor.

```dart
int TYPE_LIGHT = 5; // TYPE_LIGHT is equals to 5
// Checking if is available.
bool isAvailable = SensorManager.isSensorAvailable(TYPE_LIGHT);
// Initialize a stream to receive the updates.
_lightSubscription =
          SensorManager.sensorUpdates(SensorRequest(TYPE_LIGHT))
              .listen((sensorEvent) {
        setState(() {
          _lightData = sensorEvent.data;
        });
      });
 // Cancel the stream after using it.
_lightSubscription.cancel();
```

You can get the rest of the IDs from [here](https://developer.android.com/reference/android/hardware/Sensor#TYPE_LIGHT).
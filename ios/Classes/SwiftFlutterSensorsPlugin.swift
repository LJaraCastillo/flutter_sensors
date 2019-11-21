import Flutter
import UIKit
import CoreMotion
import CoreLocation

public class SwiftFlutterSensorsPlugin: NSObject, FlutterPlugin {
    public let accelerometerStreamHandler = AccelerometerStreamHandler()
    public let gyroscopeStreamHandler = GyroscopeStreamHandler()
    public let headingStreamHandler = HeadingStreamHandler()
    public let linearAccelerationStreamHandler = LinearAccelerationStreamHandler()
    public let magneticFieldStreamHandler = MagneticFieldStreamHandler()
    public let stepDetectorStreamHandler = StepDetectorStreamHandler()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftFlutterSensorsPlugin()
        let channel = FlutterMethodChannel(name: "flutter_sensors/utils", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        let accelerometerEventChannel = FlutterEventChannel(name:"flutter_sensors/\(AccelerometerStreamHandler.SENSOR_ID)", binaryMessenger: registrar.messenger())
        accelerometerEventChannel.setStreamHandler(instance.accelerometerStreamHandler)
        let gyroscopeEventChannel = FlutterEventChannel(name:"flutter_sensors/\(GyroscopeStreamHandler.SENSOR_ID)", binaryMessenger: registrar.messenger())
        gyroscopeEventChannel.setStreamHandler(instance.gyroscopeStreamHandler)
        let headingEventChannel = FlutterEventChannel(name:"flutter_sensors/\(HeadingStreamHandler.SENSOR_ID)", binaryMessenger: registrar.messenger())
        headingEventChannel.setStreamHandler(instance.headingStreamHandler)
        let linearAccelerationEventChannel = FlutterEventChannel(name:"flutter_sensors/\(LinearAccelerationStreamHandler.SENSOR_ID)", binaryMessenger: registrar.messenger())
        linearAccelerationEventChannel.setStreamHandler(instance.linearAccelerationStreamHandler)
        let magneticFieldEventChannel = FlutterEventChannel(name:"flutter_sensors/\(MagneticFieldStreamHandler.SENSOR_ID)", binaryMessenger: registrar.messenger())
        magneticFieldEventChannel.setStreamHandler(instance.magneticFieldStreamHandler)
        let stepDetectorEventChannel = FlutterEventChannel(name:"flutter_sensors/\(StepDetectorStreamHandler.SENSOR_ID)", binaryMessenger: registrar.messenger())
        stepDetectorEventChannel.setStreamHandler(instance.stepDetectorStreamHandler)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "is_sensor_available":
            let dataMap = call.arguments as! NSDictionary
            let sensorId = dataMap["sensorId"] as! Int
            let isAvailable = isSensorAvailable(sensorId: sensorId)
            result(isAvailable)
            break
        case "update_sensor_interval":
            let dataMap = call.arguments as! NSDictionary
            let sensorId = dataMap["sensorId"] as? Int
            let interval = dataMap["interval"] as? Int
            if sensorId != nil && interval != nil {
                updateSensorInterval(sensorId: sensorId!, interval: interval!)
            }
            result(nil)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public static func notify(sensorId:Int, sensorData:[Double], eventSink:FlutterEventSink){
        let data = [
            "sensorId": sensorId,
            "data": sensorData,
            "accuracy": 3 //iOS does not send this value so we will match it to the value of high accuracy of Android which is 3
            ] as [String : Any]
        eventSink(data)
    }
    
    private func isSensorAvailable(sensorId: Int)->Bool{
        var isAvailable = false
        switch sensorId {
        case AccelerometerStreamHandler.SENSOR_ID:
            isAvailable = accelerometerStreamHandler.isAvailable()
            break
        case GyroscopeStreamHandler.SENSOR_ID:
            isAvailable = gyroscopeStreamHandler.isAvailable()
            break
        case MagneticFieldStreamHandler.SENSOR_ID:
            isAvailable = magneticFieldStreamHandler.isAvailable()
            break
        case LinearAccelerationStreamHandler.SENSOR_ID:
            isAvailable = linearAccelerationStreamHandler.isAvailable()
            break
        case StepDetectorStreamHandler.SENSOR_ID:
            isAvailable = stepDetectorStreamHandler.isAvailable()
            break
        case HeadingStreamHandler.SENSOR_ID:
            isAvailable = headingStreamHandler.isAvailable()
            break
        default:
            isAvailable = false
            break
        }
        return isAvailable
    }
    
    private func updateSensorInterval(sensorId: Int, interval: Int){
        switch sensorId {
        case AccelerometerStreamHandler.SENSOR_ID:
            accelerometerStreamHandler.setInterval(interval: interval)
            break
        case GyroscopeStreamHandler.SENSOR_ID:
            gyroscopeStreamHandler.setInterval(interval: interval)
            break
        case MagneticFieldStreamHandler.SENSOR_ID:
            magneticFieldStreamHandler.setInterval(interval: interval)
            break
        case LinearAccelerationStreamHandler.SENSOR_ID:
            linearAccelerationStreamHandler.setInterval(interval: interval)
            break
        default:
            break
        }
    }
}

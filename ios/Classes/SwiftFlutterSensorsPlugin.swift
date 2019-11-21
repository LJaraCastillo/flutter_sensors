import Flutter
import UIKit
import CoreMotion
import CoreLocation

public class SwiftFlutterSensorsPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, CLLocationManagerDelegate {
    private let ACCELEROMETER_ID:Int = 1
    private let GYROSCOPE_ID:Int = 4
    private let MAGNETIC_FIELD_ID:Int = 2
    private let LINEAR_ACCELERATION_ID:Int = 10
    private let STEP_DETECTOR_ID:Int = 18
    private let HEADING_ID:Int = 11
    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    private let locationManager = CLLocationManager()
    private var sinks: [FlutterEventSink] = []
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftFlutterSensorsPlugin()
        let channel = FlutterMethodChannel(name: "flutter_sensors", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name:"flutter_sensors_update_channel", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "is_sensor_available":
            let dataMap = call.arguments as! NSDictionary
            let sensorType = dataMap["sensor"] as! Int
            let isAvailable = isSensorAvailable(sensorType: sensorType)
            result(isAvailable)
            break
        case "register_sensor_listener":
            let dataMap = call.arguments as! NSDictionary
            let sensorType  = dataMap["sensor"] as! Int
            let rate = dataMap["delay"] as! Double
            let registered = registerSensorListener(sensorType: sensorType, updateInterval: rate)
            result(registered)
            break
        case "unregister_sensor_listener":
            let dataMap = call.arguments as! NSDictionary
            let sensorType  = dataMap["sensor"] as! Int
            let unregistered = unregisterSensorListener(sensorType: sensorType)
            result(unregistered)
            break
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sinks.append(events)
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sinks.removeAll()
        return nil
    }
    
    private func notify(sensorType:Int, sensorData:[Double]){
        let data = [
            "sensor": sensorType,
            "data": sensorData,
            "accuracy": 3 //iOS does not send this value so we will match it to the value of high accuracy of Android which is 3
            ] as [String : Any]
        for it in sinks{
            it(data)
        }
    }
    
    private func isSensorAvailable(sensorType:Int)->Bool{
        var isAvailable = false
        switch sensorType {
        case ACCELEROMETER_ID:
            isAvailable = motionManager.isAccelerometerAvailable
            break
        case GYROSCOPE_ID:
            isAvailable = motionManager.isGyroAvailable
            break
        case MAGNETIC_FIELD_ID:
            isAvailable = motionManager.isMagnetometerAvailable
            break
        case LINEAR_ACCELERATION_ID:
            isAvailable = motionManager.isDeviceMotionAvailable
            break
        case STEP_DETECTOR_ID:
            isAvailable = CMPedometer.isStepCountingAvailable()
            break
        case HEADING_ID:
            isAvailable = CLLocationManager.headingAvailable()
            break
        default:
            isAvailable = false
            break
        }
        return isAvailable
    }
    
    private func registerSensorListener(sensorType:Int, updateInterval:Double)->Bool{
        var registered = false
        if(self.isSensorAvailable(sensorType: sensorType)){
            switch sensorType {
            case ACCELEROMETER_ID:
                motionManager.accelerometerUpdateInterval = TimeInterval(updateInterval)
                motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {data, error in
                    guard error == nil else { return }
                    guard let accelerometerData = data else { return }
                    let values = accelerometerData.acceleration
                    let dataArray = [
                        values.x,
                        values.y,
                        values.z
                    ]
                    self.notify(sensorType: self.ACCELEROMETER_ID, sensorData: dataArray)
                })
                registered = true
                break
            case GYROSCOPE_ID:
                motionManager.gyroUpdateInterval = TimeInterval(updateInterval)
                motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler:{data, error in
                    guard error == nil else { return }
                    guard let gyroData = data else { return }
                    let dataArray = [
                        gyroData.rotationRate.x,
                        gyroData.rotationRate.y,
                        gyroData.rotationRate.z
                    ]
                    self.notify(sensorType: self.GYROSCOPE_ID, sensorData: dataArray)
                })
                registered = true
                break
            case MAGNETIC_FIELD_ID:
                motionManager.deviceMotionUpdateInterval = TimeInterval(updateInterval)
                motionManager.showsDeviceMovementDisplay = true
                motionManager.startDeviceMotionUpdates(using:CMAttitudeReferenceFrame.xMagneticNorthZVertical, to: OperationQueue.current!, withHandler:{data, error in
                    guard error == nil else { return }
                    guard let deviceMotion = data else { return }
                    let dataArray = [
                        deviceMotion.magneticField.field.x,
                        deviceMotion.magneticField.field.y,
                        deviceMotion.magneticField.field.z
                    ]
                    self.notify(sensorType: self.MAGNETIC_FIELD_ID, sensorData: dataArray)
                })
                registered = true
                break
            case LINEAR_ACCELERATION_ID:
                motionManager.deviceMotionUpdateInterval = TimeInterval(updateInterval)
                motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {data, error in
                    guard error == nil else { return }
                    guard let deviceMotionData = data else { return }
                    let values = deviceMotionData.userAcceleration
                    let dataArray = [
                        values.x,
                        values.y,
                        values.z
                    ]
                    self.notify(sensorType: self.LINEAR_ACCELERATION_ID, sensorData: dataArray)
                })
                registered = true
                break
            case STEP_DETECTOR_ID:
                // The updates of this one depends of the user and does not need an inverval.
                pedometer.startUpdates(from: Date(), withHandler: {data, error in
                    guard error == nil else { return }
                    let steps = [1.0]
                    self.notify(sensorType: self.STEP_DETECTOR_ID, sensorData: steps)
                })
                registered = true
                break
            case HEADING_ID:
                // The updates of this one depends of the user and does not need an inverval.
                locationManager.startUpdatingHeading()
                locationManager.delegate = self
                break
            default:
                registered = false
                break
            }
        }
        return registered
    }
    
    private func unregisterSensorListener(sensorType:Int)->Bool{
        var unregistered = false
        switch sensorType {
        case ACCELEROMETER_ID:
            motionManager.stopAccelerometerUpdates()
            unregistered = true
            break
        case GYROSCOPE_ID:
            motionManager.stopGyroUpdates()
            unregistered = true
            break
        case MAGNETIC_FIELD_ID:
            motionManager.stopMagnetometerUpdates()
            unregistered = true
            break
        case LINEAR_ACCELERATION_ID:
            motionManager.stopDeviceMotionUpdates()
            unregistered = true
            break
        case STEP_DETECTOR_ID:
            pedometer.stopUpdates()
            unregistered = true
            break
        case HEADING_ID:
            locationManager.delegate = nil
            locationManager.stopUpdatingHeading()
            unregistered = true
            break
        default:
            unregistered = false
            break
        }
        return unregistered
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let data = [newHeading.magneticHeading]
        self.notify(sensorType: self.HEADING_ID, sensorData: data)
    }
    
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}

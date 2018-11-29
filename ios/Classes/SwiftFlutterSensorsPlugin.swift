import Flutter
import UIKit
import CoreMotion

public class SwiftFlutterSensorsPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private let ACCELEROMETER_ID:Int = 1
    private let GYROSCOPE_ID:Int = 4
    private let MAGNETIC_FIELD_ID:Int = 1
    private let LINEAR_ACCELERATION_ID:Int = 10
    private let STEP_DETECTOR_ID:Int = 18
    private let motionManager=CMMotionManager()
    private let deviceMotion=CMDeviceMotion()
    private let pedometer=CMPedometer()
    private var sinks: [FlutterEventSink] = []
    private var notifyLinearAcceleration = false
    private var notifyAcceleration = false
    private var isAccelerometerActive = false
    
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
            var rate = dataMap["rate"] as! Int?
            if(rate == nil){
                rate = 1/60 // Default interval of 60hz
            }
            let registered = registerSensorListener(sensorType: sensorType, updateInterval: rate!)
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
            isAvailable = motionManager.isAccelerometerAvailable
            break
        case STEP_DETECTOR_ID:
            isAvailable = CMPedometer.isStepCountingAvailable()
            break
        default:
            isAvailable = false
            break
        }
        return isAvailable
    }
    
    private func registerSensorListener(sensorType:Int, updateInterval:Int)->Bool{
        var registered = false
        if(self.isSensorAvailable(sensorType: sensorType)){
            switch sensorType {
            case ACCELEROMETER_ID:
                self.notifyAcceleration = true
                self.startAccelerometerUpdates(updateInverval: updateInterval)
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
                motionManager.magnetometerUpdateInterval = TimeInterval(updateInterval)
                motionManager.startMagnetometerUpdates(to: OperationQueue.current!, withHandler:{data, error in
                    guard error == nil else { return }
                    guard let magnetometerData = data else { return }
                    let dataArray = [
                        magnetometerData.magneticField.x,
                        magnetometerData.magneticField.y,
                        magnetometerData.magneticField.z
                    ]
                    self.notify(sensorType: self.MAGNETIC_FIELD_ID, sensorData: dataArray)
                })
                registered = true
                break
            case LINEAR_ACCELERATION_ID:
                self.notifyLinearAcceleration = true
                self.startAccelerometerUpdates(updateInverval: updateInterval)
                registered = true
                break
            case STEP_DETECTOR_ID:
                // The updates of this one depends of the user and does not need an inverval.
                pedometer.startUpdates(from: Date(), withHandler: {data, error in
                    guard error == nil else { return }
                    guard let pedometerData = data else { return }
                    let steps = [1.0]
                    self.notify(sensorType: self.STEP_DETECTOR_ID, sensorData: steps)
                })
                registered = true
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
            self.notifyAcceleration = false
            if(!self.notifyLinearAcceleration){
                motionManager.stopAccelerometerUpdates()
                self.isAccelerometerActive = false
            }
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
            self.notifyLinearAcceleration = false
            if(!self.notifyAcceleration){
                motionManager.stopAccelerometerUpdates()
                self.isAccelerometerActive = false
            }
            unregistered = true
            break
        case STEP_DETECTOR_ID:
            pedometer.stopUpdates()
            unregistered = true
            break
        default:
            unregistered = false
            break
        }
        return unregistered
    }
    
    private func startAccelerometerUpdates(updateInverval:Int){
        if(!self.isAccelerometerActive){
            motionManager.accelerometerUpdateInterval = TimeInterval(updateInverval)
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:{data, error in
                guard error == nil else { return }
                guard let accelerometerData = data else { return }
                let dataArray = [
                    accelerometerData.acceleration.x,
                    accelerometerData.acceleration.y,
                    accelerometerData.acceleration.z
                ]
                if(self.notifyAcceleration){
                    self.notify(sensorType: self.ACCELEROMETER_ID, sensorData: dataArray)
                }
                if(self.notifyLinearAcceleration){
                    let gravity = self.deviceMotion.gravity
                    let linearAcc = [
                        accelerometerData.acceleration.x - gravity.x,
                        accelerometerData.acceleration.y - gravity.y,
                        accelerometerData.acceleration.z - gravity.z
                    ]
                    self.notify(sensorType: self.LINEAR_ACCELERATION_ID, sensorData: linearAcc)
                }
            })
            self.isAccelerometerActive = true
        }
    }
}

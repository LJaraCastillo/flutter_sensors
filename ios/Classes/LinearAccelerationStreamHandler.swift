//
//  AccelerometerStreamHandler.swift
//  flutter_sensors
//
//  Created by Luis Jara Castillo on 11/21/19.
//

import Foundation
import Flutter
import CoreMotion

public class LinearAccelerationStreamHandler : NSObject, FlutterStreamHandler {
    public static let SENSOR_ID = 10
    private var motionManager: CMMotionManager?
    private var interval: Double = 0

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        if isAvailable() {
            self.startUpdates(eventSink: eventSink)
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.stopUpdates()
        return nil
    }
    
    private func initMotionManager() {
        if motionManager == nil{
            motionManager = CMMotionManager()
        }
    }
    
    private func startUpdates(eventSink:@escaping FlutterEventSink){
        initMotionManager()
        updateInterval()
        self.motionManager?.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
            guard error == nil else { return }
            guard let deviceMotion = data else { return }
            let values = deviceMotion.userAcceleration
            let dataArray = [
                values.x,
                values.y,
                values.z
            ]
            SwiftFlutterSensorsPlugin.notify(sensorId: LinearAccelerationStreamHandler.SENSOR_ID, sensorData: dataArray, timestamp: deviceMotion.timestamp * 1000, eventSink: eventSink)
        })
    }
    
    private func stopUpdates(){
        motionManager?.stopDeviceMotionUpdates()
        motionManager = nil
    }
    
    public func setInterval(interval: Double) {
        self.interval = interval
        self.updateInterval()
    }
    
    private func updateInterval(){
        motionManager?.deviceMotionUpdateInterval = TimeInterval(interval)
    }
    
    public func isAvailable() -> Bool {
        return CMMotionManager().isDeviceMotionAvailable
    }
}

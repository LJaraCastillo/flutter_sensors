//
//  AccelerometerStreamHandler.swift
//  flutter_sensors
//
//  Created by Luis Jara Castillo on 11/21/19.
//

import Foundation
import Flutter
import CoreMotion

public class GyroscopeStreamHandler : NSObject, FlutterStreamHandler {
    public static let SENSOR_ID = 4
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
    
    private func startUpdates(eventSink: @escaping FlutterEventSink){
        initMotionManager()
        updateInterval()
        self.motionManager?.startGyroUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
            guard error == nil else { return }
            guard let gyroscopeData = data else { return }
            let values = gyroscopeData.rotationRate
            let dataArray = [
                values.x,
                values.y,
                values.z
            ]
            SwiftFlutterSensorsPlugin.notify(sensorId: GyroscopeStreamHandler.SENSOR_ID, sensorData: dataArray, eventSink: eventSink)
        })
    }
    
    private func stopUpdates(){
        motionManager?.stopGyroUpdates()
        motionManager = nil
    }
    
    public func setInterval(interval: Double) {
        self.interval = interval
        self.updateInterval()
    }
    
    private func updateInterval(){
        motionManager?.gyroUpdateInterval = TimeInterval(interval)
    }
    
    public func isAvailable() -> Bool {
        return CMMotionManager().isGyroAvailable
    }
}

//
//  AccelerometerStreamHandler.swift
//  flutter_sensors
//
//  Created by Luis Jara Castillo on 11/21/19.
//

import Foundation
import Flutter
import CoreMotion

public class AccelerometerStreamHandler : NSObject, FlutterStreamHandler {
    public static let SENSOR_ID = 1
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
        self.motionManager?.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
            guard error == nil else { return }
            guard let accelerometerData = data else { return }
            let values = accelerometerData.acceleration
            let dataArray = [
                values.x,
                values.y,
                values.z
            ]
            SwiftFlutterSensorsPlugin.notify(sensorId: AccelerometerStreamHandler.SENSOR_ID, sensorData: dataArray, eventSink: eventSink)
        })
    }
    
    private func stopUpdates(){
        motionManager?.stopAccelerometerUpdates()
        motionManager = nil
    }
    
    public func setInterval(interval: Double) {
        self.interval = interval
        self.updateInterval()
    }
    
    private func updateInterval(){
        motionManager?.accelerometerUpdateInterval = TimeInterval(interval)
    }
    
    public func isAvailable() -> Bool {
        return CMMotionManager().isAccelerometerAvailable
    }
}

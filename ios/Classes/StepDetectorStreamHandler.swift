//
//  AccelerometerStreamHandler.swift
//  flutter_sensors
//
//  Created by Luis Jara Castillo on 11/21/19.
//

import Foundation
import Flutter
import CoreMotion

public class StepDetectorStreamHandler : NSObject, FlutterStreamHandler {
    public static let SENSOR_ID = 18
    private var pedometer: CMPedometer?
    
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        if isAvailable() {
            startUpdates(eventSink: eventSink)
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopUpdates()
        return nil
    }
    
    private func initPedometer() {
        if pedometer == nil{
            pedometer = CMPedometer()
        }
    }
    
    private func startUpdates(eventSink:@escaping FlutterEventSink){
        initPedometer()
        pedometer?.startUpdates(from: Date(), withHandler: {data, error in
            guard error == nil else { return }
            let steps = [1.0]
            SwiftFlutterSensorsPlugin.notify(sensorId: StepDetectorStreamHandler.SENSOR_ID, sensorData: steps, eventSink: eventSink)
        })
    }
    
    private func stopUpdates(){
        pedometer?.stopUpdates()
        pedometer = nil
    }
    
    public func isAvailable() -> Bool {
        return CMPedometer.isStepCountingAvailable()
    }
}

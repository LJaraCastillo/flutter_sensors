//
//  AccelerometerStreamHandler.swift
//  flutter_sensors
//
//  Created by Luis Jara Castillo on 11/21/19.
//

import Foundation
import Flutter
import CoreLocation

public class HeadingStreamHandler : NSObject, FlutterStreamHandler, CLLocationManagerDelegate {
    public static let SENSOR_ID = 11
    private var locationManager: CLLocationManager?
    private var eventSink: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        if isAvailable() {
            startUpdates(arguments: arguments, eventSink: eventSink)
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopUpdates()
        return nil
    }
    
    private func initPedometer() {
        if locationManager == nil{
            locationManager = CLLocationManager()
        }
    }
    
    private func startUpdates(arguments: Any?, eventSink:@escaping FlutterEventSink){
        initPedometer()
        self.eventSink = eventSink
        locationManager?.startUpdatingHeading()
        locationManager?.delegate = self
    }
    
    private func stopUpdates(){
        locationManager?.stopUpdatingHeading()
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let data = [newHeading.magneticHeading]
        SwiftFlutterSensorsPlugin.notify(sensorId: HeadingStreamHandler.SENSOR_ID, sensorData: data, eventSink: self.eventSink!)
    }
    
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
       return true
    }
    
    public func isAvailable() -> Bool {
        return CLLocationManager.headingAvailable()
    }
}

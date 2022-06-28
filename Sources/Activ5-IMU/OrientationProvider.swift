//
//  File.swift
//  Activ5-IMU
//
//  Created by Martin Kuvandzhiev on 7.08.19.
//

import Foundation
import Activ5Device
import MetalPerformanceShaders
import Hamilton


public class OrientationProvider {
    let defaultTareTime = 1.0
    let kalmanFilter: KalmanFilter?
    public var isTaring = false
    
    var xRotationTareValues: [Double] = [0.0]
    var yRotationTareValues: [Double] = [0.0]
    var zRotationTareValues: [Double] = [0.0]
    
    var xRotationOffset = 0.0
    var yRotationOffset = 0.0
    var zRotationOffset = 0.0
    
    
    public var processNoiseScalar: Double {
        set {
            kalmanFilter?.processNoise = simd_mul(newValue, simd_double3x3(1.0))
        }
        get {
            return kalmanFilter?.processNoise[0][0] ?? 0.0
        }
    }
    
    public var measurementNoiseScalar: Double {
        set {
            kalmanFilter?.measurementNoise = simd_mul(newValue, simd_double3x3(1.0))
        }
        get {
            return kalmanFilter?.measurementNoise[0][0] ?? 0.0
        }
    }
    
    public init() {
        self.kalmanFilter = KalmanFilter()
        self.xRotationTareValues = [0.0]
        self.yRotationTareValues = [0.0]
        self.zRotationTareValues = [0.0]
    }
    
    public init(kalmanFilter: KalmanFilter, xRotationTareValues: [Double], yRotationTareValues: [Double], zRotationTareValues: [Double]) {
        self.kalmanFilter = kalmanFilter
        self.xRotationTareValues = xRotationTareValues
        self.yRotationTareValues = xRotationTareValues
        self.zRotationTareValues = zRotationTareValues
    }

    public func resetOrientation() {
        kalmanFilter?.resetOrientation()
    }
    
    public var lastOrientation: Orientation {
        return Orientation(quanternion: kalmanFilter!.getQuaternion())
    }
    
    public func tare(duration: Double, completed: @escaping ()->()) {
        xRotationTareValues.removeAll()
        yRotationTareValues.removeAll()
        zRotationTareValues.removeAll()
        self.isTaring = true
        
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { (_) in
            self.isTaring = false
            self.updateRotationOffset()
            print("X Rotation Offset: " + String(format: "%0.2f", self.xRotationOffset))
            print("Y Rotation Offset: " + String(format: "%0.2f", self.yRotationOffset))
            print("Z Rotation Offset: " + String(format: "%0.2f", self.zRotationOffset))
            completed()
        }
    }
    
    public func updateRotationOffset() {
        xRotationOffset = xRotationTareValues.average
        yRotationOffset = yRotationTareValues.average
        zRotationOffset = zRotationTareValues.average
    }
    
    public func update(imuData: IMUObject) -> Orientation {
        let imuData = imuData.scaledValue
        
        if self.isTaring == true {
            xRotationTareValues.append(imuData.gyroX)
            yRotationTareValues.append(imuData.gyroY)
            zRotationTareValues.append(imuData.gyroZ)
        }
        
        let accelerationVector = Vector3(x: imuData.accelerationX,
                                         y: imuData.accelerationY,
                                         z: imuData.accelerationZ)
        
        let gyroVector = Vector3(x: imuData.gyroX - xRotationOffset,
                                 y: imuData.gyroY - yRotationOffset,
                                 z: imuData.gyroZ - zRotationOffset)
        
       return kalmanFilter!.update(acceleration: accelerationVector, rotationalVelocity: gyroVector, time: imuData.timestamp)
    }
}

extension Array where Element: FloatingPoint {
    
    var sum: Element {
        return reduce(0, +)
    }
    
    var average: Element {
        guard !isEmpty else {
            return 0
        }
        return sum / Element(count)
    }
    
}

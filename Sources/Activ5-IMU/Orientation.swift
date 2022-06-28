//
//  Orientation.swift
//  Activ5-IMU
//
//  Created by Martin Kuvandzhiev on 7.08.19.
//

import Foundation
import Hamilton
import CoreMotion

public class Orientation {
    let quanternion: Quaternion!
    
    public init(quanternion: Quaternion) {
        self.quanternion = quanternion
    }
    
    public init(x: Double, y: Double, z: Double) {
        let roll = Measurement(value: x, unit: UnitAngle.degrees)
        let yall = Measurement(value: y, unit: UnitAngle.degrees)
        let pitch = Measurement(value: z, unit: UnitAngle.degrees)
        
        let eulerAngle = EulerAngles(pitch: pitch, yaw: yall, roll: roll)
        self.quanternion = Quaternion(eulerAngles: eulerAngle)
    }
    
    public func getAngularDifferenceInRadians(with orientation: Orientation) -> Double {
        let differenceQ = self.quanternion.multiplied(by: orientation.quanternion.inverse)
        return 2 * acos(differenceQ.w)
    }
    
    public func getAngularDifferenceInDegrees(with orientation: Orientation) -> Double {
        return self.getAngularDifferenceInRadians(with: orientation) * 180.0 / .pi
    }
    
    public func getEulerAngelsDouble() -> [Double] {
        let angles = self.quanternion.asEulerAngles.converted(to: .degrees)
        return [angles.pitch.value, angles.yaw.value, angles.roll.value]
    }
}

extension Quaternion {
    static let identity:Quaternion = { return Quaternion(w: 1, x: 0, y: 0, z: 0) }()
    static let zero:Quaternion = { return Quaternion(w: 0, x: 0, y: 0, z: 0) }()
    static let I:Quaternion = { return Quaternion(w: 0, x: 1, y: 0, z: 0) }()
    static let K:Quaternion = { return Quaternion(w: 0, x: 0, y: 1, z: 0) }()
    static let J:Quaternion = { return Quaternion(w: 0, x: 0, y: 0, z: 1) }()
}

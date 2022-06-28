//
//  QuaternionExtension.swift
//  Activ5-IMU
//
//  Created by Martin Kuvandzhiev on 15.08.19.
//

import Foundation
import Hamilton
import Accelerate
import MetalPerformanceShaders

extension Quaternion {
    static func fromSimd(_ simdq: simd_quatd) -> Quaternion {
        return Quaternion(w: simdq.angle, x: simdq.axis.x, y: simdq.axis.y, z: simdq.axis.z)
    }
    
    func toSimd() -> simd_quatd {
        return simd_quatd(angle: self.w, axis: simd_make_double3(self.x, self.y, self.z))
    }
    
    static func fromVector(_ vector: Vector3) -> Quaternion{
        let half = vector.dividing(scalar: 2.0)
        let norm = half.getNorm()
        let sinNorm = sin(norm)
        let cosNorm = cos(norm)
        let divided = half.dividing(scalar: norm)
        let multiplied = divided.multiplying(scalar: sinNorm)
        
        return Quaternion(w: cosNorm, x: multiplied.x, y: multiplied.y, z: multiplied.z)
    }
    
    func getNorm() -> Double {
        var sum = 0.0
        for item in self.components {
            sum += item * item
        }
        return sqrt(sum)
    }
    
    func toVector() -> Vector3 {
        let imaginary = Vector3(self.x, self.y, self.z)
        let norm = imaginary.getNorm()
        if norm == 0 {
            return Vector3.zero
        }
        
        return imaginary.dividing(scalar: norm).multiplying(scalar: acos(self.w / self.getNorm())).multiplying(scalar: 2.0)
    }
    
    func getVectorPart() -> Vector3 {
        return Vector3(self.x, self.y, self.z)
    }
}

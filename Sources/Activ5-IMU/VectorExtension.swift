//
//  VectorExtension.swift
//  Activ5-IMU
//
//  Created by Martin Kuvandzhiev on 15.08.19.
//

import Foundation
import Hamilton
import Accelerate
import MetalPerformanceShaders

extension Vector3 {
    static func fromSimd(_ simd: simd_double3) -> Vector3 {
        return Vector3(simd.x, simd.y, simd.z)
    }
    
    func toSimd() -> simd_double3{
        return simd_make_double3(x, y, z)
    }
    
    
    func getNorm() -> Double {
        var sum: Double = 0.0
        sum += self.x * self.x
        sum += self.y * self.y
        sum += self.z * self.z
        return sqrt(sum)
    }
}

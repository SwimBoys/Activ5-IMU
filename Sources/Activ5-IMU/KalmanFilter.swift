//
//  KalmanFilter.swift
//  Activ5-IMU
//
//  Created by Martin Kuvandzhiev on 7.08.19.
//

import Foundation
import Hamilton
import Accelerate
import MetalPerformanceShaders


public class KalmanFilter {
    static let defaultEstimatedErrorScalar = 1.0
    static let defaultProcessNoiseScalar = 25.0
    static let defaultmeasurementNoiseScalar = 1.0
    
    
    static let startingPosition: Quaternion =  Quaternion.identity
    var previousOrientation: Quaternion = Quaternion.identity
    var sigmaPoints: [Quaternion] = [Quaternion]()
    var process: [Quaternion] = [Quaternion]()
    var errorVectors: [Vector3] = [Vector3]()
    var gravity: Quaternion = Quaternion.K
    
    var estimatedError: simd_double3x3!
    var processNoise: simd_double3x3!
    var measurementNoise: simd_double3x3!
    var processPrediction: simd_double3x3!
    var modeledAcceleration: Vector3!
    var pvv: simd_double3x3!
    var pxz: simd_double3x3!
    var gain: simd_double3x3!
    
    var lastUpdateTime: Double = 0.0
    var enableAcceleration = true
    
    
    convenience init() {
        let estimatedError = simd_mul(KalmanFilter.defaultEstimatedErrorScalar, simd_double3x3(1.0))
        let processNoise = simd_mul(KalmanFilter.defaultProcessNoiseScalar, simd_double3x3(1.0))
        let measurementNoise = simd_mul(KalmanFilter.defaultmeasurementNoiseScalar, simd_double3x3(1.0))
        
        let gravity = Quaternion(0,0,0,1)
        self.init(estimatedError: estimatedError, processNoise: processNoise, measurementNoise: measurementNoise, gravityVector: gravity, enableAcceleration: true)
    }
    
    init(estimatedError: simd_double3x3,
         processNoise: simd_double3x3,
         measurementNoise: simd_double3x3,
         gravityVector: Quaternion,
         enableAcceleration: Bool) {
        self.estimatedError = estimatedError
        self.processNoise = processNoise
        self.measurementNoise = measurementNoise
        self.gravity = gravityVector
        self.enableAcceleration = enableAcceleration
        
        pvv = simd_double3x3(0.0)
        pxz = simd_double3x3(0.0)
        gain = simd_double3x3(0.0)
        
        processPrediction = simd_double3x3(0.0)
    }
    
    func getQuaternion() -> Quaternion {
        return Quaternion(w: previousOrientation.w,
                          x: previousOrientation.x,
                          y: previousOrientation.y,
                          z: previousOrientation.z)
    }
    
    func update(acceleration: Vector3, rotationalVelocity: Vector3, time: Double) -> Orientation {
        let timeDelta = time - lastUpdateTime
        
        if lastUpdateTime == 0 || timeDelta < 0.0 {
            lastUpdateTime = time
            return Orientation(quanternion: previousOrientation)
        }
        
        computeSigmaPoints()
        processModel(rotationalVelocity: rotationalVelocity, timeDelta: timeDelta)
        prediction()
        
        if enableAcceleration {
            measurementModel(acceleration: acceleration)
            gain = simd_mul(pxz, pvv.inverse)
            
            var accGain = Vector3.zero
            for rowIndex in 0..<3 {
                for colIndex in 0..<3 {
                    // because it is 3x3 matrix
                    var components = accGain.components
                    let gainEntry = gain[rowIndex][colIndex]
                    let modeledAccelerationEntry = modeledAcceleration.components[colIndex]
                    let accGainComponent = components[rowIndex]
                    components[rowIndex] = accGainComponent + modeledAccelerationEntry * gainEntry
                    accGain = Vector3(x: components[0], y: components[1], z: components[2])
                }
            }
            
            let quatGain = Quaternion.fromVector(accGain)
            previousOrientation = quatGain.multiplied(by: previousOrientation)
            
            let gainPvv = simd_mul(gain, pvv)
            estimatedError = simd_sub(processPrediction, simd_mul(gainPvv, gain.transpose))
        } else {
            estimatedError = processPrediction
        }
        
        lastUpdateTime = time
        
        return Orientation(quanternion: previousOrientation)
    }
    
    func resetOrientation() {
        self.previousOrientation = KalmanFilter.startingPosition
    }
    
    func computeSigmaPoints() {
        sigmaPoints.removeAll()
        sigmaPoints.append(previousOrientation)
        let rows = 6 // estimated error rows * 2
        let lMatrix = simd_add(estimatedError, processNoise)
        let xPositive = lMatrix * sqrt(Double(rows))
        let xNegative = lMatrix * -sqrt(Double(rows))

        sigmaPoints.append(previousOrientation.multiplied(by: Quaternion.fromVector(Vector3.fromSimd(xPositive.columns.0))))
        sigmaPoints.append(previousOrientation.multiplied(by: Quaternion.fromVector(Vector3.fromSimd(xPositive.columns.1))))
        sigmaPoints.append(previousOrientation.multiplied(by: Quaternion.fromVector(Vector3.fromSimd(xPositive.columns.2))))
        
        sigmaPoints.append(previousOrientation.multiplied(by: Quaternion.fromVector(Vector3.fromSimd(xNegative.columns.0))))
        sigmaPoints.append(previousOrientation.multiplied(by: Quaternion.fromVector(Vector3.fromSimd(xNegative.columns.1))))
        sigmaPoints.append(previousOrientation.multiplied(by: Quaternion.fromVector(Vector3.fromSimd(xNegative.columns.2))))
        
    }
    
    func processModel(rotationalVelocity: Vector3, timeDelta: Double) {
        process.removeAll()
        let delta = Quaternion.fromVector(rotationalVelocity.multiplying(scalar: timeDelta))
        for quaternion in self.sigmaPoints {
            process.append(quaternion.multiplied(by: delta))
        }
    }
    
    func prediction() {
        computePredictionMean()
        processPrediction = simd_double3x3(0.0)
        for errorVector in errorVectors {
            processPrediction = simd_add(processPrediction, matrixOuterProduct(v1: errorVector, v2: errorVector))
        }
        
        processPrediction = simd_mul(1.0/Double(errorVectors.count), processPrediction)
    }
    
    func computePredictionMean() {
        let epsilon = 0.001
        let maxIterations = 1000
        var meanErrorVector = Vector3.zero
        
        for _ in 0..<maxIterations {
            errorVectors.removeAll()
            meanErrorVector = Vector3.zero
            let inverse = previousOrientation.inverse
            
            for quaterion in process {
                let quaternionError = quaterion.multiplied(by: inverse).normalized()
                var vectorError = quaternionError.toVector()
                let vectorNorm = vectorError.getNorm()
                
                if vectorNorm == 0.0 {
                    errorVectors.append(Vector3.zero)
                }
                else {
                    let vectorNormNorm: Double = -1.0 * Double.pi + (vectorNorm + Double.pi).truncatingRemainder(dividingBy: Double.pi * 2.0)
                    vectorError = vectorError.dividing(scalar: vectorNorm)
                    vectorError = vectorError.multiplying(scalar: vectorNormNorm)
                    errorVectors.append(vectorError)
                    meanErrorVector = meanErrorVector.adding(vectorError)
                }
            }
            
            meanErrorVector = meanErrorVector.dividing(scalar: Double(errorVectors.count))
            previousOrientation = Quaternion.fromVector(meanErrorVector).multiplied(by: previousOrientation).normalized()
            
            if meanErrorVector.getNorm() < epsilon {
                break
            }
        }
    }
    
    func measurementModel(acceleration: Vector3) {
        var acceleratonPredictions = [Vector3]()
        var accelerationPredictionMean = Vector3.zero
        
        for quaternion in process {
            var quat = quaternion.inverse.multiplied(by: gravity)
            quat = quat.multiplied(by: quaternion)
            let prediction = quat.getVectorPart()
            acceleratonPredictions.append(prediction)
            accelerationPredictionMean = accelerationPredictionMean.adding(prediction)
        }
        
        accelerationPredictionMean = accelerationPredictionMean.dividing(scalar: Double(acceleratonPredictions.count))
        accelerationPredictionMean = accelerationPredictionMean.dividing(scalar: accelerationPredictionMean.getNorm())
        
        var pzz = simd_double3x3(0.0)
        pxz = simd_double3x3(0.0)
        
        for index in 0..<acceleratonPredictions.count {
            acceleratonPredictions[index] = acceleratonPredictions[index].subtracted(by: accelerationPredictionMean)
        }
        
        for index in 0..<process.count {
            let prediction = acceleratonPredictions[index]
            let error = errorVectors[index]
            pzz = simd_add(pzz, matrixOuterProduct(v1: prediction, v2: prediction))
            pxz = simd_add(pxz, matrixOuterProduct(v1: error, v2: prediction))
        }
        
        pzz = simd_mul(1.0/Double(process.count), pzz)
        pxz = simd_mul(1.0/Double(process.count), pxz)
        
        modeledAcceleration = acceleration.dividing(scalar: acceleration.getNorm()).subtracted(by: accelerationPredictionMean)
        pvv = simd_add(pzz, measurementNoise)
    }
    
    
    
}


extension KalmanFilter {
    func matrixOuterProduct(v1: Vector3, v2: Vector3) -> simd_double3x3{
        var matrix = simd_double3x3(0.0)
        for m in 0..<v1.components.count {
            for n in 0..<v2.components.count {
                matrix[m][n] = v1.components[m] * v2.components[n]
            }
        }
        return matrix
    }
}




//
//  FileManager.swift
//  Activ5-IMU_Example
//
//  Created by Martin Kuvandzhiev on 20.09.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Activ5_IMU
import Activ5Device

class LocalFileManager{
    static var lastFileName = ""
    static var buffer = ""
    
    class func createNewFile() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let fileName = dateFormatter.string(from: Date()) + ".csv"
        //let fileName = Date().description.replacingOccurrences(of: " ", with: "-") + ".csv"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            LocalFileManager.lastFileName = fileName
            buffer = (Date().description + "\n")
        }
    }
    
    class func appendFile(imuObject: IMUObject) {
        
        var csvString = Date().description + ", "
        csvString += imuObject.timestamp.fromSec.description + ", "
        csvString += "RAW DATA, "
        
        csvString += "mX, "
        csvString += imuObject.accelerationX.fromGForce.description + ", "
        csvString += "mY, "
        csvString += imuObject.accelerationY.fromGForce.description + ", "
        csvString += "mZ, "
        csvString += imuObject.accelerationZ.fromGForce.description + ", "
        
        csvString += "mGx, "
        csvString += imuObject.gyroX.fromRadPerSec.description + ", "
        csvString += "mGy, "
        csvString += imuObject.gyroY.fromRadPerSec.description + ", "
        csvString += "mGz, "
        csvString += imuObject.gyroZ.fromRadPerSec.description + ", "
        
        csvString += "mIso, "
        csvString += 12.description + "\n"
        LocalFileManager.buffer += csvString
    }
    
    class func writeFile() {
        let fileName = LocalFileManager.lastFileName
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            try! LocalFileManager.buffer.write(to: fileURL, atomically: false, encoding: .utf8)
            buffer = ""
        }
    }
}

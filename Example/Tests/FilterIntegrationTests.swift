//
//  FilterIntegrationTests.swift
//  Activ5-IMU_Tests
//
//  Created by Martin Kuvandzhiev on 19.08.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import Activ5Device
@testable import Activ5_IMU
import Hamilton

class FilterIntegrationTests: XCTestCase {
    
    func testPerformance() {
//        measure {
//            let imuData = getIMUObjects(from: "02")
//            let orientation = getFinalOrientation(imuObjects: imuData)
//        }
       
    }
    
    func testFile2() {
        let imuData = getIMUObjects(from: "02")
        let orientation = getFinalOrientation(imuObjects: imuData)
        let finalResult = Orientation(quanternion: Quaternion(0.7090421833942585, 0.7046657116283386, 0.0873486815981751, 0.0654758190180812))
        
        XCTAssertEqual(orientation.quanternion.w, finalResult.quanternion.w, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.x, finalResult.quanternion.x, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.y, finalResult.quanternion.y, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.z, finalResult.quanternion.z, accuracy: 0.02)
    }
    
    func testFile4() {
        let imuData = getIMUObjects(from: "04")
        let orientation = getFinalOrientation(imuObjects: imuData)
        let finalResult = Orientation(quanternion: Quaternion(0.7057806049216186, 0.7084013078955791, 0.004518870102361621, -0.004572144059979399))
        
        XCTAssertEqual(orientation.quanternion.w, finalResult.quanternion.w, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.x, finalResult.quanternion.x, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.y, finalResult.quanternion.y, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.z, finalResult.quanternion.z, accuracy: 0.02)
    }
    
    func testFile5() {
        let imuData = getIMUObjects(from: "05")
        let orientation = getFinalOrientation(imuObjects: imuData)
        let finalResult = Orientation(quanternion: Quaternion(0.714634645382242, 0.6978977863657801, 0.0237694861427992, -0.0072475659745800825))
        
        XCTAssertEqual(orientation.quanternion.w, finalResult.quanternion.w, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.x, finalResult.quanternion.x, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.y, finalResult.quanternion.y, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.z, finalResult.quanternion.z, accuracy: 0.02)
    }
    
    func testFile6() {
        let imuData = getIMUObjects(from: "06")
        let orientation = getFinalOrientation(imuObjects: imuData)
        let finalResult = Orientation(quanternion: Quaternion(0.7281486292467002, 0.6835857407327112, 0.049538806729594646, -0.007484345052833198))
        
        XCTAssertEqual(orientation.quanternion.w, finalResult.quanternion.w, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.x, finalResult.quanternion.x, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.y, finalResult.quanternion.y, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.z, finalResult.quanternion.z, accuracy: 0.02)
    }
    
    func testFile7() {
        let imuData = getIMUObjects(from: "07")
        let orientation = getFinalOrientation(imuObjects: imuData)
        let finalResult = Orientation(quanternion: Quaternion(0.7113804535985236, 0.7005798255464156, 0.05547652977979815, -0.00693634766315073))
        
        XCTAssertEqual(orientation.quanternion.w, finalResult.quanternion.w, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.x, finalResult.quanternion.x, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.y, finalResult.quanternion.y, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.z, finalResult.quanternion.z, accuracy: 0.02)
    }
    
    func testFile11() {
        let imuData = getIMUObjects(from: "11")
        let orientation = getFinalOrientation(imuObjects: imuData)
        let finalResult = Orientation(quanternion: Quaternion(0.7075839720875391, 0.7066203420566308, 0.002893315411538469, -0.0020599423585062632))
        
        XCTAssertEqual(orientation.quanternion.w, finalResult.quanternion.w, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.x, finalResult.quanternion.x, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.y, finalResult.quanternion.y, accuracy: 0.02)
        XCTAssertEqual(orientation.quanternion.z, finalResult.quanternion.z, accuracy: 0.02)
    }
    
    func testFiles() {
        var fileNames = [String]()
        for index in 1...21 {
            fileNames.append("r-" + index.description)
        }
        var resultList = [Double]()
        
        for fileName in fileNames {
            let imuData = getIMUObjects(from: fileName)
            let orientations = getFirstAndLastOrientations(imuObjects: imuData)
            resultList.append(orientations.last.getAngularDifferenceInDegrees(with: orientations.first))
        }
        
        print(resultList)
    }
    
    
}


extension FilterIntegrationTests {
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\t", with: "")
        cleanFile = cleanFile.replacingOccurrences(of: " ", with: "")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
        return cleanFile
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    func getIMUObjects(from filename: String) -> [IMUObject] {
        var data = readDataFromCSV(fileName: filename, fileType: "csv")
        data = cleanRows(file: data!)
        let csvRows = csv(data: data!)
        
        var imuData = [IMUObject]()
        for rowIndex in 0..<csvRows.count {
            if csvRows[rowIndex].count < 5 {
                continue
            }
            var RAWDATAindex = 0
            
            if csvRows[rowIndex][3] == "RAWDATA"{
                RAWDATAindex = 3
            } else if csvRows[rowIndex][2] == "RAWDATA" {
                RAWDATAindex = 2
            } else {
                continue
            }
            
            let accelX = Int(Double(csvRows[rowIndex][RAWDATAindex+2])!)
            let accelY = Int(Double(csvRows[rowIndex][RAWDATAindex+4])!)
            let accelZ = Int(Double(csvRows[rowIndex][RAWDATAindex+6])!)
            
            let gyroX = Int(Double(csvRows[rowIndex][RAWDATAindex+8])!)
            let gyroY = Int(Double(csvRows[rowIndex][RAWDATAindex+10])!)
            let gyroZ = Int(Double(csvRows[rowIndex][RAWDATAindex+12])!)
            
            let timestamp = Int(csvRows[rowIndex][RAWDATAindex-1])!
            
            let imuObject = IMUObject(accelerationX: accelX.toGForce,
                                      accelerationY: accelY.toGForce,
                                      accelerationZ: accelZ.toGForce,
                                      gyroX: gyroX.toRadPerSec,
                                      gyroY: gyroY.toRadPerSec,
                                      gyroZ: gyroZ.toRadPerSec,
                                      timestamp: timestamp.toSec)
            imuData.append(imuObject)
        }
        return imuData
    }

    func getFinalOrientation(imuObjects: [IMUObject]) -> Orientation {
        let orientationProvider = OrientationProvider()
        var orientation: Orientation?
        var initialOrientation: Orientation?
        for imuItem in imuObjects {
            orientation = orientationProvider.update(imuData: imuItem)
            if initialOrientation == nil {
                initialOrientation = orientation
            }
            XCTAssertNotNil(orientation)
            XCTAssertNotEqual(orientation!.quanternion.w.description, "nan")
            XCTAssertNotEqual(orientation!.quanternion.w.description, "-nan")
        }
        print(orientation!.getAngularDifferenceInDegrees(with: initialOrientation!))
        return orientation!
    }
    
    func getFirstAndLastOrientations(imuObjects: [IMUObject]) -> (first: Orientation, last: Orientation) {
        let orientationProvider = OrientationProvider()
        var orientation: Orientation?
        var initialOrientation: Orientation?
        for imuItem in imuObjects {
            orientation = orientationProvider.update(imuData: imuItem)
            if initialOrientation == nil {
                initialOrientation = orientation
            }
            XCTAssertNotNil(orientation)
            XCTAssertNotEqual(orientation!.quanternion.w.description, "nan")
            XCTAssertNotEqual(orientation!.quanternion.w.description, "-nan")
        }
        print(orientation!.getAngularDifferenceInDegrees(with: initialOrientation!))
        return (initialOrientation!, orientation!)
    }
}

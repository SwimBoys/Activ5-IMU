//
//  IMUReadingTests.swift
//  Activ5-IMU_Tests
//
//  Created by Martin Kuvandzhiev on 19.08.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import Activ5Device
@testable import Activ5_IMU


class IMUReadingTests: XCTestCase {
    func testIMUData() {
        // FF0F FE1F FF07 FF0F FE1F FF07 92090907 == Values are: 1 g, 2 g, 0.5 g, 250 dps, 500 dps, 125 dps, 30 min
        let data = Data(base64Encoded: "/w/+H/8H/w/+H/8HkgkJBw==")
        let imuData = MessageParser.parseIMUValue(data: data!)
        XCTAssertEqual(imuData.accelerationX, 1.0, accuracy: 0.01)
        XCTAssertEqual(imuData.accelerationY, 2.0, accuracy: 0.01)
        XCTAssertEqual(imuData.accelerationZ, 0.5, accuracy: 0.01)
        
        XCTAssertEqual(imuData.gyroX, 4.36, accuracy: 0.01)
        XCTAssertEqual(imuData.gyroY, 8.72, accuracy: 0.01)
        XCTAssertEqual(imuData.gyroZ, 2.18, accuracy: 0.01)
        
        XCTAssertEqual(imuData.timestamp, 1800, accuracy: 0.001)
    }
}

// https://github.com/Quick/Quick

import Foundation
import XCTest
@testable import Activ5_IMU
import Hamilton


class QuaternionTests: XCTestCase {
    func testQuaternionsInRad() {
        let data: [(o1: Orientation, o2: Orientation, result: Double)] = [
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(1,0,0,0)), result: 0.0),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0,1,0)), result: .pi),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,1,0,0)), result: .pi),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0,0,1)), result: .pi),
            
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.7071,0,-0.7071,0)), result: .pi/2),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.7071,0,0,-0.7071)), result: .pi/2),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.7071,0,0,0.7071)), result: .pi/2),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.7071,0.7071,0,0)), result: .pi/2),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.7071,-0.7071,0,0)), result: .pi/2),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0,0.7071,0.7071)), result: .pi),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0.7071,0.7071,0)), result: .pi),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,-0.7071,0.7071,0)), result: .pi),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0,0.7071,-0.7071)), result: .pi),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0.7071,0,-0.7071)), result: .pi),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0.7071,0,0.7071)), result: .pi),
            
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,0.5,0.5,0.5)), result: (.pi*2/3)),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,-0.5,-0.5,0.5)), result: .pi*2/3),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,-0.5,0.5,-0.5)), result: .pi*2/3),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,0.5,-0.5,-0.5)), result: .pi*2/3),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,0.5,0.5,-0.5)), result: .pi*2/3),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,0.5,-0.5,0.5)), result: .pi*2/3),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,-0.5,0.5,0.5)), result: .pi*2/3),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,-0.5,-0.5,-0.5)), result: .pi*2/3),
        ]

        XCTAssertEqual(data[0].o1.getAngularDifferenceInRadians(with: data[0].o2), data[0].result, accuracy: 0.001)
        XCTAssertEqual(data[1].o1.getAngularDifferenceInRadians(with: data[1].o2), data[1].result, accuracy: 0.001)
        XCTAssertEqual(data[2].o1.getAngularDifferenceInRadians(with: data[2].o2), data[2].result, accuracy: 0.001)
        XCTAssertEqual(data[3].o1.getAngularDifferenceInRadians(with: data[3].o2), data[3].result, accuracy: 0.001)
        XCTAssertEqual(data[4].o1.getAngularDifferenceInRadians(with: data[4].o2), data[4].result, accuracy: 0.001)
        XCTAssertEqual(data[5].o1.getAngularDifferenceInRadians(with: data[5].o2), data[5].result, accuracy: 0.001)
        XCTAssertEqual(data[6].o1.getAngularDifferenceInRadians(with: data[6].o2), data[6].result, accuracy: 0.001)
        XCTAssertEqual(data[7].o1.getAngularDifferenceInRadians(with: data[7].o2), data[7].result, accuracy: 0.001)
        XCTAssertEqual(data[8].o1.getAngularDifferenceInRadians(with: data[8].o2), data[8].result, accuracy: 0.001)
        XCTAssertEqual(data[9].o1.getAngularDifferenceInRadians(with: data[9].o2), data[9].result, accuracy: 0.001)
        XCTAssertEqual(data[10].o1.getAngularDifferenceInRadians(with: data[10].o2), data[10].result, accuracy: 0.001)
        XCTAssertEqual(data[11].o1.getAngularDifferenceInRadians(with: data[11].o2), data[11].result, accuracy: 0.001)
        XCTAssertEqual(data[12].o1.getAngularDifferenceInRadians(with: data[12].o2), data[12].result, accuracy: 0.001)
        XCTAssertEqual(data[13].o1.getAngularDifferenceInRadians(with: data[13].o2), data[13].result, accuracy: 0.001)
        XCTAssertEqual(data[14].o1.getAngularDifferenceInRadians(with: data[14].o2), data[14].result, accuracy: 0.001)
        XCTAssertEqual(data[15].o1.getAngularDifferenceInRadians(with: data[15].o2), data[15].result, accuracy: 0.001)
        XCTAssertEqual(data[16].o1.getAngularDifferenceInRadians(with: data[16].o2), data[16].result, accuracy: 0.001)
        XCTAssertEqual(data[17].o1.getAngularDifferenceInRadians(with: data[17].o2), data[17].result, accuracy: 0.001)
        XCTAssertEqual(data[18].o1.getAngularDifferenceInRadians(with: data[18].o2), data[18].result, accuracy: 0.001)
        XCTAssertEqual(data[19].o1.getAngularDifferenceInRadians(with: data[19].o2), data[19].result, accuracy: 0.001)
        XCTAssertEqual(data[20].o1.getAngularDifferenceInRadians(with: data[20].o2), data[20].result, accuracy: 0.001)
        XCTAssertEqual(data[21].o1.getAngularDifferenceInRadians(with: data[21].o2), data[21].result, accuracy: 0.001)
        XCTAssertEqual(data[22].o1.getAngularDifferenceInRadians(with: data[22].o2), data[22].result, accuracy: 0.001)
    }
    
    
    func testQuaternionsInDeg() {
        let data: [(o1: Orientation, o2: Orientation, result: Double)] = [
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(1,0,0,0)), result: 0.0),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0,1,0)), result: 180),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,1,0,0)), result: 180),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0,0,1)), result: 180),
            
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.7071,0,-0.7071,0)), result: 90),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.7071,0,0,-0.7071)), result: 90),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.7071,0,0,0.7071)), result: 90),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.7071,0.7071,0,0)), result: 90),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.7071,-0.7071,0,0)), result: 90),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0,0.7071,0.7071)), result: 180),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0.7071,0.7071,0)), result: 180),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,-0.7071,0.7071,0)), result: 180),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0,0.7071,-0.7071)), result: 180),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0.7071,0,-0.7071)), result: 180),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0,0.7071,0,0.7071)), result: 180),
            
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,0.5,0.5,0.5)), result: 120),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,-0.5,-0.5,0.5)), result: 120),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,-0.5,0.5,-0.5)), result: 120),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,0.5,-0.5,-0.5)), result: 120),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,0.5,0.5,-0.5)), result: 120),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,0.5,-0.5,0.5)), result: 120),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,-0.5,0.5,0.5)), result: 120),
            (o1: Orientation(quanternion: Quaternion(1,0,0,0)), o2: Orientation(quanternion: Quaternion(0.5,-0.5,-0.5,-0.5)), result: 120),
        ]
        
        XCTAssertEqual(data[0].o1.getAngularDifferenceInDegrees(with: data[0].o2), data[0].result, accuracy: 0.01)
        XCTAssertEqual(data[1].o1.getAngularDifferenceInDegrees(with: data[1].o2), data[1].result, accuracy: 0.01)
        XCTAssertEqual(data[2].o1.getAngularDifferenceInDegrees(with: data[2].o2), data[2].result, accuracy: 0.01)
        XCTAssertEqual(data[3].o1.getAngularDifferenceInDegrees(with: data[3].o2), data[3].result, accuracy: 0.01)
        XCTAssertEqual(data[4].o1.getAngularDifferenceInDegrees(with: data[4].o2), data[4].result, accuracy: 0.01)
        XCTAssertEqual(data[5].o1.getAngularDifferenceInDegrees(with: data[5].o2), data[5].result, accuracy: 0.01)
        XCTAssertEqual(data[6].o1.getAngularDifferenceInDegrees(with: data[6].o2), data[6].result, accuracy: 0.01)
        XCTAssertEqual(data[7].o1.getAngularDifferenceInDegrees(with: data[7].o2), data[7].result, accuracy: 0.01)
        XCTAssertEqual(data[8].o1.getAngularDifferenceInDegrees(with: data[8].o2), data[8].result, accuracy: 0.01)
        XCTAssertEqual(data[9].o1.getAngularDifferenceInDegrees(with: data[9].o2), data[9].result, accuracy: 0.01)
        XCTAssertEqual(data[10].o1.getAngularDifferenceInDegrees(with: data[10].o2), data[10].result, accuracy: 0.01)
        XCTAssertEqual(data[11].o1.getAngularDifferenceInDegrees(with: data[11].o2), data[11].result, accuracy: 0.01)
        XCTAssertEqual(data[12].o1.getAngularDifferenceInDegrees(with: data[12].o2), data[12].result, accuracy: 0.01)
        XCTAssertEqual(data[13].o1.getAngularDifferenceInDegrees(with: data[13].o2), data[13].result, accuracy: 0.01)
        XCTAssertEqual(data[14].o1.getAngularDifferenceInDegrees(with: data[14].o2), data[14].result, accuracy: 0.01)
        XCTAssertEqual(data[15].o1.getAngularDifferenceInDegrees(with: data[15].o2), data[15].result, accuracy: 0.01)
        XCTAssertEqual(data[16].o1.getAngularDifferenceInDegrees(with: data[16].o2), data[16].result, accuracy: 0.01)
        XCTAssertEqual(data[17].o1.getAngularDifferenceInDegrees(with: data[17].o2), data[17].result, accuracy: 0.01)
        XCTAssertEqual(data[18].o1.getAngularDifferenceInDegrees(with: data[18].o2), data[18].result, accuracy: 0.01)
        XCTAssertEqual(data[19].o1.getAngularDifferenceInDegrees(with: data[19].o2), data[19].result, accuracy: 0.01)
        XCTAssertEqual(data[20].o1.getAngularDifferenceInDegrees(with: data[20].o2), data[20].result, accuracy: 0.01)
        XCTAssertEqual(data[21].o1.getAngularDifferenceInDegrees(with: data[21].o2), data[21].result, accuracy: 0.01)
        XCTAssertEqual(data[22].o1.getAngularDifferenceInDegrees(with: data[22].o2), data[22].result, accuracy: 0.01)
    }
}


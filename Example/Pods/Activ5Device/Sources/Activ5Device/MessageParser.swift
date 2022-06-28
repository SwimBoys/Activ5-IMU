//
//  MessageParser.swift
//  Activ5Device
//
//  Created by Martin Kuvandzhiev on 6.08.19.
//

import Foundation
import CoreBluetooth

public enum MessageType: String {
    case initialMessage = "TC5k"
    case isometric = "IS"
    case timestamp = "TS"
    case imu = "IM"
    case unknown = "unknown"
    
    
    init(from message: String) {
        if message.starts(with: MessageType.initialMessage.rawValue) {
            self = .initialMessage
        } else if message.starts(with: MessageType.isometric.rawValue) {
            self = .isometric
        } else {
            self = .unknown
        }
    }
}

public class MessageParser {
    public class func parseMessage(characteristic: CBCharacteristic)->(type: MessageType, value: Any?) {
        guard let value = characteristic.value else {
            return (.unknown, nil)
        }
        
        switch characteristic.characteristicType {
        case .read:
            let messageString = String(data: characteristic.value!, encoding: String.Encoding.ascii)
            return parseLegacyMessage(messageString)
        case .force:
            let forceData = parseValue(data: value)
            return (.isometric, forceData)
        case .imu:
            let imuData = parseIMUValue(data: value)
            return (.imu, imuData)
        default:
            return (.unknown, nil)
        }
    }
    
    public class func parseLegacyMessage(_ message: String?) -> (type: MessageType, value: Any?) {
        guard var message = message else {
            return (.unknown, nil)
        }
        
        message = message.replacingOccurrences(of: "\u{12}", with: "").replacingOccurrences(of: "\u{13}", with: "")
        
        let messageParts = message.components(separatedBy: ";")
        let messageType = MessageType(from: messageParts[0])
        switch messageType {
        case .initialMessage:
            let deviceVersion = messageParts[1]
            return (messageType, deviceVersion)
        case .isometric:
            let isomValue = message.replacingOccurrences(of: "IS", with: "").replacingOccurrences(of: "/", with: "")
            return (messageType, isomValue)
        default:
            return (.unknown, nil)
        }
    }
    
    public class func parseValue(data: Data) -> Int {
        let value = data.withUnsafeBytes { $0.load(as: Int16.self) }
        return Int(value)
    }
    
    public class func parseIMUValue(data: Data) -> IMUObject {
        let accelerationX = parseValue(data: data.subdata(in: Range(uncheckedBounds: (lower: 0, upper: 2))))
        let accelerationY = parseValue(data:data.subdata(in: Range(uncheckedBounds: (lower: 2, upper: 4))))
        let accelerationZ = parseValue(data:data.subdata(in: Range(uncheckedBounds: (lower: 4, upper: 6))))
        let gyroX = parseValue(data:data.subdata(in: Range(uncheckedBounds: (lower: 6, upper: 8))))
        let gyroY = parseValue(data:data.subdata(in: Range(uncheckedBounds: (lower: 8, upper: 10))))
        let gyroZ = parseValue(data:data.subdata(in: Range(uncheckedBounds: (lower: 10, upper: 12))))
        let timestampData = data.subdata(in: Range(uncheckedBounds: (lower: 12, upper: 16))).withUnsafeBytes { $0.load(as: Int32.self) }
        let timestamp = Int(timestampData)
        
        return IMUObject(accelerationX: accelerationX,
                         accelerationY: accelerationY,
                         accelerationZ: accelerationZ,
                         gyroX: gyroX,
                         gyroY: gyroY,
                         gyroZ: gyroZ,
                         timestamp: timestamp)
    }
}


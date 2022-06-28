//
//  A5Device.swift
//  Activ5-Device_Example
//
//  Created by Martin Kuvandzhiev on 3.09.2018.
//  Copyright (c) 2019 ActivBody Inc. <https://activ5.com>. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum A5DeviceDataState {
    case handshake
    case isometric
    case stop
    case disconnected
}

public enum A5Error: Error {
    case imuUnsupported
}

public class A5Device {
    public var device: CBPeripheral
    public var name: String?
    public var writeCharacteristic: CBCharacteristic?
    public var readCharacteristic: CBCharacteristic?
    //API spec v2
    public var usesNewProtocol: Bool = false
    public var forceCharacteristic: CBCharacteristic?
    public var imuCharacteristic: CBCharacteristic?
    public var timestampCharacteristic: CBCharacteristic?
    
    public var deviceDataState: A5DeviceDataState = .disconnected
    public var deviceVersion: String?
    public var evergreenMode: Bool = false {
        didSet {
            setEvergreen(evergreenMode)
        }
    }
    
    private var evergreenTimer: Timer?
    
    public init(device: CBPeripheral, name: String? = nil, writeCharacteristic: CBCharacteristic? = nil, readCharacteristic: CBCharacteristic? = nil) {
        self.device = device
        self.name = name
        self.writeCharacteristic = writeCharacteristic
        self.readCharacteristic = readCharacteristic
    }
}

extension A5Device {
    enum Characteristic: String {
        case read = "5A01"
        case write = "5A02"
        case force = "F0F1"
        case timestamp = "F0F3"
        case imu = "F0F5"
        case unknown = "FFFF"
    }
}

extension A5Device: Equatable {
    public static func == (lhs: A5Device, rhs: A5Device) -> Bool {
        return lhs.name == rhs.name
    }
}

extension A5Device: Hashable {
    public var hashValue: Int {
            return self.name?.hashValue ?? 0
    }
}

//Bluetooth functionality

public enum A5Command:String {
    case doHandshake = "TVGTIME"
    case startIsometric = "ISOM!"
    case tare = "TARE!"
    case stop = "STOP!"
}

public extension A5Device {
    func sendCommand(_ command: A5Command) {
        self.sendMessage(message: command.rawValue)
        switch command {
        case .stop:
            self.deviceDataState = .stop
        default:
            break
        }
    }

    private func sendMessage(message: String) {
        A5DeviceManager.send(message: message, to: self)
    }
    
    func startIsometric() {
        self.sendCommand(.startIsometric)
    }
    
    func stop() {
        self.sendCommand(.stop)
    }
    
    func startIMU() throws {
        guard let imuCharacteristic = self.imuCharacteristic else {
            throw A5Error.imuUnsupported
        }
        self.device.setNotifyValue(true, for: imuCharacteristic)
    }
    
    func stopIMU() throws {
        guard let imuCharacteristic = self.imuCharacteristic else {
            throw A5Error.imuUnsupported
        }
        self.device.setNotifyValue(false, for: imuCharacteristic)
    }

    func disconnect() {
        A5DeviceManager.disconnect(device: self.device)
        self.deviceDataState = .disconnected
    }
}

public extension A5Device {
    func setEvergreen(_ enabled: Bool) {
        switch enabled {
        case true:
            evergreenTimer?.invalidate()
            evergreenTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (timer) in
                switch self.deviceDataState {
                case .stop, .handshake:
                    self.sendCommand(.stop)
                default:
                    break
                }
            })
            evergreenTimer?.tolerance = 100
        case false:
            evergreenTimer?.invalidate()
            evergreenTimer = nil
        }
    }
}

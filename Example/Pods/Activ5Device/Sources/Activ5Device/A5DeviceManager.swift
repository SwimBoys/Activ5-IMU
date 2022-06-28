//
//  A5DeviceManager.swift
//  Activ5-Device_Example
//
//  Created by Martin Kuvandzhiev on 27.08.2018.
//  Copyright (c) 2019 ActivBody Inc. <https://activ5.com>. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct A5DeviceManagerOptions {
    var services: [CBUUID] = [CBUUID(string: "0x5000")]
    var autoHandshake: Bool = true
    var searchTimeout = 30.0
}

public protocol A5DeviceDelegate: class {
    func searchCompleted()
    func deviceFound(device: A5Device)
    func deviceConnected(device: A5Device)
    func deviceDisconnected(device: A5Device)
    func didReceiveMessage(device: A5Device, message: String, type: MessageType)
    func didReceiveIsometric(device: A5Device, value: Int)
    func didReceiveIMUData(device: A5Device, value: IMUObject)
    func didFailToConnect(device: A5Device, error: Error?)
    func didChangeBluetoothState(_ state: CBManagerState)
    func bluetoothIsSwitchedOff()
}

public extension A5DeviceDelegate {
    func didFailToConnect(device: CBPeripheral, error: Error?) {}
    func didReceiveMessage(device: A5Device, message: String, type: MessageType) {}
    func didReceiveIsometric(device:A5Device, value: Int) {}
    func didReceiveIMUData(device: A5Device, value: IMUObject) {}
    func didChangeBluetoothState(_ state: CBManagerState) {}
    func bluetoothIsSwitchedOff() {}
}

public class A5DeviceManager: NSObject {
    public static let instance = { return A5DeviceManager() }()
    public static var delegate: A5DeviceDelegate?
    public static let cbManager = { return CBCentralManager(delegate: A5DeviceManager.instance, queue: bluetoothQueue)}()

    public static var devices = [String: A5Device]()
    public static var connectedDevices = [String: A5Device]()
    public static var options = A5DeviceManagerOptions()

    private static var searchTimer: Timer?
    private static let bluetoothQueue = DispatchQueue(label: "A5-Dispatch-Queue")
    
    public class func initializeDeviceManager(){
        _ = cbManager // initializing the CBManager
    }

    public class func scanForDevices(searchCompleted: @escaping () -> Void) {
        //clean current list
        switch cbManager.state {
        case .poweredOn:
            break
        default:
            delegate?.bluetoothIsSwitchedOff()
        }
        
        if self.connectedDevices.isEmpty {
             self.devices.removeAll()
        }
        self.cbManager.scanForPeripherals(withServices: options.services)
        self.searchTimer = Timer.scheduledTimer(withTimeInterval: self.options.searchTimeout, repeats: false, block: { (_) in
            cbManager.stopScan()
            self.delegate?.searchCompleted()
            searchCompleted()
        })
    }

    public class func connect(device: CBPeripheral) {
        self.cbManager.connect(device, options: nil)
    }
    
    public class func disconnect(device: CBPeripheral) {
        self.cbManager.cancelPeripheralConnection(device)
    }

    class func send(message: String, to device: A5Device) {
        let message = "A"+message+"\u{13}"
        let data = message.data(using: String.Encoding.utf8)!
        guard let writeChar = device.writeCharacteristic else {
            return
        }

        device.device.writeValue(data, for: writeChar, type: CBCharacteristicWriteType.withResponse)
    }

    public class func device(for peripheral: CBPeripheral) -> (key: String, value:A5Device)? {
        var allDevices = A5DeviceManager.devices
        for item in connectedDevices {
            allDevices[item.key] = item.value
        }

        guard let device = allDevices.filter({ (deviceToCheck) -> Bool in
            return deviceToCheck.value.device == peripheral
        }).first else {
            return nil
        }
        return (device.key, device.value)
    }
}

extension A5DeviceManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        A5DeviceManager.delegate?.didChangeBluetoothState(central.state)
        switch central.state {
        case .poweredOn :
            print("Ready for device connect")
        case .poweredOff:
            A5DeviceManager.connectedDevices.forEach { device in
                A5DeviceManager.connectedDevices.removeValue(forKey: device.value.name!)
                A5DeviceManager.devices.removeValue(forKey: device.value.name!)
                DispatchQueue.main.async {
                    A5DeviceManager.delegate?.deviceDisconnected(device: device.value)
                }
            }
        default:
            break
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String else {
            return
        }

        let device = A5Device(device: peripheral, name: deviceName, writeCharacteristic: nil, readCharacteristic: nil)
        A5DeviceManager.devices[deviceName] = device
        DispatchQueue.main.async {
            A5DeviceManager.delegate?.deviceFound(device: device)
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let device = A5DeviceManager.device(for: peripheral) {
            A5DeviceManager.connectedDevices[device.value.name!] = device.value
            device.value.device.delegate = self
            device.value.device.discoverServices(nil)
            DispatchQueue.main.async {
                A5DeviceManager.delegate?.deviceConnected(device: device.value)
            }
            return
        }
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard let device = A5DeviceManager.device(for: peripheral)?.value else {
            return
        }
        DispatchQueue.main.async {
            A5DeviceManager.delegate?.didFailToConnect(device: device, error: error)
        }
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let device = A5DeviceManager.device(for: peripheral)?.value else {
            return
        }
        device.deviceDataState = .disconnected
        A5DeviceManager.connectedDevices.removeValue(forKey: device.name!)
        A5DeviceManager.devices.removeValue(forKey: device.name!)
        DispatchQueue.main.async {
            A5DeviceManager.delegate?.deviceDisconnected(device: device)
        }
    }
}

extension A5DeviceManager: CBPeripheralDelegate {

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        
        guard let device = A5DeviceManager.device(for: peripheral)?.value else {
            return
        }
        
        for service in services {
            if service.uuid.uuidString == "0xF0F0" {
                device.usesNewProtocol = true
            }
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        guard let device = A5DeviceManager.device(for: peripheral) else {
            return
        }

        for characrteristic in characteristics {
            switch characrteristic.characteristicType {
            case .read:
                device.value.readCharacteristic = characrteristic
                peripheral.setNotifyValue(true, for: characrteristic)
            case .write:
                device.value.writeCharacteristic = characrteristic
            case .force:
                device.value.forceCharacteristic = characrteristic
            case .timestamp:
                device.value.timestampCharacteristic = characrteristic
            case .imu:
                device.value.imuCharacteristic = characrteristic
            default:
                break
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let device = A5DeviceManager.device(for: peripheral)?.value else {
            return
        }
        
        let parsedData = MessageParser.parseMessage(characteristic: characteristic)
        let messageType: MessageType = parsedData.type
        var message: String = ""
        
        switch messageType {
        case .initialMessage:
            device.deviceDataState = .handshake
            device.deviceVersion = (parsedData.value as? String) ?? ""
            if A5DeviceManager.options.autoHandshake == true {
                device.sendCommand(.doHandshake)
                device.deviceDataState = .stop
            }
        case .isometric:
            device.deviceDataState = .isometric
            message = ((parsedData.value as? Int) ?? 0).description
        case .imu:
            print(parsedData.value!)
        default:
            device.deviceDataState = .stop
        }
        
        
        DispatchQueue.main.async {
            A5DeviceManager.delegate?.didReceiveMessage(device: device, message: message, type: messageType)
            if messageType == .isometric, let value = Int(message) {
                A5DeviceManager.delegate?.didReceiveIsometric(device: device, value: value)
            }
        }
    }
    
    
}

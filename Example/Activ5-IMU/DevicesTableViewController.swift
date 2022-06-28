//
//  DevicesTableViewController.swift
//  Activ5-IMU_Example
//
//  Created by Martin Kuvandzhiev on 24.08.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Activ5Device
import SVProgressHUD


class DevicesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        A5DeviceManager.delegate = self
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return A5DeviceManager.devices.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let device = Array(A5DeviceManager.devices.values)[indexPath.row]
        cell.textLabel?.text = device.name
        cell.detailTextLabel?.text = device.connected ? "Connected" : ""

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < A5DeviceManager.devices.count else {
            return
        }
        
        let device = Array(A5DeviceManager.devices.values)[indexPath.row]
        for connectedDevice in A5DeviceManager.connectedDevices {
            connectedDevice.value.disconnect()
        }
        A5DeviceManager.connect(device: device.device)
        
    }

    @IBAction func refreshTapped(_ sender: Any) {
        A5DeviceManager.scanForDevices {
            self.tableView.reloadData()
        }
    }
}


extension DevicesTableViewController: A5DeviceDelegate {
    func didReceiveIsometric(device: A5Device, value: Double) {
        
    }
    
    func didFailToConnect(device: A5Device, error: Error?) {
        SVProgressHUD.showError(withStatus: "\(device.name ?? "A device") failed to connect")
        self.tableView.reloadData()
    }
    
    func searchCompleted() {
        SVProgressHUD.showInfo(withStatus: "Search Completed")
    }
    
    func deviceFound(device: A5Device) {
        self.tableView.reloadData()
    }
    
    func deviceConnected(device: A5Device) {
        self.tableView.reloadData()
    }
    
    func deviceInitialized(device: A5Device) {
        do {
            try device.startIMU()
        } catch {
            if error as? A5Error == A5Error.imuUnsupported {
                SVProgressHUD.showError(withStatus: "Device doesn't support IMU")
                device.disconnect()
            }
        }
    }
    
    func deviceDisconnected(device: A5Device) {
        self.tableView.reloadData()
    }
    
    
}

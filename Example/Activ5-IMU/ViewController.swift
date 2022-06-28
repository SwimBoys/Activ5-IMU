//
//  ViewController.swift
//  Activ5-IMU
//
//  Created by Martin Kuvandzhiev on 08/07/2019.
//  Copyright (c) 2019 Martin Kuvandzhiev. All rights reserved.
//

import UIKit
import Activ5Device
import Activ5_IMU
import Hamilton
import SVProgressHUD


class ViewController: UIViewController {
    @IBOutlet weak var orientationLabel: UILabel!
    @IBOutlet weak var angleXLabel: UILabel!
    @IBOutlet weak var angleYLabel: UILabel!
    @IBOutlet weak var angleZLabel: UILabel!
    @IBOutlet weak var accelXLabel: UILabel!
    @IBOutlet weak var accelYLabel: UILabel!
    @IBOutlet weak var accelZLabel: UILabel!
    @IBOutlet weak var gyroXLabel: UILabel!
    @IBOutlet weak var gyroYLabel: UILabel!
    @IBOutlet weak var gyroZLabel: UILabel!
    @IBOutlet weak var saveDataSwitch: UISwitch!
    
    
    var orientationProvider = OrientationProvider()
    var startOrientation: Orientation? = nil
    var measuring = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        A5DeviceManager.delegate = self
        A5DeviceManager.scanForDevices {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func calibrateTapped(_ sender: Any) {
        SVProgressHUD.showInfo(withStatus: "Calibrating")
        self.orientationProvider.tare(duration: 1.0) {
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        self.startOrientation = nil
        self.measuring = true
        LocalFileManager.createNewFile()
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        print("Process Noise Scalar: " + orientationProvider.processNoiseScalar.roundedString)
        print("Measurement Noise Scalar: " + orientationProvider.measurementNoiseScalar.roundedString)
        self.measuring = false
        LocalFileManager.writeFile()
    }
}


extension ViewController: A5DeviceDelegate {
    func didReceiveIsometric(device: A5Device, value: Double) {
        
    }
    
    func searchCompleted() {
        
    }
    
    func deviceFound(device: A5Device) {
//        if device.name == "ACTIV5-AC-4706" {
//            A5DeviceManager.connect(device: device.device)
//        }
    }
    
    func deviceConnected(device: A5Device) {
        
    }
    
    func deviceInitialized(device: A5Device) {
        try? device.startIMU()
    }
    
    func didFailToConnect(device: A5Device, error: Error?) {
        
    }
    
    func deviceDisconnected(device: A5Device) {
        
    }

    func didReceiveIMUData(device: A5Device, value: IMUObject) {
        let lastOrientation = self.orientationProvider.update(imuData: value)
        
        if startOrientation == nil {
            startOrientation = lastOrientation
            return
        }
        
        let orientationDifference = self.startOrientation!.getAngularDifferenceInDegrees(with: lastOrientation)
        
        if self.measuring {
            self.orientationLabel.text = orientationDifference.roundedString
            self.angleXLabel.text = lastOrientation.getEulerAngelsDouble()[0].roundedString
            self.angleYLabel.text = lastOrientation.getEulerAngelsDouble()[1].roundedString
            self.angleZLabel.text = lastOrientation.getEulerAngelsDouble()[2].roundedString
            self.accelXLabel.text = value.accelerationX.roundedString
            self.accelYLabel.text = value.accelerationY.roundedString
            self.accelZLabel.text = value.accelerationZ.roundedString
            self.gyroXLabel.text = value.gyroX.roundedString
            self.gyroYLabel.text = value.gyroY.roundedString
            self.gyroZLabel.text = value.gyroZ.roundedString
            LocalFileManager.appendFile(imuObject: value)
        }
    }
}

extension Double {
    var roundedString: String {
        return String(format: "%0.02f", self)
    }
}

# Activ5-IMU

![Swift](https://github.com/ActivBody/Activ5-IMU/workflows/Swift/badge.svg)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Activ5-IMU is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Activ5-IMU'
```

## Use of framework
1. Use A5Device framework
2. Scan for devices
3. Connect to an IMU device
4. Request IMU data using
```swift 
func deviceInitialized(device: A5Device) {
    do {
        try device.startIMU()
    }
    catch {
        print("device doesn't have IMU")
    }
 }
 ```
5. Inside `didReceiveIMUData` function you should implement a function collecting information about the current orientation of the device. 
```swift 
func didReceiveIMUData(device: A5Device, value: IMUObject) {
        let lastOrientation = self.orientationProvider.update(imuData: value)
}
```

If it is needed to calculate angular difference between 2 angles then you can use
```swift 
let orientationDifference = self.startOrientation!.getAngularDifferenceInDegrees(with: lastOrientation)
```
If `startOrientation` has been recorded at some point using `let startOrientation = lastOrientation `

The orientationDifference returns information about the Euler angles in an array. If is needed the information of the X,Y and Z axises to be printed the following code can be used
```swift 
print(lastOrientation.getEulerAngelsDouble()[0]) // x
print(lastOrientation.getEulerAngelsDouble()[1]) // y
print(lastOrientation.getEulerAngelsDouble()[2]) // z
```


## Author

Martin Kuvandzhiev, martinkuvandzhiev@gmail.com

## License

Activ5-IMU is available under the MIT license. See the LICENSE file for more info.

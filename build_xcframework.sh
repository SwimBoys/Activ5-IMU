swift package generate-xcodeproj

xcodebuild archive \
  -project "Activ5-IMU.xcodeproj" \
  -scheme Activ5-IMU-Package \
  -sdk iphoneos \
  -archivePath "archives/ios_devices.xcarchive" \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO
  
xcodebuild archive \
  -project "Activ5-IMU.xcodeproj" \
  -scheme Activ5-IMU-Package \
  -sdk iphonesimulator \
  -archivePath "archives/ios_simulators.xcarchive" \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO
  
xcodebuild archive \
  -project "Activ5-IMU.xcodeproj" \
  -scheme Activ5-IMU-Package \
  -sdk macosx \
  -archivePath "archives/macosx.xcarchive" \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO

xcodebuild -create-xcframework \
  -framework archives/ios_devices.xcarchive/Products/Library/Frameworks/Activ5_IMU.framework \
  -framework archives/ios_simulators.xcarchive/Products/Library/Frameworks/Activ5_IMU.framework \
  -framework archives/macosx.xcarchive/Products/Library/Frameworks/Activ5_IMU.framework \
  -output Activ5-IMU.xcframework

rm -rf "archives"

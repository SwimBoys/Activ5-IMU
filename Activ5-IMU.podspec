#
# Be sure to run `pod lib lint Activ5-IMU.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Activ5-IMU'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Activ5-IMU.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Activbody-ChinaJV/Activ5-IMU'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Martin Kuvandzhiev' => 'martinkuvandzhiev@gmail.com' }
  s.source           = { :git => 'https://github.com/Activbody-ChinaJV/Activ5-IMU.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/**/*.swift'
  
  # s.resource_bundles = {
  #   'Activ5-IMU' => ['Activ5-IMU/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Activ5Device'
   s.dependency 'Hamilton'
end

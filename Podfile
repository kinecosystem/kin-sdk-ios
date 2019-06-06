# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

use_frameworks!
inhibit_all_warnings!

workspace 'KinSDK'

# def pods
#   pod 'KinSDK'
# end

target 'KinSDK' do
  project 'KinSDK/KinSDK.xcodeproj'

  pod 'KinUtil', '0.1.0'
  pod 'Sodium', '0.8.0'
end

target 'KinSDKTests' do
  project 'KinSDK/KinSDK.xcodeproj'

  # pod 'KinSDK', :path => './'
end

target 'KinSDKSampleApp' do
  project 'KinSDKSampleApp/KinSDKSampleApp.xcodeproj'

  pod 'KinSDK', :path => './'
  pod 'KinUtil', '0.1.0'
  pod 'Sodium', '0.8.0'
end
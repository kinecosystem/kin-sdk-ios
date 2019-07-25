use_frameworks!
inhibit_all_warnings!
# install!  'cocoapods', 
#           :generate_multiple_pod_projects => true,  # Cocoapods 1.7.0
#           :incremental_installation => true         # Cocoapods 1.7.0

platform :ios, '9.0'
workspace 'KinSDK'

source 'https://github.com/kinecosystem/kin-util-ios.git'
source 'https://github.com/jedisct1/swift-sodium.git'

abstract_target 'Dependencies' do
  pod 'KinUtil'
  pod 'Sodium'

  target 'KinSDK' do
    project 'KinSDK/KinSDK.xcodeproj'
    target 'KinSDKTests'
  end
  
  target 'KinSDKSampleApp' do
    project 'SampleApps/KinSDKSampleApp/KinSDKSampleApp.xcodeproj'
  end
  
  target 'KinBackupRestoreSampleApp' do
    project 'SampleApps/KinBackupRestoreSampleApp/KinBackupRestoreSampleApp.xcodeproj'
  end
end
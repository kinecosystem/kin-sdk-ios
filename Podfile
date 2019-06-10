use_frameworks!
inhibit_all_warnings!

platform :ios, '9.0'
workspace 'KinSDK'

target 'KinSDK' do
  project 'KinSDK/KinSDK.xcodeproj'

  pod 'KinUtil', '0.1.0'
  pod 'Sodium', '0.8.0'
end

target 'KinSDKTests' do
  project 'KinSDK/KinSDK.xcodeproj'
end

target 'KinSDKSampleApp' do
  project 'SampleApps/KinSDKSampleApp/KinSDKSampleApp.xcodeproj'

  pod 'KinSDK', :path => './'
end

target 'KinBackupRestoreSampleApp' do
  project 'SampleApps/KinBackupRestoreSampleApp/KinBackupRestoreSampleApp.xcodeproj'

  pod 'KinSDK', :path => './'
end
# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

use_frameworks!
inhibit_all_warnings!

workspace 'KinBackupRestoreModule'

def pods
  pod 'KinSDK', '0.8.5'
end

target 'KinBackupRestoreModule' do
  project 'KinBackupRestoreModule/KinBackupRestoreModule.xcodeproj'

  pods
end

target 'KinBackupRestoreModuleTests' do
  project 'KinBackupRestoreModule/KinBackupRestoreModule.xcodeproj'

  pods
end

target 'KinBackupRestoreSampleApp' do
  project 'KinBackupRestoreSampleApp/KinBackupRestoreSampleApp.xcodeproj'

  pod 'KinBackupRestoreModule', :path => './'
end
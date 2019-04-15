Pod::Spec.new do |s|
  s.name         = 'KinBackupRestoreModule'
  s.version      = '0.0.1'
  s.summary      = 'Pod for the Kin Backup and Restore.'
  s.description  = 'Pod for the KinSDK to backup and restore.'
  s.homepage     = 'https://github.com/kinecosystem/kin-sdk-ios/tree/master/KinBackupRestoreModule'
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { 'Kin Foundation' => 'info@kin.org' }
  s.source       = { :git => 'https://github.com/kinecosystem/kin-sdk-ios.git', :tag => "#{s.version}", :submodules => true }

  s.source_files = 'KinBackupRestoreModule/KinBackupRestoreModule/**/*.{strings,swift}'
  s.resources    = 'KinBackupRestoreModule/KinBackupRestoreModule/Assets.xcassets'

  s.dependency 'KinSDK', '0.8.6'

  s.ios.deployment_target = '9.0'
  s.swift_version = "4.2"
  s.platform = :ios, '9.0'
end
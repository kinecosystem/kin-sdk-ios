Pod::Spec.new do |s|
  s.name         = 'KinBackupRestoreModule'
  s.version      = '0.0.1'
  s.summary      = 'Pod for the Kin Backup and Restore.'
  s.description  = 'Pod for the KinSDK to backup and restore.'
  s.homepage     = 'https://github.com/kinecosystem/kin-backup-restore-module-ios'
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { 'Kin Foundation' => 'kin@kik.com' }
  s.source       = { :git => 'https://github.com/kinecosystem/kin-backup-restore-module-ios.git', :tag => "#{s.version}", :submodules => true }

  s.source_files = 'KinBackupRestoreModule/KinBackupRestoreModule/**/*.{strings,swift,xib}'
  s.resources    = 'KinBackupRestoreModule/KinBackupRestoreModule/Assets.xcassets'

  s.dependency 'KinSDK', '0.8.5'

  s.ios.deployment_target = '9.0'
  s.swift_version = "4.2"
  s.platform = :ios, '9.0'
end

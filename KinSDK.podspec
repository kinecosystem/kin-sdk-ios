Pod::Spec.new do |s|
  s.name         = 'KinSDK'
  s.version      = '0.9.1'
  s.summary      = 'Pod for the KIN SDK.'
  s.description  = "Initial pod for the KIN SDK."
  s.homepage     = 'https://github.com/kinecosystem/kin-sdk-ios'
  s.license      = { :type => 'Kin Ecosystem SDK License' }
  s.author       = { 'Kin Foundation' => 'info@kin.org' }
  s.source       = { :git => 'https://github.com/kinecosystem/kin-sdk-ios.git', :tag => "#{s.version}", :submodules => true }

  s.source_files = 'KinSDK/KinSDK/source/*.swift',
                   'KinSDK/KinSDK/source/blockchain/**/*.swift',
                   'KinSDK/KinSDK/source/third-party/SHA256.swift',
                   'KinSDK/KinSDK/source/third-party/keychain-swift/KeychainSwift/*.swift'

  s.dependency 'KinUtil', '0.1.0'
  s.dependency 'Sodium', '0.8.0'

  s.ios.deployment_target = '8.0'
  s.swift_version = "5.0"
  s.platform = :ios, '8.0'
end

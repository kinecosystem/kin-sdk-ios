Pod::Spec.new do |s|
  s.name              = 'KinSDK'
  s.version           = '1.0.2'
  s.license           = { :type => 'Kin Ecosystem SDK License', :file => 'LICENSE.md' }
  s.author            = { 'Kin Foundation' => 'info@kin.org' }
  s.summary           = 'Pod for the Kin SDK.'
  s.homepage          = 'https://github.com/kinecosystem/kin-sdk-ios'
  s.documentation_url = 'https://kinecosystem.github.io/kin-website-docs/docs/quick-start/hi-kin-ios'
  s.social_media_url  = 'https://twitter.com/kin_foundation'
  
  s.platform      = :ios, '9.0'
  s.swift_version = '5.0'

  s.source = { 
    :git => 'https://github.com/kinecosystem/kin-sdk-ios.git', 
    :tag => s.version.to_s,
    :submodules => true
  }
  s.source_files = ['KinSDK/KinSDK/**/*.swift',
                    'KinSDK/ThirdParty/SHA256.swift',
                    'KinSDK/ThirdParty/keychain-swift/KeychainSwift/*.swift']

  s.dependency 'KinUtil', '0.1.0'
  s.dependency 'Sodium', '0.8.0'
end

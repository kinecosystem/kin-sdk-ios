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
    :tag => s.version.to_s
  }
  source_files = ['KinSDK/Core/**/*.swift',
                  'KinSDK/ThirdParty/SHA256.swift',
                  'KinSDK/ThirdParty/keychain-swift/KeychainSwift/*.swift']
  s.source_files = source_files

  s.dependency 'KinUtil', '0.1.0'
  s.dependency 'Sodium', '0.8.0'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = source_files
  end

  s.subspec 'BackupRestore' do |ss|
    root = 'KinSDK/Modules/BackupRestore'

    ss.source_files = root+'/**/*.{strings,swift}'
    ss.resources    = root+'/Assets.xcassets'
    ss.dependency 'KinSDK/Core'
  end
end

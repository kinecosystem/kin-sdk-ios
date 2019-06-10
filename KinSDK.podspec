Pod::Spec.new do |s|
  s.name              = 'KinSDK'
  s.version           = '1.0.0-rc1'
  s.license           = { :type => 'Kin Ecosystem SDK License' }
  s.author            = { 'Kin Foundation' => 'info@kin.org' }
  s.summary           = 'Pod for the Kin SDK.'
  s.homepage          = 'https://github.com/kinecosystem/kin-sdk-ios'
  s.documentation_url = 'https://kinecosystem.github.io/kin-website-docs/docs/quick-start/hi-kin-ios'
  s.social_media_url  = 'https://twitter.com/kin_foundation'
  
  s.platform      = :ios, '9.0'
  s.swift_version = '5.0'
  
  s.source       = { 
    :git => 'https://github.com/kinecosystem/kin-sdk-ios.git', 
    :tag => s.version.to_s
  }
  source_files = 'KinSDK/KinSDK/Core/**/*.swift',
                 'KinSDK/KinSDK/ThirdParty/SHA256.swift',
                 'KinSDK/KinSDK/ThirdParty/keychain-swift/KeychainSwift/*.swift'
  s.source_files = source_files

  s.dependency 'KinUtil', '0.1.0'
  s.dependency 'Sodium', '0.8.0'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = source_files

    ss.test_spec 'Tests' do |sts|
      sts.requires_app_host = true
      sts.source_files = 'KinSDK/KinSDKTests/Core/*.swift'
    end

    ss.app_spec 'SampleApp' do |sas|
      sas.source_files = 'SampleApps/KinSDKSampleApp/**/*'
    end
  end

  s.subspec 'BackupRestore' do |ss|
    ss.source_files = 'KinSDK/KinSDK/Modules/BackupRestore/**/*.{strings,swift}'
    ss.resources = 'KinSDK/KinSDK/Modules/BackupRestore/Assets.xcassets'

    ss.test_spec 'Tests' do |sts|
      sts.requires_app_host = true
      sts.source_files = 'KinSDK/KinSDKTests/Modules/BackupRestore/*.swift'
    end

    ss.app_spec 'SampleApp' do |sas|
      sas.source_files = 'SampleApps/KinBackupRestoreSampleApp/**/*'
    end
  end
end

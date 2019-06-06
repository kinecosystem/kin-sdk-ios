Pod::Spec.new do |s|
  s.name              = 'KinSDK'
  s.version           = '1.0.0'
  s.license           = { :type => 'Kin Ecosystem SDK License' }
  s.author            = { 'Kin Foundation' => 'info@kin.org' }
  s.summary           = 'Pod for the Kin SDK.'
  s.homepage          = 'https://github.com/kinecosystem/kin-sdk-ios'
  s.documentation_url = 'https://kinecosystem.github.io/kin-website-docs/docs/quick-start/hi-kin-ios'
  s.social_media_url  = 'https://twitter.com/kin_foundation'
  
  s.platform      = :ios, '8.0'
  s.swift_version = '5.0'
  
  s.source       = { 
    :git => 'https://github.com/kinecosystem/kin-sdk-ios.git', 
    :tag => s.version.to_s, 
    :submodules => true 
  }
  s.source_files = 'KinSDK/KinSDK/Core/**/*.swift',
                   'KinSDK/KinSDK/ThirdParty/SHA256.swift',
                   'KinSDK/KinSDK/ThirdParty/keychain-swift/KeychainSwift/*.swift'

  s.dependency 'KinUtil', '0.1.0'
  s.dependency 'Sodium', '0.8.0'

  # TODO:
  # s.app_spec 'SampleApp' do |as|
  #   as.source_files = 'KinSampleApp/**/*.swift'
  # end

  # s.test_spec 'Tests' do |ts|
  #   ts.requires_app_host = true
  #   ts.source_files = 'KinSDK/KinSDKTests/*.swift'
  # end

  # s.subspec 'KinBackupRestoreModule' do |ss|
  #   ss.source_files = 'KinBackupRestoreModule/KinBackupRestoreModule/KinBackupRestoreModule'

  #   # ss.dependency 'KinSDK'

  #   # s.test_spec 'Tests' do |sts|
  #   #   sts.requires_app_host = true
  #   #   sts.source_files = 'KinBackupRestoreModule/KinBackupRestoreModule/KinBackupRestoreModuleTests/*.swift'
  #   # end
  # end
end

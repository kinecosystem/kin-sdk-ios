Pod::Spec.new do |s|
  s.name        = "KinUtil"
  s.version     = "0.0.6"
  s.license     = { :type => "MIT" }
  s.homepage    = "https://github.com/kinfoundation/kin-util-ios.git"
  s.summary     = "A framework containing utility classes used by Kin Foundation SDKs."
  s.description = <<-DESC
		KinUtil contains classes used by several Kin Foundation SDKs and apps."
                DESC
  s.author      = { 'Kin Foundation' => 'kin@kik.com' }
  s.source      = { :git => "https://github.com/kinfoundation/kin-util-ios.git", :tag => s.version, :submodules => false }

  s.ios.deployment_target = "8.0"
  s.swift_version = "3.2"

  s.source_files          = 'KinUtil/KinUtil/source/**/*.swift'
end

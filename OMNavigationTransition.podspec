Pod::Spec.new do |s|


  s.name         = "OMNavigationTransition"
  s.version      = "0.0.1"
  s.summary      = "A CocoaPods library written in Swift."
  s.description  = <<-DESC
  This CocoaPods library helps you perform custom navigation background transition written in Swift.
                   DESC

  s.homepage     = "https://github.com/OlivierMrz/Custom-navigation-transition"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Olivier Miserez" => "oliviermiserez@ame.com" }

  s.ios.deployment_target = "13.0"
  s.swift_version = "5.0"

  s.source       = { :git => "https://github.com/OlivierMrz/Custom-navigation-transition.git", :tag => "#{s.version}" }
  s.source_files  = "navigation-custom-transition/**/*.{h,m,swift}"


end
Pod::Spec.new do |s|
  s.name          = "WordPressKit"
  s.version       = "4.5.2-beta.2"
  s.summary       = "WordPressKit offers a clean and simple WordPress.com and WordPress.org API."

  s.description   = <<-DESC
                    This framework encapsulates all of the networking calls and entity parsers required to interact
                    with WordPress.com and WordPress.org endpoints.
                    DESC

  s.homepage      = "https://github.com/wordpress-mobile/WordPressKit-iOS"
  s.license       = "GPLv2"
  s.author        = { "WordPress" => "mobile@automattic.com" }
  s.platform      = :ios, "11.0"
  s.swift_version = '4.2'
  s.source        = { :git => "https://github.com/wordpress-mobile/WordPressKit-iOS.git", :tag => s.version.to_s }
  s.source_files  = 'WordPressKit/**/*.{h,m,swift}'
  s.private_header_files = "WordPressKit/Private/*.h"
  s.requires_arc  = true
  s.header_dir    = 'WordPressKit'

  s.dependency 'Alamofire', '~> 4.7.3'
  s.dependency 'CocoaLumberjack', '~> 3.4'
  s.dependency 'WordPressShared', '~> 1.8.0'
  s.dependency 'NSObject-SafeExpectations', '0.0.3'
  s.dependency 'wpxmlrpc', '0.8.4'
  s.dependency 'UIDeviceIdentifier', '~> 1.1.4'
end

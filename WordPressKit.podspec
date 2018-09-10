Pod::Spec.new do |s|
  s.name          = "WordPressKit"
  s.version       = "1.4.0"
  s.summary       = "WordPressKit offers a clean and simple WordPress.com and WordPress.org API."

  s.description   = <<-DESC
                    This framework encapsulates all of the networking calls and entity parsers required to interact
                    with WordPress.com and WordPress.org endpoints.
                    DESC

  s.homepage      = "http://apps.wordpress.com"
  s.license       = "GPLv2"
  s.author        = { "Jorge Leandro Perez" => "jorge.perez@automattic.com" }
  s.platform      = :ios, "10.0"
  s.swift_version = '4.0'
  s.source        = { :git => "https://github.com/wordpress-mobile/WordPressKit-iOS.git", :tag => s.version.to_s }
  s.source_files  = 'WordPressKit/**/*.{h,m,swift}'
  s.private_header_files = "WordPressKit/Private/*.h"
  s.requires_arc  = true
  s.header_dir    = 'WordPressKit'

  s.dependency 'Alamofire', '~> 4.7'
  s.dependency 'CocoaLumberjack', '3.4.2'
  s.dependency 'WordPressShared', '~> 1.0.3'
  s.dependency 'NSObject-SafeExpectations', '0.0.3'
  s.dependency 'wpxmlrpc', '0.8.3'
  s.dependency 'UIDeviceIdentifier', '~> 0.4'
end

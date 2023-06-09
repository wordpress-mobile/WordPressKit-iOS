# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name          = 'WordPressKit'
  s.version       = '8.3.0-beta.1'

  s.summary       = 'WordPressKit offers a clean and simple WordPress.com and WordPress.org API.'
  s.description   = <<-DESC
                    This framework encapsulates all of the networking calls and entity parsers required to interact
                    with WordPress.com and WordPress.org endpoints.
  DESC

  s.homepage      = 'https://github.com/wordpress-mobile/WordPressKit-iOS'
  s.license       = { type: 'GPLv2', file: 'LICENSE' }
  s.author        = { 'The WordPress Mobile Team' => 'mobile@wordpress.org' }

  s.platform      = :ios, '13.0'
  s.swift_version = '5.0'

  s.source        = { git: 'https://github.com/wordpress-mobile/WordPressKit-iOS.git', tag: s.version.to_s }
  s.source_files  = 'WordPressKit/**/*.{h,m,swift}'
  s.private_header_files = 'WordPressKit/Private/*.h'
  s.header_dir = 'WordPressKit'

  s.dependency 'Alamofire', '~> 4.8.0'
  s.dependency 'NSObject-SafeExpectations', '~> 0.0.4'
  s.dependency 'wpxmlrpc', '~> 0.10'
  s.dependency 'UIDeviceIdentifier', '~> 2.0'

  # Use a loose restriction that allows both production and beta versions, up to the next major version.
  # If you want to update which of these is used, specify it in the host app.
  s.dependency 'WordPressShared', '~> 2.0-beta'
end

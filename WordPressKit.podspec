# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name          = 'WordPressKit'
  s.version       = '13.1.0'

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
  s.source_files  = 'Sources/**/*.{h,m,swift}'
  s.public_header_files = 'Sources/WordPressKit/**/*.h', 'Sources/WordPressKit/WordPressKit.h'
  s.private_header_files = 'Sources/WordPressKit/WordPressAndJetpack/Private/*.h'

  s.dependency 'NSObject-SafeExpectations', '~> 0.0.4'
  s.dependency 'wpxmlrpc', '~> 0.10'
  s.dependency 'UIDeviceIdentifier', '~> 2.0'

  # Use a loose restriction that allows both production and beta versions, up to the next major version.
  # If you want to update which of these is used, specify it in the host app.
  s.dependency 'WordPressShared', '~> 2.0-beta'

  # Test specs disabled because they also use Buildkite's test collector, which is not setup via CocoaPod.
  # https://github.com/buildkite/test-collector-swift
  #
  # s.test_spec do |test_spec|
  #   test_spec.source_files = 'Tests/WordPressKitTests'

  #   test_spec.dependency 'OHHTTPStubs', '~> 9.0'
  #   test_spec.dependency 'OHHTTPStubs/Swift', '~> 9.0'
  #   test_spec.dependency 'OCMock', '~> 3.4'
  #   test_spec.dependency 'Alamofire', '~> 5.0'
  # end

  s.subspec 'CoreAPI' do |subspec|
    subspec.source_files = 'Sources/CoreAPI'

    # Currently failing during `lib lint`.
    # Will need to followup.
    #
    # subspec.test_spec do |test_spec|
    #   test_spec.source_files = 'Tests/CoreAPITests'
    #   test_spec.dependency 'OHHTTPStubs', '~> 9.0'
    #   test_spec.dependency 'OHHTTPStubs/Swift', '~> 9.0'
    #   test_spec.dependency 'Alamofire', '~> 5.0'
    # end
  end
end

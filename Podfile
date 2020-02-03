source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

platform :ios, '11.0'

def wordpresskit_pods
  pod 'Alamofire', '~> 4.7.3'
  pod 'CocoaLumberjack', '3.4.2'
  pod 'WordPressShared', '~> 1.8.13-beta'
  # pod 'WordPressShared', :git => 'https://github.com/wordpress-mobile/WordPress-iOS-Shared.git', :commit  => 'efe5a065f3ace331353595ef85eef502baa23497'
  pod 'NSObject-SafeExpectations', '~> 0.0.3'
  pod 'wpxmlrpc', '0.8.4'
  pod 'UIDeviceIdentifier', '~> 1'
end

## WordPress Kit
## =============
##
target 'WordPressKit' do
  project 'WordPressKit.xcodeproj'
  wordpresskit_pods
end

target 'WordPressKitTests' do
  project 'WordPressKit.xcodeproj'
  wordpresskit_pods

  pod 'OHHTTPStubs', '6.1.0'
  pod 'OHHTTPStubs/Swift', '6.1.0'
  pod 'OCMock', '~> 3.4.2'
end

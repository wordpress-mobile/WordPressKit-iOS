source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

platform :ios, '11.0'

def wordpresskit_pods
  pod 'Alamofire', '~> 4.8.0'
  pod 'CocoaLumberjack', '3.4.2'
  pod 'WordPressShared', '~> 1.10-beta'
  pod 'NSObject-SafeExpectations', '~> 0.0.4'
  pod 'wpxmlrpc', '0.8.5'
  #pod 'wpxmlrpc', :git => 'https://github.com/wordpress-mobile/wpxmlrpc.git', :branch => 'feature/update-xcode-settings'
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

  pod 'OHHTTPStubs', '9.0'
  pod 'OHHTTPStubs/Swift', '9.0'
  pod 'OCMock', '~> 3.4.2'
end

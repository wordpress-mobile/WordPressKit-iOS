# frozen_string_literal: true

source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

platform :ios, '13.0'

def wordpresskit_pods
  pod 'Alamofire', '~> 5.6.0'
  pod 'WordPressShared', '~> 2.0.0-beta.2'
  pod 'NSObject-SafeExpectations', '~> 0.0.4'
  pod 'wpxmlrpc', '~> 0.10.0'
  pod 'UIDeviceIdentifier', '~> 2.0'
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

  pod 'OHHTTPStubs', '~> 9.0'
  pod 'OHHTTPStubs/Swift', '~> 9.0'
  pod 'OCMock', '~> 3.4'
end

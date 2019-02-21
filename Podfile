source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

platform :ios, '10.0'
plugin 'cocoapods-repo-update'

## WordPress Kit
## =============
##
target 'WordPressKit' do
  pod 'Alamofire', '~> 4.7.3'
  pod 'CocoaLumberjack', '3.4.2'
  pod 'WordPressShared', '~> 1.4'
  pod 'NSObject-SafeExpectations', '~> 0.0.3'
  pod 'wpxmlrpc', '0.8.4'
  pod 'UIDeviceIdentifier', '~> 1.1.4'

  target 'WordPressKitTests' do
    inherit! :search_paths

    pod 'OHHTTPStubs', '6.1.0'
    pod 'OHHTTPStubs/Swift', '6.1.0'
    pod 'OCMock', '~> 3.4.2'
    pod 'WordPressShared', '~> 1.4'
  end
end

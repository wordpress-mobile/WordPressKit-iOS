source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

platform :ios, '10.0'


## WordPress Kit
## =============
##
target 'WordPressKit' do
  project 'WordPressKit.xcodeproj'

  pod 'AFNetworking', '3.2.1'
  pod 'Alamofire', '4.7.2'
  pod 'CocoaLumberjack', '3.4.2'
  pod 'WordPressShared', '1.0.1'
  pod 'wpxmlrpc', '0.8.3'
  pod 'UIDeviceIdentifier', '~> 0.4'

  target 'WordPressKitTests' do
    inherit! :search_paths

    pod 'OHHTTPStubs', '6.1.0'
    pod 'OHHTTPStubs/Swift', '6.1.0'
    pod 'OCMock', '~> 3.4'
  end
end
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

platform :ios, '10.0'
plugin 'cocoapods-repo-update'

def wordpress_kit
  pod 'WordPressKit', :path => './'
end

## WordPress Kit
## =============
##
target 'WordPressKit' do
  wordpress_kit
end

## WordPress Kit Tests
## ===================
##
target 'WordPressKitTests' do
  wordpress_kit
  pod 'OHHTTPStubs', '6.1.0'
  pod 'OHHTTPStubs/Swift', '6.1.0'
  pod 'OCMock', '~> 3.4.2'
end

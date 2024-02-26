# frozen_string_literal: true

source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

APP_IOS_DEPLOYMENT_TARGET = Gem::Version.new('13.0')

platform :ios, APP_IOS_DEPLOYMENT_TARGET

def swiftlint_version
  require 'yaml'

  YAML.load_file('.swiftlint.yml')['swiftlint_version']
end

def wordpresskit_pods
  pod 'Alamofire', '~> 4.8.0'
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

abstract_target 'Tools' do
  pod 'SwiftLint', swiftlint_version
end

# Let Pods targets inherit deployment target from the app
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      ios_deployment_key = 'IPHONEOS_DEPLOYMENT_TARGET'
      pod_ios_deployment_target = Gem::Version.new(configuration.build_settings[ios_deployment_key])
      configuration.build_settings.delete(ios_deployment_key) if pod_ios_deployment_target <= APP_IOS_DEPLOYMENT_TARGET
    end
  end

  yellow_marker = "\033[33m"
  reset_marker = "\033[0m"
  puts "#{yellow_marker}The abstract target warning below is expected. Feel free to ignore
 it.#{reset_marker}"
end

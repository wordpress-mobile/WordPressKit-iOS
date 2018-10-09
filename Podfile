source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

platform :ios, '10.0'


## WordPress Kit
## =============
##
target 'WordPressKit' do
  pod "WordPressKit", :path => "./"

  target 'WordPressKitTests' do
    inherit! :search_paths

    pod 'OHHTTPStubs', '6.1.0'
    pod 'OHHTTPStubs/Swift', '6.1.0'
    pod 'OCMock', '~> 3.4.2'
    pod 'WordPressShared', '1.1.1-beta.4'
  end
end

ROOT="./.build/xcframeworks"

rm -rf $ROOT

for SDK in iphoneos iphonesimulator
do
xcodebuild archive \
    -workspace WordPressKit.xcworkspace \
    -scheme WordPressKit \
    -archivePath "$ROOT/WordPressKit-$SDK.xcarchive" \
    -sdk $SDK \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    DEBUG_INFORMATION_FORMAT=DWARF
done

xcodebuild -create-xcframework \
    -framework "$ROOT/WordPressKit-iphoneos.xcarchive/Products/Library/Frameworks/WordPressKit.framework" \
    -framework "$ROOT/WordPressKit-iphonesimulator.xcarchive/Products/Library/Frameworks/WordPressKit.framework" \
    -output "$ROOT/WordPressKit.xcframework"

cd $ROOT
zip -r -X WordPressKit.zip *.xcframework
rm -rf *.xcframework

swift package compute-checksum WordPressKit.zip
cd -

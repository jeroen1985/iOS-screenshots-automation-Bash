#!/bin/bash
#Ask user input if login required for app
echo "Please provide your login information:"
read -e -p "Enter your username: " USR
read -e -s -p "Enter your password: " PASS

echo -e "\n\nPlease provide a unique security pass phrase:"
read -e -s -p "Phrase: " SECURITY

echo -e "\nPath to your xcode project"
read -e -p "Please enter the path to your xcode project (e.g. /Users/jstevens/app/name.xcodeproj):" PROJECT

#encrypt username and password using pass phrase
USERNAME=$(echo $USR | openssl aes-256-cbc -a -salt -pass pass:$SECURITY)
PASSWORD=$(echo $PASS | openssl aes-256-cbc -a -salt -pass pass:$SECURITY)

#configuration
ARCH="i386"
VALID_ARCHS_CONF="i386 armv7 armv7s"
PROJECT_PATH="$PROJECT"
CONFIGURATION="Debug"
SDK_VERSION="8.1"
SDK="iphonesimulator8.1"
SCHEME="ToDoList"
SCRIPT_NAME="screenshots.js"
#In case of app with authentication
#SCRIPT_NAME="auth_screenshots.js"
APP_NAME="screenshots"
BUILD_PATH="/Users/jstevens/apple/generic_version"
SCRIPT_LOCATION="/Users/jstevens/apple/generic_version"
IMAGE_LOCATION="/Users/jstevens/app/images"
declare -a PHONE_NAME=("iPhone 5s ($SDK_VERSION Simulator)" "iPhone 6 ($SDK_VERSION Simulator)" "iPhone 6 Plus ($SDK_VERSION Simulator)" "iPad 2 ($SDK_VERSION Simulator)")
declare -a PHONE_FOLDER=('iphone5' 'iphone6' 'iphone6plus' 'ipad2')

#--dynamically load simulators udid--#
z=0
for i in "${PHONE_NAME[@]}"
do
	temp=$(echo $i)
	udid=$(instruments -s devices | grep "$temp" | awk -F'[' '{print $2}' | cut -d']' -f1)
	PHONE_UDID+=($udid)
done

echo ${PHONE_UDID[@]}

#structure image folder if it doesn't already exists
if [ ! -d "$IMAGE_LOCATION" ]; then
	for folder in "${PHONE_FOLDER[@]}"
	do
		mkdir -p $IMAGE_LOCATION/$folder
	done
fi

#build the app for the simulator first
xcodebuild TARGET_NAME=$APP_NAME CONFIGURATION_BUILD_DIR=$BUILD_PATH ARCHS=$ARCH VALID_ARCHS="$VALID_ARCHS_CONF" -arch $ARCH -project $PROJECT_PATH -configuration $CONFIGURATION -sdk $SDK
echo "Building app for simulator..."
echo "Build Directory:"
echo $BUILD_PATH

#kill all simulators
killall "iOS Simulator"

#reset simulator first
instruments -s devices | grep Simulator | grep -o "[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}" \
 | while read -r line ; do
    xcrun simctl erase $line
done

#add in temp file (bug in instruments workaround)
echo -e "var username = \"$USERNAME\"; \nvar password = \"$PASSWORD\";"> $SCRIPT_LOCATION/tmp.js
echo -e "var security = \"$SECURITY\";" > $SCRIPT_LOCATION/_tmp_.js

echo $SCRIPT_LOCATION/$SCRIPT_NAME

#create screenshots
y=0
for i in "${PHONE_NAME[@]}"
do
	xcrun instruments -w "${PHONE_NAME[$y]}"
	xcrun instruments -t /Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.xrplugin/Contents/Resources/Automation.tracetemplate -w ${PHONE_UDID[$y]} $BUILD_PATH/$APP_NAME.app -e UIASCRIPT $SCRIPT_LOCATION/$SCRIPT_NAME -D $SCRIPT_LOCATION -e UIARESULTSPATH $IMAGE_LOCATION/${PHONE_FOLDER[$y]}/ 2> /dev/null
	((y++))
	sleep 5
done

killall "iOS Simulator"

#remove credentials
rm $SCRIPT_LOCATION/tmp.js
rm $SCRIPT_LOCATION/_tmp_.js

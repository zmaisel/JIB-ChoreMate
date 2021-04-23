
# JIB-ChoreMate 

# Release Notes

This is the initial release of the app ChoreMate

Features include:
- Editable Chore List
- Calendar
- Reminders
- User Data 

# Known bugs:
- No known bugs

# Missing functionality:
- Chores have no repeating functionality (this functionality proved to be complex as we needed to keep track of time, we prioritized other functionality that we decided was more important to the initial release of our app)
- Initially, our goal was to implement push notifications. We could not figure out a way to implement these as we are not licensed apple developers, thus we regrouped and implemented internal reminders instead. The functionality exists, it is just different than our initial plan

# Install Guide
Our app has not been published to the Apple App Store nor the Google Play Store. As a result, to use our app, you must download Flutter and manually load the app on your phone. The steps are provided by Flutter in their documentation which can be found below. 

# Pre-requisites

- Flutter version 1.22.5
- Xcode version 12.3 for iOS
- Android Studio version 4.1.2
steps to download and set up the entire enviornment can be found below provided by Flutter

# iOS
To run the iOS app, a mac running macOS(64-bit) is required along with 2.8 GB of free space. XCode is also required. Details for downloading XCode are provided in the documentation provided by flutter, but XCode can be downloaded straight from the App Store on the Mac device. 
please see the following documentation provided by Flutter to install flutter

  https://flutter.dev/docs/get-started/install/macos
  
- Follow all of the steps provided in the documentation linked above until reaching the step "Set up the iOS simulator" 
- Skip "Set up the iOS simulator" and "Create and run a simple Flutter app"
- At this point, clone this repo and then proceede with the steps in "Deploy to iOS device"
- *note you will need to install cocoapods which is an optional step listed
- After following these steps, you should be able to use the app on your iOS device. 

# Android
The android app can be set up from either a Mac(running macOS 64 bit) device or a Windows device(running windows 7 64-bit or newer). 
please see the following documentation provided by Flutter to install flutter

for macOS: 

https://flutter.dev/docs/get-started/install/macos
- Follow all of the steps provided until reaching the iOS set up steps. At this point, skip down to Android setup. 
- Clone this repo then
- Follow the steps in Android set up, but stopping before the Android emulator. 

for windows: 

https://flutter.dev/docs/get-started/install/windows
- Follow all of the steps provided until reaching the Android emulator. 
- After installing flutter but before setting up the Android device, be sure to clone this repo, and then resume with the steps.

# Troubleshooting

The initial build can sometimes take up to 10 minutes. Allow time for the app to build and minimize other programs running on your computer. 





# Kintone-iOS-SDK Test Automation Project

[![Swift Version](https://img.shields.io/badge/Swift-4.2.x-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/cocoapods/p/FacebookCore.svg)](https://cocoapods.org/pods/kintone-ios-sdk)


## Overview

- Kintone-iOS-SDK Test Automation are using [Quick](https://github.com/Quick/Quick) and [Nimble](https://github.com/Quick/Nimble) as frameworks and [Fastlane](https://github.com/fastlane/fastlane) as tool to automate tasks



### System Requirements
- Install [CocoaPods](https://cocoapods.org) or [Carthage](https://github.com/carthage/carthage)
- Swift 4.2 or late
- Minimum iOS Deployment Target 11.4
- Setup [Kintone-iOS-SDK Project](https://github.com/cybozu-tevn/kintone-ios-sdk/blob/testing_structure/README.md) complete



## Test automation preparation

### Install Quick and Nimble
- Edit `Cartfile` and add new line .
```bash
github "Quick/Quick"
github "Quick/Nimble"
```

- Run `carthage update`.


### Install Fastlane
- Run `brew cask install fastlane`



## Execute test command

### Run all test script
- Run all tests and generate report in html format (by default)
```bash
fastlane test
```

- Run all tests and generate report in junit format
```bash
fastlane test junit:true
```


### Run test module
- Run test for specific modules (Eg: record, file) and generate report in html format
```bash
fastlane test test_modules:"record,file" html:true
```

- Run test for specific modules (Eg: app, bulkrequest) and generate report in in junit format
```bash
fastlane test test_modules:"app,bulkrequest" junit:true`
```


### Run test class
- Run test for specific test classes (Eg: GetAppTest, GetRecordTest) and generate report in html format
```bash
fastlane test test_classes:"GetAppTest,GetRecordTest" html:true
```

- Run test for specific test classes (Eg: GetAppTest, GetRecordTest) and generate report in junit format
```bash
fastlane test test_classes:"AddRecordTest,GetRecordTest" junit:true
```



## Contribute

All of Kintone iOS SDK Automation Test for Swift development happens on GitHub.

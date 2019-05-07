//
//  TestCommonHandling.swift
//  kintone-ios-sdkTests
//
//  Created by Vu Tran on 5/6/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import XCTest
@testable import Promises
@testable import kintone_ios_sdk

class TestCommonHandling {
    static func createConnection(_ username: String = TestsConstants.ADMIN_USERNAME, _ password: String = TestsConstants.ADMIN_PASSWORD) -> Connection {
        let auth = Auth.init().setPasswordAuth(username, password)
        let conn = Connection(TestsConstants.DOMAIN , auth)
        return conn
    }
    
    static func createConnection(_ apiToken: String) -> Connection {
        let auth = Auth.init().setApiToken(apiToken)
        let conn = Connection(TestsConstants.DOMAIN , auth)
        return conn
    }
    
    static func createConnection(_ username: String, _ password: String, _ guestSpaceId: Int) -> Connection {
        let auth = Auth.init().setPasswordAuth(username, password)
        let conn = Connection(TestsConstants.DOMAIN , auth, guestSpaceId)
        return conn
    }
    
    static func getErrorMessage(_ error: Any) -> String {
        if error is KintoneAPIException {
            return (error as! KintoneAPIException).toString()!
        } else {
            return (error as! Error).localizedDescription
        }
    }
    
    static func awaitAsync<T>(_ promise: Promise<T>) -> Any{
        let xcTestCase = XCTestCase()
        let expectation = xcTestCase.expectation(description: "Async call")
        var response: Any? = nil
        var errorVal: Any? = nil
        
        promise.then { asyncResult in
            response = asyncResult
            expectation.fulfill()
            }.catch{error in
                errorVal = error
                expectation.fulfill()
        }
        //        xcTestCase.waitForExpectations(timeout: Double(TestsConstants.WAIT_FOR_PROMISE_TIMEOUT))
        xcTestCase.waitForExpectations(timeout: 30)
        
        if(response != nil){
            return response as Any
        }
        return errorVal as Any
    }
    
    static func waitForDeployAppSuccess(appModule: App, appId: Int) {
        var flag = true
        while (flag) {
            appModule.getAppDeployStatus([appId])
                .then {response in
                    let status = response.getApps()![0].getStatus()?.rawValue
                    if(status == "SUCCESS"){
                        print("Deploy app \(response.getApps()![0].getApp()!) SUCCESS")
                        flag = false
                    } else {
                        print("Status deploy app \(response.getApps()![0].getApp()!): \(status!)")
                    }
                }.catch {error in
                    if let errorVal = error as? KintoneAPIException {
                        fatalError(errorVal.toString()!)
                    } else {
                        fatalError(error.localizedDescription)
                    }
            }
            _ = waitForPromises(timeout: TestsConstants.WAIT_FOR_PROMISE_TIMEOUT)
        }
    }
    
    static func deployApp(appModule: App, apps: [PreviewApp]) {
        var appIds = [Int]()
        appModule.deployAppSettings(apps)
            .then {
                for app in apps {
                    appIds.append(app.getApp()!)
                    print("Deploy app: \(app.getApp()!)")
                }
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestsConstants.WAIT_FOR_PROMISE_TIMEOUT)
        
        for id in appIds {
            self.waitForDeployAppSuccess(appModule: appModule, appId: id)
        }
    }
    
    static func createApp(appModule: App, appName: String = "Test App",  spaceId: Int? = nil, threadId: Int? = nil) -> Int {
        var apps = [PreviewApp]()
        var appId: Int!
        appModule.addPreviewApp(appName, spaceId, threadId)
            .then{response in
                apps.append(response)
                appId = response.getApp()
                print("Create app: \(response.getApp()!)")
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestsConstants.WAIT_FOR_PROMISE_TIMEOUT)
        self.deployApp(appModule: appModule, apps: apps)
        return appId
    }
    
    public static func handleDoTryCatch<T>(closure:() throws -> T) -> Any {
        do {
            let result = try closure()
            return result
        } catch let error {
            dump(error)
            return error
        }
    }
    
    public static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    public static func addData(_ recordData: Dictionary<String, FieldValue>, _ code: String, _ type: FieldType, _ value: Any) -> Dictionary<String, FieldValue> {
        var recData = recordData
        let field = FieldValue()
        field.setType(type)
        field.setValue(value)
        recData[code] = field
        return recData
    }
}

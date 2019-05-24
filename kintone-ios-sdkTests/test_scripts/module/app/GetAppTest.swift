//
//  GetApp.swift
//  kintone-ios-sdkTests
//
//  Created by Vu Tran on 5/6/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppTest: QuickSpec {
    override func spec() {
        let app = App(TestCommonHandling.createConnection())
        let appName = "App Name"
        var appId: Int?
        
        //        let json = "{ \"people\": [{ \"firstName\": \"Paul\", \"lastName\": \"Hudson\", \"isAlive\": true }, { \"firstName\": \"Angela\", \"lastName\": \"Merkel\", \"isAlive\": true }, { \"firstName\": \"George\", \"lastName\": \"Washington\", \"isAlive\": false } ] }"
        //        let kintoneErrFilePath = Bundle(identifier: "com.myframework")!.path(forResource: "KintoneErrorMessage", ofType: "json")!
        //        let fileContents = try? String(contentsOfFile: kintoneErrFilePath, encoding: String.Encoding.utf8)
        
        beforeSuite {
            print("=== TEST PREPARATION ===")
            appId = AppUtils.createApp(appModule: app, appName: appName)
        }
        
        afterSuite {
            print("=== TEST CLEANING UP ===")
            AppUtils.deleteApp(appId: appId!)
        }
        
        describe("GetAppTest") {
            
            it("Success Case 1") {
                //                if let data = fileContents?.data(using: .utf8) {
                //                    if let json = try? JSON(data: data) {
                //                        //for item in json["API_TOKEN_ERROR"]["code"].stringValue {
                //                        //print(item["firstName"].stringValue)
                //                        //}
                //                        print(json["API_TOKEN_ERROR"]["code"].stringValue)
                //                    }
                //                }
                
                let getAppRsp = TestCommonHandling.awaitAsync(app.getApp(appId!)) as! AppModel
                expect(getAppRsp.getAppId()).to(equal(appId))
                expect(getAppRsp.getName()).to(equal(appName))
                expect(getAppRsp.getCode()).to(equal(""))
                expect(getAppRsp.getCreator()?.getName()).to(equal(TestConstant.Connection.ADMIN_USERNAME))
                expect(getAppRsp.getSpaceId()).to(beNil())
                expect(getAppRsp.getThreadId()).to(beNil())
                
            }
        }
    }
}

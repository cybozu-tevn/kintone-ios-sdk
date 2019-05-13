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

class GetAppTest: QuickSpec{
    override func spec(){
        let app = App(TestCommonHandling.createConnection())
        let appName = "App Name"
        var appId: Int?
        
        beforeSuite {
            print("=== TEST PREPARATION ===")
            appId = AppUtils.createApp(appModule: app, appName: appName)
        }
        
        afterSuite {
            print("=== TEST CLEANING UP ===")
            AppUtils.deleteApp(appId: appId!)
        }
        
        describe("GetAppTest"){
   
            it("Success Case 1"){
                
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

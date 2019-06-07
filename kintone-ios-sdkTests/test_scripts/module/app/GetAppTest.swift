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
        
        beforeSuite {
            print("=== TEST PREPARATION ===")
            appId = AppUtils.createApp(appModule: app, appName: appName)
        }
        
        afterSuite {
            print("=== TEST CLEANING UP ===")
            AppUtils.deleteApp(appId: appId!)
        }
        
        describe("GetAppTest") {
            
            it("test_003_SuccessWithApiToken") {
                let apiToken = AppUtils.generateApiToken(app, appId!)
                let tokenPermission  = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: app, appId: appId!, token: tokenPermission)
                
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                let getAppRsp = TestCommonHandling.awaitAsync(appModule.getApp(appId!)) as! AppModel
                
                expect(getAppRsp.getAppId()).to(equal(appId))
                expect(getAppRsp.getName()).to(equal(appName))
                expect(getAppRsp.getCode()).to(equal(""))
                expect(getAppRsp.getCreator()?.getName()).to(equal(TestConstant.Connection.ADMIN_USERNAME))
                expect(getAppRsp.getSpaceId()).to(beNil())
                expect(getAppRsp.getThreadId()).to(beNil())
            }
            
            it("test_004_Success") {
                let getAppRsp = TestCommonHandling.awaitAsync(app.getApp(appId!)) as! AppModel
                expect(getAppRsp.getAppId()).to(equal(appId))
                expect(getAppRsp.getName()).to(equal(appName))
                expect(getAppRsp.getCode()).to(equal(""))
                expect(getAppRsp.getCreator()?.getName()).to(equal(TestConstant.Connection.ADMIN_USERNAME))
                expect(getAppRsp.getSpaceId()).to(beNil())
                expect(getAppRsp.getThreadId()).to(beNil())
            }
            
            it("test_004_Success_With_GuesSpaceApp") {
                // Test setting up
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD, TestConstant.Connection.GUEST_SPACE_ID))
                let guestAppId = AppUtils.createApp(appModule: guestAppModule, appName: appName, spaceId: TestConstant.Connection.GUEST_SPACE_ID, threadId: TestConstant.Common.GUEST_SPACE_THREAD_ID)
                
                let getAppRsp = TestCommonHandling.awaitAsync(guestAppModule.getApp(guestAppId)) as! AppModel
                expect(getAppRsp.getAppId()).to(equal(guestAppId))
                expect(getAppRsp.getName()).to(equal(appName))
                expect(getAppRsp.getCode()).to(equal(""))
                expect(getAppRsp.getCreator()?.getName()).to(equal(TestConstant.Connection.ADMIN_USERNAME))
                expect(getAppRsp.getSpaceId()).to(equal(TestConstant.Connection.GUEST_SPACE_ID))
                expect(getAppRsp.getThreadId()).to(equal(TestConstant.Common.GUEST_SPACE_THREAD_ID))
                
                // Test cleaning up
                AppUtils.deleteApp(appId: guestAppId)
            }
            
            it("test_005_FailedWithInvalidAppId") {
                let invalidAppId = 9999 // non-existed appId
                let getAppRsp = TestCommonHandling.awaitAsync(app.getApp(invalidAppId)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()
                expectedError?.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(invalidAppId))
                TestCommonHandling.compareError(getAppRsp.getErrorResponse()!, expectedError!)
            }
        }
    }
}

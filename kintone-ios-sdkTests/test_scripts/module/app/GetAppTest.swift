//
// kintone-ios-sdkTests
// Created on 5/10/19
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
        
        describe("GetApp") {
            
            it("Test_003_Success_ApiToken") {
                let apiToken = AppUtils.generateApiToken(app, appId!)
                let tokenPermission  = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: app, appId: appId!, token: tokenPermission)
                
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                let getAppRsp = TestCommonHandling.awaitAsync(appModule.getApp(appId!)) as! AppModel
                
                expect(getAppRsp.getAppId()).to(equal(appId))
                expect(getAppRsp.getName()).to(equal(appName))
                expect(getAppRsp.getCode()).to(equal(""))
                expect(getAppRsp.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                expect(getAppRsp.getSpaceId()).to(beNil())
                expect(getAppRsp.getThreadId()).to(beNil())
            }
            
            it("Test_004_Success") {
                let getAppRsp = TestCommonHandling.awaitAsync(app.getApp(appId!)) as! AppModel
                expect(getAppRsp.getAppId()).to(equal(appId))
                expect(getAppRsp.getName()).to(equal(appName))
                expect(getAppRsp.getCode()).to(equal(""))
                expect(getAppRsp.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                expect(getAppRsp.getSpaceId()).to(beNil())
                expect(getAppRsp.getThreadId()).to(beNil())
            }
            
            it("Test_004_Success_GuesSpace") {
                // Test setting up
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, TestConstant.InitData.GUEST_SPACE_ID!))
                let guestAppId = AppUtils.createApp(appModule: guestAppModule, appName: appName, spaceId: TestConstant.InitData.GUEST_SPACE_ID, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID)
                
                let getAppRsp = TestCommonHandling.awaitAsync(guestAppModule.getApp(guestAppId)) as! AppModel
                expect(getAppRsp.getAppId()).to(equal(guestAppId))
                expect(getAppRsp.getName()).to(equal(appName))
                expect(getAppRsp.getCode()).to(equal(""))
                expect(getAppRsp.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                expect(getAppRsp.getSpaceId()).to(equal(TestConstant.InitData.GUEST_SPACE_ID))
                expect(getAppRsp.getThreadId()).to(equal(TestConstant.InitData.GUEST_SPACE_THREAD_ID))
                
                // Test cleaning up
                AppUtils.deleteApp(appId: guestAppId)
            }
            
            it("Test_005_Error_InvalidAppId") {
                let invalidAppId = 9999 // non-existed appId
                let getAppRsp = TestCommonHandling.awaitAsync(app.getApp(invalidAppId)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()
                expectedError?.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(invalidAppId))
                TestCommonHandling.compareError(getAppRsp.getErrorResponse()!, expectedError!)
            }
        }
    }
}

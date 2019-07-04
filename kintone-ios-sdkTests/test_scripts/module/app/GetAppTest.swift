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
        let appModule = App(TestCommonHandling.createConnection())
        let appInfo = TestConstant.InitData.apps.appInSpace[0]
        let appId = Int(appInfo.appId)!
        
        describe("GetApp") {
            it("Test_003_Success_ApiToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(String(appInfo.apiToken.fullPermission)))
                let getAppRsp = TestCommonHandling.awaitAsync(appModuleApiToken.getApp(appId)) as! AppModel
                
                expect(getAppRsp.getAppId()).to(equal(Int(appInfo.appId)!))
                expect(getAppRsp.getName()).to(equal(appInfo.name))
                expect(getAppRsp.getCode()).to(equal(appInfo.code))
                expect(getAppRsp.getDescription()).to(equal(appInfo.description))
                expect(getAppRsp.getCreator()?.getName()).to(equal(appInfo.creator.name))
                expect(getAppRsp.getSpaceId()).to(equal(Int(appInfo.spaceId)))
                expect(getAppRsp.getThreadId()).to(equal(Int(appInfo.threadId)))
            }
            
            it("Test_004_Success") {
                let getAppRsp = TestCommonHandling.awaitAsync(appModule.getApp(appId)) as! AppModel
                
                expect(getAppRsp.getAppId()).to(equal(Int(appInfo.appId)!))
                expect(getAppRsp.getName()).to(equal(appInfo.name))
                expect(getAppRsp.getCode()).to(equal(appInfo.code))
                expect(getAppRsp.getDescription()).to(equal(appInfo.description))
                expect(getAppRsp.getCreator()?.getName()).to(equal(appInfo.creator.name))
                expect(getAppRsp.getSpaceId()).to(equal(Int(appInfo.spaceId)))
                expect(getAppRsp.getThreadId()).to(equal(Int(appInfo.threadId)))
            }
            
            it("Test_004_Success_GuestSpace") {
                let guestSpaceAppInfo = TestConstant.InitData.apps.appInGuestSpace[0]
                let guestSpaceAppId = Int(guestSpaceAppInfo.appId)!
                let appModuleGuestSpace = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                
                let getAppRsp = TestCommonHandling.awaitAsync(appModuleGuestSpace.getApp(guestSpaceAppId)) as! AppModel
                expect(getAppRsp.getAppId()).to(equal(guestSpaceAppId))
                expect(getAppRsp.getName()).to(equal(guestSpaceAppInfo.name))
                expect(getAppRsp.getCode()).to(equal(guestSpaceAppInfo.code))
                expect(getAppRsp.getDescription()).to(equal(guestSpaceAppInfo.description))
                expect(getAppRsp.getCreator()?.getName()).to(equal(guestSpaceAppInfo.creator.name))
                expect(getAppRsp.getSpaceId()).to(equal(Int(guestSpaceAppInfo.spaceId)))
                expect(getAppRsp.getThreadId()).to(equal(Int(guestSpaceAppInfo.threadId)))
            }
            
            it("Test_005_Error_InvalidAppId") {
                let invalidAppId = 9999 // non-existed appId
                let result = TestCommonHandling.awaitAsync(appModule.getApp(invalidAppId)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(invalidAppId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

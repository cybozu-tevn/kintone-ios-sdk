//
// kintone-ios-sdkTests
// Created on 6/27/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetFormLayoutTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let appId = TestConstant.InitData.SPACE_APP_ID!
        let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
        
        describe("GetFormLayout") {
            it("Test_015_Error_ApiToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.getFormLayout(appId)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_016_017_Success") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormLayout(appId)) as! FormLayout
                
                expect(result.getLayout()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
            }
            
            it("Test_16_Success_GuestSpace") {
                let appModuleGuestSpace = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormLayout(guestSpaceAppId)) as! FormLayout
                
                expect(result.getLayout()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
            }
            
            it("Test_019_Success_IsPreviewTrue") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormLayout(appId, true)) as! FormLayout
                
                expect(result.getLayout()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
            }
            
            it("Test_020_Success_IsPreviewFalse") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormLayout(appId, false)) as! FormLayout
                
                expect(result.getLayout()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
            }
            
            it("Test_021_Error_NegativeAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormLayout(TestConstant.Common.NEGATIVE_ID, false)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_025_Error_PermissionDenied") {
                let appModuleWithoutPermission = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(appModuleWithoutPermission.getFormLayout(appId)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

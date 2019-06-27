///**
/**
 kintone-ios-sdkTests
 Created on 6/27/19
*/

import Foundation
import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetFormLayoutTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let APP_ID = TestConstant.InitData.SPACE_APP_ID!
        let GUEST_SPACE_APP_ID = TestConstant.InitData.GUEST_SPACE_APP_ID!
        
        describe("GetFormLayout") {
            it("Test_015_ApiToken_FailedWithApiToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.getFormLayout(APP_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_016_017_Success") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormLayout(APP_ID)) as! FormLayout
                expect(result.getLayout()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
            }
            
            it("Test_16_GuestSpace_Success") {
                let appModuleGuestSpace = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormLayout(GUEST_SPACE_APP_ID)) as! FormLayout
                expect(result.getLayout()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
            }
            
            it("Test_019_Success_WithIsPreviewTrue") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormLayout(APP_ID, true)) as! FormLayout
                expect(result.getLayout()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
            }
            
            it("Test_020_Success_WithIsPreviewFalse") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormLayout(APP_ID, false)) as! FormLayout
                expect(result.getLayout()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
            }
            
            it("Test_021_Error_FailedWithNegativeAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormLayout(TestConstant.Common.NEGATIVE_ID, false)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_025_Error_FailedWithPermissionDenied") {
                let appModuleWithoutPermission = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(appModuleWithoutPermission.getFormLayout(APP_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

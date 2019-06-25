///**
/**
 kintone-ios-sdkTests
 Created on 6/25/19
 */

import Foundation
import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class DeleteFormFieldsTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let appModuleGuestSpace = App(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            TestConstant.InitData.GUEST_SPACE_ID!))
        let APP_ID = TestConstant.InitData.APP_ID!
        let GUEST_SPACE_APP_ID = TestConstant.InitData.GUEST_SPACE_THREAD_ID!
        let fieldCodes = TestConstant.InitData.FIELD_CODES

        describe("DeleteFormFields") {
            it("Test_039_FailedWithApiToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.deleteFormFields(APP_ID, fieldCodes)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_040_Success_WithRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                let result = TestCommonHandling.awaitAsync(appModule.deleteFormFields(APP_ID, fieldCodes, currentRevision)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(APP_ID)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: APP_ID)
            }
            
            it("Test_040_Success_WithRevision_GuestSpaceApp") {
                let currentForm = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormFields(GUEST_SPACE_APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.deleteFormFields(GUEST_SPACE_APP_ID, fieldCodes, currentRevision)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(GUEST_SPACE_APP_ID)
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModuleGuestSpace, appId: GUEST_SPACE_APP_ID)
            }
            
            it("Test_041_Success_WithoutRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                let result = TestCommonHandling.awaitAsync(appModule.deleteFormFields(APP_ID, fieldCodes)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(APP_ID)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: APP_ID)
            }
            
            it("Test_042_Success_IgnoreRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                let result = TestCommonHandling.awaitAsync(appModule.deleteFormFields(APP_ID, fieldCodes, -1)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(APP_ID)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: APP_ID)
            }
            
            it("Test_047_FailedWithInvalidAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.deleteFormFields(TestConstant.Common.NEGATIVE_ID, fieldCodes)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_060_FailedWithNonExistentAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.deleteFormFields(TestConstant.Common.NONEXISTENT_ID, fieldCodes)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_048_FailedWithInvalidFieldsCode") {
                let fieldCode = "Invalid"
                let result = TestCommonHandling.awaitAsync(appModule.deleteFormFields(APP_ID, [fieldCode])) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_FIELD_CODE_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(fieldCode))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_049_Failed_InvalidRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                let result = TestCommonHandling.awaitAsync(appModule.deleteFormFields(APP_ID, fieldCodes, currentRevision! + 1)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(APP_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_052_FailedWithPermissionDenied") {
                let appModuleWothoutPermission = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(appModuleWothoutPermission.deleteFormFields(APP_ID, fieldCodes)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

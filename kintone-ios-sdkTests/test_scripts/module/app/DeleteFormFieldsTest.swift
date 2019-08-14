//
// kintone-ios-sdkTests
// Created on 6/25/19
//

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
        let appId = TestConstant.InitData.APP_ID!
        let fieldCodes = TestConstant.InitData.FIELD_CODES

        describe("DeleteFormFields") {
            it("Test_039_Error_ApiToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.deleteFormFields(appId, fieldCodes)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_040_Success_Revision") {
                let form = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT)) as! FormFields
                let revision = form.getRevision()!
                let deleteFormFieldsRsp = TestCommonHandling.awaitAsync(appModule.deleteFormFields(appId, fieldCodes, revision)) as! BasicResponse
                expect(deleteFormFieldsRsp.getRevision()).to(equal(revision + 1))
                
                let previewApp = PreviewApp(appId)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
            }
            
            it("Test_040_Success_Revision_GuestSpace") {
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let form = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormFields(guestSpaceAppId, LanguageSetting.DEFAULT)) as! FormFields
                
                let revision = form.getRevision()!
                let deleteFormFieldsRsp = TestCommonHandling.awaitAsync(appModuleGuestSpace.deleteFormFields(guestSpaceAppId, fieldCodes, revision)) as! BasicResponse
                expect(deleteFormFieldsRsp.getRevision()).to(equal(revision + 1))

                let previewApp = PreviewApp(guestSpaceAppId)
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModuleGuestSpace, appId: guestSpaceAppId)
            }
            
            it("Test_041_Success_WithoutRevision") {
                let form = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT)) as! FormFields
                let revision = form.getRevision()!
                let deleteFormFieldsRsp = TestCommonHandling.awaitAsync(appModule.deleteFormFields(appId, fieldCodes)) as! BasicResponse
                expect(deleteFormFieldsRsp.getRevision()).to(equal(revision + 1))
                
                let previewApp = PreviewApp(appId)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
            }
            
            it("Test_042_Success_IgnoreRevision") {
                let form = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT)) as! FormFields
                let revision = form.getRevision()!
                
                let deleteFormFieldsRsp = TestCommonHandling.awaitAsync(appModule.deleteFormFields(appId, fieldCodes, -1)) as! BasicResponse
                expect(deleteFormFieldsRsp.getRevision()).to(equal(revision + 1))
                
                let previewApp = PreviewApp(appId)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
            }
            
            it("Test_047_Error_InvalidAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.deleteFormFields(TestConstant.Common.NEGATIVE_ID, fieldCodes)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_060_Error_NonexistentAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.deleteFormFields(TestConstant.Common.NONEXISTENT_ID, fieldCodes)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_048_Error_InvalidFieldsCode") {
                let fieldCode = "Invalid"
                let result = TestCommonHandling.awaitAsync(appModule.deleteFormFields(appId, [fieldCode])) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_FIELD_CODE_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(fieldCode))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_049_Error_InvalidRevision") {
                let form = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT)) as! FormFields
                let revision = form.getRevision()!
                let result = TestCommonHandling.awaitAsync(appModule.deleteFormFields(appId, fieldCodes, revision + 1)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_052_Error_PermissionDenied") {
                let appModuleWithoutPermission = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))                
                let result = TestCommonHandling.awaitAsync(appModuleWithoutPermission.deleteFormFields(appId, fieldCodes)) as! KintoneAPIException

                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

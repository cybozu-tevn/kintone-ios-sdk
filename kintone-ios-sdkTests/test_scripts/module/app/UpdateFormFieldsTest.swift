///**
/**
 kintone-ios-sdkTests
 Created on 6/21/19
 */

import Foundation
import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class UpdateFormFieldsTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let appModuleGuestSpace = App(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            TestConstant.InitData.GUEST_SPACE_ID!))
        let APP_ID = TestConstant.InitData.APP_ID!
        let GUEST_SPACE_APP_ID = TestConstant.InitData.GUEST_SPACE_THREAD_ID!
        
        describe("UpdateFormFields") {
            it("Test_053_FailedWithApiToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let fieldCode = "Text"
                let singleLineText = SingleLineTextField(fieldCode)
                singleLineText.setLabel("updated label")
                var fields = [String: Field]()
                fields[fieldCode] = singleLineText
                
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.updateFormFields(APP_ID, fields)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_054_SuccessWithRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                var fields = [String: Field]()
                fields = currentForm.getProperties()!
                let fieldCode = "Text"
                let singleLineText = SingleLineTextField(fieldCode)
                singleLineText.setLabel("updated label")
                fields[fieldCode] = singleLineText

                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(APP_ID, fields, currentRevision)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(APP_ID)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: APP_ID)
            }
            
            it("Test_054_SuccessWithRevision_GuestSpaceApp") {
                let currentForm = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormFields(GUEST_SPACE_APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                var fields = [String: Field]()
                fields = currentForm.getProperties()!
                let fieldCode = "Text"
                let singleLineText = SingleLineTextField(fieldCode)
                singleLineText.setLabel("updated label")
                fields[fieldCode] = singleLineText
                
                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateFormFields(GUEST_SPACE_APP_ID, fields, currentRevision)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(GUEST_SPACE_APP_ID)
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModuleGuestSpace, appId: GUEST_SPACE_APP_ID)
            }
            
            it("Test_055_SuccessWithoutRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                var fields = [String: Field]()
                fields = currentForm.getProperties()!
                let fieldCode = "Text"
                let singleLineText = SingleLineTextField(fieldCode)
                singleLineText.setLabel("updated label")
                fields[fieldCode] = singleLineText
                
                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(APP_ID, fields)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(APP_ID)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: APP_ID)
            }
            
            it("Test_056_SuccessIgnoreRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                var fields = [String: Field]()
                fields = currentForm.getProperties()!
                let fieldCode = "Text"
                let singleLineText = SingleLineTextField(fieldCode)
                singleLineText.setLabel("updated.  label")
                fields[fieldCode] = singleLineText

                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(APP_ID, fields, -1)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(APP_ID)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: APP_ID)
            }
            
            it("Test_060_FailedWithInvalidAppId") {
                let fieldCode = "Text"
                let singleLineText  = SingleLineTextField(fieldCode)
                singleLineText.setLabel("New Added Field")
                var fields = [String: Field]()
                fields[fieldCode] = singleLineText
                
                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(TestConstant.Common.NEGATIVE_ID, fields)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_060_FailedWithNonExistentAppId") {
                let fieldCode = "Text"
                let singleLineText  = SingleLineTextField(fieldCode)
                singleLineText.setLabel("New Added Field")
                var fields = [String: Field]()
                fields[fieldCode] = singleLineText
                
                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(TestConstant.Common.NONEXISTENT_ID, fields)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_061_FailedWithInvalidFieldsCode") {
                let fieldCode = "Invalid"
                let singleLineText  = SingleLineTextField(fieldCode)
                singleLineText.setLabel("New Added Field")
                var fields = [String: Field]()
                fields[fieldCode] = singleLineText
                
                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(APP_ID, fields)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_FIELD_CODE_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(fieldCode))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_062_Failed_InvalidRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                var fields = [String: Field]()
                fields = currentForm.getProperties()!
                let fieldCode = "Text"
                let singleLineText = SingleLineTextField(fieldCode)
                singleLineText.setLabel("updated label")
                fields[fieldCode] = singleLineText

                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(APP_ID, fields, currentRevision! + 1)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(APP_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_063_FailedWithPermissionDenied") {
                let appModuleWothoutPermission = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let fieldCode = "Text"
                let singleLineText  = SingleLineTextField(fieldCode)
                singleLineText.setLabel("New Added Field")
                var fields = [String: Field]()
                fields[fieldCode] = singleLineText
                
                let result = TestCommonHandling.awaitAsync(appModuleWothoutPermission.updateFormFields(APP_ID, fields)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

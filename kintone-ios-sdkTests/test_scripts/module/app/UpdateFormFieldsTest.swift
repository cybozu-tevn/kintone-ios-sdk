//
// kintone-ios-sdkTests
// Created on 6/21/19
//

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
        let appId = TestConstant.InitData.APP_ID!
        let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let fieldCodes = TestConstant.InitData.FIELD_CODES

        describe("UpdateFormFields") {
            it("Test_053_Error_ApiToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let fieldCode = "Text"
                let singleLineText = SingleLineTextField(fieldCode)
                singleLineText.setLabel("updated label")
                var fields = [String: Field]()
                fields[fieldCode] = singleLineText
                
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.updateFormFields(appId, fields)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_054_Success_Revision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                var fields = [String: Field]()
                fields = currentForm.getProperties()!
                for fieldCode in fieldCodes {
                    if(fieldCode == TestConstant.InitData.TEXT_FIELD || fieldCode == TestConstant.InitData.TEXT_UPDATE_KEY_FIELD) {
                        let singleLineTextField = SingleLineTextField(fieldCode)
                        singleLineTextField.setLabel("updated label")
                        fields[fieldCode] = singleLineTextField
                    }
                    if(fieldCode == TestConstant.InitData.NUMBER_FIELD || fieldCode == TestConstant.InitData.NUMBER_PROHIBIT_DUPLICATE_FIELD) {
                        let numberField = NumberField(fieldCode)
                        numberField.setLabel("updated label")
                        fields[fieldCode] = numberField
                    }
                    if(fieldCode == TestConstant.InitData.TEXT_AREA_FIELD) {
                        let multiLineTextField = MultiLineTextField(fieldCode)
                        multiLineTextField.setLabel("updated label")
                        fields[fieldCode] = multiLineTextField
                    }
                    if(fieldCode == TestConstant.InitData.DATE_FIELD) {
                        let dateField = DateField(fieldCode)
                        dateField.setLabel("updated label")
                        fields[fieldCode] = dateField
                    }
                    if(fieldCode == TestConstant.InitData.LINK_FIELD) {
                        let linkField = LinkField(fieldCode)
                        linkField.setLabel("updated label")
                        fields[fieldCode] = linkField
                    }
                    if(fieldCode == TestConstant.InitData.ATTACHMENT_FIELD) {
                        let attachmentField = AttachmentField(fieldCode)
                        attachmentField.setLabel("updated label")
                        fields[fieldCode] = attachmentField
                    }
                }
                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(appId, fields, currentRevision)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(appId)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
            }
            
            it("Test_054_Success_Revision_GuestSpace") {
                let currentForm = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormFields(guestSpaceAppId, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                var fields = [String: Field]()
                fields = currentForm.getProperties()!
                for fieldCode in fieldCodes {
                    if(fieldCode == TestConstant.InitData.TEXT_FIELD || fieldCode == TestConstant.InitData.TEXT_UPDATE_KEY_FIELD) {
                        let singleLineTextField = SingleLineTextField(fieldCode)
                        singleLineTextField.setLabel("updated label")
                        fields[fieldCode] = singleLineTextField
                    }
                    if(fieldCode == TestConstant.InitData.NUMBER_FIELD || fieldCode == TestConstant.InitData.NUMBER_PROHIBIT_DUPLICATE_FIELD) {
                        let numberField = NumberField(fieldCode)
                        numberField.setLabel("updated label")
                        fields[fieldCode] = numberField
                    }
                    if(fieldCode == TestConstant.InitData.TEXT_AREA_FIELD) {
                        let multiLineTextField = MultiLineTextField(fieldCode)
                        multiLineTextField.setLabel("updated label")
                        fields[fieldCode] = multiLineTextField
                    }
                    if(fieldCode == TestConstant.InitData.DATE_FIELD) {
                        let dateField = DateField(fieldCode)
                        dateField.setLabel("updated label")
                        fields[fieldCode] = dateField
                    }
                    if(fieldCode == TestConstant.InitData.LINK_FIELD) {
                        let linkField = LinkField(fieldCode)
                        linkField.setLabel("updated label")
                        fields[fieldCode] = linkField
                    }
                    if(fieldCode == TestConstant.InitData.ATTACHMENT_FIELD) {
                        let attachmentField = AttachmentField(fieldCode)
                        attachmentField.setLabel("updated label")
                        fields[fieldCode] = attachmentField
                    }
                }
                
                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateFormFields(guestSpaceAppId, fields, currentRevision)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(guestSpaceAppId)
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModuleGuestSpace, appId: guestSpaceAppId)
            }
            
            it("Test_055_Success_WithoutRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                var fields = [String: Field]()
                fields = currentForm.getProperties()!
                let fieldCode = "Text"
                let singleLineText = SingleLineTextField(fieldCode)
                singleLineText.setLabel("updated label")
                fields[fieldCode] = singleLineText
                
                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(appId, fields)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(appId)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
            }
            
            it("Test_056_Success_IgnoreRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                var fields = [String: Field]()
                fields = currentForm.getProperties()!
                let fieldCode = "Text"
                let singleLineText = SingleLineTextField(fieldCode)
                singleLineText.setLabel("updated.  label")
                fields[fieldCode] = singleLineText

                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(appId, fields, -1)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                let previewApp = PreviewApp(appId)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
            }
            
            it("Test_060_Error_InvalidAppId") {
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
            
            it("Test_060_Error_NonExistentAppId") {
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
            
            it("Test_061_Error_InvalidFieldsCode") {
                let fieldCode = "Invalid"
                let singleLineText  = SingleLineTextField(fieldCode)
                singleLineText.setLabel("New Added Field")
                var fields = [String: Field]()
                fields[fieldCode] = singleLineText
                
                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(appId, fields)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_FIELD_CODE_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(fieldCode))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_062_Error_InvalidRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT)) as! FormFields
                let currentRevision = currentForm.getRevision()
                var fields = [String: Field]()
                fields = currentForm.getProperties()!
                let fieldCode = "Text"
                let singleLineText = SingleLineTextField(fieldCode)
                singleLineText.setLabel("updated label")
                fields[fieldCode] = singleLineText

                let result = TestCommonHandling.awaitAsync(appModule.updateFormFields(appId, fields, currentRevision! + 1)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_063_Error_PermissionDenied") {
                let appModuleWothoutPermission = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let fieldCode = "Text"
                let singleLineText  = SingleLineTextField(fieldCode)
                singleLineText.setLabel("New Added Field")
                var fields = [String: Field]()
                fields[fieldCode] = singleLineText
                
                let result = TestCommonHandling.awaitAsync(appModuleWothoutPermission.updateFormFields(appId, fields)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

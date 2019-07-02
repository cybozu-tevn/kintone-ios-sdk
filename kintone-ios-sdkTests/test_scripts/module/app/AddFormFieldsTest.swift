//
// kintone-ios-sdkTests
// Created on 6/20/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class AddFormFieldsTest: QuickSpec {
    override func spec() {
        let spaceId = TestConstant.InitData.SPACE_ID
        let threadId = TestConstant.InitData.SPACE_THREAD_ID
        let appModule = App(TestCommonHandling.createConnection())
        var appId: Int!
        var properties = [String: Field]()
        var fieldCodes: [String] = []
        
        describe("AddFormFields") {
            beforeSuite {
                appId = AppUtils.createApp(appModule: appModule, spaceId: spaceId, threadId: threadId)

                // SINGLE_LINE_TEXT field
                let singleLineTextFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(singleLineTextFieldCode)
                let singleLineTextField = SingleLineTextField(singleLineTextFieldCode)
                singleLineTextField.setLabel(DataRandomization.generateString(length: 10))
                singleLineTextField.setDefaultValue(DataRandomization.generateString(length: 10))
                singleLineTextField.setMaxLength("30")
                singleLineTextField.setMinLength("3")
                singleLineTextField.setUnique(true)
                singleLineTextField.setNoLabel(true)
                singleLineTextField.setRequired(true)
                properties[singleLineTextFieldCode] = singleLineTextField
                
                // MULTI_LINE_TEXT field
                let multiLineTextFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(multiLineTextFieldCode)
                let multiLineTextField = MultiLineTextField(multiLineTextFieldCode)
                multiLineTextField.setLabel(DataRandomization.generateString(length: 10))
                multiLineTextField.setDefaultValue(DataRandomization.generateString(length: 10))
                properties[multiLineTextFieldCode] = multiLineTextField
                
                // RICH_TEXT field
                let richTextFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(richTextFieldCode)
                let richTextField = RichTextField(richTextFieldCode)
                richTextField.setLabel(DataRandomization.generateString(length: 10))
                richTextField.setDefaultValue(DataRandomization.generateString(length: 10))
                properties[richTextFieldCode] = richTextField
                
                // NUMBER field
                let numberFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(numberFieldCode)
                let numberField = NumberField(numberFieldCode)
                numberField.setLabel(DataRandomization.generateString(length: 10))
                numberField.setDefaultValue("1")
                numberField.setDigit(true)
                numberField.setUnit("$")
                numberField.setMinValue("1")
                numberField.setMaxValue("30")
                numberField.setDisplayScale("10")
                numberField.setUnitPosition(UnitPosition.BEFORE)
                properties[numberFieldCode] = numberField
                
                // CALC field
                let calculatedFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(calculatedFieldCode)
                let calculatedField = CalculatedField(calculatedFieldCode)
                calculatedField.setLabel(DataRandomization.generateString(length: 10))
                calculatedField.setExpression("10 + 10")
                properties[calculatedFieldCode] = calculatedField
                
                // RADIO_BUTTON field
                let radioButtonFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(radioButtonFieldCode)
                let radioButtonField = RadioButtonField(radioButtonFieldCode)
                radioButtonField.setLabel(DataRandomization.generateString(length: 10))
                radioButtonField.setOptions(["1": OptionData("1", "1"), "2": OptionData("2", "2"), "3": OptionData("3", "3")])
                radioButtonField.setDefaultValue("1")
                properties[radioButtonFieldCode] = radioButtonField
                
                // CHECK_BOX field
                let checkBoxFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(checkBoxFieldCode)
                let checkBoxField = CheckboxField(checkBoxFieldCode)
                checkBoxField.setLabel(DataRandomization.generateString(length: 10))
                checkBoxField.setOptions(["1": OptionData("1", "1"), "2": OptionData("2", "2"), "3": OptionData("3", "3")])
                checkBoxField.setDefaultValue(["1"])
                properties[checkBoxFieldCode] = checkBoxField
                
                // MULTI_SELECT field
                let multiChoiceFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(multiChoiceFieldCode)
                let multiChoiceField = MultipleSelectField(multiChoiceFieldCode)
                multiChoiceField.setLabel(DataRandomization.generateString(length: 10))
                multiChoiceField.setOptions(["1": OptionData("1", "1"), "2": OptionData("2", "2"), "3": OptionData("3", "3")])
                multiChoiceField.setDefaultValue(["1"])
                properties[multiChoiceFieldCode] = multiChoiceField
                
                // DROP_DOWN field
                let dropDownFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(dropDownFieldCode)
                let dropDownField = DropDownField(dropDownFieldCode)
                dropDownField.setLabel(DataRandomization.generateString(length: 10))
                dropDownField.setOptions(["1": OptionData("1", "1"), "2": OptionData("2", "2"), "3": OptionData("3", "3")])
                dropDownField.setDefaultValue("1")
                properties[dropDownFieldCode] = dropDownField
                
                // DATE field
                let dateFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(dateFieldCode)
                let dateField = DateField(dateFieldCode)
                dateField.setLabel(DataRandomization.generateString(length: 10))
                dateField.setDefaultNowValue(true)
                properties[dateFieldCode] = dateField
                
                // TIME field
                let timeFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(timeFieldCode)
                let timeField = TimeField(timeFieldCode)
                timeField.setLabel(DataRandomization.generateString(length: 10))
                timeField.setDefaultNowValue(true)
                properties[timeFieldCode] = timeField
                
                // DATETIME field
                let dateAndTimeFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(dateAndTimeFieldCode)
                let dateAndTimeField = DateTimeField(dateAndTimeFieldCode)
                dateAndTimeField.setLabel(DataRandomization.generateString(length: 10))
                dateAndTimeField.setDefaultNowValue(true)
                properties[dateAndTimeFieldCode] = dateAndTimeField
                
                // FILE field
                let attachmentFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(attachmentFieldCode)
                let attachmentField = AttachmentField(attachmentFieldCode)
                attachmentField.setLabel(DataRandomization.generateString(length: 10))
                attachmentField.setThumbnailSize("50")
                properties[attachmentFieldCode] = attachmentField
                
                // LINK field
                let linkFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(linkFieldCode)
                let linkField = LinkField(linkFieldCode)
                linkField.setLabel(DataRandomization.generateString(length: 10))
                linkField.setProtocol(LinkProtocol.MAIL)
                linkField.setMinLength("1")
                linkField.setMaxLength("100")
                linkField.setDefaultValue("test@test.com")
                properties[linkFieldCode] = linkField
                
                // USER_SELECT field
                let userSelectionFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(userSelectionFieldCode)
                let userSelectionField = UserSelectionField(userSelectionFieldCode)
                userSelectionField.setLabel(DataRandomization.generateString(length: 10))
                userSelectionField.setDefaultValue([MemberSelectEntity("cybozu", MemberSelectEntityType.USER)])
                properties[userSelectionFieldCode] = userSelectionField
                
                // ORGANIZATION_SELECT field
                let departmentSelectionFieldCode = DataRandomization.generateString(length: 10)
                fieldCodes.append(departmentSelectionFieldCode)
                let departmentSelectionField = DepartmentSelectionField(departmentSelectionFieldCode)
                departmentSelectionField.setLabel(DataRandomization.generateString(length: 10))
                properties[departmentSelectionFieldCode] = departmentSelectionField
            }
            
            afterSuite {
                AppUtils.deleteApp(appId: appId)
            }
            
            afterEach {
                let previewApp: PreviewApp? = PreviewApp(appId, -1)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp!], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
            }
            
            it("Test_027_Error_ApiToken") {
                // Prepare test data
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.addFormFields(appId, properties, nil)) as! KintoneAPIException
                
                // Verify error
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_028_Success_Revision") {
                // Prepare test data
                var currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, false)) as! FormFields
                let currentRevision = currentForm.getRevision()
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(appId, properties, currentRevision)) as! BasicResponse
                currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                var actualResult: [String] = []
                for (_, value) in currentForm.getProperties()! {
                    actualResult.append(value.getCode())
                }
                
                // Verify revision and file code of fieldForm
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                expect(actualResult).to(contain(fieldCodes))
            }
            
            it("Test_028_Success_Revision_GuestSpace") {
                let appModuleGuestSpace = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID
                let guestSpaceThreadId = TestConstant.InitData.GUEST_SPACE_THREAD_ID
                let appGuestSpaceId = AppUtils.createApp(appModule: appModuleGuestSpace, spaceId: guestSpaceId, threadId: guestSpaceThreadId)
                let currentForm = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormFields(appGuestSpaceId, LanguageSetting.DEFAULT, true)) as! FormFields
                let currentRevision = currentForm.getRevision()
                
                let fieldCode = "newField"
                let newField  = SingleLineTextField(fieldCode)
                newField.setLabel("New Field")
                var property = [String: Field]()
                property[fieldCode] = newField

                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.addFormFields(appGuestSpaceId, property, currentRevision)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                AppUtils.deleteApp(appId: appGuestSpaceId)
            }
            
            it("Test_029_Success_Revision") {
                var currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                let currentRevision = currentForm.getRevision()
                
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(appId, properties)) as! BasicResponse
                currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                var actualResult: [String] = []
                for (_, value) in currentForm.getProperties()! {
                    actualResult.append(value.getCode())
                }
                
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                expect(actualResult).to(contain(fieldCodes))
            }
            
            it("Test_030_Success_IgnoreRevision") {
                var currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                let currentRevision = currentForm.getRevision()
                
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(appId, properties, -1)) as! BasicResponse
                currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                var actualResult: [String] = []
                for (_, value) in currentForm.getProperties()! {
                    actualResult.append(value.getCode())
                }
                
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                expect(actualResult).to(contain(fieldCodes))
            }
            
            it("Test_035_Error_NegativeAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(TestConstant.Common.NEGATIVE_ID, properties, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_035_Error_NonExistentAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(TestConstant.Common.NONEXISTENT_ID, properties, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_037_Error_InvalidRevision") {
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                let currentRevision = currentForm.getRevision()!
                
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(appId, properties, currentRevision + 1)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_038_Error_PermissionDenied") {
                let appModuleWithoutPermisstion = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                appId = AppUtils.createApp(appModule: appModule, spaceId: spaceId, threadId: threadId)
                
                let result = TestCommonHandling.awaitAsync(appModuleWithoutPermisstion.addFormFields(appId, properties)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

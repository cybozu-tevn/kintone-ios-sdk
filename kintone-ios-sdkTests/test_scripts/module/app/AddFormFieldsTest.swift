///**
/**
 kintone-ios-sdkTests
 Created on 6/20/19
 */

import Foundation
import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class AddFormFieldsTest: QuickSpec {
    override func spec() {
        let SPACE_ID = TestConstant.InitData.SPACE_ID
        let THREAD_ID = TestConstant.InitData.SPACE_THREAD_ID
        let GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_ID
        let GUEST_SPACE_THREAD_ID = TestConstant.InitData.GUEST_SPACE_THREAD_ID
        let appModule = App(TestCommonHandling.createConnection())
        let appModuleGuestSpace = App(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            TestConstant.InitData.GUEST_SPACE_ID!))
        
        var appId: Int!
        var appGuestSpaceId: Int!
        var properties = [String: Field]()
        var fieldCodes: [String] = []
        
        // SINGLE_LINE_TEXT field
        let singleLineTextFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(singleLineTextFieldCode)
        let singleLineTextAddedField = SingleLineTextField(singleLineTextFieldCode)
        singleLineTextAddedField.setLabel(DataRandomization.generateString(length: 10))
        singleLineTextAddedField.setDefaultValue(DataRandomization.generateString(length: 10))
        singleLineTextAddedField.setMaxLength("30")
        singleLineTextAddedField.setMinLength("3")
        singleLineTextAddedField.setUnique(true)
        singleLineTextAddedField.setNoLabel(true)
        singleLineTextAddedField.setRequired(true)
        properties[singleLineTextFieldCode] = singleLineTextAddedField
        
        // MULTI_LINE_TEXT field
        let multiLineTextFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(multiLineTextFieldCode)
        let multiLineTextAddedField = MultiLineTextField(multiLineTextFieldCode)
        multiLineTextAddedField.setLabel(DataRandomization.generateString(length: 10))
        multiLineTextAddedField.setDefaultValue(DataRandomization.generateString(length: 10))
        properties[multiLineTextFieldCode] = multiLineTextAddedField
        
        // RICH_TEXT field
        let richTextFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(richTextFieldCode)
        let richTextAddedField = RichTextField(richTextFieldCode)
        richTextAddedField.setLabel(DataRandomization.generateString(length: 10))
        richTextAddedField.setDefaultValue(DataRandomization.generateString(length: 10))
        properties[richTextFieldCode] = richTextAddedField
        
        // NUMBER field
        let numberFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(numberFieldCode)
        let numberAddedField = NumberField(numberFieldCode)
        numberAddedField.setLabel(DataRandomization.generateString(length: 10))
        numberAddedField.setDefaultValue("1")
        numberAddedField.setDigit(true)
        numberAddedField.setUnit("$")
        numberAddedField.setMinValue("1")
        numberAddedField.setMaxValue("30")
        numberAddedField.setDisplayScale("10")
        numberAddedField.setUnitPosition(UnitPosition.BEFORE)
        properties[numberFieldCode] = numberAddedField
        
        // CALC field
        let calculatedFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(calculatedFieldCode)
        let calculatedAddedField = CalculatedField(calculatedFieldCode)
        calculatedAddedField.setLabel(DataRandomization.generateString(length: 10))
        calculatedAddedField.setExpression("10 + 10")
        properties[calculatedFieldCode] = calculatedAddedField
        
        // RADIO_BUTTON field
        let radioButtonFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(radioButtonFieldCode)
        let radioButtonAddedField = RadioButtonField(radioButtonFieldCode)
        radioButtonAddedField.setLabel(DataRandomization.generateString(length: 10))
        radioButtonAddedField.setOptions(["1": OptionData("1", "1"), "2": OptionData("2", "2"), "3": OptionData("3", "3")])
        radioButtonAddedField.setDefaultValue("1")
        properties[radioButtonFieldCode] = radioButtonAddedField
        
        // CHECK_BOX field
        let checkBoxFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(checkBoxFieldCode)
        let checkBoxAddedField = CheckboxField(checkBoxFieldCode)
        checkBoxAddedField.setLabel(DataRandomization.generateString(length: 10))
        checkBoxAddedField.setOptions(["1": OptionData("1", "1"), "2": OptionData("2", "2"), "3": OptionData("3", "3")])
        checkBoxAddedField.setDefaultValue(["1"])
        properties[checkBoxFieldCode] = checkBoxAddedField
        
        // MULTI_SELECT field
        let multiChoiceFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(multiChoiceFieldCode)
        let multiChoiceAddedField = MultipleSelectField(multiChoiceFieldCode)
        multiChoiceAddedField.setLabel(DataRandomization.generateString(length: 10))
        multiChoiceAddedField.setOptions(["1": OptionData("1", "1"), "2": OptionData("2", "2"), "3": OptionData("3", "3")])
        multiChoiceAddedField.setDefaultValue(["1"])
        properties[multiChoiceFieldCode] = multiChoiceAddedField
        
        // DROP_DOWN field
        let dropDownFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(dropDownFieldCode)
        let dropDownAddedField = DropDownField(dropDownFieldCode)
        dropDownAddedField.setLabel(DataRandomization.generateString(length: 10))
        dropDownAddedField.setOptions(["1": OptionData("1", "1"), "2": OptionData("2", "2"), "3": OptionData("3", "3")])
        dropDownAddedField.setDefaultValue("1")
        properties[dropDownFieldCode] = dropDownAddedField
        
        // DATE field
        let dateFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(dateFieldCode)
        let dateAddedField = DateField(dateFieldCode)
        dateAddedField.setLabel(DataRandomization.generateString(length: 10))
        dateAddedField.setDefaultNowValue(true)
        properties[dateFieldCode] = dateAddedField
        
        // TIME field
        let timeFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(timeFieldCode)
        let timeAddedField = TimeField(timeFieldCode)
        timeAddedField.setLabel(DataRandomization.generateString(length: 10))
        timeAddedField.setDefaultNowValue(true)
        properties[timeFieldCode] = timeAddedField
        
        // DATETIME field
        let dateAndTimeFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(dateAndTimeFieldCode)
        let dateAndTimeAddedField = DateTimeField(dateAndTimeFieldCode)
        dateAndTimeAddedField.setLabel(DataRandomization.generateString(length: 10))
        dateAndTimeAddedField.setDefaultNowValue(true)
        properties[dateAndTimeFieldCode] = dateAndTimeAddedField
        
        // FILE field
        let attachmentFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(attachmentFieldCode)
        let attachmentAddedField = AttachmentField(attachmentFieldCode)
        attachmentAddedField.setLabel(DataRandomization.generateString(length: 10))
        attachmentAddedField.setThumbnailSize("50")
        properties[attachmentFieldCode] = attachmentAddedField
        
        // LINK field
        let linkFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(linkFieldCode)
        let linkAddedField = LinkField(linkFieldCode)
        linkAddedField.setLabel(DataRandomization.generateString(length: 10))
        linkAddedField.setProtocol(LinkProtocol.MAIL)
        linkAddedField.setMinLength("1")
        linkAddedField.setMaxLength("100")
        linkAddedField.setDefaultValue("test@test.com")
        properties[linkFieldCode] = linkAddedField
        
        // USER_SELECT field
        let userSelectionFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(userSelectionFieldCode)
        let userSelectionAddedField = UserSelectionField(userSelectionFieldCode)
        userSelectionAddedField.setLabel(DataRandomization.generateString(length: 10))
        userSelectionAddedField.setDefaultValue([MemberSelectEntity("cybozu", MemberSelectEntityType.USER)])
        properties[userSelectionFieldCode] = userSelectionAddedField
        
        // ORGANIZATION_SELECT field
        let departmentSelectionFieldCode = DataRandomization.generateString(length: 10)
        fieldCodes.append(departmentSelectionFieldCode)
        let departmentSelectionAddedField = DepartmentSelectionField(departmentSelectionFieldCode)
        departmentSelectionAddedField.setLabel(DataRandomization.generateString(length: 10))
        properties[departmentSelectionFieldCode] = departmentSelectionAddedField
        
        describe("AddFormFields") {
            it("Test_027_FailedWithApiToken") {
                appId = AppUtils.createApp(appModule: appModule, spaceId: SPACE_ID, threadId: THREAD_ID)
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.addFormFields(appId, properties, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                AppUtils.deleteApp(appId: appId)
            }
            
            it("test_028_Success_WithRevision") {
                appId = AppUtils.createApp(appModule: appModule, spaceId: SPACE_ID, threadId: THREAD_ID)
                var currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, false)) as! FormFields
                let currentRevision = currentForm.getRevision()
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(appId, properties, currentRevision)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                var actualResult: [String] = []
                for (_, value) in currentForm.getProperties()! {
                    actualResult.append(value.getCode())
                }
                expect(actualResult).to(contain(fieldCodes))
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_028_Success_WithRevision_GuestSpaceApp") {
                appGuestSpaceId = AppUtils.createApp(appModule: appModuleGuestSpace, spaceId: GUEST_SPACE_ID, threadId: GUEST_SPACE_THREAD_ID)
                let currentForm = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormFields(appGuestSpaceId, LanguageSetting.DEFAULT, true)) as! FormFields
                let currentRevision = currentForm.getRevision()
                
                let fieldCode = "newAddedField"
                let newAddedField  = SingleLineTextField(fieldCode)
                newAddedField.setLabel("New Added Field")
                var property = [String: Field]()
                property[fieldCode] = newAddedField

                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.addFormFields(appGuestSpaceId, property, currentRevision)) as! BasicResponse
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                
                AppUtils.deleteApp(appId: appGuestSpaceId)
            }
            
            it("Test_029_Success_WithoutRevision") {
                appId = AppUtils.createApp(appModule: appModule, spaceId: SPACE_ID, threadId: THREAD_ID)
                var currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                let currentRevision = currentForm.getRevision()
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(appId, properties)) as! BasicResponse
                
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                var actualResult: [String] = []
                for (_, value) in currentForm.getProperties()! {
                    actualResult.append(value.getCode())
                }
                expect(actualResult).to(contain(fieldCodes))
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_030_Success_IgnoreRevision") {
                appId = AppUtils.createApp(appModule: appModule, spaceId: SPACE_ID, threadId: THREAD_ID)
                var currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                let currentRevision = currentForm.getRevision()
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(appId, properties, -1)) as! BasicResponse
                
                expect(result.getRevision()).to(equal(currentRevision! + 1))
                currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                var actualResult: [String] = []
                for (_, value) in currentForm.getProperties()! {
                    actualResult.append(value.getCode())
                }
                expect(actualResult).to(contain(fieldCodes))
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_035_FailedWithNegativeAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(TestConstant.Common.NEGATIVE_ID, properties, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_035_FailedWithNonExistentAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(TestConstant.Common.NONEXISTENT_ID, properties, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_037_Failed_InvalidRevision") {
                appId = AppUtils.createApp(appModule: appModule, spaceId: SPACE_ID, threadId: THREAD_ID)
                let currentForm = TestCommonHandling.awaitAsync(appModule.getFormFields(appId, LanguageSetting.DEFAULT, true)) as! FormFields
                let currentRevision = currentForm.getRevision()!
                
                let result = TestCommonHandling.awaitAsync(appModule.addFormFields(appId, properties, currentRevision + 1)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_038_FailedWithPermissionDenied") {
                let appModuleWithoutPermisstion = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                appId = AppUtils.createApp(appModule: appModule, spaceId: SPACE_ID, threadId: THREAD_ID)
                let result = TestCommonHandling.awaitAsync(appModuleWithoutPermisstion.addFormFields(appId, properties)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

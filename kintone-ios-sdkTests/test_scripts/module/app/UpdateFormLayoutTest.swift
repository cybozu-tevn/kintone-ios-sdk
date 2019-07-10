//
// kintone-ios-sdkTests
// Created on 6/27/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class UpdateFormLayoutTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let appId = TestConstant.InitData.SPACE_APP_ID!
        let fieldWidth = "288"
        var itemLayoutRequest: [ItemLayout]? = [ItemLayout]()
        
        // Fields of first Row
        let numberField = TestConstant.InitData.NUMBER_FIELD
        let numberRequireField = TestConstant.InitData.NUMBER_PROHIBIT_DUPLICATE_FIELD
        
        // Fields of second Row
        let textField = TestConstant.InitData.TEXT_FIELD
        let uniqueTextField = TestConstant.InitData.TEXT_UPDATE_KEY_FIELD
        let dateField = TestConstant.InitData.DATE_FIELD
        
        // Fields of 3rd Row
        let richTextField = TestConstant.InitData.TEXT_AREA_FIELD
        
        // Fields of 4rd Row
        let attachmentField = TestConstant.InitData.ATTACHMENT_FIELD
        let linkField = TestConstant.InitData.LINK_FIELD
        
        // Fields of subTable
        let textInTableField = "Text_In_Table"
        let tableField = TestConstant.InitData.TABLE_FIELD
        
        var rowLayout1: RowLayout? = RowLayout()
        var rowLayout2: RowLayout? = RowLayout()
        var rowLayout3: RowLayout? = RowLayout()
        var rowLayout4: RowLayout? = RowLayout()
        var fieldsRowLayout1: [FieldLayout]? = [FieldLayout]()
        var fieldsRowLayout2: [FieldLayout]? = [FieldLayout]()
        var fieldsRowLayout3: [FieldLayout]? = [FieldLayout]()
        var fieldsRowLayout4: [FieldLayout]? = [FieldLayout]()
        var subTableLayout: SubTableLayout? = SubTableLayout()
        var fieldSubTableLayout: [FieldLayout]? = [FieldLayout]()
        let fieldSize: FieldSize? = FieldSize()
        
        describe("UpdateFormLayout_1") {
            it("AddTestData_BeforeSuiteWorkaround") {
                // The field size will be updated
                fieldSize?.setWidth(fieldWidth)
                
                // First row
                let fieldLayout1: FieldLayout? = FieldLayout()
                fieldLayout1?.setCode(numberField)
                fieldLayout1?.setType(FieldType.NUMBER.rawValue)
                fieldLayout1?.setSize(fieldSize)
                
                let fieldLayout2: FieldLayout? = FieldLayout()
                fieldLayout2?.setCode(numberRequireField)
                fieldLayout2?.setType(FieldType.NUMBER.rawValue)
                fieldLayout2?.setSize(fieldSize)
                
                fieldsRowLayout1?.append(fieldLayout1!)
                fieldsRowLayout1?.append(fieldLayout2!)
                rowLayout1?.setFields(fieldsRowLayout1)
                
                // Second row
                let fieldLayout3: FieldLayout? = FieldLayout()
                fieldLayout3?.setCode(textField)
                fieldLayout3?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
                fieldLayout3?.setSize(fieldSize)
                
                let fieldLayout4: FieldLayout? = FieldLayout()
                fieldLayout4?.setCode(uniqueTextField)
                fieldLayout4?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
                fieldLayout4?.setSize(fieldSize)
                
                let fieldLayout5: FieldLayout? = FieldLayout()
                fieldLayout5?.setCode(dateField)
                fieldLayout5?.setType(FieldType.DATE.rawValue)
                fieldLayout5?.setSize(fieldSize)
                
                fieldsRowLayout2?.append(fieldLayout3!)
                fieldsRowLayout2?.append(fieldLayout4!)
                fieldsRowLayout2?.append(fieldLayout5!)
                rowLayout2?.setFields(fieldsRowLayout2)
                
                // 3rd row
                let fieldLayout6: FieldLayout? = FieldLayout()
                fieldLayout6?.setCode(richTextField)
                fieldLayout6?.setType(FieldType.MULTI_LINE_TEXT.rawValue)
                fieldLayout6?.setSize(fieldSize)
                fieldsRowLayout3?.append(fieldLayout6!)
                rowLayout3?.setFields(fieldsRowLayout3)
                
                // 4rd row
                let fieldLayout7: FieldLayout? = FieldLayout()
                fieldLayout7?.setCode(attachmentField)
                fieldLayout7?.setType(FieldType.FILE.rawValue)
                fieldLayout7?.setSize(fieldSize)
                
                let fieldLayout8: FieldLayout? = FieldLayout()
                fieldLayout8?.setCode(linkField)
                fieldLayout8?.setType(FieldType.LINK.rawValue)
                fieldLayout8?.setSize(fieldSize)
                
                fieldsRowLayout4?.append(fieldLayout7!)
                fieldsRowLayout4?.append(fieldLayout8!)
                rowLayout4?.setFields(fieldsRowLayout4)
                
                // Subtable
                let fieldLayout9: FieldLayout? = FieldLayout()
                fieldLayout9?.setCode(textInTableField)
                fieldLayout9?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
                fieldLayout9?.setSize(fieldSize)
                
                fieldSubTableLayout?.append(fieldLayout9!)
                subTableLayout?.setFields(fieldSubTableLayout)
                subTableLayout?.setCode(tableField)
                
                // Assign itemLayout Request for update
                itemLayoutRequest?.append(rowLayout1!)
                itemLayoutRequest?.append(rowLayout2!)
                itemLayoutRequest?.append(rowLayout3!)
                itemLayoutRequest?.append(rowLayout4!)
                itemLayoutRequest?.append(subTableLayout!)
            }
            
            it("Test_064_Error_ApiToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.updateFormLayout(appId, itemLayoutRequest!)) as! KintoneAPIException
                
                // Verify error result
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_065_066_Success_ValidData") {
                var result = TestCommonHandling.awaitAsync(appModule.getFormLayout(appId, true)) as! FormLayout
                let currentRevision = Int(result.getRevision()!)
                let updateFormLayout = TestCommonHandling.awaitAsync(appModule.updateFormLayout(appId, itemLayoutRequest!)) as! BasicResponse
                result = TestCommonHandling.awaitAsync(appModule.getFormLayout(appId, true)) as! FormLayout
                
                // Get row and subtable data
                let row1Result = result.getLayout()![0] as! RowLayout
                let row2Result = result.getLayout()![1] as! RowLayout
                let row3Result = result.getLayout()![2] as! RowLayout
                let row4Result = result.getLayout()![3] as! RowLayout
                let tableResult = result.getLayout()![4] as! SubTableLayout
                
                //Verify the revision will be increased by 1
                expect(Int(updateFormLayout.getRevision()!)).to(equal(currentRevision! + 1))
                
                // Verify fields of first row
                expect(row1Result.getFields()![0].getCode()).to(equal(numberField))
                expect(row1Result.getFields()![1].getCode()).to(equal(numberRequireField))
                expect(row1Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row1Result.getFields()![1].getSize()?.getWidth()).to(equal(fieldWidth))
                
                // Verify fields of second row
                expect(row2Result.getFields()![0].getCode()).to(equal(textField))
                expect(row2Result.getFields()![1].getCode()).to(equal(uniqueTextField))
                expect(row2Result.getFields()![2].getCode()).to(equal(dateField))
                expect(row2Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row2Result.getFields()![1].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row2Result.getFields()![2].getSize()?.getWidth()).to(equal(fieldWidth))
                
                // Verify fields of 3rd row
                expect(row3Result.getFields()![0].getCode()).to(equal(richTextField))
                expect(row3Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                
                // Verify fields of 4rd row
                expect(row4Result.getFields()![0].getCode()).to(equal(attachmentField))
                expect(row4Result.getFields()![1].getCode()).to(equal(linkField))
                expect(row4Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row4Result.getFields()![1].getSize()?.getWidth()).to(equal(fieldWidth))
                
                // Verify fields of Subtable
                expect(tableResult.getFields()![0].getCode()).to(equal(textInTableField))
                expect(tableResult.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
            }
            
            it("Test_065_066_Success_ValidData_GuestSpace") {
                let appModuleGuestSpace = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                var result = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormLayout(guestSpaceAppId, true)) as! FormLayout
                let currentRevision = Int(result.getRevision()!)
                let updateFormLayout = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateFormLayout(guestSpaceAppId, itemLayoutRequest!)) as! BasicResponse
                result = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormLayout(guestSpaceAppId, true)) as! FormLayout
                
                let row1Result = result.getLayout()![0] as! RowLayout
                let row2Result = result.getLayout()![1] as! RowLayout
                let row3Result = result.getLayout()![2] as! RowLayout
                let row4Result = result.getLayout()![3] as! RowLayout
                let tableResult = result.getLayout()![4] as! SubTableLayout
                
                expect(Int(updateFormLayout.getRevision()!)).to(equal(currentRevision! + 1))
                
                expect(row1Result.getFields()![0].getCode()).to(equal(numberField))
                expect(row1Result.getFields()![1].getCode()).to(equal(numberRequireField))
                expect(row1Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row1Result.getFields()![1].getSize()?.getWidth()).to(equal(fieldWidth))
                
                expect(row2Result.getFields()![0].getCode()).to(equal(textField))
                expect(row2Result.getFields()![1].getCode()).to(equal(uniqueTextField))
                expect(row2Result.getFields()![2].getCode()).to(equal(dateField))
                expect(row2Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row2Result.getFields()![1].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row2Result.getFields()![2].getSize()?.getWidth()).to(equal(fieldWidth))
                
                expect(row3Result.getFields()![0].getCode()).to(equal(richTextField))
                expect(row3Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                
                expect(row4Result.getFields()![0].getCode()).to(equal(attachmentField))
                expect(row4Result.getFields()![1].getCode()).to(equal(linkField))
                expect(row4Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row4Result.getFields()![1].getSize()?.getWidth()).to(equal(fieldWidth))
                
                expect(tableResult.getFields()![0].getCode()).to(equal(textInTableField))
                expect(tableResult.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                
                let previewApp: PreviewApp? = PreviewApp(guestSpaceAppId, -1)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp!], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModuleGuestSpace, appId: guestSpaceAppId)
            }
            
            it("Test_067_Success_RevisionDefault") {
                var result = TestCommonHandling.awaitAsync(appModule.getFormLayout(appId, true)) as! FormLayout
                let currentRevision = Int(result.getRevision()!)
                
                let updateFormLayout = TestCommonHandling.awaitAsync(appModule.updateFormLayout(appId, itemLayoutRequest!, -1)) as! BasicResponse
                result = TestCommonHandling.awaitAsync(appModule.getFormLayout(appId, true)) as! FormLayout
                
                let row1Result = result.getLayout()![0] as! RowLayout
                let row2Result = result.getLayout()![1] as! RowLayout
                let row3Result = result.getLayout()![2] as! RowLayout
                let row4Result = result.getLayout()![3] as! RowLayout
                let tableResult = result.getLayout()![4] as! SubTableLayout
                
                expect(Int(updateFormLayout.getRevision()!)).to(equal(currentRevision! + 1))
                
                expect(row1Result.getFields()![0].getCode()).to(equal(numberField))
                expect(row1Result.getFields()![1].getCode()).to(equal(numberRequireField))
                expect(row1Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row1Result.getFields()![1].getSize()?.getWidth()).to(equal(fieldWidth))
                
                expect(row2Result.getFields()![0].getCode()).to(equal(textField))
                expect(row2Result.getFields()![1].getCode()).to(equal(uniqueTextField))
                expect(row2Result.getFields()![2].getCode()).to(equal(dateField))
                expect(row2Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row2Result.getFields()![1].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row2Result.getFields()![2].getSize()?.getWidth()).to(equal(fieldWidth))
                
                expect(row3Result.getFields()![0].getCode()).to(equal(richTextField))
                expect(row3Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                
                expect(row4Result.getFields()![0].getCode()).to(equal(attachmentField))
                expect(row4Result.getFields()![1].getCode()).to(equal(linkField))
                expect(row4Result.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
                expect(row4Result.getFields()![1].getSize()?.getWidth()).to(equal(fieldWidth))
                
                expect(tableResult.getFields()![0].getCode()).to(equal(textInTableField))
                expect(tableResult.getFields()![0].getSize()?.getWidth()).to(equal(fieldWidth))
            }
            
            it("Test_071_Error_InvalidAppId") {
                // Nonexistent app id
                var result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(TestConstant.Common.NONEXISTENT_ID, itemLayoutRequest!)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Negative app id
                result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(TestConstant.Common.NEGATIVE_ID, itemLayoutRequest!)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Zero app is
                result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(0, itemLayoutRequest!)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                // Revert FormLayout changes
                let previewApp: PreviewApp? = PreviewApp(appId, -1)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp!], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
            }
        }
        
        describe("UpdateFormLayout_2") {
            beforeEach {
                // Clear update data
                itemLayoutRequest? = []
                rowLayout1 = RowLayout()
                rowLayout2 = RowLayout()
                rowLayout3 = RowLayout()
                rowLayout4 = RowLayout()
                fieldsRowLayout1 = [FieldLayout]()
                fieldsRowLayout2 = [FieldLayout]()
                fieldsRowLayout3 = [FieldLayout]()
                fieldsRowLayout4 = [FieldLayout]()
                subTableLayout = SubTableLayout()
                fieldSubTableLayout = [FieldLayout]()
                
                // The field size will be updated
                fieldSize?.setWidth(fieldWidth)
                
                // First row
                let fieldLayout1: FieldLayout? = FieldLayout()
                fieldLayout1?.setCode(numberField)
                fieldLayout1?.setType(FieldType.NUMBER.rawValue)
                fieldLayout1?.setSize(fieldSize)
                
                let fieldLayout2: FieldLayout? = FieldLayout()
                fieldLayout2?.setCode(numberRequireField)
                fieldLayout2?.setType(FieldType.NUMBER.rawValue)
                fieldLayout2?.setSize(fieldSize)
                
                fieldsRowLayout1?.append(fieldLayout1!)
                fieldsRowLayout1?.append(fieldLayout2!)
                rowLayout1?.setFields(fieldsRowLayout1)
                
                // Second row
                let fieldLayout3: FieldLayout? = FieldLayout()
                fieldLayout3?.setCode(textField)
                fieldLayout3?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
                fieldLayout3?.setSize(fieldSize)
                
                let fieldLayout4: FieldLayout? = FieldLayout()
                fieldLayout4?.setCode(uniqueTextField)
                fieldLayout4?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
                fieldLayout4?.setSize(fieldSize)
                
                let fieldLayout5: FieldLayout? = FieldLayout()
                fieldLayout5?.setCode(dateField)
                fieldLayout5?.setType(FieldType.DATE.rawValue)
                fieldLayout5?.setSize(fieldSize)
                
                fieldsRowLayout2?.append(fieldLayout3!)
                fieldsRowLayout2?.append(fieldLayout4!)
                fieldsRowLayout2?.append(fieldLayout5!)
                rowLayout2?.setFields(fieldsRowLayout2)
                
                // 3rd row
                let fieldLayout6: FieldLayout? = FieldLayout()
                fieldLayout6?.setCode(richTextField)
                fieldLayout6?.setType(FieldType.MULTI_LINE_TEXT.rawValue)
                fieldLayout6?.setSize(fieldSize)
                fieldsRowLayout3?.append(fieldLayout6!)
                rowLayout3?.setFields(fieldsRowLayout3)
                
                // 4rd row
                let fieldLayout7: FieldLayout? = FieldLayout()
                fieldLayout7?.setCode(attachmentField)
                fieldLayout7?.setType(FieldType.FILE.rawValue)
                fieldLayout7?.setSize(fieldSize)
                
                let fieldLayout8: FieldLayout? = FieldLayout()
                fieldLayout8?.setCode(linkField)
                fieldLayout8?.setType(FieldType.LINK.rawValue)
                fieldLayout8?.setSize(fieldSize)
                
                fieldsRowLayout4?.append(fieldLayout7!)
                fieldsRowLayout4?.append(fieldLayout8!)
                rowLayout4?.setFields(fieldsRowLayout4)
                
                // Subtable
                let fieldLayout9: FieldLayout? = FieldLayout()
                fieldLayout9?.setCode(textInTableField)
                fieldLayout9?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
                fieldLayout9?.setSize(fieldSize)
                
                fieldSubTableLayout?.append(fieldLayout9!)
                subTableLayout?.setFields(fieldSubTableLayout)
                subTableLayout?.setCode(tableField)
                
                // Assign itemLayout Request for update
                itemLayoutRequest?.append(rowLayout1!)
                itemLayoutRequest?.append(rowLayout2!)
                itemLayoutRequest?.append(rowLayout3!)
                itemLayoutRequest?.append(rowLayout4!)
                itemLayoutRequest?.append(subTableLayout!)
            }
            
            afterEach {
                let previewApp: PreviewApp? = PreviewApp(appId, -1)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp!], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
            }
            
            it("Test_072_Error_InvalidLayoutType") {
                let fieldLayout9: FieldLayout? = FieldLayout()
                fieldLayout9?.setCode(textField)
                fieldLayout9?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
                fieldLayout9?.setSize(fieldSize)
                
                var fieldSubTableLayout: [FieldLayout]? = [FieldLayout]()
                fieldSubTableLayout?.append(fieldLayout9!)
                subTableLayout?.setFields(fieldSubTableLayout)
                subTableLayout?.setCode(tableField)
                
                itemLayoutRequest?.append(subTableLayout!)
                let result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(appId, itemLayoutRequest!)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_FIELD_IN_TABLE_UPDATE_LAYOUT_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%LAYOUT", newTemplate: "4")
                expectedError.replaceValueError(_key: "layout[4].fields", oldTemplate: "%TABLE_CODE", newTemplate: tableField)
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_073_Error_InvalidFieldCode") {
                let INVALID_CODE = "INEXISTENT"
                let fieldLayout1: FieldLayout? = FieldLayout()
                fieldLayout1?.setCode(INVALID_CODE)
                fieldLayout1?.setType(FieldType.NUMBER.rawValue)
                fieldsRowLayout1?.append(fieldLayout1!)
                rowLayout1?.setFields(fieldsRowLayout1)
                itemLayoutRequest?.append(rowLayout1!)
                let result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(appId, itemLayoutRequest!)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_FIELD_CODE_UPDATE_LAYOUT_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%LAYOUT", newTemplate: "0")
                expectedError.replaceKeyError(oldTemplate: "%FIELD", newTemplate: "2")
                expectedError.replaceValueError(_key: "layout[0].fields[2].code", oldTemplate: "%CODE", newTemplate: INVALID_CODE)
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_074_Error_InvalidFieldType") {
                let fieldLayout1: FieldLayout? = FieldLayout()
                fieldLayout1?.setCode(numberField)
                fieldLayout1?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
                fieldsRowLayout1?.append(fieldLayout1!)
                rowLayout1?.setFields(fieldsRowLayout1)
                itemLayoutRequest?.append(rowLayout1!)
                let result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(appId, itemLayoutRequest!)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_UPDATE_LAYOUT_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%LAYOUT", newTemplate: "0")
                expectedError.replaceKeyError(oldTemplate: "%FIELD", newTemplate: "2")
                expectedError.replaceValueError(_key: "layout[0].fields[2].type", oldTemplate: "%CODE", newTemplate: numberField)
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_075_Error_InvalidRevision") {
                let INVALID_REVISION = 6789
                let result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(appId, itemLayoutRequest!, INVALID_REVISION)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_076_Error_Permission") {
                let appModuleWithoutPermission = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(appModuleWithoutPermission.updateFormLayout(appId, itemLayoutRequest!)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

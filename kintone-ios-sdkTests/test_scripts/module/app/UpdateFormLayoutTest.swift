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

class UpdateFormLayoutTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let APP_ID = 11 //TestConstant.InitData.SPACE_APP_ID!
        let GUEST_SPACE_APP_ID = TestConstant.InitData.GUEST_SPACE_APP_ID!
        
        var rowLayout1: RowLayout? = RowLayout()
        var fieldsRowLayout1: [FieldLayout]? = [FieldLayout]()
        var itemLayoutRequest: [ItemLayout]? = [ItemLayout]()
        var subTableLayout: SubTableLayout? = SubTableLayout()
        
        let FIELD_01 = "Text"
        let FIELD_02 = "Text_0"
        let FIELD_03 = "Number"
        let FIELD_04 = "Attachment"
        let FIELD_TABLE = "Table"
        let FIELD_05_TABLE = "Text_1"
        let FIELD_WIDTH = "288"
        
        beforeSuite {
            // Clear update data
            itemLayoutRequest? = []
            rowLayout1 = RowLayout()
            subTableLayout = SubTableLayout()
            fieldsRowLayout1 = [FieldLayout]()
            
            let fieldLayout1: FieldLayout? = FieldLayout()
            fieldLayout1?.setCode(FIELD_01)
            fieldLayout1?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
            let fieldSize1: FieldSize? = FieldSize()
            fieldSize1?.setWidth(FIELD_WIDTH)
            fieldLayout1?.setSize(fieldSize1)
            
            fieldsRowLayout1?.append(fieldLayout1!)
            
            let fieldLayout2: FieldLayout? = FieldLayout()
            fieldLayout2?.setCode(FIELD_02)
            fieldLayout2?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
            let fieldSize2: FieldSize? = FieldSize()
            fieldSize2?.setWidth(FIELD_WIDTH)
            fieldLayout2?.setSize(fieldSize2)
            fieldsRowLayout1?.append(fieldLayout2!)
            
            let fieldLayout4: FieldLayout? = FieldLayout()
            fieldLayout4?.setCode(FIELD_03)
            fieldLayout4?.setType(FieldType.NUMBER.rawValue)
            let fieldSize4: FieldSize? = FieldSize()
            fieldSize4?.setWidth(FIELD_WIDTH)
            fieldLayout4?.setSize(fieldSize4)
            fieldsRowLayout1?.append(fieldLayout4!)
            
            let fieldLayout5: FieldLayout? = FieldLayout()
            fieldLayout5?.setCode(FIELD_04)
            fieldLayout5?.setType(FieldType.FILE.rawValue)
            let fieldSize5: FieldSize? = FieldSize()
            fieldSize5?.setWidth(FIELD_WIDTH)
            fieldLayout5?.setSize(fieldSize5)
            fieldsRowLayout1?.append(fieldLayout5!)
            
            rowLayout1?.setFields(fieldsRowLayout1)
            
            // Subtable Layout
            var fieldSubTableLayout: [FieldLayout]? = [FieldLayout]()
            
            let fieldLayout3: FieldLayout? = FieldLayout()
            fieldLayout3?.setCode(FIELD_05_TABLE)
            fieldLayout3?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
            let fieldSize3: FieldSize? = FieldSize()
            fieldSize3?.setWidth(FIELD_WIDTH)
            fieldLayout3?.setSize(fieldSize3)
            
            fieldSubTableLayout?.append(fieldLayout3!)
            subTableLayout?.setFields(fieldSubTableLayout)
            subTableLayout?.setCode(FIELD_TABLE)
            
            // Assign itemLayout Request for update
            itemLayoutRequest?.append(rowLayout1!)
            itemLayoutRequest?.append(subTableLayout!)
        }
        
        afterSuite {
            // Revert changes
            let previewApp: PreviewApp? = PreviewApp(APP_ID, -1)
            _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp!], true))
            
            sleep(5) // Temp: should write an action waitForDeployStatus here
        }
        describe("UpdateFormLayout") {
            // ---------------- NORMAL SPACE
            it("Test_064_Error_APIToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.updateFormLayout(APP_ID, itemLayoutRequest!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            fit("Test_065_066_ValidData") {
                let a = TestCommonHandling.awaitAsync(appModule.updateFormLayout(APP_ID, itemLayoutRequest!))


                let result = TestCommonHandling.awaitAsync(appModule.getFormLayout(11, true)) as! FormLayout
                print("=========> Result <==========")
                dump(result)
                print("=========> End <==========")
                // Check Row data
                let rowResult = result.getLayout()![0] as! RowLayout
                dump(rowResult)

                XCTAssertEqual(rowResult.getFields()![0].getCode(), FIELD_01)
                XCTAssertEqual(rowResult.getFields()![1].getCode(), FIELD_02)
                XCTAssertEqual(rowResult.getFields()![2].getCode(), FIELD_03)
                XCTAssertEqual(rowResult.getFields()![3].getCode(), FIELD_04)
                XCTAssertEqual(rowResult.getFields()![0].getSize()?.getWidth(), FIELD_WIDTH)
                XCTAssertEqual(rowResult.getFields()![1].getSize()?.getWidth(), FIELD_WIDTH)
                XCTAssertEqual(rowResult.getFields()![2].getSize()?.getWidth(), FIELD_WIDTH)
                XCTAssertEqual(rowResult.getFields()![3].getSize()?.getWidth(), FIELD_WIDTH)
                
                // Check SUBTABLE data
                let tableResult = result.getLayout()![1] as! SubTableLayout
                XCTAssertEqual(tableResult.getFields()![0].getCode(), FIELD_05_TABLE)
                XCTAssertEqual(tableResult.getFields()![0].getSize()?.getWidth(), FIELD_WIDTH)
            }
            
            it("Test_067_RevisionDefault") {
                let DEFAULT_REVISION = -1
                _ = TestCommonHandling.awaitAsync(appModule.updateFormLayout(APP_ID, itemLayoutRequest!, DEFAULT_REVISION))
                
                let result = TestCommonHandling.awaitAsync(appModule.getFormLayout(APP_ID, true)) as! FormLayout
                
                // Check Row data
                let rowResult = result.getLayout()![0] as! RowLayout
                XCTAssertEqual(rowResult.getFields()![0].getCode(), FIELD_01)
                XCTAssertEqual(rowResult.getFields()![1].getCode(), FIELD_02)
                XCTAssertEqual(rowResult.getFields()![2].getCode(), FIELD_03)
                XCTAssertEqual(rowResult.getFields()![3].getCode(), FIELD_04)
                XCTAssertEqual(rowResult.getFields()![0].getSize()?.getWidth(), FIELD_WIDTH)
                XCTAssertEqual(rowResult.getFields()![1].getSize()?.getWidth(), FIELD_WIDTH)
                XCTAssertEqual(rowResult.getFields()![2].getSize()?.getWidth(), FIELD_WIDTH)
                XCTAssertEqual(rowResult.getFields()![3].getSize()?.getWidth(), FIELD_WIDTH)
                
                // Check SUBTABLE data
                let tableResult = result.getLayout()![1] as! SubTableLayout
                XCTAssertEqual(tableResult.getFields()![0].getCode(), FIELD_05_TABLE)
                XCTAssertEqual(tableResult.getFields()![0].getSize()?.getWidth(), FIELD_WIDTH)
            }
            
            it("Test_071_Error_InvalidAppID") {
                // nonexístent
                var result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(TestConstant.Common.NONEXISTENT_ID, itemLayoutRequest!)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
                
                // negative
                result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(-1, itemLayoutRequest!)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // zero appID
                result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(0, itemLayoutRequest!)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)

            }
            it("Test_074_Error_InvalidFieldType") {
                // Set Number type for Single Line Text field
                let fieldLayout1: FieldLayout? = FieldLayout()
                fieldLayout1?.setCode(FIELD_01)
                fieldLayout1?.setType(FieldType.NUMBER.rawValue)
                fieldsRowLayout1?.append(fieldLayout1!)
                
                rowLayout1?.setFields(fieldsRowLayout1)
                itemLayoutRequest?.append(rowLayout1!)
                itemLayoutRequest?.append(subTableLayout!)
                
                // nonexístent
                let result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(APP_ID, itemLayoutRequest!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_UPDATE_LAYOUT_ERROR()!
                // temporary set Hard Value -> manual wait for function create new app
                expectedError.replaceKeyError(oldTemplate: "%LAYOUT", newTemplate: "0")
                expectedError.replaceKeyError(oldTemplate: "%FIELD", newTemplate: "4")
                expectedError.replaceValueError(_key: "layout[0].fields[4].type", oldTemplate: "%CODE", newTemplate: "Text")
                
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
                itemLayoutRequest?.append(subTableLayout!)
                
                // nonexitstent
                let result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(APP_ID, itemLayoutRequest!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!

                var expectedError = KintoneErrorParser.NONEXISTENT_FIELD_CODE_UPDATE_LAYOUT_ERROR()!
                // temporary set Hard Value -> manual wait for function create new app
                expectedError.replaceKeyError(oldTemplate: "%LAYOUT", newTemplate: "0")
                expectedError.replaceKeyError(oldTemplate: "%FIELD", newTemplate: "4")
                expectedError.replaceValueError(_key: "layout[0].fields[4].code", oldTemplate: "%CODE", newTemplate: INVALID_CODE)
                
                TestCommonHandling.compareError(actualError, expectedError)

            }
            it("Test_072_Error_InvalidLayoutType") {
                // Set field 1 (code: Text) is not in the table
                let fieldLayout3: FieldLayout? = FieldLayout()
                fieldLayout3?.setCode(FIELD_01)
                fieldLayout3?.setType(FieldType.SINGLE_LINE_TEXT.rawValue)
                let fieldSize3: FieldSize? = FieldSize()
                fieldSize3?.setWidth(FIELD_WIDTH)
                fieldLayout3?.setSize(fieldSize3)
                
                var fieldSubTableLayout: [FieldLayout]? = [FieldLayout]()
                fieldSubTableLayout?.append(fieldLayout3!)
                subTableLayout?.setFields(fieldSubTableLayout)
                subTableLayout?.setCode(FIELD_TABLE)
                
                itemLayoutRequest?.append(subTableLayout!)
                
                let result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(APP_ID, itemLayoutRequest!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!

                var expectedError = KintoneErrorParser.NONEXISTENT_FIELD_IN_TABLE_UPDATE_LAYOUT_ERROR()!
                // temporary set Hard Value -> manual wait for function create new app
                expectedError.replaceKeyError(oldTemplate: "%LAYOUT", newTemplate: "1")
                expectedError.replaceValueError(_key: "layout[1].fields", oldTemplate: "%TABLE_CODE", newTemplate: FIELD_TABLE)
                
                TestCommonHandling.compareError(actualError, expectedError)

            }
            it("Test_075_Error_InvalidRevision") {
                // Set field 1 (code: Text) is not in the table
                let INVALID_REVISION = 6789
                
                let result = TestCommonHandling.awaitAsync(appModule.updateFormLayout(APP_ID, itemLayoutRequest!, INVALID_REVISION)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(APP_ID))
                TestCommonHandling.compareError(actualError, expectedError)

            }
            xit("Test_076_Error_Permission") {
                let appModuleWithoutPermission = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                
                // Set field 1 (code: Text) is not in the table
                let result = TestCommonHandling.awaitAsync(appModuleWithoutPermission.updateFormLayout(APP_ID, itemLayoutRequest!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)

            }
            // ---------------- GUEST SPACE
            xit("Test_065_066_GuestSpace_ValidData") {
                let appModuleGuestSpace = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateFormLayout(GUEST_SPACE_APP_ID, itemLayoutRequest!))
                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormLayout(GUEST_SPACE_APP_ID, true)) as! FormLayout
                
                // Check Row data
                let rowResult = result.getLayout()![0] as! RowLayout
                XCTAssertEqual(rowResult.getFields()![0].getCode(), FIELD_01)
                XCTAssertEqual(rowResult.getFields()![1].getCode(), FIELD_02)
                XCTAssertEqual(rowResult.getFields()![2].getCode(), FIELD_03)
                XCTAssertEqual(rowResult.getFields()![3].getCode(), FIELD_04)
                XCTAssertEqual(rowResult.getFields()![0].getSize()?.getWidth(), FIELD_WIDTH)
                XCTAssertEqual(rowResult.getFields()![1].getSize()?.getWidth(), FIELD_WIDTH)
                XCTAssertEqual(rowResult.getFields()![2].getSize()?.getWidth(), FIELD_WIDTH)
                XCTAssertEqual(rowResult.getFields()![3].getSize()?.getWidth(), FIELD_WIDTH)
                
                // Check SUBTABLE data
                let tableResult = result.getLayout()![1] as! SubTableLayout
                XCTAssertEqual(tableResult.getFields()![0].getCode(), FIELD_05_TABLE)
                XCTAssertEqual(tableResult.getFields()![0].getSize()?.getWidth(), FIELD_WIDTH)
            }
        }
    }
}

//
// kintone-ios-sdkTests
// Created on 5/7/19
// 

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class AddRecordTest: QuickSpec {
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        let appId = TestConstant.InitData.APP_ID!
        
        let textField: String = TestConstant.InitData.TEXT_FIELD
        let numberField: String = TestConstant.InitData.NUMBER_FIELD
        
        describe("AddRecord") {
            it("Test_027_Success_ValidData") {
                // Set field value and add record
                let textFieldValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue as Any)
                
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                
                // Verify record info
                expect(recordId).toNot(beNil())
                expect(addRecordResponse.getRevision()).to(equal(1))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect(value.getValue() as? String).to(equal(textFieldValue))
                    }
                }
                
                // Delete test data
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId]))
            }
            
            it("Test_027_Success_ValidData_ApiToken") {
                let apiToken = TestConstant.InitData.APP_API_TOKEN
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(apiToken))
                let textFieldValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue as Any)
                
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.addRecord(appId, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                
                expect(recordId).toNot(beNil())
                expect(addRecordResponse.getRevision()).to(equal(1))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect(value.getValue() as? String).to(equal(textFieldValue))
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.deleteRecords(appId, [recordId]))
            }
            
            it("Test_028_Error_NonexistentAppId") {
                let nonexistentId = TestConstant.Common.NONEXISTENT_ID
                let textFieldValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue as Any)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(nonexistentId, testData)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError  = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(nonexistentId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_029_Error_NegativeAppId") {
                let negativeId = TestConstant.Common.NEGATIVE_ID
                let textFieldValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue as Any)
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(negativeId, testData)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError  = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_030_Error_InputTextToNumberField") {
                let testData = RecordUtils.setRecordData([:], numberField, FieldType.NUMBER, "inputTextToNumber")
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[\(numberField)]")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_031_Error_DuplicateDataForProhibitDuplicateValue") {
                let appHasProhibitDuplicateFieldId = TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, "prohibitValue")
                let addRecordRespone = TestCommonHandling.awaitAsync(recordModule.addRecord(appHasProhibitDuplicateFieldId, testData)) as! AddRecordResponse
                
                let recordId = addRecordRespone.getId()!
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(appHasProhibitDuplicateFieldId, testData)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(textField)")
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appHasProhibitDuplicateFieldId, [recordId]))
            }
            
            it("Test_035_Success_WithoutRecordData") {
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, nil)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                
                expect(recordId).toNot(beNil())
                expect(addRecordResponse.getRevision()).to(equal(1))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect(value.getValue() as? String).to(equal(""))
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId]))
            }
            
            it("Test_036_Error_WithoutRequiredField") {
                let appHasRequiredFieldId = TestConstant.InitData.APP_ID_HAS_REQUIRED_FIELDS!
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(appHasRequiredFieldId, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(textField)")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_039_Success_ValidData_GuestSpace") {
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                let textFieldValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue as Any)
                
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(guestSpaceAppId, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                
                expect(recordId).toNot(beNil())
                expect(addRecordResponse.getRevision()).to(equal(1))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect(value.getValue() as? String).to(equal(textFieldValue))
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(guestSpaceAppId, [recordId]))
            }
            
            it("Test_041_Error_WithoutAddRecordPermissionOnApp") {
                let recordModuleWithoutAddPermissionApp = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_ADD_RECORDS_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_ADD_RECORDS_PERMISSION))
                let textFieldValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue as Any)
                
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutAddPermissionApp.addRecord(appId, testData)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_045_Success_BlankApp") {
                let blankAppId = TestConstant.InitData.APP_BLANK_ID!
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(blankAppId, nil)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                
                expect(recordId).toNot(beNil())
                expect(addRecordResponse.getRevision()).to(equal(1))
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(blankAppId, [recordId]))
            }
        }
    }
}

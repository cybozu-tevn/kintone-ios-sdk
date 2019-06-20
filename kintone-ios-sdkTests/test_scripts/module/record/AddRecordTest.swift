///**
/**
 kintone-ios-sdkTests
 Created on 5/7/19
 */

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class AddRecordTest: QuickSpec {
    override func spec() {
        let APP_ID = TestConstant.InitData.APP_ID!
        let APP_HAVE_REQUIRED_FIELD_ID = TestConstant.InitData.APP_ID_HAS_REQUIRED_FIELDS!
        let NONEXISTENT_ID = TestConstant.Common.NONEXISTENT_ID
        let NEGATIVE_ID = TestConstant.Common.NEGATIVE_ID
        let GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_ID!
        let APP_GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let APP_BLANK_ID = TestConstant.InitData.APP_BLANK_ID
        let APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID = TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!
        let APP_API_TOKEN = TestConstant.InitData.APP_API_TOKEN
        
        var recordID: Int?
        var recordRevision: Int?
        let TEXT_FIELD: String = TestConstant.InitData.TEXT_FIELD
        let NUMBER_FILED: String = TestConstant.InitData.NUMBER_FIELD
        var recordTextValue: String?
        var testData: Dictionary<String, FieldValue>! = [:]
        
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("AddRecord") {
            it("Test_027_Success_ValidData") {
                recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordID = addRecordResponse.getId()
                recordRevision = addRecordResponse.getRevision()
                
                expect(recordID).toNot(beNil())
                expect(1).to(equal(recordRevision))
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == TEXT_FIELD) {
                        expect(recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, [recordID!]))
            }
            
            it("Test_027_Success_APITokenValidData") {
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(APP_API_TOKEN))
                recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordID = addRecordResponse.getId()
                recordRevision = addRecordResponse.getRevision()
                
                expect(recordID).toNot(beNil())
                expect(1).to(equal(recordRevision))
                let result = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.getRecord(APP_ID, recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == TEXT_FIELD) {
                        expect(recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.deleteRecords(APP_ID, [recordID!]))
            }
            
            it("Test_028_Error_NonexistentAppID") {
                recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(NONEXISTENT_ID, testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                //Get expect error
                var expectedError  = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_029_Error_NegativeAppID") {
                recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(NEGATIVE_ID, testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError  = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }// End it
            
            //To test this case please set up an application have number field
            it("Test_030_Error_InputTextToNumberField") {
                testData = RecordUtils.setRecordData([:], NUMBER_FILED, FieldType.NUMBER, "inputTextToNumber")
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[\(NUMBER_FILED)]")
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            //To test this case please set up an application have prohibit duplicate value field. fieldCode = RECORD_TEXT_FIELD
            it("Test_031_Error_DuplicateDataForProhibitDuplicateValue") {
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, "prohibitValue")
                let addRecord = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, testData)) as! AddRecordResponse
                recordID = addRecord.getId()
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(TEXT_FIELD)")
                
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, [recordID!]))
            }
            
            it("Test_035_Success_WithoutRecordData") {
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, nil)) as! AddRecordResponse
                recordID = addRecordResponse.getId()
                recordRevision = addRecordResponse.getRevision()
                
                expect(recordID).toNot(beNil())
                expect(1).to(equal(recordRevision))
                
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == TEXT_FIELD) {
                        expect("").to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, [recordID!]))
            }
            
            //To test this case please set up an application have required field. fieldCode = RECORD_TEXT_FIELD
            it("Test_036_Error_WithoutRequiredField") {
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_HAVE_REQUIRED_FIELD_ID, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(TEXT_FIELD)")
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_039_Success_ValidDataGuestSpace") {
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    GUEST_SPACE_ID))
                recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(APP_GUEST_SPACE_ID, testData)) as! AddRecordResponse
                recordID = addRecordResponse.getId()
                recordRevision = addRecordResponse.getRevision()
                
                expect(recordID).toNot(beNil())
                expect(1).to(equal(recordRevision))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(APP_GUEST_SPACE_ID, recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == TEXT_FIELD) {
                        expect(recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(APP_GUEST_SPACE_ID, [recordID!]))
            }
            
            it("Test_041_Error_WithoutAddRecordPermissionOnApp") {
                let recordModuleWithoutAddPermissionApp = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_ADD_RECORDS_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_ADD_RECORDS_PERMISSION))
                
                recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutAddPermissionApp.addRecord(APP_ID, testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_045_Success_BlankApp") {
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_BLANK_ID!, nil)) as! AddRecordResponse
                recordID = addRecordResponse.getId()
                recordRevision = addRecordResponse.getRevision()
                
                expect(recordID).toNot(beNil())
                expect(1).to(equal(recordRevision))
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_BLANK_ID!, [recordID!]))
            }// End it
        }// End describe
    }// End spec function
}

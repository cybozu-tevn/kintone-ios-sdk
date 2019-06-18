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
    private var recordModule: Record!
    private var recordModuleGuestSpace: Record!
    private var recordModuleWithoutAddPermissionApp: Record!
    private var recordModuleWithAPIToken: Record!
    
    private let APP_ID = TestConstant.InitData.APP_ID!
    private let APP_HAVE_REQUIRED_FIELD_ID = TestConstant.InitData.APP_ID_HAS_REQUIRED_FIELDS!
    private let NONEXISTENT_ID = TestConstant.Common.NONEXISTENT_ID
    private let NEGATIVE_ID = TestConstant.Common.NEGATIVE_ID
    private let GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_ID!
    private let APP_GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_APP_ID!
    private let APP_BLANK_ID = TestConstant.InitData.APP_BLANK_ID
    private let APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID = TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!
    private let APP_API_TOKEN = TestConstant.InitData.APP_API_TOKEN

    private var recordID: Int?
    private var recordRevision: Int?
    private let RECORD_TEXT_FIELD: String = TestConstant.InitData.TEXT_FIELD
    private let RECORD_NUMBER_FILED: String = TestConstant.InitData.NUMBER_FIELD
    private var recordTextValue: String?
    private var testData: Dictionary<String, FieldValue>! = [:]
    
    override func spec() {
        describe("AddRecord") {
            beforeSuite {
                self.recordModule = Record(TestCommonHandling.createConnection())
                self.recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    self.GUEST_SPACE_ID))
                self.recordModuleWithoutAddPermissionApp = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_ADD_RECORDS_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_ADD_RECORDS_PERMISSION))
                self.recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(self.APP_API_TOKEN))
            }
            
            it("Test_027_Success_ValidData") {
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                self.recordRevision = addRecordResponse.getRevision()
                
                expect(self.recordID).toNot(beNil())
                expect(1).to(equal(self.recordRevision))
                let result = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, self.recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == self.RECORD_TEXT_FIELD) {
                        expect(self.recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, [self.recordID!]))
            }
            
            it("Test_027_Success_APITokenValidData") {
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModuleWithAPIToken.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                self.recordRevision = addRecordResponse.getRevision()
                
                expect(self.recordID).toNot(beNil())
                expect(1).to(equal(self.recordRevision))
                let result = TestCommonHandling.awaitAsync(self.recordModuleWithAPIToken.getRecord(self.APP_ID, self.recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == self.RECORD_TEXT_FIELD) {
                        expect(self.recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(self.recordModuleWithAPIToken.deleteRecords(self.APP_ID, [self.recordID!]))
            }
            
            it("Test_028_Error_NonexistentAppID") {
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let result = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.NONEXISTENT_ID, self.testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                //Get expect error
                var expectedError  = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_029_Error_NegativeAppID") {
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let result = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.NEGATIVE_ID, self.testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError  = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }// End it
            
            //To test this case please set up an application have number field
            it("Test_030_Error_InputTextToNumberField") {
                self.testData = RecordUtils.setRecordData([:], self.RECORD_NUMBER_FILED, FieldType.NUMBER, "inputTextToNumber")
                let result = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[\(self.RECORD_NUMBER_FILED)]")
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            //To test this case please set up an application have prohibit duplicate value field. fieldCode = RECORD_TEXT_FIELD
            it("Test_031_Error_DuplicateDataForProhibitDuplicateValue") {
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, "prohibitValue")
                let addRecord = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, self.testData)) as! AddRecordResponse
                self.recordID = addRecord.getId()
                let result = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, self.testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(self.RECORD_TEXT_FIELD)")
                
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, [self.recordID!]))
            }
            
            it("Test_035_Success_WithoutRecordData") {
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, nil)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                self.recordRevision = addRecordResponse.getRevision()
                
                expect(self.recordID).toNot(beNil())
                expect(1).to(equal(self.recordRevision))
                
                let result = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, self.recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == self.RECORD_TEXT_FIELD) {
                        expect("").to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, [self.recordID!]))
            }
            
            //To test this case please set up an application have required field. fieldCode = RECORD_TEXT_FIELD
            it("Test_036_Error_WithoutRequiredField") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_HAVE_REQUIRED_FIELD_ID, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(self.RECORD_TEXT_FIELD)")
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_039_Success_ValidDataGuestSpace") {
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.addRecord(self.APP_GUEST_SPACE_ID, self.testData)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                self.recordRevision = addRecordResponse.getRevision()
                
                expect(self.recordID).toNot(beNil())
                expect(1).to(equal(self.recordRevision))
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getRecord(self.APP_GUEST_SPACE_ID, self.recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == self.RECORD_TEXT_FIELD) {
                        expect(self.recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.deleteRecords(self.APP_GUEST_SPACE_ID, [self.recordID!]))
            }
            
            it("Test_041_Error_WithoutAddRecordPermissionOnApp") {
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let result = TestCommonHandling.awaitAsync(self.recordModuleWithoutAddPermissionApp.addRecord(self.APP_ID, self.testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_045_Success_BlankApp") {
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_BLANK_ID, nil)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                self.recordRevision = addRecordResponse.getRevision()
                
                expect(self.recordID).toNot(beNil())
                expect(1).to(equal(self.recordRevision))
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_BLANK_ID, [self.recordID!]))
            }// End it
        }// End describe
    }// End spec function
}

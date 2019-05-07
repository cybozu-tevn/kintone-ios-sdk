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

class AddRecordTest: QuickSpec{
    let APP_ID = 1
    let APP_NONEXISTENT_ID = 1000
    let APP_NEGATIVE_ID = -1
    
    var recordID: Int? = nil
    var recordRevision: Int? = nil
    let RECORD_TEXT_FIELD: String = "txt_Name"
    let RECORD_NUMBER_FILED: String = "txt_Number"
    var recordTextValue: String? = nil
    var testData: Dictionary<String, FieldValue>! = [:]
    
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        
        beforeSuite {
            // Add app to test
        }
        
        afterSuite {
            // Remove testing data
        }
        
        describe("AddRecord"){
            it("Test_27_Success_ValidData"){
                self.recordTextValue = TestCommonHandling.randomString(length: 64)
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                self.recordRevision = addRecordResponse.getRevision()
                
                expect(self.recordID).toNot(beNil())
                expect(1).to(equal(self.recordRevision))
                
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, self.recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()!{
                    if(key == self.RECORD_TEXT_FIELD){
                        expect(self.recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, [self.recordID!]))
                
            }// End it
            
            it("Test_28_Error_NonexistentAppID"){
                self.recordTextValue = TestCommonHandling.randomString(length: 64)
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_NONEXISTENT_ID, self.testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                //Get expect error
                var expectedError  = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.APP_NONEXISTENT_ID))
                
                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
            }// End it
            
            it("Test_29_Error_NegativeAppID"){
                self.recordTextValue = TestCommonHandling.randomString(length: 64)
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_NEGATIVE_ID, self.testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError  = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                
                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
            }// End it
            
            //To test this case please set up an application have number field
            it("Test_30_Error_InputTextToNumberField"){
                self.testData = TestCommonHandling.addData([:], self.RECORD_NUMBER_FILED, FieldType.NUMBER, "inputTextToNumber")
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_ID, self.testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[\(self.RECORD_NUMBER_FILED)]")
                
                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
            }// End it
            
            //To test this case please set up an application have prohibit duplicate value field. fieldCode = RECORD_TEXT_FIELD
            it("Test_31_Error_DuplicateDataForProhibitDuplicateValue"){
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, "prohibitValue")
                let addRecord = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                self.recordID = addRecord.getId()
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_ID, self.testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(self.RECORD_TEXT_FIELD)")
                
                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, [self.recordID!]))
            }// End it
            
            fit("Test_35_Success_WithoutRecordData"){
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_ID, nil)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                self.recordRevision = addRecordResponse.getRevision()
                
                expect(self.recordID).toNot(beNil())
                expect(1).to(equal(self.recordRevision))
                
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, self.recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()!{
                    if(key == self.RECORD_TEXT_FIELD){
                        expect("").to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, [self.recordID!]))
                
            }// End it
            
        }// End describe
    }// End spec function
}

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
    let APP_HAVE_REQUIRED_FIELD_ID = 4
    let APP_NONEXISTENT_ID = 1000
    let APP_NEGATIVE_ID = -1
    let GUESTSPACE_APP_ID = 2
    let APP_BLANK_ID = 6 // Create app without fields
    
    var recordID: Int? = nil
    var recordRevision: Int? = nil
    let RECORD_TEXT_FIELD: String = "txt_Name"
    let RECORD_NUMBER_FILED: String = "txt_Number"
    var recordTextValue: String? = nil
    var testData: Dictionary<String, FieldValue>! = [:]
    
    //User without permisstion to add record
    let CRED_USERNAME_WITHOUT_PEMISSION_ADD_RECORD = "user1"
    let CRED_PASSWORD_WITHOUT_PEMISSION_ADD_RECORD = "user1@123"
    let APP_API_TOKEN = "8q3KBOy9eDgsHQmvyE4SXDB2YB4i1ngN4zApwhUz"
    
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
            TestsConstants.ADMIN_USERNAME,
            TestsConstants.ADMIN_PASSWORD,
            self.GUESTSPACE_APP_ID))
        let recordModuleWithoutAddPermissionApp = Record(TestCommonHandling.createConnection(
            self.CRED_USERNAME_WITHOUT_PEMISSION_ADD_RECORD,
            self.CRED_PASSWORD_WITHOUT_PEMISSION_ADD_RECORD))
        let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(self.APP_API_TOKEN))

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
            
            it("Test_27_Success_APITokenValidData"){
                self.recordTextValue = TestCommonHandling.randomString(length: 64)
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                self.recordRevision = addRecordResponse.getRevision()
                
                expect(self.recordID).toNot(beNil())
                expect(1).to(equal(self.recordRevision))
                let result = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.getRecord(self.APP_ID, self.recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()!{
                    if(key == self.RECORD_TEXT_FIELD){
                        expect(self.recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.deleteRecords(self.APP_ID, [self.recordID!]))
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
            
            it("Test_35_Success_WithoutRecordData"){
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
            
            //To test this case please set up an application have required field. fieldCode = RECORD_TEXT_FIELD
            it("Test_36_Error_WithoutRequiredField"){
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_HAVE_REQUIRED_FIELD_ID, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(self.RECORD_TEXT_FIELD)")
                
                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
            }// End it
            
            it("Test_39_Success_ValidDataGuestSpace"){
                self.recordTextValue = TestCommonHandling.randomString(length: 64)
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(self.GUESTSPACE_APP_ID, self.testData)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                self.recordRevision = addRecordResponse.getRevision()
                
                expect(self.recordID).toNot(beNil())
                expect(1).to(equal(self.recordRevision))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(self.GUESTSPACE_APP_ID, self.recordID!)) as! GetRecordResponse
                for(key, value) in result.getRecord()!{
                    if(key == self.RECORD_TEXT_FIELD){
                        expect(self.recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(self.GUESTSPACE_APP_ID, [self.recordID!]))
            }// End it
            
            it("Test_41_Error_WithoutAddRecordPermissionOnApp"){
                self.recordTextValue = TestCommonHandling.randomString(length: 64)
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutAddPermissionApp.addRecord(self.APP_ID, self.testData)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
            }// End it
            
            it("Test_45_Success_BlankApp"){
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_BLANK_ID, nil)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                self.recordRevision = addRecordResponse.getRevision()
                
                expect(self.recordID).toNot(beNil())
                expect(1).to(equal(self.recordRevision))
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.GUESTSPACE_APP_ID, [self.recordID!]))
            }// End it
        }// End describe
    }// End spec function
}

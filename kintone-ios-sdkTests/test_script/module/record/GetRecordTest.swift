//
//  GetRecordTest.swift
//  kintone-ios-sdkTests
//
//  Created by Hoang Van Phong on 5/6/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class GetRecordTest: QuickSpec {
    
    let APP_ID = 1
    let APP_NONEXISTENT_ID = 1000
    let APP_NEGATIVE_ID = -1
    let APP_BLANK_ID = 4 //Create app without fields
    let GUESTSPACE_APP_ID = 2
    
    let RECORD_ID = 1
    let RECORD_NONEXISTENT_ID = 1000
    let RECORD_NEGATIVE_ID = -1
    
    let APP_API_TOKEN = "8q3KBOy9eDgsHQmvyE4SXDB2YB4i1ngN4zApwhUz"
    
    let RECORD_TEXT_FIELD = "txt_Name"
    let RECORD_TEST_VALUE = "Phong Hoang"
    
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleWithoutViewPermisstionApp = Record(TestCommonHandling.createConnection(TestsConstants.CRED_USERNAME_WITHOUT_PEMISSION_VIEW_APP,
                                                                                               TestsConstants.CRED_PASSWORD_WITHOUT_PEMISSION_VIEW_APP))
        let recordModuleWithoutViewPermisstionRecord = Record(TestCommonHandling.createConnection(TestsConstants.CRED_USERNAME_WITHOUT_PEMISSION_VIEW_RECORD,
                                                                                               TestsConstants.CRED_PASSWORD_WITHOUT_PEMISSION_VIEW_RECORD))
        let recordModuleWithoutViewPermisstionField = Record(TestCommonHandling.createConnection(TestsConstants.CRED_USERNAME_WITHOUT_PEMISSION_VIEW_FIELD,
                                                                                               TestsConstants.CRED_PASSWORD_WITHOUT_PEMISSION_VIEW_FIELD))
        let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(TestsConstants.ADMIN_USERNAME, TestsConstants.ADMIN_PASSWORD, self.GUESTSPACE_APP_ID))
        let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(self.APP_API_TOKEN))
        
        beforeSuite {
            //Add app to test
            //Add record to test
        }
        
        afterSuite {
            //remove testing data
        }
        
        describe("GetRecord"){
            it("Test_3_Success_ValidData"){
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, self.RECORD_ID)) as! GetRecordResponse
                for(key, value) in result.getRecord()!{
                    if(key == self.RECORD_TEXT_FIELD){
                        expect(self.RECORD_TEST_VALUE).to(equal(value.getValue() as? String))
                    }
                }
            } //End it
            
            it("Test_3_Success_GuestSpaceValidData"){
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(self.GUESTSPACE_APP_ID, self.RECORD_ID)) as! GetRecordResponse
                for(key, value) in result.getRecord()!{
                    if(key == self.RECORD_TEXT_FIELD){
                        expect(self.RECORD_TEST_VALUE).to(equal(value.getValue() as? String))
                    }
                }
            } //End it
            
            it("Test_3_Success_APITokenValidData"){
                let result = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.getRecord(self.APP_ID, self.RECORD_ID)) as! GetRecordResponse
                for(key, value) in result.getRecord()!{
                    if(key == self.RECORD_TEXT_FIELD){
                        expect(self.RECORD_TEST_VALUE).to(equal(value.getValue() as? String))
                    }
                }
            } //End it
            
            it("Test_4_Error_NonexistentAppID"){
                //Get error from kintone
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_NONEXISTENT_ID, self.RECORD_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                //Get expect error
                var expectedError  = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.APP_NONEXISTENT_ID))

                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
            } //End it
            
            it("Test_4_Error_NegativeAppID"){
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_NEGATIVE_ID, self.RECORD_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError  = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                
                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
            }
            
            it("Test_5_Error_NonexistentRecordID"){
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, self.RECORD_NONEXISTENT_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.RECORD_NONEXISTENT_ID))
                
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
            } //End it
            
            
            it("Test_5_Error_NegativeRecordID"){
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, self.RECORD_NEGATIVE_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.RECORD_NEGATIVE_ID))

                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
            } //End it
            
            //When user don't have View records permission for app
            it("Test_8_Error_WithoutViewRecordPermission"){
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermisstionApp.getRecord(self.APP_ID, self.RECORD_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!

                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
            } //End it
            
            //When user don't have View records permission for record
            it("Test_9_Error_WithoutViewRecordPermission"){
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermisstionRecord.getRecord(self.APP_ID, self.RECORD_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                expect(expectedError.getCode()).to(equal(actualError!.getCode()))
                expect(expectedError.getMessage()).to(equal(actualError!.getMessage()))
                if(expectedError.getErrors() != nil){
                    expect(expectedError.getErrors()).to(equal(actualError!.getErrors()))
                }
            } //End it
            
            //When user don't have View records permission for field - ex: txt_Name field
            it("Test_10_Error_WithoutViewRecordPermission"){
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermisstionField.getRecord(self.APP_ID, self.RECORD_ID)) as! GetRecordResponse
                var fieldItems = [String]()
                for(key, _) in result.getRecord()!{
                    fieldItems.append(key)
                }
                expect(fieldItems).toNot(contain(self.RECORD_TEXT_FIELD))
            } //End it
            
            it("Test_13_Success_BlankApp"){
                var defaultKey =  [
                    "Created_datetime": "Created_datetime",
                    "$id" : "$id",
                    "Updated_datetime" : "Updated_datetime",
                    "$revision" : "$revision",
                    "Updated_by" : "Updated_by",
                    "Created_by" : "Created_by",
                    "Record_number" : "Record_number"
                ]
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_BLANK_ID, self.RECORD_ID)) as! GetRecordResponse
                for (key, _) in result.getRecord()!{
                    expect(defaultKey[key]).to(equal(key))
                }
            } //End it
        } //Enddescribe
    } //End spec func
}

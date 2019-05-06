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
    
    let RECORD_ID = 1
    let RECORD_NONEXISTENT_ID = 1000
    let RECORD_NEGATIVE_ID = -1
    
    let RECORD_TEXT_FIELD = "txt_Name"
    let RECORD_TEST_VALUE = "Phong Hoang"
    
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())

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
        } //Enddescribe
    } //End spec func
}

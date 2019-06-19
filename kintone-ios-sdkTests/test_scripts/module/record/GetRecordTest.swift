//
//  GetRecordTest.swift
//  kintone-ios-sdkTests
//
//  Created by Hoang Van Phong on 5/6/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class GetRecordTest: QuickSpec {
    let APP_ID = TestConstant.InitData.APP_ID
    let NONEXISTENT_ID = TestConstant.Common.NONEXISTENT_ID
    let NEGATIVE_ID = TestConstant.Common.NEGATIVE_ID
    let APP_BLANK_ID = TestConstant.InitData.APP_BLANK_ID
    let GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_ID
    let GUEST_SPACE_APP_ID = TestConstant.InitData.GUEST_SPACE_APP_ID
    let APP_API_TOKEN = TestConstant.InitData.APP_API_TOKEN
    
    //User without permisstion to view record details
    let USERNAME_WITHOUT_VIEW_RECORDS_PERMISSTION = TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION
    let PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION = TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION
    let USERNAME_WITHOUT_VIEW_RECORD_PERMISSION = TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION
    let PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION = TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION
    let USERNAME_WITHOUT_VIEW_FIELD_PERMISSION = TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION
    let PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION = TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION
    
    var recordId: Int?
    var recordGuestSpaceId: Int?
    let RECORD_NUMBER_FILED: String = TestConstant.InitData.NUMBER_FIELD
    let RECORD_TEXT_FIELD = TestConstant.InitData.TEXT_FIELD
    var recordTextValue: String?
    var testData: Dictionary<String, FieldValue>! = [:]
    
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleWithoutViewPermissionApp = Record(TestCommonHandling.createConnection(
            self.USERNAME_WITHOUT_VIEW_RECORDS_PERMISSTION,
            self.PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
        let recordModuleWithoutViewPermissionRecord = Record(TestCommonHandling.createConnection(
            self.USERNAME_WITHOUT_VIEW_RECORD_PERMISSION,
            self.PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
        let recordModuleWithoutViewPermissionField = Record(TestCommonHandling.createConnection(
            self.USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
            self.PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
        let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            self.GUEST_SPACE_ID!))
        let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(self.APP_API_TOKEN))
        
        beforeSuite {
            self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
            self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
            let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_ID!, self.testData)) as! AddRecordResponse
            self.recordId = addRecordResponse.getId()
            
            let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(self.GUEST_SPACE_APP_ID!, self.testData)) as! AddRecordResponse
            self.recordGuestSpaceId = addRecordGuestSpaceResponse.getId()
        }
        
        afterSuite {
            _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID!, [self.recordId!]))
        }
        
        describe("GetRecord") {
            fit("Test_003_Success_ValidData") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID!, self.recordId!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == self.RECORD_TEXT_FIELD) {
                        expect(self.recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
            }
            
            it("Test_003_Success_GuestSpaceValidData") {
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(self.GUEST_SPACE_APP_ID!, self.recordGuestSpaceId!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == self.RECORD_TEXT_FIELD) {
                        expect(self.recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
            }
            
            it("Test_003_Success_APITokenValidData") {
                let result = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.getRecord(self.APP_ID!, self.recordId!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == self.RECORD_TEXT_FIELD) {
                        expect(self.recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
            }
            
            it("Test_004_Error_NonexistentAppID") {
                //Get error from kintone
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.NONEXISTENT_ID, self.recordId!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                //Get expect error
                var expectedError  = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_004_Error_NegativeAppID") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.NEGATIVE_ID, self.recordId!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError  = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_005_Error_NonexistentRecordID") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID!, self.NONEXISTENT_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_005_Error_NegativeRecordID") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID!, self.NEGATIVE_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NEGATIVE_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // When user don't have View records permission for app
            it("Test_008_Error_WithoutViewAppPermission") {
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermissionApp.getRecord(self.APP_ID!, self.recordId!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // When user don't have View records permission for record
            it("Test_009_Error_WithoutViewRecordPermission") {
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermissionRecord.getRecord(self.APP_ID!, self.recordId!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // When user don't have View records permission for field - ex: txt_Name field
            it("Test_010_Error_WithoutFieldRecordPermission") {
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermissionField.getRecord(self.APP_ID!, self.recordId!)) as! GetRecordResponse
                var fieldItems = [String]()
                for(key, _) in result.getRecord()! {
                    fieldItems.append(key)
                }
                expect(fieldItems).toNot(contain(self.RECORD_TEXT_FIELD))
            }
            
            it("Test_013_Success_BlankApp") {
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_BLANK_ID, nil)) as! AddRecordResponse
                let blankRecordId = addRecordResponse.getId()
                
                var defaultKey =  [
                    "Created_datetime": "Created_datetime",
                    "$id": "$id",
                    "Updated_datetime": "Updated_datetime",
                    "$revision": "$revision",
                    "Updated_by": "Updated_by",
                    "Created_by": "Created_by",
                    "Record_number": "Record_number"
                ]
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_BLANK_ID, blankRecordId!)) as! GetRecordResponse
                for (key, _) in result.getRecord()! {
                    expect(defaultKey[key]).to(equal(key))
                }
            }
        }
    }
}

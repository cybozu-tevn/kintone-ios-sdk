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
    override func spec() {
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
        let RECORD_TEXT_FIELD = TestConstant.InitData.TEXT_FIELD
        var recordTextValue: String?
        var testData: Dictionary<String, FieldValue>! = [:]
        
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            GUEST_SPACE_ID!))
        
        beforeSuite {
            recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
            testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
            let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID!, testData)) as! AddRecordResponse
            recordId = addRecordResponse.getId()
            
            let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(GUEST_SPACE_APP_ID!, testData)) as! AddRecordResponse
            recordGuestSpaceId = addRecordGuestSpaceResponse.getId()
        }
        
        afterSuite {
            _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID!, [recordId!]))
        }
        
        describe("GetRecord") {
            it("Test_003_Success_ValidData") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID!, recordId!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == RECORD_TEXT_FIELD) {
                        expect(recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
            }
            
            it("Test_003_Success_GuestSpaceValidData") {
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(GUEST_SPACE_APP_ID!, recordGuestSpaceId!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == RECORD_TEXT_FIELD) {
                        expect(recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
            }
            
            it("Test_003_Success_APITokenValidData") {
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.getRecord(APP_ID!, recordId!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == RECORD_TEXT_FIELD) {
                        expect(recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
            }
            
            it("Test_004_Error_NonexistentAppID") {
                //Get error from kintone
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(NONEXISTENT_ID, recordId!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                //Get expect error
                var expectedError  = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_004_Error_NegativeAppID") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(NEGATIVE_ID, recordId!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError  = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_005_Error_NonexistentRecordID") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID!, NONEXISTENT_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_005_Error_NegativeRecordID") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID!, NEGATIVE_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NEGATIVE_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // When user don't have View records permission for app
            it("Test_008_Error_WithoutViewAppPermission") {
                let recordModuleWithoutViewPermissionApp = Record(TestCommonHandling.createConnection(
                    USERNAME_WITHOUT_VIEW_RECORDS_PERMISSTION,
                    PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermissionApp.getRecord(APP_ID!, recordId!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // When user don't have View records permission for record
            it("Test_009_Error_WithoutViewRecordPermission") {
                let recordModuleWithoutViewPermissionRecord = Record(TestCommonHandling.createConnection(
                    USERNAME_WITHOUT_VIEW_RECORD_PERMISSION,
                    PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermissionRecord.getRecord(APP_ID!, recordId!)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // When user don't have View records permission for field - ex: txt_Name field
            it("Test_010_Error_WithoutFieldRecordPermission") {
                let recordModuleWithoutViewPermissionField = Record(TestCommonHandling.createConnection(
                    USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
                    PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermissionField.getRecord(APP_ID!, recordId!)) as! GetRecordResponse
                var fieldItems = [String]()
                for(key, _) in result.getRecord()! {
                    fieldItems.append(key)
                }
                expect(fieldItems).toNot(contain(RECORD_TEXT_FIELD))
            }
            
            it("Test_013_Success_BlankApp") {
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_BLANK_ID, nil)) as! AddRecordResponse
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
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_BLANK_ID, blankRecordId!)) as! GetRecordResponse
                for (key, _) in result.getRecord()! {
                    expect(defaultKey[key]).to(equal(key))
                }
            }
        }
    }
}

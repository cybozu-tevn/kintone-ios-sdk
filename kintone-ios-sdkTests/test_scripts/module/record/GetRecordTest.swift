//
//  GetRecordTest.swift
//  kintone-ios-sdkTests
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class GetRecordTest: QuickSpec {
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        let appId = TestConstant.InitData.SPACE_APP_ID!
        let nonexistentId = TestConstant.Common.NONEXISTENT_ID
        let negativeId = TestConstant.Common.NEGATIVE_ID
        
        var recordId: Int!
        let textField = TestConstant.InitData.TEXT_FIELD
        var textFieldValue: String?
        var testData: Dictionary<String, FieldValue>! = [:]
        
        describe("GetRecord") {
            it("AddTestData_BeforeSuiteWorkaround") {
                textFieldValue = DataRandomization.generateString(prefix: "GetRecord", length: 10)
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
            }
            
            it("Test_003_Success_ValidData") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId!)) as! GetRecordResponse
                
                for(key, value) in result.getRecord()! {
                    if(key == textField) {
                        expect(value.getValue() as? String).to(equal(textFieldValue))
                    }
                }
            }
            
            it("Test_003_Success_ValidData_GuestSpace") {
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                
                let addRecordRsp = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(guestSpaceAppId, testData)) as! AddRecordResponse
                let recordGuestSpaceId = addRecordRsp.getId()!
                
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(guestSpaceAppId, recordGuestSpaceId)) as! GetRecordResponse
                
                for(key, value) in result.getRecord()! {
                    if(key == textField) {
                        expect(value.getValue() as? String).to(equal(textFieldValue))
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(guestSpaceAppId, [recordGuestSpaceId]))
            }
            
            it("Test_003_Success_ValidData_ApiToken") {
                let apiToken = TestConstant.InitData.SPACE_APP_API_TOKEN
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(apiToken))
                let result = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.getRecord(appId, recordId)) as! GetRecordResponse
                
                for(key, value) in result.getRecord()! {
                    if(key == textField) {
                        expect(value.getValue() as? String).to(equal(textFieldValue))
                    }
                }
            }
            
            it("Test_004_Error_NonexistentAppId") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(nonexistentId, recordId)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError  = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(nonexistentId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_004_Error_NegativeAppId") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(negativeId, recordId)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError  = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_005_Error_NonexistentRecordId") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, nonexistentId)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(nonexistentId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_005_Error_NegativeRecordId") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, negativeId)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(negativeId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // When user don't have View records permission for app
            it("Test_008_Error_WithoutViewAppPermission") {
                let usernameWithoutViewAppPermission = TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION
                let passwordWithoutViewAppPermission = TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION
                let recordModuleWithoutViewPermissionApp = Record(TestCommonHandling.createConnection(
                    usernameWithoutViewAppPermission,
                    passwordWithoutViewAppPermission))
                
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermissionApp.getRecord(appId, recordId)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // When user don't have View records permission for record
            it("Test_009_Error_WithoutViewRecordPermission") {
                let usernameWithoutViewRecordPermission = TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION
                let passwordWithoutViewRecordPermission = TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION
                let recordModuleWithoutViewPermissionRecord = Record(TestCommonHandling.createConnection(
                    usernameWithoutViewRecordPermission,
                    passwordWithoutViewRecordPermission))
                
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermissionRecord.getRecord(appId, recordId)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_010_Error_WithoutFieldRecordPermission") {
                let usernameWithoutViewFieldPermission = TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION
                let passwordWithoutViewFieldPermission = TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION
                let recordModuleWithoutViewPermissionField = Record(TestCommonHandling.createConnection(
                    usernameWithoutViewFieldPermission,
                    passwordWithoutViewFieldPermission))
                
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermissionField.getRecord(appId, recordId)) as! GetRecordResponse
                var fieldItems = [String]()
                for(key, _) in result.getRecord()! {
                    fieldItems.append(key)
                }
                
                expect(fieldItems).toNot(contain(textField))
            }
            
            it("Test_013_Success_BlankApp") {
                let blankAppId = TestConstant.InitData.APP_BLANK_ID!
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(blankAppId, nil)) as! AddRecordResponse
                let blankRecordId = addRecordResponse.getId()!
                var defaultKey =  [
                    "Created_datetime": "Created_datetime",
                    "$id": "$id",
                    "Updated_datetime": "Updated_datetime",
                    "$revision": "$revision",
                    "Updated_by": "Updated_by",
                    "Created_by": "Created_by",
                    "Record_number": "Record_number",
                    "Assignee": "Assignee",
                    "Status": "Status"
                ]
                
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(blankAppId, blankRecordId)) as! GetRecordResponse
                
                for (key, _) in result.getRecord()! {
                    expect(key).to(equal(defaultKey[key]))
                }
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId!]))
            }
        }
    }
}

//
//  UpdateRecordByIDTest.swift
//  kintone-ios-sdkTests
//

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class UpdateRecordByIDTest: QuickSpec {
    override func spec() {
        let RECORD_TEXT_FIELD: String! = TestConstant.InitData.TEXT_FIELD
        let RECORD_NUMBER_FIELD: String! = TestConstant.InitData.NUMBER_FIELD
        let AppId = TestConstant.InitData.SPACE_APP_ID!
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("UpdateRecordByIDTest") {
            it("Test_065_Success_ValidData") {
                var recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                
                recordTextValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, recordId, testData, 1)) as! UpdateRecordResponse
                expect(updateRecordResponse.getRevision()).to(equal(2))
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == RECORD_TEXT_FIELD) {
                        expect((value.getValue() as! String)).to(equal(recordTextValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            it("Test_066_Success_RevisionNegative1") {
                var recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                recordTextValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, recordID, testData, -1)) as! UpdateRecordResponse
                expect(updateRecordResponse.getRevision()).to(equal(2))
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, recordID)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == RECORD_TEXT_FIELD) {
                        expect((value.getValue() as! String)).to(equal(recordTextValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            it("Test_067_Error_WrongRevision") {
                var recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                recordTextValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, recordID, testData, TestConstant.Common.NONEXISTENT_ID)) as! KintoneAPIException
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            it("Test_068_Error_UpdateCreatedByField") {
                let recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                let testValue = Member("user1", "user1")
                testData = RecordUtils.setRecordData([:], "Created_by", FieldType.CREATOR, testValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, recordID, testData, nil)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATOR")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            it("Test_068_Error_UpdateUpdatedByField") {
                let recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                let testValue = Member("user1", "user1")
                testData = RecordUtils.setRecordData([:], "Updated_by", FieldType.MODIFIER, testValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, recordID, testData, nil)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIER")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            it("Test_068_Error_UpdateCreatedDateTimeField") {
                let recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                testData = RecordUtils.setRecordData([:], "Created_datetime", FieldType.CREATED_TIME, "2018-12-05T10:00:00Z")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, recordID, testData, nil)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATED_AT")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            it("Test_068_Error_UpdateUpdatedDateTimeField") {
                let recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                testData = RecordUtils.setRecordData([:], "Updated_datetime", FieldType.UPDATED_TIME, "2018-12-05T10:00:00Z")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, recordID, testData, nil)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIED_AT")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            // When you wan to check different cases below please set up by manual
            //Error will display when user does not have View records or Edit permission for app
            //Error will display when user does not have View records or Edit permission for the record
            //Error will display when user does not have View records or Edit permission for the field
            it("Test_069_70_71_Error_WithoutPermission") {
                let recordModuleWithoutViewPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                var recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                recordTextValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermission.updateRecordByID(AppId, recordID, testData, nil)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIED_AT")
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            it("Test_072_Error_NonexistentAppID") {
                let testData: Dictionary<String, FieldValue>! = nil
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(TestConstant.Common.NONEXISTENT_ID, 123, testData, nil)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
            }
            
            it("Test_072_Error_NegativeAppID") {
                let testData: Dictionary<String, FieldValue>! = nil
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(-4, 123, testData, nil)) as! KintoneAPIException
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_APPID_ERROR()!)
            }
            
            it("Test_073_Error_NonexistentRecordID") {
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, TestConstant.Common.NONEXISTENT_ID, nil, nil)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
            }
            
            it("Test_073_Error_NegativeRecordID") {
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, -4, nil, nil)) as! KintoneAPIException
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_RECORD_ID_ERROR()!)
            }
            
            it("Test_075_Success_WithoutRecordData") {
                let recordTextValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, recordID, nil, 1)) as! UpdateRecordResponse
                expect(updateRecordResponse.getRevision()).to(equal(2))
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, recordID)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == RECORD_TEXT_FIELD) {
                        expect((value.getValue() as! String)).to(equal(recordTextValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            it("Test_076_Error_WithoutRecordDataWithRequiredField") {
                let appIdHasRequiredFields = TestConstant.InitData.APP_ID_HAS_REQUIRED_FIELDS!
                let recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appIdHasRequiredFields, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, "")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appIdHasRequiredFields, recordID, testData, 1)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(RECORD_TEXT_FIELD!)")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appIdHasRequiredFields)
            }
            
            it("Test_077_Success_InValidField") {
                var recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!
                recordTextValue = DataRandomization.generateString()

                testData = RecordUtils.setRecordData([:], "Invalid", FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, recordID, testData, 1)) as! UpdateRecordResponse
                expect(updateRecordResponse.getRevision()).to(equal(2))
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            it("Test_078_Error_InputTextToNumberField") {
                var testData = RecordUtils.setRecordData([:], RECORD_NUMBER_FIELD, FieldType.NUMBER, 123579)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                testData = RecordUtils.setRecordData([:], RECORD_NUMBER_FIELD, FieldType.NUMBER, "This is text")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, recordID, testData, 1)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[\(RECORD_NUMBER_FIELD!)]")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            it("Test_079_Error_DuplicateDataWithProhibitValue") {
                let appIdHasProhibitDuplicateValueFields = TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!
                let recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                _ = TestCommonHandling.awaitAsync(recordModule.addRecord(TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!, testData)) as! AddRecordResponse
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, "Avoid duplicate")
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appIdHasProhibitDuplicateValueFields, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appIdHasProhibitDuplicateValueFields, recordID, testData, nil)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(RECORD_TEXT_FIELD!)")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appIdHasProhibitDuplicateValueFields)
            }
            
            it("Test_065_Success_ValidDataAPI") {
                let auth = Auth().setApiToken(TestConstant.InitData.SPACE_APP_API_TOKEN)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth)
                let recordModule = Record(conn)

                var recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                recordTextValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(AppId, recordID, testData, 1)) as! UpdateRecordResponse
                expect(updateRecordResponse.getRevision()).to(equal(2))
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, recordID)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == RECORD_TEXT_FIELD) {
                        expect((value.getValue() as! String)).to(equal(recordTextValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: AppId)
            }
            
            it("Test_065_Success_ValidDataGuestSpace") {
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))

                var recordTextValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(TestConstant.InitData.GUEST_SPACE_APP_ID!, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!

                recordTextValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.updateRecordByID(TestConstant.InitData.GUEST_SPACE_APP_ID!, recordID, testData, 1)) as! UpdateRecordResponse
                expect(updateRecordResponse.getRevision()).to(equal(2))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(TestConstant.InitData.GUEST_SPACE_APP_ID!, recordID)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == RECORD_TEXT_FIELD) {
                        expect((value.getValue() as! String)).to(equal(recordTextValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModuleGuestSpace, appID: TestConstant.InitData.GUEST_SPACE_APP_ID!)
            }
        }
    }
}

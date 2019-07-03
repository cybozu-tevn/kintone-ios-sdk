//
//  UpdateRecordByIDTest.swift
//  kintone-ios-sdkTests
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class UpdateRecordByIDTest: QuickSpec {
    override func spec() {
        let textField: String! = TestConstant.InitData.TEXT_FIELD
        let numberField: String! = TestConstant.InitData.NUMBER_FIELD
        var textFieldValue: String!
        let appId = TestConstant.InitData.SPACE_APP_ID!
        var recordId: Int!
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("UpdateRecordByID") {
            it("Test_065_Success_ValidData") {
                // Prepare record
                let recordId = _prepareRecord(appId)
                
                // Set new value for text field and update record by id
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, recordId, testData, 1)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                
                // Verify:
                // - revision is increased
                // - field value is updated
                expect(updateRecordResponse.getRevision()).to(equal(2))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect((value.getValue() as! String)).to(equal(textFieldValue))
                    }
                }
                
                // Delete test data
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_066_Success_RevisionNegative1") {
                let recordId = _prepareRecord(appId)
                
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, recordId, testData, -1)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                
                expect(updateRecordResponse.getRevision()).to(equal(2))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect((value.getValue() as! String)).to(equal(textFieldValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_067_Error_WrongRevision") {
                let recordId = _prepareRecord(appId)
                
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, recordId, testData, TestConstant.Common.NONEXISTENT_ID)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_068_Error_UpdateCreatedByField") {
                let recordId = _prepareRecord(appId)
                
                let testValue = Member("user1", "user1")
                let testData = RecordUtils.setRecordData([:], "Created_by", FieldType.CREATOR, testValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, recordId, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATOR")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_068_Error_UpdateUpdatedByField") {
                let recordId = _prepareRecord(appId)
                
                let testValue = Member("user1", "user1")
                let testData = RecordUtils.setRecordData([:], "Updated_by", FieldType.MODIFIER, testValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, recordId, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIER")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_068_Error_UpdateCreatedDateTimeField") {
                let recordId = _prepareRecord(appId)
                
                let testData = RecordUtils.setRecordData([:], "Created_datetime", FieldType.CREATED_TIME, "2018-12-05T10:00:00Z")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, recordId, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATED_AT")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_068_Error_UpdateUpdatedDateTimeField") {
                let recordId = _prepareRecord(appId)
                
                let testData = RecordUtils.setRecordData([:], "Updated_datetime", FieldType.UPDATED_TIME, "2018-12-05T10:00:00Z")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, recordId, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIED_AT")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_069_Error_WithoutPermissionOnApp") {
                let recordId = _prepareRecord(appId)
                
                let recordModuleWithoutViewPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermission.updateRecordByID(appId, recordId, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_070_Error_WithoutPermissionOnRecord") {
                let recordId = _prepareRecord(appId)
                
                let recordModuleWithoutViewPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermission.updateRecordByID(appId, recordId, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_071_Error_WithoutPermissionOnField") {
                let recordId = _prepareRecord(appId)
                
                let recordModuleWithoutViewPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermission.updateRecordByID(appId, recordId, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.PERMISSION_EDIT_FIELD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: textField)
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_072_Error_NonexistentAppID") {
                let testData: Dictionary<String, FieldValue>! = nil
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(TestConstant.Common.NONEXISTENT_ID, 123, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_072_Error_NegativeAppID") {
                let testData: Dictionary<String, FieldValue>! = nil
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(-4, 123, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_APPID_ERROR()!)
            }
            
            it("Test_073_Error_NonexistentRecordID") {
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, TestConstant.Common.NONEXISTENT_ID, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_073_Error_NegativeRecordID") {
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, -4, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_RECORD_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_075_Success_WithoutRecordData") {
                let recordId = _prepareRecord(appId)
                
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, recordId, nil, 1)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                
                expect(updateRecordResponse.getRevision()).to(equal(2))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect((value.getValue() as! String)).to(equal(textFieldValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_076_Error_WithoutRecordDataWithRequiredField") {
                let appIdHasRequiredFields = TestConstant.InitData.APP_ID_HAS_REQUIRED_FIELDS!
                let recordId = _prepareRecord(appIdHasRequiredFields)
                
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, "")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appIdHasRequiredFields, recordId, testData, 1)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(textField!)")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appIdHasRequiredFields)
            }
            
            it("Test_077_Success_InvalidField") {
                let recordId = _prepareRecord(appId)
                
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], "Invalid", FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, recordId, testData, 1)) as! UpdateRecordResponse
                
                expect(updateRecordResponse.getRevision()).to(equal(2))
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_078_Error_InputTextToNumberField") {
                var testData = RecordUtils.setRecordData([:], numberField, FieldType.NUMBER, 123579)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                
                testData = RecordUtils.setRecordData([:], numberField, FieldType.NUMBER, "This is text")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, recordId, testData, 1)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[\(numberField!)]")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_079_Error_DuplicateDataForProhibitDuplicateValueField") {
                // Add the first record into an app having prohibit duplicate value field
                let appIdHasProhibitDuplicateValueFields = TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!
                let textFieldValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                _ = TestCommonHandling.awaitAsync(recordModule.addRecord(TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!, testData)) as! AddRecordResponse

                // Add the second record into an app having prohibit duplicate value field
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, "Avoid duplicate")
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appIdHasProhibitDuplicateValueFields, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                
                // Update value of text field for the second record and its value is duplicated with value of text field in the first record
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appIdHasProhibitDuplicateValueFields, recordId, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(textField!)")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appIdHasProhibitDuplicateValueFields)
            }
            
            it("Test_065_Success_ValidData_APIToken") {
                let auth = Auth().setApiToken(TestConstant.InitData.SPACE_APP_API_TOKEN)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth)
                let recordModule = Record(conn)
                
                var textFieldValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                
                textFieldValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByID(appId, recordId, testData, 1)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                
                expect(updateRecordResponse.getRevision()).to(equal(2))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect((value.getValue() as! String)).to(equal(textFieldValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_065_Success_ValidDataGuestSpace") {
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                var textFieldValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(TestConstant.InitData.GUEST_SPACE_APP_ID!, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                
                textFieldValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.updateRecordByID(TestConstant.InitData.GUEST_SPACE_APP_ID!, recordId, testData, 1)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(TestConstant.InitData.GUEST_SPACE_APP_ID!, recordId)) as! GetRecordResponse
                
                expect(updateRecordResponse.getRevision()).to(equal(2))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect((value.getValue() as! String)).to(equal(textFieldValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModuleGuestSpace, appID: TestConstant.InitData.GUEST_SPACE_APP_ID!)
            }
        }
        
        func _prepareRecord(_ appId: Int) -> Int {
            textFieldValue = DataRandomization.generateString()
            let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
            let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
            let recordId = addRecordResponse.getId()!
            
            return recordId
        }
    }
}

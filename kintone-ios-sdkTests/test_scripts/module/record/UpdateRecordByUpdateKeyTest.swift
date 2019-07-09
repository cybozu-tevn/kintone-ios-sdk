//
//  UpdateRecordByUpdateKeyTest.swift
//  kintone-ios-sdkTests
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class UpdateRecordByUpdateKeyTest: QuickSpec {
    override func spec() {
        let textField: String! = TestConstant.InitData.TEXT_FIELD
        let textUpdateKeyField: String! = TestConstant.InitData.TEXT_UPDATE_KEY_FIELD
        var textUpdateKeyFieldValue: String!
        let appId = TestConstant.InitData.APP_ID!
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("UpdateRecordByUpdateKey") {
            it("Test_085_Success_ValidData") {
                // Add record
                let recordId = _prepareRecord(recordModule, appId)
                
                // Set new value for text field and update record by update key value
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(appId, updateKey, testData, 1)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                
                // Verify:
                // - Record revision is updated to 2
                // - Text field value is updated
                expect(updateRecordResponse.getRevision()).to(equal(2))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect((value.getValue() as! String)).to(equal(textFieldValue))
                    }
                }
                
                // Delete test data
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_086_Success_RevisionNegative1") {
                let recordId = _prepareRecord(recordModule, appId)
                
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(appId, updateKey, testData, -1)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                
                expect(updateRecordResponse.getRevision()).to(equal(2))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect((value.getValue() as! String)).to(equal(textFieldValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_087_Error_WrongRevision") {
                _ = _prepareRecord(recordModule, appId)
                
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(appId, updateKey, testData, TestConstant.Common.NONEXISTENT_ID)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_088_Error_WrongUpdateKeyValue") {
                _ = _prepareRecord(recordModule, appId)
                
                let wrongUpdateKey = RecordUpdateKey(textUpdateKeyField, "wrongUpdateKeyValue")
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(appId, wrongUpdateKey, testData, 1)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.INCORRECT_UPDATEKEY_VALUE_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_088_Error_WrongUpdateKeyField") {
                _ = _prepareRecord(recordModule, appId)
                
                let wrongUpdateKey = RecordUpdateKey("WrongUpdateKeyField", textUpdateKeyFieldValue)
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(appId, wrongUpdateKey, testData, 1)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INCORRECT_UPDATEKEY_FIELD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "WrongUpdateKeyField")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_091_Error_UpdateUpdatedDateTimeField") {
                _ = _prepareRecord(recordModule, appId)
                
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let testData = RecordUtils.setRecordData([:], "Updated_datetime", FieldType.UPDATED_TIME, "2018-12-05T10:00:00Z")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(appId, updateKey, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIED_AT")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            it("Test_091_Error_UpdateCreatedDateTimeField") {
                _ = _prepareRecord(recordModule, appId)
                
                // Update record by update key for "Created_datetime" field
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let testData = RecordUtils.setRecordData([:], "Created_datetime", FieldType.CREATED_TIME, "2018-12-05T10:00:00Z")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(appId, updateKey, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATED_AT")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_091_Error_UpdateCreatedByField") {
                _ = _prepareRecord(recordModule, appId)
                
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let user = Member("user1", "user1")
                let testData = RecordUtils.setRecordData([:], "Created_by", FieldType.CREATOR, user)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(appId, updateKey, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATOR")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_091_Error_UpdateUpdatedByField") {
                _ = _prepareRecord(recordModule, appId)
                
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let user = Member("user1", "user1")
                let testData = RecordUtils.setRecordData([:], "Updated_by", FieldType.MODIFIER, user)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(appId, updateKey, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIER")
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_092_Error_WithoutPermissionOnApp") {
                _ = _prepareRecord(recordModule, appId)
                
                // Update record by update key by user not have permission on app
                let recordModuleWithoutViewPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermission.updateRecordByUpdateKey(appId, updateKey, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_093_Error_WithoutPermissionOnRecord") {
                _ = _prepareRecord(recordModule, appId)
                
                // Update record by update key by user not have permission on record
                let recordModuleWithoutViewPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermission.updateRecordByUpdateKey(appId, updateKey, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_094_Error_WithoutPermissionOnField") {
                _ = _prepareRecord(recordModule, appId)
                
                // Update record by update key by user not have permission on field
                let recordModuleWithoutViewPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermission.updateRecordByUpdateKey(appId, updateKey, testData, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.PERMISSION_EDIT_FIELD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: textField)
                TestCommonHandling.compareError(actualError, expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_095_Error_NonexistentAppID") {
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(TestConstant.Common.NONEXISTENT_ID, RecordUpdateKey("test","test"), [:], nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_095_Error_NegativeAppID") {
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(-4, RecordUpdateKey("test","test"), [:], nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_085_Success_ValidData_GuestSpace") {
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                
                // Add record for an App in Guest Space
                let recordId = _prepareRecord(recordModuleGuestSpace, guestSpaceAppId)
                
                // Update record by update key value
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.updateRecordByUpdateKey(guestSpaceAppId, updateKey, testData, 1)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                
                // Verify:
                // - Record revision is updated to 2
                // - Text field value is updated
                expect(updateRecordResponse.getRevision()).to(equal(2))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect((value.getValue() as! String)).to(equal(textFieldValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModuleGuestSpace, appID: guestSpaceAppId)
            }
            
            it("Test_085_Success_ValidData_ApiToken") {
                let recordId = _prepareRecord(recordModule, appId)
                
                let conn = TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN)
                let recordModuleWithApiToken = Record(conn)
                let updateKey = RecordUpdateKey(textUpdateKeyField, textUpdateKeyFieldValue)
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModuleWithApiToken.updateRecordByUpdateKey(appId, updateKey, testData, 1)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                
                // Verify:
                // - Record revision is updated to 2
                // - Text field value is updated
                expect(updateRecordResponse.getRevision()).to(equal(2))
                for(key, value) in getRecordResponse.getRecord()! {
                    if(key == textField) {
                        expect((value.getValue() as! String)).to(equal(textFieldValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
        }
        
        func _prepareRecord(_ recordModule: Record, _ appId: Int) -> Int {
            textUpdateKeyFieldValue = DataRandomization.generateString()
            let textFieldValue = DataRandomization.generateString()
            var testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
            testData = RecordUtils.setRecordData([:], textUpdateKeyField, FieldType.SINGLE_LINE_TEXT, textUpdateKeyFieldValue)
            let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
            let recordId = addRecordResponse.getId()!
            
            return recordId
        }
    }
}

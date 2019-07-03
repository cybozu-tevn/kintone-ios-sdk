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
        let TEXT_FIELD: String! = TestConstant.InitData.TEXT_FIELD
        let TEXT_UPDATE_KEY_FIELD: String! = TestConstant.InitData.TEXT_UPDATE_KEY_FIELD
        let APP_ID = TestConstant.InitData.APP_ID!
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("UpdateRecordByUpdateKeyTest") {
            it("Test_085_Success_ValidData") {
                // Add record
                let textUpdateKeyValue = DataRandomization.generateString()
                var textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                
                // Update record by update key value
                let updateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, textUpdateKeyValue)
                textValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(APP_ID, updateKey, testData, 1)) as! UpdateRecordResponse
                
                // Verify:
                // - Record revision is updated to 2
                // - Text field value is updated
                expect(updateRecordResponse.getRevision()).to(equal(2))
                
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, recordId)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == TEXT_FIELD) {
                        expect((value.getValue() as! String)).to(equal(textValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
            }
            
            it("Test_086_Success_RevisionNegative1") {
                // Add record
                let textUpdateKeyValue = DataRandomization.generateString()
                var textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                
                // Update record by update key with nagative revision
                let updateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, textUpdateKeyValue)
                textValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(APP_ID, updateKey, testData, -1)) as! UpdateRecordResponse
                
                expect(updateRecordResponse.getRevision()).to(equal(2))
                
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, recordId)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == TEXT_FIELD) {
                        expect((value.getValue() as! String)).to(equal(textValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
            }
            
            it("Test_087_Error_WrongRevision") {
                // Add record
                let textUpdateKeyValue = DataRandomization.generateString()
                var textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                _ = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                
                // Update record by update key with incorrect record revision
                let updateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, textUpdateKeyValue)
                textValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(APP_ID, updateKey, testData, TestConstant.Common.NONEXISTENT_ID)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
            }
            
            it("Test_088_Error_WrongUpdateKeyValue") {
                // Add record
                let textUpdateKeyValue = DataRandomization.generateString()
                var textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                _ = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                
                // Update record by update key with wrong update key value
                let wrongUpdateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, "wrongUpdateKeyValue")
                textValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(APP_ID, wrongUpdateKey, testData, 1)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.INCORRECT_UPDATEKEY_VALUE_ERROR()!)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
            }
            
            it("Test_088_Error_WrongUpdateKeyField") {
                // Add record
                let textUpdateKeyValue = DataRandomization.generateString()
                var textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                _ = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                
                // Update record by update key with worong update key field
                let wrongUpdateKey = RecordUpdateKey("WrongUpdateKeyField", textUpdateKeyValue)
                textValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(APP_ID, wrongUpdateKey, testData, 1)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.INCORRECT_UPDATEKEY_FIELD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "WrongUpdateKeyField")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
            }
            
            it("Test_091_Error_UpdateUpdatedDateTimeField") {
                // Add record
                let textUpdateKeyValue = DataRandomization.generateString()
                let textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                _ = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                
                // Update record by update key for "Updated_datetime" field
                let updateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, textUpdateKeyValue)
                testData = RecordUtils.setRecordData([:], "Updated_datetime", FieldType.UPDATED_TIME, "2018-12-05T10:00:00Z")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(APP_ID, updateKey, testData, nil)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIED_AT")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
            }
            it("Test_091_Error_UpdateCreatedDateTimeField") {
                // Add record
                let textUpdateKeyValue = DataRandomization.generateString()
                let textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                _ = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                
                // Update record by update key for "Created_datetime" field
                let updateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, textUpdateKeyValue)
                testData = RecordUtils.setRecordData([:], "Created_datetime", FieldType.CREATED_TIME, "2018-12-05T10:00:00Z")
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(APP_ID, updateKey, testData, nil)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATED_AT")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
            }
            
            it("Test_091_Error_UpdateCreatedByField") {
                // Add record
                let textUpdateKeyValue = DataRandomization.generateString()
                let textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                _ = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                
                // Update record by update key for "Created_by" field
                let updateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, textUpdateKeyValue)
                let user = Member("user1", "user1")
                testData = RecordUtils.setRecordData([:], "Created_by", FieldType.CREATOR, user)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(APP_ID, updateKey, testData, nil)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATOR")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
            }
            
            it("Test_091_Error_UpdateUpdatedByField") {
                // Add record
                let textUpdateKeyValue = DataRandomization.generateString()
                let textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                _ = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                
                // Update record by update key for "Updated_by" field
                let updateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, textUpdateKeyValue)
                let user = Member("user1", "user1")
                testData = RecordUtils.setRecordData([:], "Updated_by", FieldType.MODIFIER, user)
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(APP_ID, updateKey, testData, nil)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIER")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
            }
            
            
            // When you want to check different cases below please set up by manual
            //Error will display when user does not have View records or Edit permission for app
            //Error will display when user does not have View records or Edit permission for the record
            //Error will display when user does not have View records or Edit permission for the field
            it("Test_092_093_094_Error_WithoutPermission") {
                // Add record
                let textUpdateKeyValue = DataRandomization.generateString()
                var textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                _ = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                
                // Update record by update key by user not have permission on app
                let recordModuleWithoutViewPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                
                let updateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, textUpdateKeyValue)
                textValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermission.updateRecordByUpdateKey(APP_ID, updateKey, testData, nil)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIED_AT")
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
            }
            
            it("Test_095_Error_NonexistentAppID") {
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(TestConstant.Common.NONEXISTENT_ID, RecordUpdateKey("test","test"), [:], nil)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
            }
            
            it("Test_095_Error_NegativeAppID") {
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordByUpdateKey(-4, RecordUpdateKey("test","test"), [:], nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_APPID_ERROR()!)
            }
            
            it("Test_085_Success_ValidDataGuestSpace") {
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                
                // Add record for an App in Guest Space
                let textUpdateKeyValue = DataRandomization.generateString()
                var textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(guestSpaceAppId!, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                
                // Update record by update key value
                let updateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, textUpdateKeyValue)
                textValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.updateRecordByUpdateKey(guestSpaceAppId!, updateKey, testData, 1)) as! UpdateRecordResponse
                
                // Verify:
                // - Record revision is updated to 2
                // - Text field value is updated
                expect(updateRecordResponse.getRevision()).to(equal(2))
                
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(guestSpaceAppId!, recordId)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == TEXT_FIELD) {
                        expect((value.getValue() as! String)).to(equal(textValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModuleGuestSpace, appID: guestSpaceAppId!)
            }
            
            it("Test_085_Success_ValidApiToken") {
                // Add record
                let textUpdateKeyValue = DataRandomization.generateString()
                var textValue = DataRandomization.generateString()
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textUpdateKeyValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                
                // Update record by update key value via API token
                let conn = TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN)
                let recordModuleWithApiToken = Record(conn)
                
                let updateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, textUpdateKeyValue)
                textValue = DataRandomization.generateString()
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                let updateRecordResponse = TestCommonHandling.awaitAsync(recordModuleWithApiToken.updateRecordByUpdateKey(APP_ID, updateKey, testData, 1)) as! UpdateRecordResponse
                
                // Verify:
                // - Record revision is updated to 2
                // - Text field value is updated
                expect(updateRecordResponse.getRevision()).to(equal(2))
                
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, recordId)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == TEXT_FIELD) {
                        expect((value.getValue() as! String)).to(equal(textValue))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
            }
        }
    }
}

//
// kintone-ios-sdkTests
// Created on 5/8/19
// 

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class UpdateRecordsTest: QuickSpec {
    override func spec() {
        let negativeId: Int = TestConstant.Common.NEGATIVE_ID
        let recordModule = Record(TestCommonHandling.createConnection())
        let appId = TestConstant.InitData.APP_ID!
        let textField: String! = TestConstant.InitData.TEXT_FIELD
        var recordIds =  [Int]()
        
        describe("UpdateRecords") {
            it("Test_107_Success_ValidDataById") {
                // Prepare 2 records
                _prepareRecords(recordModule, appId, 2)
                
                // Update records
                let textFieldValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! UpdateRecordsResponse
                
                // Verify records info
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == textField) {
                            expect(value.getValue() as? String).to(equal(textFieldValue))
                        }
                    }
                }
                
                // Delete test data
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_107_Success_ValidDataById_GuestSpace") {
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                
                _prepareRecords(recordModuleGuestSpace, guestSpaceAppId, 2)
                
                let textFieldValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let updateRecordsRsp = TestCommonHandling.awaitAsync(recordModuleGuestSpace.updateRecords(guestSpaceAppId, recordsUpdateItem)) as! UpdateRecordsResponse
                
                for record in updateRecordsRsp.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(guestSpaceAppId, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == textField) {
                            expect(value.getValue() as? String).to(equal(textFieldValue))
                        }
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(guestSpaceAppId, recordIds))
            }
            
            it("Test_107_Success_ValidDataById_ApiToken") {
                _prepareRecords(recordModule, appId, 2)
                
                let textFieldValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let apiToken: String = TestConstant.InitData.APP_API_TOKEN
                let recordModuleApiToken = Record(TestCommonHandling.createConnection(apiToken))
                let updateRecordsRsp = TestCommonHandling.awaitAsync(recordModuleApiToken.updateRecords(appId, recordsUpdateItem)) as! UpdateRecordsResponse
                
                for record in updateRecordsRsp.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getRecord(appId, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == textField) {
                            expect(value.getValue() as? String).to(equal(textFieldValue))
                        }
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.deleteRecords(appId, recordIds))
            }
            
            it("Test_108_Success_ValidDataByUpdateKey") {
                // Add the first record with update key
                let updateKeyField: String! = TestConstant.InitData.TEXT_UPDATE_KEY_FIELD
                var recordTextKeyValue = DataRandomization.generateString(prefix: "Record", length: 10)
                var testData = RecordUtils.setRecordData([:], updateKeyField, FieldType.SINGLE_LINE_TEXT, recordTextKeyValue)
                var updateKeys = [RecordUpdateKey]()
                updateKeys.append(RecordUpdateKey(updateKeyField, recordTextKeyValue))
                
                var textFieldValue = DataRandomization.generateString(prefix: "Record", length: 10)
                testData = RecordUtils.setRecordData(testData, textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                
                var addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                var recordIds: [Int] = [addRecordsResponse.getId()!]
                
                // Add the second record with update key
                recordTextKeyValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], updateKeyField, FieldType.SINGLE_LINE_TEXT, recordTextKeyValue)
                updateKeys.append(RecordUpdateKey(updateKeyField, recordTextKeyValue))
                
                textFieldValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(testData, textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordsResponse.getId()!)
                
                // Update records
                textFieldValue = DataRandomization.generateString(prefix: "Record", length: 10)
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for updateKey in updateKeys {
                    recordsUpdateItem.append(RecordUpdateItem(nil, nil, updateKey, testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! UpdateRecordsResponse
                
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == textField) {
                            expect(value.getValue() as? String).to(equal(textFieldValue))
                        }
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_109_Success_RevisionNegative") {
                _prepareRecords(recordModule, appId, 2)
                
                let textFieldValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, -1, nil, testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! UpdateRecordsResponse
                
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == textField) {
                            expect(value.getValue() as? String).to(equal(textFieldValue))
                        }
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_110_Error_WrongRevision") {
                _prepareRecords(recordModule, appId, 2)
                
                let textFieldValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                let invalidRevision: Int = 99999
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, invalidRevision, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_111_Error_UpdateCreatedTimeField") {
                _prepareRecords(recordModule, appId, 2)
                
                let testData = RecordUtils.setRecordData([:], "Created_datetime", FieldType.CREATED_TIME, "2018-12-08T08:39:00Z")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATED_AT")
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_111_Error_UpdateUpdatedTimeField") {
                _prepareRecords(recordModule, appId, 2)
                
                let testData = RecordUtils.setRecordData([:], "Updated_datetime", FieldType.UPDATED_TIME, "2018-12-08T08:39:00Z")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIED_AT")
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_111_Error_UpdateCreateByField") {
                _prepareRecords(recordModule, appId, 2)
                
                let testValue = Member("user1", "user1")
                let testData = RecordUtils.setRecordData([:], "Created_by", FieldType.CREATOR, testValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATOR")
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_111_Error_UpdateUpdateByField") {
                _prepareRecords(recordModule, appId, 2)
                
                let testValue = Member("user1", "user1")
                let testData = RecordUtils.setRecordData([:], "Updated_by", FieldType.MODIFIER, testValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIER")
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_112_113_114_Error_UpdateWithouPermission") {
                _prepareRecords(recordModule, appId, 2)
                
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let textFieldValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.updateRecords(appId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_115_Error_NonexistentAppId") {
                _prepareRecords(recordModule, appId, 2)
                
                let textFieldValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let noneExistentId = TestConstant.Common.NONEXISTENT_ID
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(noneExistentId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_115_Error_NegativeAppId") {
                _prepareRecords(recordModule, appId, 2)
                
                let textFieldValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(negativeId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_118_Error_MissingRequiredField") {
                let appHasRequiredFieldId = TestConstant.InitData.APP_ID_HAS_REQUIRED_FIELDS!
                _prepareRecords(recordModule, appHasRequiredFieldId, 1)
                
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, "")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(appHasRequiredFieldId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(recordIds.count-1)].\(textField!)")
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appHasRequiredFieldId, recordIds))
            }
            
            it("Test_119_Success_InvalidField") {
                _prepareRecords(recordModule, appId, 2)
                
                let textFieldValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let testData = RecordUtils.setRecordData([:], "Invalid", FieldType.SINGLE_LINE_TEXT, textFieldValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! UpdateRecordsResponse
                
                for record in result.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                }
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_120_Error_InputTextToNumber") {
                let numberField: String = TestConstant.InitData.NUMBER_FIELD
                var testData = RecordUtils.setRecordData([:], numberField, FieldType.NUMBER, 123579)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                let recordIds = [addRecordResponse.getId()!]
                
                testData = RecordUtils.setRecordData([:], numberField, FieldType.NUMBER, "input text to number")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(recordIds.count-1)].record[\(numberField)]")
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_121_Error_DuplicateDataWithProhibitDuplicateValueField") {
                // Add the first record with prohibit duplicate value field
                let appIdHasProhibitDuplicateValueField = TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!
                _prepareRecords(recordModule, appIdHasProhibitDuplicateValueField, 2)
                
                // Add the second record with prohibit duplicate value field
                let textFieldValueRecord2 = DataRandomization.generateString(prefix: "Record", length: 10)
                var testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValueRecord2)
                let addSecondRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appIdHasProhibitDuplicateValueField, testData)) as! AddRecordResponse
                recordIds.append(addSecondRecordResponse.getId()!)
                
                // Update records with new value that duplicated with value of "prohibit duplicate value" field of the second record
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValueRecord2)
                var recordsUpdateItem = [RecordUpdateItem]()
                for (index, value) in recordIds.enumerated() {
                    if(index > 0) {
                        recordsUpdateItem.append(RecordUpdateItem(value, nil, nil, testData))
                    }
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(appIdHasProhibitDuplicateValueField, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[0].\(textField!)")
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appIdHasProhibitDuplicateValueField, recordIds))
            }
        }
        
        func _prepareRecords(_ recordModule: Record, _ appId: Int, _ numberOfRecords: Int) {
            var testDataList = [Dictionary<String, FieldValue>]()
            var textFieldValues = [String]()
            for i in 0...numberOfRecords-1 {
                textFieldValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                testDataList.append(testData)
            }
            
            let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
            recordIds = addRecordsResponse.getIDs()!
        }
    }
}

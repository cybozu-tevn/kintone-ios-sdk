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
        let recordModule = Record(TestCommonHandling.createConnection())
        let appId = TestConstant.InitData.APP_ID!
        let negativeId: Int = TestConstant.Common.NEGATIVE_ID
        
        let textField: String! = TestConstant.InitData.TEXT_FIELD
        let updateKeyField: String! = TestConstant.InitData.TEXT_UPDATE_KEY_FIELD
        let numberField: String = TestConstant.InitData.NUMBER_FIELD
        var recordTextValue =  [String]()
        var recordTextKeyValue = [String]()
        var testData: Dictionary<String, FieldValue>!
        var recordIds =  [Int]()

        describe("UpdateRecords") {
            beforeEach {
                recordTextValue.removeAll()
                recordIds.removeAll()
            }
            
            it("Test_107_Success_ValidDataById") {
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! UpdateRecordsResponse
                
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == textField) {
                            expect(recordTextValue[recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_107_Success_ValidDataById_GuestSpace") {
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(guestSpaceAppId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(guestSpaceAppId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
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
                            expect(recordTextValue[recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(guestSpaceAppId, recordIds))
            }
            
            it("Test_107_Success_ValidDataById_ApiToken") {
                let apiToken: String = TestConstant.InitData.APP_API_TOKEN
                let recordModuleApiToken = Record(TestCommonHandling.createConnection(apiToken))
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    textField,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let updateRecordsRsp = TestCommonHandling.awaitAsync(recordModuleApiToken.updateRecords(appId, recordsUpdateItem)) as! UpdateRecordsResponse
                
                for record in updateRecordsRsp.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getRecord(appId, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == textField) {
                            expect(recordTextValue[recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.deleteRecords(appId, recordIds))
            }
            
            it("Test_108_Success_ValidDataByUpdateKey") {
                recordTextKeyValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], updateKeyField, FieldType.SINGLE_LINE_TEXT, recordTextKeyValue[recordTextKeyValue.count-1])
                var updateKeys = [RecordUpdateKey]()
                updateKeys.append(RecordUpdateKey(updateKeyField, recordTextKeyValue[recordTextKeyValue.count-1]))
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(testData, textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordsResponse.getId()!)
                
                recordTextKeyValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], updateKeyField, FieldType.SINGLE_LINE_TEXT, recordTextKeyValue[recordTextKeyValue.count-1])
                updateKeys.append(RecordUpdateKey(updateKeyField, recordTextKeyValue[recordTextKeyValue.count-1]))
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(testData, textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordsResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
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
                            expect(recordTextValue[recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_109_Success_RevisionNegative") {
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
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
                            expect(recordTextValue[recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_110_Error_WrongRevision") {
                let invalidRevision: Int = 99999
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
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
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], "Created_datetime", FieldType.CREATED_TIME, "2018-12-08T08:39:00Z")
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
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], "Updated_datetime", FieldType.UPDATED_TIME, "2018-12-08T08:39:00Z")
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
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                let testValue = Member("user1", "user1")
                testData = RecordUtils.setRecordData([:], "Created_by", FieldType.CREATOR, testValue)
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
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                let testValue = Member("user1", "user1")
                testData = RecordUtils.setRecordData([:], "Updated_by", FieldType.MODIFIER, testValue)
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
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
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
            
            it("Test_115_Error_NoneExistentAppId") {
                let noneExistentId = TestConstant.Common.NONEXISTENT_ID
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(noneExistentId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_115_Error_NegativeAppId") {
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
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
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appHasRequiredFieldId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, "")
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
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], "Invalid", FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIds {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(appId, recordsUpdateItem)) as! UpdateRecordsResponse
                
                for record in result.getRecords()! {
                    expect(2).to(equal(record.getRevision()))
                }
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_120_Error_InputTextToNumber") {
                testData = RecordUtils.setRecordData([:], numberField, FieldType.NUMBER, 123579)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
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
            
            it("Test_121_Error_DuplicateDataWithProhibitValue") {
                let appHasProhibitDuplicateId = TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appHasProhibitDuplicateId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appHasProhibitDuplicateId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue[0])
                var recordsUpdateItem = [RecordUpdateItem]()
                for (index, value) in recordIds.enumerated() {
                    if(index > 0) {
                        recordsUpdateItem.append(RecordUpdateItem(value, nil, nil, testData))
                    }
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(appHasProhibitDuplicateId, recordsUpdateItem)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[0].\(textField!)")
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appHasProhibitDuplicateId, recordIds))
            }
        }
    }
}

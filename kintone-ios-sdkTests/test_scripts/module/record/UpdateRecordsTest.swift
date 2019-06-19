///**
/**
 kintone-ios-sdkTests
 Created on 5/8/19
 */

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class UpdateRecordsTest: QuickSpec {
    override func spec() {
        let APP_ID = TestConstant.InitData.APP_ID!
        let GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_ID!
        let APP_UPDATE_KEY_GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let APP_HAVE_REQUIRED_FIELD_ID = TestConstant.InitData.APP_ID_HAS_REQUIRED_FIELDS!
        let APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID = TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!
        let NEGATIVE_APP_ID: Int = TestConstant.Common.NEGATIVE_ID
        let API_TOKEN: String = TestConstant.InitData.APP_API_TOKEN
        
        let RECORD_TEXT_FIELD: String! = TestConstant.InitData.TEXT_FIELD
        let RECORD_TEXT_KEY: String! = TestConstant.InitData.TEXT_UPDATE_KEY_FIELD
        let RECORD_NUMBER_FILED: String = TestConstant.InitData.NUMBER_FIELD
        var recordTextValue =  [String]()
        var recordTextKeyValue = [String]()
        var testData: Dictionary<String, FieldValue>!
        
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("UpdateRecords") {
            it("Test_107_Success_ValidDataByID") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModule.updateRecords(APP_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == RECORD_TEXT_FIELD) {
                            expect(recordTextValue[recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_107_Success_ValidDataByIdGuestSpace") {
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    GUEST_SPACE_ID))
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(APP_UPDATE_KEY_GUEST_SPACE_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(APP_UPDATE_KEY_GUEST_SPACE_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.updateRecords(APP_UPDATE_KEY_GUEST_SPACE_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(APP_UPDATE_KEY_GUEST_SPACE_ID, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == RECORD_TEXT_FIELD) {
                            expect(recordTextValue[recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(APP_UPDATE_KEY_GUEST_SPACE_ID, recordIDs))
            }
            
            it("Test_107_Success_ValidDataByIdApiToken") {
                let recordModuleApiToken = Record(TestCommonHandling.createConnection(API_TOKEN))
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.updateRecords(APP_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getRecord(APP_ID, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == RECORD_TEXT_FIELD) {
                            expect(recordTextValue[recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_108_Success_ValidDataByUpdateKey") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextKeyValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_KEY,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextKeyValue[recordTextKeyValue.count-1])
                var updateKeys = [RecordUpdateKey]()
                updateKeys.append(RecordUpdateKey(RECORD_TEXT_KEY, recordTextKeyValue[recordTextKeyValue.count-1]))
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    testData,
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordsResponse.getId()!)
                recordTextKeyValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_KEY, FieldType.SINGLE_LINE_TEXT, recordTextKeyValue[recordTextKeyValue.count-1])
                updateKeys.append(RecordUpdateKey(RECORD_TEXT_KEY, recordTextKeyValue[recordTextKeyValue.count-1]))
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    testData,
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordsResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for updateKey in updateKeys {
                    recordsUpdateItem.append(RecordUpdateItem(nil, nil, updateKey, testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModule.updateRecords(APP_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == RECORD_TEXT_FIELD) {
                            expect(recordTextValue[recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_109_Success_RevisionNegative") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:], RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, -1, nil, testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModule.updateRecords(APP_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == RECORD_TEXT_FIELD) {
                            expect(recordTextValue[recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_110_Error_WrongRevision") {
                let INVALID_REVISION: Int = 99999
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, INVALID_REVISION, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_111_Error_UpdateCreatedTimeField") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], "Created_datetime", FieldType.CREATED_TIME, "2018-12-08T08:39:00Z")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATED_AT")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_111_Error_UpdateUpdatedTimeField") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], "Updated_datetime", FieldType.UPDATED_TIME, "2018-12-08T08:39:00Z")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIED_AT")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_111_Error_UpdateCreateByField") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:], RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                let testValue = Member("user1", "user1")
                testData = RecordUtils.setRecordData([:], "Created_by", FieldType.CREATOR, testValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATOR")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_111_Error_UpdateUpdateByField") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                let testValue = Member("user1", "user1")
                testData = RecordUtils.setRecordData([:], "Updated_by", FieldType.MODIFIER, testValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIER")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_112_113_114_Error_UpdateWithouPermission") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.updateRecords(APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_115_Error_NoneExistentAppID") {
                var recordIDs =  [Int]()
                let INVALID_APP_ID: Int = 999999
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(INVALID_APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(INVALID_APP_ID))
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_115_Error_NegativeAppID") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(NEGATIVE_APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_118_Error_MissingRequiredField") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_HAVE_REQUIRED_FIELD_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, "")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(APP_HAVE_REQUIRED_FIELD_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(recordIDs.count-1)].\(RECORD_TEXT_FIELD!)")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_HAVE_REQUIRED_FIELD_ID, recordIDs))
            }
            
            it("Test_119_Success_InvalidField") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:], RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], "Invalid", FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(APP_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in result.getRecords()! {
                    expect(2).to(equal(record.getRevision()))
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_120_Error_InputTextToNumber") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                testData = RecordUtils.setRecordData([:], RECORD_NUMBER_FILED, FieldType.NUMBER, 123579)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], RECORD_NUMBER_FILED, FieldType.NUMBER, "input text to number")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(recordIDs.count-1)].record[\(RECORD_NUMBER_FILED)]")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_121_Error_DuplicateDataWithProhibitValue") {
                var recordIDs =  [Int]()
                recordTextValue.removeAll()
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValue[recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue[recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValue[0])
                var recordsUpdateItem = [RecordUpdateItem]()
                for (index, value) in recordIDs.enumerated() {
                    if(index > 0) {
                        recordsUpdateItem.append(RecordUpdateItem(value, nil, nil, testData))
                    }
                }
                let result = TestCommonHandling.awaitAsync(recordModule.updateRecords(
                    APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID,
                    recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[0].\(RECORD_TEXT_FIELD!)")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, recordIDs))
            }
        }
    }
}

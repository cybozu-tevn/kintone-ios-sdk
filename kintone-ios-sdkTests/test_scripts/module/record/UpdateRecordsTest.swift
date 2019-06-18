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
    private var recordModule: Record!
    private let APP_ID = TestConstant.InitData.APP_ID!
    private let GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_ID!
    private let APP_UPDATE_KEY_GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_APP_ID!
    private let APP_HAVE_REQUIRED_FIELD_ID = TestConstant.InitData.APP_ID_HAS_REQUIRED_FIELDS!
    private let APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID = TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!
    private let NEGATIVE_APP_ID: Int = TestConstant.Common.NEGATIVE_ID
    private let API_TOKEN: String = TestConstant.InitData.APP_API_TOKEN

    private let RECORD_TEXT_FIELD: String! = TestConstant.InitData.TEXT_FIELD
    private let RECORD_TEXT_KEY: String! = TestConstant.InitData.TEXT_UPDATE_KEY_FIELD
    private let RECORD_NUMBER_FILED: String = TestConstant.InitData.NUMBER_FIELD
    private var recordTextValue =  [String]()
    private var recordTextKeyValue = [String]()
    private var testData: Dictionary<String, FieldValue>!
    
    override func spec() {
        describe("UpdateRecords") {
            beforeSuite {
                self.recordModule = Record(TestCommonHandling.createConnection())
            }
            
            it("Test_107_Success_ValidDataByID") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.APP_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == self.RECORD_TEXT_FIELD) {
                            expect(self.recordTextValue[self.recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_107_Success_ValidDataByIdGuestSpace") {
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    self.GUEST_SPACE_ID))
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(self.APP_UPDATE_KEY_GUEST_SPACE_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(self.APP_UPDATE_KEY_GUEST_SPACE_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.updateRecords(self.APP_UPDATE_KEY_GUEST_SPACE_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(self.APP_UPDATE_KEY_GUEST_SPACE_ID, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == self.RECORD_TEXT_FIELD) {
                            expect(self.recordTextValue[self.recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(self.APP_UPDATE_KEY_GUEST_SPACE_ID, recordIDs))
            }
            
            it("Test_107_Success_ValidDataByIdApiToken") {
                let recordModuleApiToken = Record(TestCommonHandling.createConnection(self.API_TOKEN))
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.updateRecords(self.APP_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getRecord(self.APP_ID, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == self.RECORD_TEXT_FIELD) {
                            expect(self.recordTextValue[self.recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_108_Success_ValidDataByUpdateKey") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextKeyValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_KEY,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextKeyValue[self.recordTextKeyValue.count-1])
                var updateKeys = [RecordUpdateKey]()
                updateKeys.append(RecordUpdateKey(self.RECORD_TEXT_KEY, self.recordTextKeyValue[self.recordTextKeyValue.count-1]))
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    self.testData,
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var addRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordsResponse.getId()!)
                self.recordTextKeyValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_KEY, FieldType.SINGLE_LINE_TEXT, self.recordTextKeyValue[self.recordTextKeyValue.count-1])
                updateKeys.append(RecordUpdateKey(self.RECORD_TEXT_KEY, self.recordTextKeyValue[self.recordTextKeyValue.count-1]))
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    self.testData,
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                addRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordsResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for updateKey in updateKeys {
                    recordsUpdateItem.append(RecordUpdateItem(nil, nil, updateKey, self.testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.APP_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == self.RECORD_TEXT_FIELD) {
                            expect(self.recordTextValue[self.recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_109_Success_RevisionNegative") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:], self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue[self.recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, -1, nil, self.testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.APP_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in updateRecordsResponse.getRecords()! {
                    expect(record.getRevision()).to(equal(2))
                    let result = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == self.RECORD_TEXT_FIELD) {
                            expect(self.recordTextValue[self.recordTextValue.count-1]).to(equal(value.getValue() as? String))
                        }
                    }
                }
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_110_Error_WrongRevision") {
                let INVALID_REVISION: Int = 99999
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, INVALID_REVISION, nil, self.testData))
                }
                let result = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_111_Error_UpdateCreatedTimeField") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], "Created_datetime", FieldType.CREATED_TIME, "2018-12-08T08:39:00Z")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let result = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATED_AT")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_111_Error_UpdateUpdatedTimeField") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], "Updated_datetime", FieldType.UPDATED_TIME, "2018-12-08T08:39:00Z")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let result = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIED_AT")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_111_Error_UpdateCreateByField") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:], self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                let testValue = Member("user1", "user1")
                self.testData = RecordUtils.setRecordData([:], "Created_by", FieldType.CREATOR, testValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let result = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "CREATOR")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_111_Error_UpdateUpdateByField") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                let testValue = Member("user1", "user1")
                self.testData = RecordUtils.setRecordData([:], "Updated_by", FieldType.MODIFIER, testValue)
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let result = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "MODIFIER")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_112_113_114_Error_UpdateWithouPermission") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue[self.recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.updateRecords(self.APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_115_Error_NoneExistentAppID") {
                var recordIDs =  [Int]()
                let INVALID_APP_ID: Int = 999999
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let result = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(INVALID_APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(INVALID_APP_ID))
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_115_Error_NegativeAppID") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue[self.recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let result = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.NEGATIVE_APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_118_Error_MissingRequiredField") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_HAVE_REQUIRED_FIELD_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, "")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let result = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.APP_HAVE_REQUIRED_FIELD_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(recordIDs.count-1)].\(self.RECORD_TEXT_FIELD!)")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_HAVE_REQUIRED_FIELD_ID, recordIDs))
            }
            
            it("Test_119_Success_InvalidField") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:], self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], "Invalid", FieldType.SINGLE_LINE_TEXT, self.recordTextValue[self.recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let result = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.APP_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in result.getRecords()! {
                    expect(2).to(equal(record.getRevision()))
                }
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_120_Error_InputTextToNumber") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.testData = RecordUtils.setRecordData([:], self.RECORD_NUMBER_FILED, FieldType.NUMBER, 123579)
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_NUMBER_FILED, FieldType.NUMBER, "input text to number")
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let result = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(self.APP_ID, recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(recordIDs.count-1)].record[\(self.RECORD_NUMBER_FILED)]")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, recordIDs))
            }
            
            it("Test_121_Error_DuplicateDataWithProhibitValue") {
                var recordIDs =  [Int]()
                self.recordTextValue.removeAll()
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValue[self.recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue[self.recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, self.testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue[0])
                var recordsUpdateItem = [RecordUpdateItem]()
                for (index, value) in recordIDs.enumerated() {
                    if(index > 0) {
                        recordsUpdateItem.append(RecordUpdateItem(value, nil, nil, self.testData))
                    }
                }
                let result = TestCommonHandling.awaitAsync(self.recordModule.updateRecords(
                    self.APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID,
                    recordsUpdateItem)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[0].\(self.RECORD_TEXT_FIELD!)")
                TestCommonHandling.compareError(actualError, expectedError)
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID, recordIDs))
            }
        }
    }
}

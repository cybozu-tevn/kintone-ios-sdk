///**
/**
 kintone-ios-sdkTests
 Created on 5/7/19
 */

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class DeleteRecordsTest: QuickSpec {
    private var recordModule: Record!
    private var recordModuleWithoutDeletePermissionRecord: Record!
    private var recordModuleGuestSpace: Record!
    private var recordModuleWithAPIToken: Record!
    
    private let APP_ID = TestConstant.InitData.APP_ID!
    private let NEGATIVE_ID = TestConstant.Common.NEGATIVE_ID
    private let NONEXISTENT_ID = TestConstant.Common.NONEXISTENT_ID
    private let GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_ID!
    private let APP_GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_APP_ID!
    private let APP_API_TOKEN = TestConstant.InitData.APP_API_TOKEN

    private var recordIDs = [Int]()
    private let RECORD_TEXT_FIELD: String = TestConstant.InitData.TEXT_FIELD
    private let RECORD_NUMBER_FILED: String = TestConstant.InitData.NUMBER_FIELD
    private var recordTextValues = [String]()
    private var testData: Dictionary<String, FieldValue>!
    private var testDatas = [Dictionary<String, FieldValue>]()
    private let COUNT_NUMBER = 5
    
    override func spec() {
        describe("DeleteRecord") {
            beforeSuite {
                self.recordModule = Record(TestCommonHandling.createConnection())
                self.recordModuleWithoutDeletePermissionRecord = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_DELETE_RECORD_PERMISSION))
                self.recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    self.GUEST_SPACE_ID))
                self.recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(self.APP_API_TOKEN))
            }
            
            it("Test_127_Success_Single") {
                self.recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[0])
                self.testDatas.append(self.testData)
                self.testData = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, self.recordIDs))
                
                for item in self.recordIDs {
                    let result = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_128_Success_Multiple") {
                for i in 0...self.COUNT_NUMBER-1 {
                    self.recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                    self.testDatas.append(self.testData)
                    self.testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, self.recordIDs))
                
                for item in self.recordIDs {
                    let result = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_128_Success_MultipleGuestSpace") {
                for i in 0...self.COUNT_NUMBER-1 {
                    self.recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                    self.testDatas.append(self.testData)
                    self.testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.addRecords(self.APP_GUEST_SPACE_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.deleteRecords(self.APP_GUEST_SPACE_ID, self.recordIDs))
                
                for item in self.recordIDs {
                    let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getRecord(self.APP_GUEST_SPACE_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_128_Success_MultipleAPIToken") {
                for i in 0...self.COUNT_NUMBER-1 {
                    self.recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                    self.testDatas.append(self.testData)
                    self.testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(self.recordModuleWithAPIToken.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(self.recordModuleWithAPIToken.deleteRecords(self.APP_ID, self.recordIDs))
                
                for item in self.recordIDs {
                    let result = TestCommonHandling.awaitAsync(self.recordModuleWithAPIToken.getRecord(self.APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_129_Error_NoneExistentRecord") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, self.NONEXISTENT_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_130_Error_WithouDeletetPermission") {
                self.recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[0])
                self.testDatas.append(self.testData)
                self.testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(self.recordModuleWithoutDeletePermissionRecord.deleteRecords(self.APP_ID, self.recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, self.recordIDs))
            }
            
            it("Test_133_Error_NoneExistentApp") {
                self.recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[0])
                self.testDatas.append(self.testData)
                self.testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(self.recordModuleWithoutDeletePermissionRecord.deleteRecords(self.NONEXISTENT_ID, self.recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, self.recordIDs))
            }
            
            it("Test_133_Error_NegativeApp") {
                self.recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[0])
                self.testDatas.append(self.testData)
                self.testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.NEGATIVE_ID, self.recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NEGATIVE_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, self.recordIDs))
            }
            
            it("Test_138_Success_100Records") {
                for i in 0...99 {
                    self.recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                    self.testDatas.append(self.testData)
                    self.testData = [:]
                }
                let addRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, self.recordIDs))
                
                for item in self.recordIDs {
                    let result = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_139_Error_101Records") {
                for i in 0...99 {
                    self.recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                    self.testDatas.append(self.testData)
                    self.testData = [:]
                }
                //Add 100 record into the testing application
                let addRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                // Add the record 101 into testing application
                self.recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                self.testData = RecordUtils.setRecordData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValues[self.recordTextValues.count-1])
                self.testData = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                self.recordIDs.append(addRecordResponse.getId()!)
                
                //Delete the record after created
                let result = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, self.recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.RECORD_ID_LARGER_THAN_100_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete all record after test finished
                for i in 0...100 {
                    _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, [self.recordIDs[i]]))
                }
            }
        }
    }
}

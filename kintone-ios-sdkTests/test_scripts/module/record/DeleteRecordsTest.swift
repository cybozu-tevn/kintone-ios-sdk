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
    override func spec() {
        let APP_ID = TestConstant.InitData.APP_ID!
        let NEGATIVE_ID = TestConstant.Common.NEGATIVE_ID
        let NONEXISTENT_ID = TestConstant.Common.NONEXISTENT_ID
        let GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_ID!
        let APP_GUEST_SPACE_ID = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let APP_API_TOKEN = TestConstant.InitData.APP_API_TOKEN
        
        var recordIDs = [Int]()
        let RECORD_TEXT_FIELD: String = TestConstant.InitData.TEXT_FIELD
        var recordTextValues = [String]()
        var testData: Dictionary<String, FieldValue>!
        var testDatas = [Dictionary<String, FieldValue>]()
        let COUNT_NUMBER = 5
        
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleWithoutDeletePermissionRecord = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORD_PERMISSION,
            TestConstant.Connection.CRED_PASSWORD_WITHOUT_DELETE_RECORD_PERMISSION))
        
        describe("DeleteRecord") {
            it("Test_127_Success_Single") {
                recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValues[0])
                testDatas.append(testData)
                testData = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(APP_ID, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIDs = addRecordResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
                
                for item in recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_128_Success_Multiple") {
                for i in 0...COUNT_NUMBER-1 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(APP_ID, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
                
                for item in recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_128_Success_MultipleGuestSpace") {
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    GUEST_SPACE_ID))
                
                for i in 0...COUNT_NUMBER-1 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecords(APP_GUEST_SPACE_ID, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(APP_GUEST_SPACE_ID, recordIDs))
                
                for item in recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(APP_GUEST_SPACE_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_128_Success_MultipleAPIToken") {
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(APP_API_TOKEN))
                
                for i in 0...COUNT_NUMBER-1 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.addRecords(APP_ID, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.deleteRecords(APP_ID, recordIDs))
                
                for item in recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.getRecord(APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_129_Error_NoneExistentRecord") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, NONEXISTENT_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_130_Error_WithouDeletetPermission") {
                recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValues[0])
                testDatas.append(testData)
                testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(APP_ID, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIDs = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutDeletePermissionRecord.deleteRecords(APP_ID, recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_133_Error_NoneExistentApp") {
                recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValues[0])
                testDatas.append(testData)
                testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(APP_ID, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIDs = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutDeletePermissionRecord.deleteRecords(NONEXISTENT_ID, recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_133_Error_NegativeApp") {
                recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValues[0])
                testDatas.append(testData)
                testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(APP_ID, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIDs = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecords(NEGATIVE_ID, recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NEGATIVE_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
            }
            
            it("Test_138_Success_100Records") {
                for i in 0...99 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(APP_ID, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs))
                
                for item in recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_139_Error_101Records") {
                for i in 0...99 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                //Add 100 record into the testing application
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(APP_ID, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIDs = addRecordsResponse.getIDs()!
                
                // Add the record 101 into testing application
                recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValues[recordTextValues.count-1])
                testData = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                recordIDs.append(addRecordResponse.getId()!)
                
                //Delete the record after created
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.RECORD_ID_LARGER_THAN_100_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete all record after test finished
                for i in 0...100 {
                    _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, [recordIDs[i]]))
                }
            }
        }
    }
}

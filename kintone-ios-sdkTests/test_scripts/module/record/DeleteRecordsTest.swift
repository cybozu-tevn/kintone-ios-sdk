//
// kintone-ios-sdkTests
// Created on 5/7/19
// 

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class DeleteRecordsTest: QuickSpec {
    override func spec() {
        let appId = TestConstant.InitData.APP_ID!
        let negativeId = TestConstant.Common.NEGATIVE_ID
        let noneExistentId = TestConstant.Common.NONEXISTENT_ID
        
        var recordIds = [Int]()
        let textField: String = TestConstant.InitData.TEXT_FIELD
        var recordTextValues = [String]()
        var testData: Dictionary<String, FieldValue>!
        var testDatas = [Dictionary<String, FieldValue>]()
        let numberOfRecords = 5
        
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleWithoutDeletePermissionRecord = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORD_PERMISSION,
            TestConstant.Connection.CRED_PASSWORD_WITHOUT_DELETE_RECORD_PERMISSION))
        
        describe("DeleteRecord") {
            it("Test_127_Success_Single") {
                recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[0])
                testDatas.append(testData)
                testData = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIds = addRecordResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
                
                for item in recordIds {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_128_Success_Multiple") {
                for i in 0...numberOfRecords - 1 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIds = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
                
                for item in recordIds {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_128_Success_Multiple_GuestSpace") {
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                
                for i in 0...numberOfRecords - 1 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecords(guestSpaceAppId, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIds = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(guestSpaceAppId, recordIds))
                
                for item in recordIds {
                    let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(guestSpaceAppId, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_128_Success_Multiple_ApiToken") {
                let apiToken = TestConstant.InitData.APP_API_TOKEN
                let recordModuleWithApiToken = Record(TestCommonHandling.createConnection(apiToken))
                
                for i in 0...numberOfRecords - 1 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleWithApiToken.addRecords(appId, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIds = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModuleWithApiToken.deleteRecords(appId, recordIds))
                
                for item in recordIds {
                    let result = TestCommonHandling.awaitAsync(recordModuleWithApiToken.getRecord(appId, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_129_Error_NoneExistentRecord") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, noneExistentId)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_130_Error_WithoutDeletetPermission") {
                recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[0])
                testDatas.append(testData)
                testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIds = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutDeletePermissionRecord.deleteRecords(appId, recordIds)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_133_Error_NoneExistentApp") {
                recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[0])
                testDatas.append(testData)
                testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIds = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutDeletePermissionRecord.deleteRecords(noneExistentId, recordIds)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_133_Error_NegativeApp") {
                recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[0])
                testDatas.append(testData)
                testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIds = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecords(negativeId, recordIds)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(negativeId))
                
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_138_Success_100Records") {
                for i in 0...99 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIds = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
                
                for item in recordIds {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_139_Error_101Records") {
                for i in 0...99 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                //Add 100 record into the testing application
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! AddRecordsResponse
                testDatas.removeAll()
                recordIds = addRecordsResponse.getIDs()!
                
                // Add the record 101 into testing application
                recordTextValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                testData = RecordUtils.setRecordData(
                    [:],
                    textField,
                    FieldType.SINGLE_LINE_TEXT,
                    recordTextValues[recordTextValues.count-1])
                testData = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordIds.append(addRecordResponse.getId()!)
                
                //Delete the record after created
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.RECORD_ID_LARGER_THAN_100_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                //Delete all record after test finished
                for i in 0...100 {
                    _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordIds[i]]))
                }
            }
        }
    }
}

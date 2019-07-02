//
// kintone-ios-sdkTests
// Created on 5/7/19
//

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class DeleteRecordsWithRevisionTest: QuickSpec {
    override func spec() {
        let AppId = TestConstant.InitData.APP_ID!
        let textField: String = TestConstant.InitData.TEXT_FIELD
        var textValues = [String]()
        var testData: Dictionary<String, FieldValue>!
        let NUMBER_OF_RECORDS = 5
        
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("DeleteRecordsWithRevision") {
            it("Test_140_Success_SingleRecord") {
                // Prepare records
                let textValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(AppId, testDataList)) as! AddRecordsResponse
                let recordIDs = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                // Delete records with revision
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(AppId, dictOfIDAndRevision))
                
                // Verify deleted records not existing
                for item in recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, item)) as! KintoneAPIException
                    
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                }
            }
            
            it("Test_141_Success_MultipleRecords") {
                var testDataList = [Dictionary<String, FieldValue>]()
                for _ in 0...NUMBER_OF_RECORDS-1 {
                    let textValue = DataRandomization.generateString()
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValue)
                    testDataList.append(testData)
                }
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(AppId, testDataList)) as! AddRecordsResponse
                let recordIDs = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(AppId, dictOfIDAndRevision))
                
                for item in recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, item)) as! KintoneAPIException
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                }
            }
            
            it("Test_142_Error_NonexistentRecord") {
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(AppId, [TestConstant.Common.NONEXISTENT_ID:nil])) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
            }
            
            it("Test_143_Error_IncorrectRevision") {
                let textValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(AppId, testDataList)) as! AddRecordsResponse
                let recordIDs = addRecordsResponse.getIDs()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (_, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = TestConstant.Common.NONEXISTENT_ID
                }
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(AppId, dictOfIDAndRevision)) as! KintoneAPIException
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(AppId, recordIDs))
            }
            
            it("Test_144_RevisionNegative1") {
                let textValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(AppId, testDataList)) as! AddRecordsResponse
                let recordIDs = addRecordsResponse.getIDs()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (_, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = -1
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(AppId, dictOfIDAndRevision))
                
                for item in recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, item)) as! KintoneAPIException
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                }
            }
            
            it("Test_145_Error_NoPermissionApp") {
                let textValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(AppId, testDataList)) as! AddRecordsResponse
                let recordIDs = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                let recordModuleWithoutDeleteRecordPermissionOnApp = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORDS_PERMISSION, TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORDS_PERMISSION))
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutDeleteRecordPermissionOnApp.deleteRecordsWithRevision(AppId, dictOfIDAndRevision)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(AppId, recordIDs))
            }
            
            it("Test_146_Error_NoPermissionRecord") {
                let textValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(AppId, testDataList)) as! AddRecordsResponse
                let recordIDs = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                let recordModuleWithoutDeleteRecordPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORD_PERMISSION, TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORD_PERMISSION))
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutDeleteRecordPermission.deleteRecordsWithRevision(AppId, dictOfIDAndRevision)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(AppId, recordIDs))
            }
            
            it("Test_147_Error_NonexistentApp") {
                let textValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(AppId, testDataList)) as! AddRecordsResponse
                let recordIDs = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                let result = TestCommonHandling.awaitAsync(
                    recordModule.deleteRecordsWithRevision(TestConstant.Common.NONEXISTENT_ID, dictOfIDAndRevision)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(AppId, recordIDs))
            }
            
            it("Test_148_Error_NegativeAppID") {
                let textValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(AppId, testDataList)) as! AddRecordsResponse
                let recordIDs = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                let result = TestCommonHandling.awaitAsync(
                    recordModule.deleteRecordsWithRevision(-1, dictOfIDAndRevision)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "-1")
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(AppId, recordIDs))
            }
            
            it("Test_153_100Records") {
                var testDataList = [Dictionary<String, FieldValue>]()
                for _ in 0...99 {
                    let textValue = DataRandomization.generateString()
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValue)
                    testDataList.append(testData)
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(AppId, testDataList)) as! AddRecordsResponse
                let recordIDs = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(AppId, dictOfIDAndRevision))
                
                for item in recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, item)) as! KintoneAPIException
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
                }
            }
            
            it("Test_154_Error_101Records") {
                // Add 100 records
                var testDataList = [Dictionary<String, FieldValue>]()
                for _ in 0...99 {
                    let textValue = DataRandomization.generateString()
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValue)
                    testDataList.append(testData)
                }
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(AppId, testDataList)) as! AddRecordsResponse
                var recordIDs = addRecordsResponse.getIDs()!
                var recordRevisions = addRecordsResponse.getRevisions()!
                
                // Add the 101st record
                let textValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                recordIDs.append(recordId)
                recordRevisions.append(addRecordResponse.getRevision()!)
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(AppId, dictOfIDAndRevision)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.RECORD_ID_AND_REVISION_LARGER_THAN_100_ERROR()!)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(AppId, recordIDs))
            }
            
            it("Test_128_Success_MultipleRecordsGuestSpace") {
                var testDataList = [Dictionary<String, FieldValue>]()
                for i in 0...NUMBER_OF_RECORDS-1 {
                    textValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValues[i])
                    testDataList.append(testData)
                    testData = [:]
                }
                
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                let guestAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecords(guestAppId, testDataList)) as! AddRecordsResponse
                let recordIDs = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecordsWithRevision(guestAppId, dictOfIDAndRevision))
                
                for item in recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(guestAppId, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_128_Success_MultipleRecordsAPIToken") {
                var testDataList = [Dictionary<String, FieldValue>]()
                for i in 0...NUMBER_OF_RECORDS-1 {
                    textValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textValues[i])
                    testDataList.append(testData)
                    testData = [:]
                }
                
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.addRecords(AppId, testDataList)) as! AddRecordsResponse
                let recordIDs = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIDs.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.deleteRecordsWithRevision(AppId, dictOfIDAndRevision))
                
                for item in recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.getRecord(AppId, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
        }
    }
}

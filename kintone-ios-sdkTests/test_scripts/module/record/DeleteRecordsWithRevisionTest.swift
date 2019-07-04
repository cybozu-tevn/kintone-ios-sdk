//
// kintone-ios-sdkTests
// Created on 5/7/19
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class DeleteRecordsWithRevisionTest: QuickSpec {
    override func spec() {
        let appId = TestConstant.InitData.APP_ID!
        let textField: String = TestConstant.InitData.TEXT_FIELD
        var textFieldValues = [String]()
        var testData: Dictionary<String, FieldValue>!
        let numberOfRecords = 5
        
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("DeleteRecordsWithRevision") {
            it("Test_140_Success_SingleRecord") {
                // Prepare records
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                // Delete records with revision
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, dictOfIDAndRevision))
                
                // Verify deleted records not existing
                verifyRecordsNotExisting(appId, recordIds)
            }
            
            it("Test_141_Success_MultipleRecords") {
                var testDataList = [Dictionary<String, FieldValue>]()
                for _ in 0...numberOfRecords-1 {
                    let textFieldValue = DataRandomization.generateString()
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                    testDataList.append(testData)
                }
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, dictOfIDAndRevision))
                
                verifyRecordsNotExisting(appId, recordIds)
            }
            
            it("Test_142_Error_NonexistentRecord") {
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, [TestConstant.Common.NONEXISTENT_ID:nil])) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_143_Error_IncorrectRevision") {
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (_, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = TestConstant.Common.NONEXISTENT_ID
                }
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, dictOfIDAndRevision)) as! KintoneAPIException

                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_144_RevisionNegative1") {
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (_, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = -1
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, dictOfIDAndRevision))
                
                verifyRecordsNotExisting(appId, recordIds)
            }
            
            it("Test_145_Error_NoPermissionApp") {
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                let recordModuleWithoutDeletePermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORDS_PERMISSION, TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORDS_PERMISSION))
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutDeletePermission.deleteRecordsWithRevision(appId, dictOfIDAndRevision)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_146_Error_NoPermissionRecord") {
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                let recordModuleWithoutDeleteRecordPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORD_PERMISSION, TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORD_PERMISSION))
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutDeleteRecordPermission.deleteRecordsWithRevision(appId, dictOfIDAndRevision)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_147_Error_NonexistentApp") {
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                let result = TestCommonHandling.awaitAsync(
                    recordModule.deleteRecordsWithRevision(TestConstant.Common.NONEXISTENT_ID, dictOfIDAndRevision)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)

                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_148_Error_NegativeAppID") {
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let testDataList = [testData]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                let result = TestCommonHandling.awaitAsync(
                    recordModule.deleteRecordsWithRevision(-1, dictOfIDAndRevision)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: "-1")
                TestCommonHandling.compareError(actualError, expectedError)

                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_153_100Records") {
                var testDataList = [Dictionary<String, FieldValue>]()
                for _ in 0...99 {
                    let textFieldValue = DataRandomization.generateString()
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                    testDataList.append(testData)
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, dictOfIDAndRevision))
                
                verifyRecordsNotExisting(appId, recordIds)
            }
            
            it("Test_154_Error_101Records") {
                // Add 100 records
                var testDataList = [Dictionary<String, FieldValue>]()
                for _ in 0...99 {
                    let textFieldValue = DataRandomization.generateString()
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                    testDataList.append(testData)
                }
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                var recordIds = addRecordsResponse.getIDs()!
                var recordRevisions = addRecordsResponse.getRevisions()!
                
                // Add the 101st record
                let textFieldValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                let recordId = addRecordResponse.getId()!
                recordIds.append(recordId)
                recordRevisions.append(addRecordResponse.getRevision()!)
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, dictOfIDAndRevision)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.RECORD_ID_AND_REVISION_LARGER_THAN_100_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_128_Success_MultipleRecordsGuestSpace") {
                var testDataList = [Dictionary<String, FieldValue>]()
                for i in 0...numberOfRecords-1 {
                    textFieldValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                    testDataList.append(testData)
                    testData = [:]
                }
                
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                let guestAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecords(guestAppId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecordsWithRevision(guestAppId, dictOfIDAndRevision))
                
                for item in recordIds {
                    let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(appId, item)) as! KintoneAPIException
                    
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    TestCommonHandling.compareError(actualError, expectedError)
                }
            }
            
            it("Test_128_Success_MultipleRecordsAPIToken") {
                var testDataList = [Dictionary<String, FieldValue>]()
                for i in 0...numberOfRecords-1 {
                    textFieldValues.append(DataRandomization.generateString(prefix: "Record", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                    testDataList.append(testData)
                    testData = [:]
                }
                
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let recordRevisions = addRecordsResponse.getRevisions()!
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.deleteRecordsWithRevision(appId, dictOfIDAndRevision))
                
                verifyRecordsNotExisting(appId, recordIds)
            }
        }
        
        func verifyRecordsNotExisting(_ appId: Int, _ recordIds: Array<Int>) {
            for item in recordIds {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, item)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

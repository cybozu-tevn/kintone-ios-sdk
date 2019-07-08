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
        var recordIds = [Int]()
        var recordRevisions = [Int]()
        let textField: String = TestConstant.InitData.TEXT_FIELD
        let numberOfRecords = 5
        
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("DeleteRecordsWithRevision") {
            it("Test_140_Success_SingleRecord") {
                // Prepare records
                _prepareRecords(recordModule, appId, 1)
                
                // Delete records with revision
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, dictOfIDAndRevision))
                
                // Verify deleted records not existing
                _verifyRecordsNotExisting(recordModule, appId, recordIds)
            }
            
            it("Test_141_Success_MultipleRecords") {
                _prepareRecords(recordModule, appId, numberOfRecords)
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, dictOfIDAndRevision))
                
                _verifyRecordsNotExisting(recordModule, appId, recordIds)
            }
            
            it("Test_142_Error_NonexistentRecord") {
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, [TestConstant.Common.NONEXISTENT_ID:nil])) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_143_Error_IncorrectRevision") {
                _prepareRecords(recordModule, appId, 1)
                
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
                _prepareRecords(recordModule, appId, 1)
                
                var dictOfIDAndRevision = [Int:Int]()
                for (_, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = -1
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, dictOfIDAndRevision))
                
                _verifyRecordsNotExisting(recordModule, appId, recordIds)
            }
            
            it("Test_145_Error_NoPermissionApp") {
                _prepareRecords(recordModule, appId, 1)
                
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
                _prepareRecords(recordModule, appId, 1)
                
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
                _prepareRecords(recordModule, appId, 1)
                
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
                _prepareRecords(recordModule, appId, 1)
                
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
                _prepareRecords(recordModule, appId, 100)
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, dictOfIDAndRevision))
                
                _verifyRecordsNotExisting(recordModule, appId, recordIds)
            }
            
            it("Test_154_Error_101Records") {
                // Add 101 records
                _prepareRecords(recordModule, appId, 100)
                var recordIds_101 = recordIds
                var recordRevisions_101 = recordRevisions
                _prepareRecords(recordModule, appId, 1)
                recordIds_101 += recordIds
                recordRevisions_101 += recordRevisions
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds_101.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions_101[index]
                }
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecordsWithRevision(appId, dictOfIDAndRevision)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.RECORD_ID_AND_REVISION_LARGER_THAN_100_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_128_Success_MultipleRecordsGuestSpace") {
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                _prepareRecords(recordModuleGuestSpace, guestSpaceAppId, numberOfRecords)
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecordsWithRevision(guestSpaceAppId, dictOfIDAndRevision))
                
                _verifyRecordsNotExisting(recordModuleGuestSpace, guestSpaceAppId, recordIds)
            }
            
            it("Test_128_Success_MultipleRecordsAPIToken") {
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                _prepareRecords(recordModuleWithAPIToken, appId, numberOfRecords)
                
                var dictOfIDAndRevision = [Int:Int]()
                for (index, value) in recordIds.enumerated() {
                    dictOfIDAndRevision[value] = recordRevisions[index]
                }
                _ = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.deleteRecordsWithRevision(appId, dictOfIDAndRevision))
                
                _verifyRecordsNotExisting(recordModule, appId, recordIds)
            }
        }
        
        func _prepareRecords(_ recordModule: Record, _ appId: Int, _ numberOfRecords: Int) {
            var testDataList = [Dictionary<String, FieldValue>]()
            var textFieldValues = [String]()
            for i in 0...numberOfRecords-1 {
                textFieldValues.append(DataRandomization.generateString())
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                testDataList.append(testData)
            }
            
            let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
            recordIds = addRecordsResponse.getIDs()!
            recordRevisions = addRecordsResponse.getRevisions()!
        }
        
        func _verifyRecordsNotExisting(_ recordModule: Record, _ appId: Int, _ recordIds: Array<Int>) {
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

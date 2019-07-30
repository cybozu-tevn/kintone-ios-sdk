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
        let noneExistentId = TestConstant.Common.NONEXISTENT_ID
        let appId = TestConstant.InitData.APP_ID!
        var recordIds = [Int]()
        let textField: String = TestConstant.InitData.TEXT_FIELD
        let numberOfRecords = 5
        
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("DeleteRecords") {
            it("Test_127_Success_Single") {
                _prepareRecords(recordModule, appId, 1)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
                
                _verifyRecordsNotExisting(recordModule, appId, recordIds)
            }
            
            it("Test_128_Success_Multiple") {
                _prepareRecords(recordModule, appId, numberOfRecords)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
                
                _verifyRecordsNotExisting(recordModule, appId, recordIds)
            }
            
            it("Test_128_Success_Multiple_GuestSpace") {
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                _prepareRecords(recordModuleGuestSpace, guestSpaceAppId, numberOfRecords)
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(guestSpaceAppId, recordIds))
                
                _verifyRecordsNotExisting(recordModuleGuestSpace, guestSpaceAppId, recordIds)
            }
            
            it("Test_128_Success_Multiple_ApiToken") {
                let apiToken = TestConstant.InitData.APP_API_TOKEN
                let recordModuleWithApiToken = Record(TestCommonHandling.createConnection(apiToken))
                _prepareRecords(recordModuleWithApiToken, appId, numberOfRecords)
                
                _ = TestCommonHandling.awaitAsync(recordModuleWithApiToken.deleteRecords(appId, recordIds))
                
                _verifyRecordsNotExisting(recordModule, appId, recordIds)
            }
            
            it("Test_129_Error_NoneExistentRecord") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, noneExistentId)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_130_Error_WithoutDeletetPermission") {
                _prepareRecords(recordModule, appId, 1)
                
                let recordModuleWithoutDeletePermissionRecord = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_DELETE_RECORD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_DELETE_RECORD_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutDeletePermissionRecord.deleteRecords(appId, recordIds)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_133_Error_NoneExistentApp") {
                _prepareRecords(recordModule, appId, 1)
                
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecords(noneExistentId, recordIds)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_133_Error_NegativeApp") {
                _prepareRecords(recordModule, appId, 1)
                
                let negativeId = TestConstant.Common.NEGATIVE_ID
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecords(negativeId, recordIds)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(negativeId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
            }
            
            it("Test_138_Success_100Records") {
                _prepareRecords(recordModule, appId, 100)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
                
                _verifyRecordsNotExisting(recordModule, appId, recordIds)
            }
            
            it("Test_139_Error_101Records") {
                // Add 101 records
                _prepareRecords(recordModule, appId, 100)
                var recordIds_101 = recordIds
                _prepareRecords(recordModule, appId, 1)
                recordIds_101 += recordIds
                
                // Delete records
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds_101)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.RECORD_ID_LARGER_THAN_100_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordIds_101[100]]))
                recordIds_101.removeLast()
                 _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds_101))
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

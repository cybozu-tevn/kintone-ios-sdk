//
// kintone-ios-sdkTests
// Created on 7/3/19
// 

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class AddRecordsTest: QuickSpec {
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        let appId = TestConstant.InitData.SPACE_APP_ID!
        let textField: String = TestConstant.InitData.TEXT_FIELD
        let numberOfRecords = 5
        var recordIds = [Int]()
        var recordTextValues = [String]()
        var testData: Dictionary<String, FieldValue>!
        var testDatas = [Dictionary<String, FieldValue>]()
        
        describe("AddRecords") {
            beforeEach {
                testDatas.removeAll()
            }
            
            it("Test_046_Success_ValidData") {
                // Prepare test data
                for i in 0...numberOfRecords - 1 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                // Send request to add and get records
                let addRecordsRsp = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! AddRecordsResponse
                recordIds = addRecordsRsp.getIDs()!
                let query = RecordUtils.getRecordsQuery(recordIds)
                let result = TestCommonHandling.awaitAsync(recordModule.getRecords(appId, query, [textField], true)) as! GetRecordsResponse

                // Verify the actual and expected result
                for (_, value) in (addRecordsRsp.getRevisions()!.enumerated()) {
                    expect(value).to(equal(1))
                }
                expect(result.getTotalCount()!).to(equal(numberOfRecords))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(recordTextValues[index]))
                    }
                }
                
                // Remove test data
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_046_Success_ValidData_ApiToken") {
                let apiToken = TestConstant.InitData.SPACE_APP_API_TOKEN
                let recordModuleWithApiToken = Record(TestCommonHandling.createConnection(apiToken))
                for i in 0...numberOfRecords - 1 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleWithApiToken.addRecords(appId, testDatas)) as! AddRecordsResponse
                recordIds = addRecordsResponse.getIDs()!
                let query = RecordUtils.getRecordsQuery(recordIds)
                let result = TestCommonHandling.awaitAsync(recordModuleWithApiToken.getRecords(
                    appId,
                    query,
                    [textField],
                    true)) as! GetRecordsResponse
                
                for (_, value) in (addRecordsResponse.getRevisions()!.enumerated()) {
                    expect(value).to(equal(1))
                }
                expect(result.getTotalCount()!).to(equal(numberOfRecords))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(recordTextValues[index]))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModuleWithApiToken, appID: appId)
            }
            
            it("Test_047_Error_NoneExistentAppId") {
                let noneExistentId = TestConstant.Common.NONEXISTENT_ID
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(noneExistentId, testDatas)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_047_Error_NegativeAppId") {
                let negativeId = TestConstant.Common.NEGATIVE_ID
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(negativeId, testDatas)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(negativeId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_048_Success_InvalidField") {
                for i in 0...numberOfRecords - 1 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    testData = RecordUtils.setRecordData([:], "Invalid", FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let addRecordsRsp = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! AddRecordsResponse
                for (_, value) in (addRecordsRsp.getRevisions()!.enumerated()) {
                    expect(value).to(equal(1))
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_049_Error_InputTextToNumberField") {
                let numberField: String = TestConstant.InitData.NUMBER_FIELD
                testData = RecordUtils.setRecordData([:], numberField, FieldType.NUMBER, "inputTextToNumber")
                testDatas.append(testData)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(testDatas.firstIndex(of: testData)!)][\(numberField)]")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_050_Error_DuplicateDataForProhibitDuplicateValue") {
                let prohibitDuplicateField = TestConstant.InitData.TEXT_UPDATE_KEY_FIELD
                testData = RecordUtils.setRecordData([:], prohibitDuplicateField, FieldType.SINGLE_LINE_TEXT, "prohibitValue")
                testDatas.append(testData)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas))
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(testDatas.firstIndex(of: testData)!)].\(prohibitDuplicateField)")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_054_Success_WithoutRequiredFieldValue") {
                let appHasRequiredFieldId = TestConstant.InitData.APP_ID_HAS_REQUIRED_FIELDS!
                let requireField = TestConstant.InitData.REQUIRE_FIELD
                testData = RecordUtils.setRecordData([:], "", FieldType.SINGLE_LINE_TEXT, "")
                testDatas.append(testData)
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(appHasRequiredFieldId, testDatas)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(testDatas.firstIndex(of: testData)!)].\(requireField)")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_057_Success_ValidData_GuestSpace") {
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                var recordIdsGuestSpace = [Int]()
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                for i in 0...numberOfRecords - 1 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecords(guestSpaceAppId, testDatas)) as! AddRecordsResponse
                recordIdsGuestSpace = addRecordsResponse.getIDs()!
                let query = RecordUtils.getRecordsQuery(recordIdsGuestSpace)
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecords(
                    guestSpaceAppId,
                    query,
                    [textField],
                    true)) as! GetRecordsResponse
                
                for (_, value) in (addRecordsResponse.getRevisions()!.enumerated()) {
                    expect(value).to(equal(1))
                }
                expect(result.getTotalCount()!).to(equal(numberOfRecords))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(recordTextValues[index]))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModuleGuestSpace, appID: guestSpaceAppId)
            }
            
            it("Test_059_Error_WithoutAddRecordPermission") {
                let recordModuleWithoutAddPermissionApp = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_ADD_RECORDS_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_ADD_RECORDS_PERMISSION))
                for i in 0...numberOfRecords - 1 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutAddPermissionApp.addRecords(appId, testDatas)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_060_Success_100Records") {
                for i in 0...99 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! AddRecordsResponse
                recordIds = addRecordsResponse.getIDs()!
                let query = RecordUtils.getRecordsQuery(recordIds)
                let result = TestCommonHandling.awaitAsync(recordModule.getRecords(
                    appId,
                    query,
                    [textField],
                    true)) as! GetRecordsResponse
                
                for (_, value) in (addRecordsResponse.getRevisions()!.enumerated()) {
                    expect(value).to(equal(1))
                }
                expect(result.getTotalCount()!).to(equal(100))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(recordTextValues[index]))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_061_Error_101Records") {
                for i in 0...100 {
                    recordTextValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                    testDatas.append(testData)
                    testData = [:]
                }
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDatas)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.RECORD_ID_LARGER_THAN_100_ERROR_ADD_RECORD()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

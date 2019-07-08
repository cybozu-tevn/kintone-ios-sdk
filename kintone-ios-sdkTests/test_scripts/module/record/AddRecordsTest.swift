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
        
        describe("AddRecords") {
            it("Test_046_Success_ValidData") {
                // Prepare test data
                var textFieldValues = [String]()
                var testDataList = [Dictionary<String, FieldValue>]()
                for i in 0...numberOfRecords - 1 {
                    textFieldValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                    testDataList.append(testData)
                }
                
                // Send request to add and get records
                let addRecordsRsp = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsRsp.getIDs()!
                let query = RecordUtils.getRecordsQuery(recordIds)
                let getRecordsResponse = TestCommonHandling.awaitAsync(recordModule.getRecords(appId, query, [textField], true)) as! GetRecordsResponse
                
                // Verify records info
                for (_, value) in (addRecordsRsp.getRevisions()!.enumerated()) {
                    expect(value).to(equal(1))
                }
                expect(getRecordsResponse.getTotalCount()!).to(equal(numberOfRecords))
                for(index, dval) in (getRecordsResponse.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(textFieldValues[index]))
                    }
                }
                
                // Remove test data
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_046_Success_ValidData_ApiToken") {
                let apiToken = TestConstant.InitData.SPACE_APP_API_TOKEN
                let recordModuleWithApiToken = Record(TestCommonHandling.createConnection(apiToken))
                var textFieldValues = [String]()
                var testDataList = [Dictionary<String, FieldValue>]()
                for i in 0...numberOfRecords - 1 {
                    textFieldValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                    testDataList.append(testData)
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleWithApiToken.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let query = RecordUtils.getRecordsQuery(recordIds)
                let getRecordsResponse = TestCommonHandling.awaitAsync(recordModuleWithApiToken.getRecords(appId, query, [textField], true)) as! GetRecordsResponse
                
                for (_, value) in (addRecordsResponse.getRevisions()!.enumerated()) {
                    expect(value).to(equal(1))
                }
                expect(getRecordsResponse.getTotalCount()!).to(equal(numberOfRecords))
                for(index, dval) in (getRecordsResponse.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(textFieldValues[index]))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModuleWithApiToken, appID: appId)
            }
            
            it("Test_047_Error_NoneExistentAppId") {
                let noneExistentId = TestConstant.Common.NONEXISTENT_ID
                let testDataList = [Dictionary<String, FieldValue>]()
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(noneExistentId, testDataList)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_047_Error_NegativeAppId") {
                let negativeId = TestConstant.Common.NEGATIVE_ID
                let testDataList = [Dictionary<String, FieldValue>]()
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(negativeId, testDataList)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(negativeId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_048_Success_InvalidField") {
                var textFieldValues = [String]()
                var testDataList = [Dictionary<String, FieldValue>]()
                for i in 0...numberOfRecords - 1 {
                    textFieldValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    let testData = RecordUtils.setRecordData([:], "Invalid", FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                    testDataList.append(testData)
                }
                
                let addRecordsRsp = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                for (_, value) in (addRecordsRsp.getRevisions()!.enumerated()) {
                    expect(value).to(equal(1))
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_049_Error_InputTextToNumberField") {
                let numberField: String = TestConstant.InitData.NUMBER_FIELD
                let testData = RecordUtils.setRecordData([:], numberField, FieldType.NUMBER, "inputTextToNumber")
                let testDataList = [testData]
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(testDataList.firstIndex(of: testData)!)][\(numberField)]")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_050_Error_DuplicateDataForProhibitDuplicateValue") {
                let prohibitDuplicateField = TestConstant.InitData.TEXT_UPDATE_KEY_FIELD
                var testDataList = [Dictionary<String, FieldValue>]()
                let testData = RecordUtils.setRecordData([:], prohibitDuplicateField, FieldType.SINGLE_LINE_TEXT, "prohibitValue")
                testDataList.append(testData)
                testDataList.append(testData)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[1].\(prohibitDuplicateField)")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_054_Success_WithoutRequiredFieldValue") {
                let appHasRequiredFieldId = TestConstant.InitData.APP_ID_HAS_REQUIRED_FIELDS!
                let requireField = TestConstant.InitData.REQUIRE_FIELD
                let testData = RecordUtils.setRecordData([:], "", FieldType.SINGLE_LINE_TEXT, "")
                let testDataList = [testData]
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(appHasRequiredFieldId, testDataList)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(testDataList.firstIndex(of: testData)!)].\(requireField)")
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
                var textFieldValues = [String]()
                var testDataList = [Dictionary<String, FieldValue>]()
                for i in 0...numberOfRecords - 1 {
                    textFieldValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                    testDataList.append(testData)
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecords(guestSpaceAppId, testDataList)) as! AddRecordsResponse
                recordIdsGuestSpace = addRecordsResponse.getIDs()!
                let query = RecordUtils.getRecordsQuery(recordIdsGuestSpace)
                let getRecordsResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecords(guestSpaceAppId, query, [textField], true)) as! GetRecordsResponse
                
                for (_, value) in (addRecordsResponse.getRevisions()!.enumerated()) {
                    expect(value).to(equal(1))
                }
                expect(getRecordsResponse.getTotalCount()!).to(equal(numberOfRecords))
                for(index, dval) in (getRecordsResponse.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(textFieldValues[index]))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModuleGuestSpace, appID: guestSpaceAppId)
            }
            
            it("Test_059_Error_WithoutAddRecordPermission") {
                let recordModuleWithoutAddRecordsPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_ADD_RECORDS_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_ADD_RECORDS_PERMISSION))
                var testDataList = [Dictionary<String, FieldValue>]()
                for _ in 0...numberOfRecords - 1 {
                    let textFieldValue = DataRandomization.generateString(prefix: "AddRecords", length: 10)
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                    testDataList.append(testData)
                }
                
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutAddRecordsPermission.addRecords(appId, testDataList)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_060_Success_100Records") {
                var textFieldValues = [String]()
                var testDataList = [Dictionary<String, FieldValue>]()
                for i in 0...99 {
                    textFieldValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                    testDataList.append(testData)
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let query = RecordUtils.getRecordsQuery(recordIds)
                let getRecordsResponse = TestCommonHandling.awaitAsync(recordModule.getRecords(appId, query, [textField], true)) as! GetRecordsResponse
                
                for (_, value) in (addRecordsResponse.getRevisions()!.enumerated()) {
                    expect(value).to(equal(1))
                }
                expect(getRecordsResponse.getTotalCount()!).to(equal(100))
                for(index, dval) in (getRecordsResponse.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(textFieldValues[index]))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
            }
            
            it("Test_061_Error_101Records") {
                var testDataList = [Dictionary<String, FieldValue>]()
                for _ in 0...100 {
                    let textFieldValue = DataRandomization.generateString(prefix: "AddRecords", length: 10)
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValue)
                    testDataList.append(testData)
                }
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.RECORD_ID_LARGER_THAN_100_ERROR_ADD_RECORD()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

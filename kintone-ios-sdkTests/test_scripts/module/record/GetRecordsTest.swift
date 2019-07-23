//
//  GetRecordsTest.swift
//  kintone-ios-sdkTests
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class GetRecordsTest: QuickSpec {
    override func spec() {
        let appId = TestConstant.InitData.APP_ID!
        let textField: String! = TestConstant.InitData.TEXT_FIELD
        let numberOfRecords = 5
        var recordIds = [Int]()
        var textFieldValues = [String]()
        var query: String!
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("GetRecords") {
            it("AddTestData_BeforeSuiteWorkaround") {
                _prepareRecords(numberOfRecords)
                query = RecordUtils.getRecordsQuery(recordIds)
            }
            
            it("Test_004_Success_ValidData") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(appId, query, [textField], true)) as! GetRecordsResponse
                
                expect(result.getTotalCount()!).to(equal(numberOfRecords))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(textFieldValues[index]))
                    }
                }
            }
            
            it("Test_005_Error_NonexistentAppId") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(TestConstant.Common.NONEXISTENT_ID, query, [textField], true)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_005_Error_NegativeAppId") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(-4, query, [textField], true)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(-4))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_006_Error_InvalidQuery") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(appId, "invalid", [textField], true)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.INVALID_QUERY_GET_DATA_ERROR()!)
            }
            
            it("Test_021_Error_WithoutViewRecordsOnAppPermission") {
                let recordModuleWithoutViewRecordsPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutViewRecordsPermission.getRecords(appId, query, [textField], true)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_022_Error_WithoutViewOnRecordPermission") {
                let recordModuleWithoutViewOnRecordPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutViewOnRecordPermission.getRecords(appId, query, [textField], true)) as! GetRecordsResponse
                
                expect(result.getTotalCount()).to(equal(0))
            }
            
            it("Test_023_Error_WithoutViewOnFieldPermission") {
                let recordModuleWithoutViewOnFieldPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutViewOnFieldPermission.getRecords(appId, query, [textField], true)) as! GetRecordsResponse
                
                for(_, dval) in (result.getRecords()!.enumerated()) {
                    expect(dval).to(equal([:]))
                }
            }
            
            it("Test_025_Success_RetrivedAtOneIs500") {
                // There are 5 records prepared at beforeSuite hook so we just need prepare more 495 records
                var recordIds_500 = recordIds
                var textFieldValues_500 = textFieldValues
                for _ in 0...3 {
                    _prepareRecords(100)
                    recordIds_500 += recordIds
                    textFieldValues_500 += textFieldValues
                }
                _prepareRecords(95)
                recordIds_500 += recordIds
                textFieldValues_500 += textFieldValues
                
                let query = RecordUtils.getRecordsQuery(recordIds_500)
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(appId, query, [textField], true)) as! GetRecordsResponse
                
                expect(result.getTotalCount()).to(equal(500))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(textFieldValues_500[index]))
                    }
                }
            }
            
            it("Test_026_Error_QueryLargerThan500") {
                let query = "$id > 0 order by $id asc limit 999 offset 0"
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(appId, query, [textField], true)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.LIMIT_LARGER_THAN_500_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // --------- GUEST SPACE ---------
            it("Test_014_Success_ValidData_GuestSpace") {
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                
                var testDataList = [Dictionary<String, FieldValue>]()
                var textFieldValues = [String]()
                for i in 0...numberOfRecords-1 {
                    textFieldValues.append(DataRandomization.generateString())
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                    testDataList.append(testData)
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecords(guestSpaceAppId, testDataList)) as! AddRecordsResponse
                let recordIds = addRecordsResponse.getIDs()!
                let queryGuestSpace = RecordUtils.getRecordsQuery(recordIds)

                let result = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecords(guestSpaceAppId, queryGuestSpace, [textField], true)) as! GetRecordsResponse
                
                expect(result.getTotalCount()!).to(equal(numberOfRecords))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(textFieldValues[index]))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModuleGuestSpace, appID: guestSpaceAppId)
            }
            
            // --------- API Token ---------
            it("Test_014_Success_ValidData_APIToken") {
                _prepareRecords(numberOfRecords)
                query = RecordUtils.getRecordsQuery(recordIds)
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithAPIToken.getRecords(appId, query, [textField], true)) as! GetRecordsResponse
                
                expect(result.getTotalCount()!).to(equal(numberOfRecords))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(textFieldValues[index]))
                    }
                }
            }
        }
        
        func _prepareRecords(_ numberOfRecords: Int) {
            var testDataList = [Dictionary<String, FieldValue>]()
            textFieldValues.removeAll()
            for i in 0...numberOfRecords-1 {
                textFieldValues.append(DataRandomization.generateString())
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                testDataList.append(testData)
            }
            
            let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
            recordIds = addRecordsResponse.getIDs()!
        }
        
        it("WipeoutTestData_AfterSuiteWorkaround") {
            RecordUtils.deleteAllRecords(recordModule: recordModule, appID: appId)
        }
    }
}

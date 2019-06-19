//
//  GetRecordsTest.swift
//  kintone-ios-sdkTests
//

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class GetRecordsTest: QuickSpec {
    override func spec() {
        let APP_ID = TestConstant.InitData.APP_ID!
        let TEXT_FIELD: String! = TestConstant.InitData.TEXT_FIELD
        let NUMBER_OF_RECORDS = 5
        var recordIDs = [Int]()
        var recordTextValues = [String]()
        var testData: Dictionary<String, FieldValue>!
        var testDataList = [Dictionary<String, FieldValue>]()
        var query: String!
        let recordModule = Record(TestCommonHandling.createConnection())
        
        beforeSuite {
            // Prepare records
            for i in 0...NUMBER_OF_RECORDS-1 {
                recordTextValues.append(DataRandomization.generateString())
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValues[i])
                testDataList.append(testData)
                testData = [:]
            }
            
            let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(APP_ID, testDataList)) as! AddRecordsResponse
            recordIDs = addRecordsResponse.getIDs()!
            
            query = RecordUtils.getRecordsQuery(recordIDs)
        }
        
        afterSuite {
            RecordUtils.deleteAllRecords(recordModule: recordModule, appID: APP_ID)
        }
        
        describe("GetRecordsTest") {
            it("Test_004_Success_ValidData") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(APP_ID, query, [TEXT_FIELD], true)) as! GetRecordsResponse
                
                expect(result.getTotalCount()!).to(equal(NUMBER_OF_RECORDS))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(recordTextValues[index]))
                    }
                }
            }
            
            it("Test_005_Error_NonexistentAppID") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(TestConstant.Common.NONEXISTENT_ID, query, [TEXT_FIELD], true)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
            }
            
            it("Test_005_Error_NegativeAppID") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(-4, query, [TEXT_FIELD], true)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(-4))
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
            }
            
            it("Test_006_Error_InvalidQuery") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(APP_ID, "invalid", [TEXT_FIELD], true)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.INVALID_QUERY_GET_DATA_ERROR()!)
            }
            
            it("Test_021_Error_WithoutViewRecordsOnAppPermission") {
                let recordModuleWithoutViewRecordsPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutViewRecordsPermission.getRecords(APP_ID, query, [TEXT_FIELD], true)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
            }
            
            it("Test_022_Error_WithoutViewOnRecordPermission") {
                let recordModuleWithoutViewOnRecordPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutViewOnRecordPermission.getRecords(APP_ID, query, [TEXT_FIELD], true)) as! GetRecordsResponse
                
                expect(result.getTotalCount()).to(equal(0))
            }
            
            it("Test_023_Error_WithoutViewOnFieldPermission") {
                let recordModuleWithoutViewOnFieldPermission = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutViewOnFieldPermission.getRecords(APP_ID, query, [TEXT_FIELD], true)) as! GetRecordsResponse
                
                for(_, dval) in (result.getRecords()!.enumerated()) {
                    expect(dval).to(equal([:]))
                }
            }
            
            it("Test_025_Success_RetrivedAtOneIs500") {
                //We have create 5 records at setUp so we just need more 455
                let countNumber = 495
                
                for _ in 1...5 {
                    var testDataListTmp = [Dictionary<String, FieldValue>]()
                    for _ in 0...countNumber/5-1 {
                        recordTextValues.append(DataRandomization.generateString())
                        testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, recordTextValues[recordTextValues.count-1])
                        testDataListTmp.append(testData)
                        testData = [:]
                    }
                    let addRecordsResponse = TestCommonHandling.awaitAsync(
                        recordModule.addRecords(APP_ID, testDataListTmp)) as! AddRecordsResponse
                    recordIDs += addRecordsResponse.getIDs()!
                    testDataList += testDataListTmp
                }
                
                let query = RecordUtils.getRecordsQuery(recordIDs)
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(APP_ID, query, [TEXT_FIELD], true)) as! GetRecordsResponse
                
                expect(result.getTotalCount()).to(equal(500))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(recordTextValues[index]))
                    }
                }
            }
            
            it("Test_026_Error_QueryLargerThan500") {
                let query = "$id > 0 order by $id asc limit 999 offset 0"
                let result = TestCommonHandling.awaitAsync(
                    recordModule.getRecords(APP_ID, query, [TEXT_FIELD], true)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.LIMIT_LARGER_THAN_500_ERROR()!)
            }
            
            it("Test_014_Success_ValidDataGuestSpace") {
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                
                let addRecordsResponseGuestSpace = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.addRecords(guestSpaceAppId, testDataList)) as! AddRecordsResponse
                let guestSpaceRecordIds = addRecordsResponseGuestSpace.getIDs()!
                
                var idsStringGuestSpace = "("
                for id in guestSpaceRecordIds {
                    if idsStringGuestSpace == "(" {
                        idsStringGuestSpace += String(id)
                    } else {
                        idsStringGuestSpace += "," + String(id)
                    }
                }
                let queryGuestSpace = "$id in " + idsStringGuestSpace + ")" +  " order by $id asc"
                let result = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecords(guestSpaceAppId, queryGuestSpace, [TEXT_FIELD], true)) as! GetRecordsResponse
                
                expect(result.getTotalCount()!).to(equal(NUMBER_OF_RECORDS))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(recordTextValues[index]))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModuleGuestSpace, appID: guestSpaceAppId)
            }
            
            it("Test_014_Success_APITokenValidData") {
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithAPIToken.getRecords(APP_ID, query, [TEXT_FIELD], true)) as! GetRecordsResponse
                
                expect(result.getTotalCount()!).to(equal(NUMBER_OF_RECORDS))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(recordTextValues[index]))
                    }
                }
            }
        }
    }
}

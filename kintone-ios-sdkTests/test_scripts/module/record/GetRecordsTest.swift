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
    let RECORD_TEXT_FIELD: String! = "text"
    let NUMBER_OF_RECORDS = 5
    var recordIDs = [Int]()
    var recordTextValues = [String]()
    var testData: Dictionary<String, FieldValue>!
    var testDataList = [Dictionary<String, FieldValue>]()
    var query: String!
    
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        
        beforeSuite {
            for i in 0...self.NUMBER_OF_RECORDS-1 {
                self.recordTextValues.append(DataRandomization.generateString())
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                self.testDataList.append(self.testData)
                self.testData = [:]
            }
            
            //Add records
            let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(TestConstant.Common.APP_ID, self.testDataList)) as! AddRecordsResponse
            self.recordIDs = addRecordsResponse.getIDs()!
            
            self.query = RecordUtils.getRecordsQuery(self.recordIDs)
        }
        
        describe("GetRecordsTest") {
            it("Test_004_Success_ValidData") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecords(
                    TestConstant.Common.APP_ID,
                    self.query,
                    [self.RECORD_TEXT_FIELD],
                    true)) as! GetRecordsResponse
                expect(result.getTotalCount()!).to(equal(self.NUMBER_OF_RECORDS))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(self.recordTextValues[index]))
                    }
                }
            }
            
            it("Test_005_Error_NonexistentAppID") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecords(
                    TestConstant.Common.NONEXISTENT_ID,
                    self.query,
                    [self.RECORD_TEXT_FIELD],
                    true)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
            }
            
            it("Test_005_Error_NegativeAppID") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecords(
                    -4,
                    self.query,
                    [self.RECORD_TEXT_FIELD],
                    true)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(-4))
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
            }
            
            it("Test_006_Error_InvalidQuery") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecords(
                    TestConstant.Common.APP_ID,
                    "invalid",
                    [self.RECORD_TEXT_FIELD],
                    true)) as! KintoneAPIException
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.INVALID_QUERY_GET_DATA_ERROR()!)
            }
            
            // When you wan to check different cases below please set up by manual
            //Error will display when user does not have View records permission for app
            //Error will display when user does not have View records permission for the record
            it("Test_021_022_023_Error_WithoutViewRecordPermission") {
                let recordModuleWithoutViewPermissionRecord = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutViewPermissionRecord.getRecords(
                    TestConstant.Common.APP_ID,
                    self.query,
                    [self.RECORD_TEXT_FIELD],
                    true)) as! KintoneAPIException
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
                //                When user does not have View permission for field, the data of this field is not displayed
                //                let result = awaitAsync(common.recordModuleWithoutPermission.getRecords(
                //                    Constant.APP_ID,
                //                    self.query,
                //                    [self.RECORD_TEXT_FIELD],
                //                    true)) as! GetRecordsResponse
                //                for(_, dval) in (result.getRecords()!.enumerated()) {
                //                    for (code, _) in dval{
                //                        XCTAssert(code != self.RECORD_TEXT_FIELD)
                //                    }
                //                }
            }
            
            it("Test_025_Success_RetrivedAtOneIs500") {
                //We have create 5 records at setUp so we just need more 455
                let countNumber = 495
                
                for _ in 1...5 {
                    var testDatas91 = [Dictionary<String, FieldValue>]()
                    for _ in 0...countNumber/5-1 {
                        self.recordTextValues.append(DataRandomization.generateString())
                        self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[self.recordTextValues.count-1])
                        testDatas91.append(self.testData)
                        self.testData = [:]
                    }
                    let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(TestConstant.Common.APP_ID, testDatas91)) as! AddRecordsResponse
                    self.recordIDs += addRecordsResponse.getIDs()!
                    self.testDataList += testDatas91
                }
                
                let query = RecordUtils.getRecordsQuery(self.recordIDs)
                let result = TestCommonHandling.awaitAsync(recordModule.getRecords(
                    TestConstant.Common.APP_ID,
                    query,
                    [self.RECORD_TEXT_FIELD],
                    true)) as! GetRecordsResponse
                expect(result.getTotalCount()).to(equal(500))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(self.recordTextValues[index]))
                    }
                }
            }
            
            it("Test_026_Error_QueryLargerThan500") {
                let query = "$id > 0 order by $id asc limit 999 offset 0"
                let result = TestCommonHandling.awaitAsync(recordModule.getRecords(
                    TestConstant.Common.APP_ID,
                    query,
                    [self.RECORD_TEXT_FIELD],
                    true)) as! KintoneAPIException
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.LIMIT_LARGER_THAN_500_ERROR()!)
            }
            
            it("Test_004_Success_ValidDataGuestSpace") {
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.ADMIN_USERNAME,
                    TestConstant.Connection.ADMIN_PASSWORD,
                    TestConstant.Connection.GUEST_SPACE_ID))
                let addRecordsResponseGuestSpace = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecords(TestConstant.Common.GUEST_SPACE_APP_ID, self.testDataList)) as! AddRecordsResponse
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
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecords(
                    TestConstant.Common.GUEST_SPACE_APP_ID,
                    queryGuestSpace,
                    [self.RECORD_TEXT_FIELD],
                    true)) as! GetRecordsResponse
                expect(result.getTotalCount()!).to(equal(self.NUMBER_OF_RECORDS))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(self.recordTextValues[index]))
                    }
                }
                
                RecordUtils.deleteAllRecords(recordModule: recordModuleGuestSpace, appID: TestConstant.Common.GUEST_SPACE_APP_ID)
            }
            
            it("Test_004_Success_APITokenValidData") {
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(TestConstant.Connection.APP_API_TOKEN))
                
                let result = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.getRecords(
                    TestConstant.Common.APP_ID,
                    self.query,
                    [self.RECORD_TEXT_FIELD],
                    true)) as! GetRecordsResponse
                expect(result.getTotalCount()!).to(equal(self.NUMBER_OF_RECORDS))
                for(index, dval) in (result.getRecords()!.enumerated()) {
                    for (_, value) in dval {
                        expect(value.getValue() as? String).to(equal(self.recordTextValues[index]))
                    }
                }
            }
        }
    }
}

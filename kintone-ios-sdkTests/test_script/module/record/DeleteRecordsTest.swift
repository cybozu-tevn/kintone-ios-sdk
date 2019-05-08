///**
/**
 kintone-ios-sdkTests
 Created on 5/7/19
 */

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class DeleteRecordsTest: QuickSpec{
    let APP_ID = 1
    
    var recordIDs = [Int]()
    var recordRevision: Int? = nil
    let RECORD_TEXT_FIELD: String = "txt_Name"
    let RECORD_NUMBER_FILED: String = "txt_Number"
    var recordTextValues = [String]()
    var testData: Dictionary<String, FieldValue>!
    var testDatas = [Dictionary<String, FieldValue>]()
    let RECORD_NONEXISTENT_ID = 1000
    let COUNT_NUMBER = 5
    
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("DeleteRecord"){
            it("Test_127_Success_Single"){
                self.recordTextValues.append(TestCommonHandling.randomString(length: 64))
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[0])
                self.testDatas.append(self.testData)
                self.testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, self.recordIDs))
                
                for item in self.recordIDs{
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(expectedError, actualError!)
                }
            }// End it
            
            it("Test_128_Success_Multiple"){
                for i in 0...self.COUNT_NUMBER-1 {
                    self.recordTextValues.append(TestCommonHandling.randomString(length: 64))
                    self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                    self.testDatas.append(self.testData)
                    self.testData = [:]
                }
            
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, self.recordIDs))
                
                for item in self.recordIDs{
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(expectedError, actualError!)
                }
            }
            
            it("Test_129_Error_NoneexistentRecordID"){
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, self.RECORD_NONEXISTENT_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.RECORD_NONEXISTENT_ID))
                
                TestCommonHandling.compareError(expectedError, actualError!)
            }
            
            it("Test_130_Error_WithoutPermission"){
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, self.RECORD_NONEXISTENT_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.RECORD_NONEXISTENT_ID))
                
                TestCommonHandling.compareError(expectedError, actualError!)
            }//End it
        }// End describle
    }// End spec function
}

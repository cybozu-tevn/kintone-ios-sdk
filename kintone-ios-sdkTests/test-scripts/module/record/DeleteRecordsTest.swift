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

class DeleteRecordsTest: QuickSpec {
    let APP_ID = 1
    let APP_NEGATIVE_ID = -1
    let APP_NONEXISTENT_ID = 100000
    let GUESTSPACE_APP_ID = 4

    var recordIDs = [Int]()
    var recordRevision: Int?
    let RECORD_TEXT_FIELD: String = "txt_Name"
    let RECORD_NUMBER_FILED: String = "txt_Number"
    var recordTextValues = [String]()
    var testData: Dictionary<String, FieldValue>!
    var testDatas = [Dictionary<String, FieldValue>]()
    let RECORD_NONEXISTENT_ID = 100000
    let COUNT_NUMBER = 5
    let CRED_USERNAME_WITHOUT_PEMISSION_DELETE_RECORD = "user4"
    let CRED_PASSWORD_WITHOUT_PEMISSION_DELETE_RECORD = "user4@123"
    let APP_API_TOKEN = "DAVEoGAcQLp3qQmAwbISn3jUEKKLAFL9xDTrccxF"

    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleWithoutDeletePermissionRecord = Record(TestCommonHandling.createConnection(
            self.CRED_USERNAME_WITHOUT_PEMISSION_DELETE_RECORD,
            self.CRED_PASSWORD_WITHOUT_PEMISSION_DELETE_RECORD))
        let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.ADMIN_USERNAME,
            TestConstant.Connection.ADMIN_PASSWORD,
            self.GUESTSPACE_APP_ID))
        let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(self.APP_API_TOKEN))

        describe("DeleteRecord") {
            it("Test_127_Success_Single") {
                self.recordTextValues.append(DataRandomization.generateRandomString(length: 64, refix: "Record"))
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[0])
                self.testDatas.append(self.testData)
                self.testData = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, self.recordIDs))
                
                for item in self.recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(expectedError, actualError!)
                }
            }// End it
            
            it("Test_128_Success_Multiple") {
                for i in 0...self.COUNT_NUMBER-1 {
                    self.recordTextValues.append(DataRandomization.generateRandomString(length: 64, refix: "Record"))
                    self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                    self.testDatas.append(self.testData)
                    self.testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, self.recordIDs))
                
                for item in self.recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(expectedError, actualError!)
                }
            }
            
            it("Test_128_Success_MultipleGuestSpace") {
                for i in 0...self.COUNT_NUMBER-1 {
                    self.recordTextValues.append(DataRandomization.generateRandomString(length: 64, refix: "Record"))
                    self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                    self.testDatas.append(self.testData)
                    self.testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecords(self.GUESTSPACE_APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(self.GUESTSPACE_APP_ID, self.recordIDs))
                
                for item in self.recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(self.GUESTSPACE_APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(expectedError, actualError!)
                }
            }
            
            it("Test_128_Success_MultipleAPIToken") {
                for i in 0...self.COUNT_NUMBER-1 {
                    self.recordTextValues.append(DataRandomization.generateRandomString(length: 64, refix: "Record"))
                    self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                    self.testDatas.append(self.testData)
                    self.testData = [:]
                }
                
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.deleteRecords(self.APP_ID, self.recordIDs))
                
                for item in self.recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.getRecord(self.APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(expectedError, actualError!)
                }
            }
            
            it("Test_129_Error_NoneExistentRecord") {
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, self.RECORD_NONEXISTENT_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.RECORD_NONEXISTENT_ID))
                
                TestCommonHandling.compareError(expectedError, actualError!)
            }
            
            it("Test_130_Error_WithouDeletetPermission") {
                self.recordTextValues.append(DataRandomization.generateRandomString(length: 64, refix: "Record"))
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[0])
                self.testDatas.append(self.testData)
                self.testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutDeletePermissionRecord.deleteRecords(self.APP_ID, self.recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(expectedError, actualError!)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, self.recordIDs))
            }
            
            it("Test_133_Error_NoneExistentApp") {
                self.recordTextValues.append(DataRandomization.generateRandomString(length: 64, refix: "Record"))
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[0])
                self.testDatas.append(self.testData)
                self.testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutDeletePermissionRecord.deleteRecords(self.APP_NONEXISTENT_ID, self.recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.APP_NONEXISTENT_ID))
                
                TestCommonHandling.compareError(expectedError, actualError!)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, self.recordIDs))
            }
            
            it("Test_133_Error_NegativeApp") {
                self.recordTextValues.append(DataRandomization.generateRandomString(length: 64, refix: "Record"))
                self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[0])
                self.testDatas.append(self.testData)
                self.testData = [:]
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_NEGATIVE_ID, self.recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.APP_NEGATIVE_ID))
                
                TestCommonHandling.compareError(expectedError, actualError!)
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, self.recordIDs))
            }
            
            it("Test_138_Success_100Records") {
                for i in 0...99 {
                    self.recordTextValues.append(DataRandomization.generateRandomString(length: 64, refix: "Record"))
                    self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                    self.testDatas.append(self.testData)
                    self.testData = [:]
                }
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                //Delete the record after created
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, self.recordIDs))
                
                for item in self.recordIDs {
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, item)) as! KintoneAPIException
                    let actualError = result.getErrorResponse()
                    var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                    expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(item))
                    
                    TestCommonHandling.compareError(expectedError, actualError!)
                }
            }
            
            it("Test_139_Error_101Records") {
                for i in 0...99 {
                    self.recordTextValues.append(DataRandomization.generateRandomString(length: 64, refix: "Record"))
                    self.testData = TestCommonHandling.addData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValues[i])
                    self.testDatas.append(self.testData)
                    self.testData = [:]
                }
                //Add 100 record into the testing application
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(self.APP_ID, self.testDatas)) as! AddRecordsResponse
                self.testDatas.removeAll()
                self.recordIDs = addRecordsResponse.getIDs()!
                
                // Add the record 101 into testing application
                self.recordTextValues.append(DataRandomization.generateRandomString(length: 64, refix: "Record"))
                self.testData = TestCommonHandling.addData(
                    [:],
                    self.RECORD_TEXT_FIELD,
                    FieldType.SINGLE_LINE_TEXT,
                    self.recordTextValues[self.recordTextValues.count-1])
                self.testData = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                self.recordIDs.append(addRecordResponse.getId()!)

                //Delete the record after created
                let result = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, self.recordIDs)) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.RECORD_ID_LARGER_THAN_100_ERROR()!
                TestCommonHandling.compareError(expectedError, actualError!)
                
                //Delete all record after test finished
                
                for i in 0...100 {
                    _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(self.APP_ID, [self.recordIDs[i]]))
                }
            }//End it
        }// End describle
    }// End spec function
}

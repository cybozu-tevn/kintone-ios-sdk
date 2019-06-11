///**
/**
 kintone-ios-sdkTests
 Created on 5/29/19
 */

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class BulkRequestTest: QuickSpec {
    private var conn: Connection!
    private var bulkRequestModule: BulkRequest!
    private var recordModule: Record!
    
    private let APP_ID = 219
    private let APP_NUMBER_FIELD_ID: Int = 108
    private let APP_ID_UPDATE_KEY: Int = 213
    private let RECORD_ID: String! = "$id"
    private let RECORD_REVISION: String! = "$revision"
    private let RECORD_ASSIGNEE: String! = "Assignee"
    private let RECORD_STATUS: String! = "Status"
    private let RECORD_TEXT_FIELD: String = "text"
    private let RECORD_NUMBER_FILED: String = "number"
    private let RECORD_TEXT_KEY: String! = "key"
    private var recordTextValue: String!
    private var testData: Dictionary<String, FieldValue>!
    private let NONEXISTENT_ID = 999999
    private var recordID: Int!
    
    override func spec() {
        beforeSuite {
            self.conn = TestCommonHandling.createConnection()
            self.recordModule = Record(self.conn)
        }
        
        describe("BulkRequest") {
            it("Test_002_Success_ValidRequest") {
                var recordIDs = [Int]()
                let statusAction = ["Start", "Complete"]
                let status = ["In progress", "Completed"]
                self.bulkRequestModule = BulkRequest(self.conn)

                // addRecord data
                let addRecordValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let addRecordData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, addRecordValue)
                
                // addRecords data
                let addRecordsValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let addRecordsDataFirst = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, addRecordsValue)
                let addRecordsDataSecond = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, addRecordsValue)
                let addRecordsDataList = [addRecordsDataFirst, addRecordsDataSecond]
                
                // updateRecordByID data
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addUpdateRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                let updateRecordId = addUpdateRecordResponse.getId()!
                let updateRecordByIdValue = DataRandomization.generateString(prefix: "Record", length: 10)
                let updateRecordByIdData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, updateRecordByIdValue)
                
                // updateRecordByUpdateKey data
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 5)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_KEY, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addRecordByUpdateKeyResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                let recordByUpdateKeyId = addRecordByUpdateKeyResponse.getId()!
                let updateKey: RecordUpdateKey = RecordUpdateKey(self.RECORD_TEXT_KEY, self.recordTextValue)
                let updateRecordByUpdateKeyValue = DataRandomization.generateString()
                let updateRecordByUpdateKeyData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, updateRecordByUpdateKeyValue)
                
                // updateRecords data
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_KEY, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addUpdateRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                let updateRecordsId = addUpdateRecordsResponse.getId()!
                let updateRecordsValue = DataRandomization.generateString()
                let updateRecordsData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, updateRecordsValue)
                let updateDataItem = RecordUpdateItem(updateRecordsId, nil, nil, updateRecordsData)
                let updateItemList = [updateDataItem]
                
                // updateRecordAssignees data
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_KEY, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addUpdateAssigneesRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                let updateAssigneesRecordId = addUpdateAssigneesRecordsResponse.getId()!
                let assignees = [TestConstant.Connection.ADMIN_USERNAME]
                
                // updateRecordStatus data
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_KEY, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addUpdateRecordStatusResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                let updateRecordStatusId = addUpdateRecordStatusResponse.getId()!
                
                // updateRecordsStatus data
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_KEY, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let updateRecordsFirstStatusResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                let updateRecordsFirstStatusId = updateRecordsFirstStatusResponse.getId()!
                
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_KEY, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let updateRecordsSecondStatusResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                let updateRecordsSecondStatusId = updateRecordsSecondStatusResponse.getId()!
                let item1 = RecordUpdateStatusItem(statusAction[0], nil, updateRecordsFirstStatusId, nil)
                let item2 = RecordUpdateStatusItem(statusAction[0], nil, updateRecordsSecondStatusId, nil)
                let itemList = [item1, item2]
                
                // deleteRecords data
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecords(self.APP_ID, [self.testData])) as! AddRecordsResponse
                let deleteRecordsIds = addRecordResponse.getIDs()!
                
                // deleteRecordsWithRevision data
                var idsWithRevision: [Int: Int]  = [:]
                self.recordTextValue = DataRandomization.generateString(prefix: "Record", length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue as Any)
                let addRecordsResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                let deleteRecordsId = addRecordsResponse.getId()!
                idsWithRevision[deleteRecordsId] = addRecordsResponse.getRevision()
                
                do {
                    // insert add record request into bulk request
                    _ = try self.bulkRequestModule.addRecord(self.APP_ID, addRecordData)
                    _ = try self.bulkRequestModule.addRecords(self.APP_ID, addRecordsDataList)
                    
                    // insert update record request into bulk request
                    _ = try self.bulkRequestModule.updateRecordByID(self.APP_ID, updateRecordId, updateRecordByIdData, nil)
                    _ = try self.bulkRequestModule.updateRecordByUpdateKey(self.APP_ID, updateKey, updateRecordByUpdateKeyData, nil)
                    _ = try self.bulkRequestModule.updateRecords(self.APP_ID, updateItemList)
                    _ = try self.bulkRequestModule.updateRecordAssignees(self.APP_ID, updateAssigneesRecordId, assignees, nil)
                    _ = try self.bulkRequestModule.updateRecordStatus(self.APP_ID, updateRecordStatusId, statusAction[0], nil, nil)
                    _ = try self.bulkRequestModule.updateRecordsStatus(self.APP_ID, itemList)
                    
                    // insert deleted record request to bulk request
                    _ = try self.bulkRequestModule.deleteRecords(self.APP_ID, deleteRecordsIds)
                    _ = try self.bulkRequestModule.deleteRecordsWithRevision(self.APP_ID, idsWithRevision)
                } catch let err {
                    expect(err).to(beNil())
                }
                
                self.bulkRequestModule.execute().then {responses -> Promise<GetRecordsResponse> in
                    for item in responses.getResults()! {
                        if let addRecordResponse = item as? AddRecordResponse {
                            recordIDs.append(addRecordResponse.getId()!)
                        } else if let addRecordsResponse = item as? AddRecordsResponse {
                            recordIDs.append(contentsOf: addRecordsResponse.getIDs()!)
                        }
                    }
                    recordIDs.append(updateRecordId)
                    recordIDs.append(recordByUpdateKeyId)
                    recordIDs.append(updateRecordsId)
                    recordIDs.append(updateAssigneesRecordId)
                    recordIDs.append(updateRecordStatusId)
                    recordIDs.append(updateRecordsFirstStatusId)
                    recordIDs.append(updateRecordsSecondStatusId)
                    recordIDs.append(contentsOf: deleteRecordsIds)
                    recordIDs.append(deleteRecordsId)
                    
                    let query = RecordUtils.getRecordsQuery(recordIDs)
                    let fields = [self.RECORD_ID, self.RECORD_REVISION, self.RECORD_ASSIGNEE, self.RECORD_STATUS, self.RECORD_TEXT_FIELD]
                    return self.recordModule.getRecords(self.APP_ID, query, fields as? [String], true)
                    }.then { response in
                        var resultIDs: [Int] = []
                        var resultTexts: [String] = []
                        var countRecord: Int! = 0
                        
                        for record in response.getRecords()! {
                            for (key, value) in record {
                                if(key == self.RECORD_ID) {
                                    resultIDs.append(Int(value.getValue() as! String)!)
                                    
                                    // update record by id
                                    if(Int(value.getValue() as! String)! == updateRecordId) {
                                        expect(updateRecordByIdValue).to(equal(record[self.RECORD_TEXT_FIELD]?.getValue() as? String))
                                        expect(2).to(equal(Int((record[self.RECORD_REVISION]?.getValue() as? String)!)))
                                    }
                                    // update record by key
                                    if(Int(value.getValue() as! String)! == recordByUpdateKeyId) {
                                        expect(updateRecordByUpdateKeyValue).to(equal(record[self.RECORD_TEXT_FIELD]?.getValue() as? String))
                                        expect(2).to(equal(Int((record[self.RECORD_REVISION]?.getValue() as? String)!)))
                                    }
                                    // update records
                                    if(Int(value.getValue() as! String)! ==  updateRecordsId) {
                                        expect(updateRecordsValue).to(equal(record[self.RECORD_TEXT_FIELD]?.getValue() as? String))
                                        expect(2).to(equal(Int((record[self.RECORD_REVISION]?.getValue() as? String)!)))
                                    }
                                    //update assignees
                                    if(Int(value.getValue() as! String)! == updateAssigneesRecordId) {
                                        let assigneeResult = record[self.RECORD_ASSIGNEE]?.getValue() as! [Member]
                                        expect(assignees[0]).to(equal(assigneeResult[0].getName()!))
                                    }
                                    
                                    if(Int(value.getValue() as! String)! == updateRecordStatusId) {
                                        expect(status[0]).to(equal(record[self.RECORD_STATUS]?.getValue()! as? String))
                                    }
                                    if(Int(value.getValue() as! String)! == updateRecordsFirstStatusId || Int(value.getValue() as! String)! == updateRecordsSecondStatusId) {
                                        expect(status[0]).to(equal(record[self.RECORD_STATUS]?.getValue()! as? String))
                                    }
                                }
                                if(key == self.RECORD_TEXT_FIELD) {
                                    if((value.getValue()! as! String) == addRecordsValue) {
                                        countRecord += 1
                                    }
                                    resultTexts.append(value.getValue() as! String)
                                }
                            }
                        }
                        // for delete records
                        expect(resultIDs).toNot(contain(deleteRecordsIds))
                        expect(resultIDs).toNot(contain(deleteRecordsId))
                        // for add record
                        expect(resultTexts).to(contain(addRecordValue, addRecordsValue))
                        expect(countRecord).to(equal(2))
                }
                _ = waitForPromises(timeout: Double(TestConstant.Common.PROMISE_TIMEOUT))
                for id in recordIDs {
                    if(id != deleteRecordsIds[0] || id != deleteRecordsId) {
                        TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, [id]))
                    }
                }
            }
            
            it("Test_004_Error_InputTextToNumberWithAddRecord") {
                self.bulkRequestModule = BulkRequest(self.conn)
                
                self.recordTextValue = DataRandomization.generateString()
                self.testData = RecordUtils.setRecordData([:], self.RECORD_NUMBER_FILED, FieldType.NUMBER, self.recordTextValue)
                _ = TestCommonHandling.handleDoTryCatch {try self.bulkRequestModule.addRecord(self.APP_NUMBER_FIELD_ID, self.testData)}
                let result = TestCommonHandling.awaitAsync(self.bulkRequestModule.execute()) as! KintoneAPIException
                let actualError = result.getErrorResponses()![0]
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[\(self.RECORD_NUMBER_FILED)]")
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_005_Error_InputTextToNumberWithAddRecords") {
                self.bulkRequestModule = BulkRequest(self.conn)
                
                self.recordTextValue = DataRandomization.generateString()
                self.testData = RecordUtils.setRecordData([:], self.RECORD_NUMBER_FILED, FieldType.NUMBER, self.recordTextValue)
                _ = TestCommonHandling.handleDoTryCatch {try self.bulkRequestModule.addRecords(self.APP_NUMBER_FIELD_ID, [self.testData])}
                let result = TestCommonHandling.awaitAsync(self.bulkRequestModule.execute()) as! KintoneAPIException
                let actualError = result.getErrorResponses()![0]
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(0)][\(self.RECORD_NUMBER_FILED)]")
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_006_Error_NonexistentIDWithUpdateRecordByID") {
                self.bulkRequestModule = BulkRequest(self.conn)
                
                self.recordTextValue = DataRandomization.generateString()
                self.testData = RecordUtils.setRecordData([:], self.RECORD_NUMBER_FILED, FieldType.NUMBER, self.recordTextValue)
                _ = TestCommonHandling.handleDoTryCatch {try self.bulkRequestModule.updateRecordByID(self.APP_ID, self.NONEXISTENT_ID, nil, nil)}
                let result = TestCommonHandling.awaitAsync(self.bulkRequestModule.execute()) as! KintoneAPIException
                let actualError = result.getErrorResponses()![0]
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            /// Prepare app with 2 fields following as:
            /// fiels 1 -> code: key , unique: Prohibit duplicate values, type: SINGLE_LINE_TEXT
            /// fiels 2 -> code: text , unique: none, type: SINGLE_LINE_TEXT
            it("Test_007_Error_WrongUpdateKeyWithUpdateRecordByUpdateKey") {
                self.bulkRequestModule = BulkRequest(self.conn)
                let wrongUpdateKey = RecordUpdateKey(self.RECORD_TEXT_KEY, "Wrong Update Key Value")
                
                //Add record data to test
                self.recordTextValue = DataRandomization.generateString(length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID_UPDATE_KEY, self.testData)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                
                //Prepare data to update
                self.recordTextValue = DataRandomization.generateString(length: 10)
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                _ = TestCommonHandling.handleDoTryCatch {try self.bulkRequestModule.updateRecordByUpdateKey(self.APP_ID_UPDATE_KEY,
                                                                                                            wrongUpdateKey,
                                                                                                            self.testData,
                                                                                                            nil)}
                let result = TestCommonHandling.awaitAsync(self.bulkRequestModule.execute()) as! KintoneAPIException
                let actualError = result.getErrorResponses()![0]
                let expectedError = KintoneErrorParser.INCORRECT_UPDATEKEY_VALUE_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
                
                //remove test data on the app
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID_UPDATE_KEY, [self.recordID]))
            }
            
            it("Test_010_Error_InvalidIDsWithDeleteRecords") {
                self.bulkRequestModule = BulkRequest(self.conn)
                
                _ = TestCommonHandling.handleDoTryCatch {try self.bulkRequestModule.deleteRecords(self.APP_ID, [self.NONEXISTENT_ID])}
                let result = TestCommonHandling.awaitAsync(self.bulkRequestModule.execute()) as! KintoneAPIException
                let actualError = result.getErrorResponses()![0]
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

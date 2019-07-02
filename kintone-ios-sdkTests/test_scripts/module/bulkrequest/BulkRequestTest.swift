//
// kintone-ios-sdkTests
// Created on 5/29/19
//

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class BulkRequestTest: QuickSpec {
    override func spec() {
        let APP_ID = TestConstant.InitData.APP_ID!
        let RECORD_ID: String! = "$id"
        let RECORD_REVISION: String! = "$revision"
        let RECORD_ASSIGNEE: String! = "Assignee"
        let RECORD_STATUS: String! = "Status"
        let TEXT_FIELD: String = TestConstant.InitData.TEXT_FIELD
        let NUMBER_FIELD: String = TestConstant.InitData.NUMBER_FIELD
        let TEXT_UPDATE_KEY_FIELD: String! = TestConstant.InitData.TEXT_UPDATE_KEY_FIELD
        let NONEXISTENT_ID = TestConstant.Common.NONEXISTENT_ID
        
        let conn = TestCommonHandling.createConnection()
        let recordModule = Record(conn)
        var bulkRequestModule: BulkRequest!
        
        describe("BulkRequest") {
            beforeEach {
                bulkRequestModule = BulkRequest(conn)
            }
            
            it("Test_002_Success_ValidRequest") {
                var recordIDs = [Int]()
                let statusAction = ["Start", "Complete"]
                let status = ["In progress", "Completed"]
                
                // addRecord data
                let addRecordValue = DataRandomization.generateString(prefix: "Record-addRecord", length: 10)
                let addRecordData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, addRecordValue)
                
                // addRecords data
                let addRecordsValue = DataRandomization.generateString(prefix: "Record-addRecords", length: 10)
                let addRecordsDataFirst = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, addRecordsValue)
                let addRecordsDataSecond = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, addRecordsValue)
                let addRecordsDataList = [addRecordsDataFirst, addRecordsDataSecond]
                
                // updateRecordByID data
                var textValue = DataRandomization.generateString(prefix: "Record", length: 10)
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue as Any)
                let addUpdateRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let updateRecordId = addUpdateRecordResponse.getId()!
                let updateRecordByIdValue = DataRandomization.generateString(prefix: "Record-updateRecordByID", length: 10)
                let updateRecordByIdData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, updateRecordByIdValue)
                
                // updateRecordByUpdateKey data
                textValue = DataRandomization.generateString(prefix: "Record-updateRecordByUpdateKey", length: 5)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textValue as Any)
                let addRecordByUpdateKeyResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let recordByUpdateKeyId = addRecordByUpdateKeyResponse.getId()!
                let updateKey: RecordUpdateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, textValue)
                let updateRecordByUpdateKeyValue = DataRandomization.generateString()
                let updateRecordByUpdateKeyData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, updateRecordByUpdateKeyValue)
                
                // updateRecords data
                textValue = DataRandomization.generateString(prefix: "Record-updateRecords", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textValue as Any)
                let addUpdateRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let updateRecordsId = addUpdateRecordsResponse.getId()!
                let updateRecordsValue = DataRandomization.generateString()
                let updateRecordsData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, updateRecordsValue)
                let updateDataItem = RecordUpdateItem(updateRecordsId, nil, nil, updateRecordsData)
                let updateItemList = [updateDataItem]
                
                // updateRecordAssignees data
                textValue = DataRandomization.generateString(prefix: "Record-updateRecordAssignees", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textValue as Any)
                let addUpdateAssigneesRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let updateAssigneesRecordId = addUpdateAssigneesRecordsResponse.getId()!
                let assignees = [TestConstant.Connection.CRED_ADMIN_USERNAME]
                
                // updateRecordStatus data
                textValue = DataRandomization.generateString(prefix: "Record-updateRecordStatus", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textValue as Any)
                let addUpdateRecordStatusResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let updateRecordStatusId = addUpdateRecordStatusResponse.getId()!
                
                // updateRecordsStatus data
                textValue = DataRandomization.generateString(prefix: "Record-updateRecordsStatus", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textValue as Any)
                let updateRecordsFirstStatusResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let updateRecordsFirstStatusId = updateRecordsFirstStatusResponse.getId()!
                
                textValue = DataRandomization.generateString(prefix: "Record", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_UPDATE_KEY_FIELD, FieldType.SINGLE_LINE_TEXT, textValue as Any)
                let updateRecordsSecondStatusResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let updateRecordsSecondStatusId = updateRecordsSecondStatusResponse.getId()!
                let item1 = RecordUpdateStatusItem(statusAction[0], nil, updateRecordsFirstStatusId, nil)
                let item2 = RecordUpdateStatusItem(statusAction[0], nil, updateRecordsSecondStatusId, nil)
                let itemList = [item1, item2]
                
                // deleteRecords data
                textValue = DataRandomization.generateString(prefix: "Record-deleteRecords", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue as Any)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(APP_ID, [testData])) as! AddRecordsResponse
                let deleteRecordsIds = addRecordResponse.getIDs()!
                
                // deleteRecordsWithRevision data
                var idsWithRevision: [Int: Int]  = [:]
                textValue = DataRandomization.generateString(prefix: "Record-deleteRecordsWithRevision", length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue as Any)
                let addRecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let deleteRecordsId = addRecordsResponse.getId()!
                idsWithRevision[deleteRecordsId] = addRecordsResponse.getRevision()
                
                do {
                    // insert add record request into bulk request
                    _ = try bulkRequestModule.addRecord(APP_ID, addRecordData)
                    _ = try bulkRequestModule.addRecords(APP_ID, addRecordsDataList)
                    
                    // insert update record request into bulk request
                    _ = try bulkRequestModule.updateRecordByID(APP_ID, updateRecordId, updateRecordByIdData, nil)
                    _ = try bulkRequestModule.updateRecordByUpdateKey(APP_ID, updateKey, updateRecordByUpdateKeyData, nil)
                    _ = try bulkRequestModule.updateRecords(APP_ID, updateItemList)
                    _ = try bulkRequestModule.updateRecordAssignees(APP_ID, updateAssigneesRecordId, assignees, nil)
                    _ = try bulkRequestModule.updateRecordStatus(APP_ID, updateRecordStatusId, statusAction[0], nil, nil)
                    _ = try bulkRequestModule.updateRecordsStatus(APP_ID, itemList)
                    
                    // insert deleted record request to bulk request
                    _ = try bulkRequestModule.deleteRecords(APP_ID, deleteRecordsIds)
                    _ = try bulkRequestModule.deleteRecordsWithRevision(APP_ID, idsWithRevision)
                } catch let err {
                    expect(err).to(beNil())
                }
                
                bulkRequestModule.execute().then {responses -> Promise<GetRecordsResponse> in
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
                    let fields = [RECORD_ID, RECORD_REVISION, RECORD_ASSIGNEE, RECORD_STATUS, TEXT_FIELD]
                    return recordModule.getRecords(APP_ID, query, fields as? [String], true)
                    }.then { response in
                        var resultIDs: [Int] = []
                        var resultTexts: [String] = []
                        var countRecord: Int! = 0
                        
                        for record in response.getRecords()! {
                            for (key, value) in record {
                                if(key == RECORD_ID) {
                                    resultIDs.append(Int(value.getValue() as! String)!)
                                    // update record by id
                                    if(Int(value.getValue() as! String)! == updateRecordId) {
                                        print("UPDATE RECORD BY ID TEST")
                                        expect(updateRecordByIdValue).to(equal(record[TEXT_FIELD]?.getValue() as? String))
                                        expect(2).to(equal(Int((record[RECORD_REVISION]?.getValue() as? String)!)))
                                    }
                                    // update record by key
                                    if(Int(value.getValue() as! String)! == recordByUpdateKeyId) {
                                        print("UPDATE RECORD BY KEY TEST")
                                        expect(updateRecordByUpdateKeyValue).to(equal(record[TEXT_FIELD]?.getValue() as? String))
                                        expect(2).to(equal(Int((record[RECORD_REVISION]?.getValue() as? String)!)))
                                    }
                                    // update records
                                    if(Int(value.getValue() as! String)! ==  updateRecordsId) {
                                        print("UPDATE RECORDS TEST")
                                        expect(updateRecordsValue).to(equal(record[TEXT_FIELD]?.getValue() as? String))
                                        expect(2).to(equal(Int((record[RECORD_REVISION]?.getValue() as? String)!)))
                                    }
                                    // update assignees
                                    if(Int(value.getValue() as! String)! == updateAssigneesRecordId) {
                                        print("UPDATE ASSIGNEE TEST")
                                        let assigneeResult = record[RECORD_ASSIGNEE]?.getValue() as! [Member]
                                        expect(assignees[0]).to(equal(assigneeResult[0].getName()!))
                                    }
                                    // update record status
                                    if(Int(value.getValue() as! String)! == updateRecordStatusId) {
                                        print("UPDATE RECORD STATUS TEST")
                                        expect(status[0]).to(equal(record[RECORD_STATUS]?.getValue()! as? String))
                                    }
                                    // update records status
                                    if(Int(value.getValue() as! String)! == updateRecordsFirstStatusId || Int(value.getValue() as! String)! == updateRecordsSecondStatusId) {
                                        print("UPDATE RECORDS STATUS TEST")
                                        expect(status[0]).to(equal(record[RECORD_STATUS]?.getValue()! as? String))
                                    }
                                }
                                if(key == TEXT_FIELD) {
                                    if((value.getValue()! as! String) == addRecordsValue) {
                                        countRecord += 1
                                    }
                                    resultTexts.append(value.getValue() as! String)
                                }
                            }
                        }
                        // for delete records
                        print("DELETE RECORD TEST")
                        expect(resultIDs).toNot(contain(deleteRecordsIds))
                        expect(resultIDs).toNot(contain(deleteRecordsId))
                        // for add record
                        print("ADD RECORD/RECORDS TEST")
                        expect(resultTexts).to(contain(addRecordValue, addRecordsValue))
                        expect(countRecord).to(equal(2))
                }
                _ = waitForPromises(timeout: Double(TestConstant.Common.PROMISE_TIMEOUT))
                
                for id in recordIDs {
                    if(id != deleteRecordsIds[0] || id != deleteRecordsId) {
                        _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, [id]))
                    }
                }
            }
            
            it("Test_004_Error_InputTextToNumberWithAddRecord") {
                let textValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], NUMBER_FIELD, FieldType.NUMBER, textValue)
                _ = TestCommonHandling.handleDoTryCatch {try bulkRequestModule.addRecord(APP_ID, testData)}
                let result = TestCommonHandling.awaitAsync(bulkRequestModule.execute()) as! KintoneAPIException
                let actualError = result.getErrorResponses()![0]
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[\(NUMBER_FIELD)]")
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_005_Error_InputTextToNumberWithAddRecords") {
                let textValue = DataRandomization.generateString()
                let testData = RecordUtils.setRecordData([:], NUMBER_FIELD, FieldType.NUMBER, textValue)
                _ = TestCommonHandling.handleDoTryCatch {try bulkRequestModule.addRecords(APP_ID, [testData])}
                let result = TestCommonHandling.awaitAsync(bulkRequestModule.execute()) as! KintoneAPIException
                let actualError = result.getErrorResponses()![0]
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "s[\(0)][\(NUMBER_FIELD)]")
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_006_Error_NonexistentRecordIDWithUpdateRecordByID") {
                _ = TestCommonHandling.handleDoTryCatch {try bulkRequestModule.updateRecordByID(APP_ID, NONEXISTENT_ID, nil, nil)}
                let result = TestCommonHandling.awaitAsync(bulkRequestModule.execute()) as! KintoneAPIException
                let actualError = result.getErrorResponses()![0]
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            /// Prepare app with 2 fields as following:
            /// field 1 -> unique: Prohibit duplicate values, type: SINGLE_LINE_TEXT
            /// field 2 -> unique: none, type: SINGLE_LINE_TEXT
            it("Test_007_Error_WrongUpdateKeyWithUpdateRecordByUpdateKey") {
                let wrongUpdateKey = RecordUpdateKey(TEXT_UPDATE_KEY_FIELD, "Wrong Update Key Value")
                
                // Add record data to test
                var textValue = DataRandomization.generateString(length: 10)
                var testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, testData)) as! AddRecordResponse
                let recordID = addRecordResponse.getId()!
                
                // Prepare data to update
                textValue = DataRandomization.generateString(length: 10)
                testData = RecordUtils.setRecordData([:], TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, textValue)
                _ = TestCommonHandling.handleDoTryCatch {
                    try bulkRequestModule.updateRecordByUpdateKey(APP_ID, wrongUpdateKey, testData, nil)}
                let result = TestCommonHandling.awaitAsync(bulkRequestModule.execute()) as! KintoneAPIException
                let actualError = result.getErrorResponses()![0]
                let expectedError = KintoneErrorParser.INCORRECT_UPDATEKEY_VALUE_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
                
                //remove test data on the app
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, [recordID]))
            }
            
            it("Test_010_Error_InvalidIDsWithDeleteRecords") {
                _ = TestCommonHandling.handleDoTryCatch {try bulkRequestModule.deleteRecords(APP_ID, [NONEXISTENT_ID])}
                let result = TestCommonHandling.awaitAsync(bulkRequestModule.execute()) as! KintoneAPIException
                let actualError = result.getErrorResponses()![0]
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}

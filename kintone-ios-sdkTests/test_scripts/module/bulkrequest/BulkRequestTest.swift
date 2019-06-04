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
    private var connAPI: Connection!
    private var connGuestSpace: Connection!
    private var bulkRequestModule: BulkRequest!
    private var bulkRequestAPI: BulkRequest!
    private var bulkRequestModuleGuestSpace: BulkRequest!
    private var recordModule: Record!
    private var recordModuleAPI: Record!
    private var recordModuleGuestSpace: Record!
    
    private let APP_ID = 34
    private let API_TOKEN: String = "tXbzzErsSkqLrQYN1E6H0f0S1Iy8HlGiD6iZyO0z"
    private let GUEST_SPACE_ID: Int = 5
    private let APP_ID_GUESTSPACE: Int = 45
    private let APP_NUMBER_FIELD_ID: Int = 108
    private let APP_ID_UPDATE_KEY: Int = 213
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
            self.connAPI = TestCommonHandling.createConnection(self.API_TOKEN)
            self.connGuestSpace = TestCommonHandling.createConnection(TestConstant.Connection.ADMIN_USERNAME,
                                                                      TestConstant.Connection.ADMIN_PASSWORD,
                                                                      self.GUEST_SPACE_ID)
            self.bulkRequestAPI = BulkRequest(self.connAPI)
            self.bulkRequestModuleGuestSpace = BulkRequest(self.connGuestSpace)
            self.recordModule = Record(self.conn)
            self.recordModuleAPI = Record(self.connAPI)
            self.recordModuleGuestSpace = Record(self.connGuestSpace)
        }
        
        describe("BulkRequest") {
            it("Test_002_Success_ValidRequest") {
                self.bulkRequestModule = BulkRequest(self.conn)
                
                var recordIDs = [Int]()
                self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                do {
                    _ = try self.bulkRequestModule.addRecord(self.APP_ID, self.testData)
                    _ = try self.bulkRequestModule.addRecords(self.APP_ID, [self.testData])
                } catch let err {
                    expect(err).to(beNil())
                }
                
                self.bulkRequestModule.execute()
                    .then {responses -> Promise<GetRecordsResponse> in
                        expect(responses.getResults()?.count).to(equal(2))
                        for item in responses.getResults()! {
                            if let addRecordResponse = item as? AddRecordResponse {
                                recordIDs.append(addRecordResponse.getId()!)
                            } else if let addRecordsResponse = item as? AddRecordsResponse {
                                recordIDs.append(contentsOf: addRecordsResponse.getIDs()!)
                                for (_, value) in (addRecordsResponse.getRevisions()!.enumerated()) {
                                    expect(value).to(equal(1))
                                }
                            }
                        }
                        let query = RecordUtils.getRecordsQuery(recordIDs)
                        
                        return self.recordModule.getRecords(self.APP_ID, query, [self.RECORD_TEXT_FIELD], true)
                    }.then {response in
                        expect(response.getTotalCount()).to(equal(2))
                        for record in response.getRecords()! {
                            for (_, value) in record {
                                expect(value.getValue() as? String).to(equal(self.recordTextValue))
                            }
                        }
                    }.then {_ -> Promise<BulkRequestResponse> in
                        let bulkRequestModule = BulkRequest(self.conn)
                        self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
                        self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                        for id in recordIDs {
                            _ = try bulkRequestModule.updateRecordByID(self.APP_ID, id, self.testData, nil)
                        }
                        
                        return bulkRequestModule.execute()
                    }.then {response -> Promise<GetRecordsResponse> in
                        expect(response.getResults()?.count).to(equal(2))
                        let query = RecordUtils.getRecordsQuery(recordIDs)
                        
                        return self.recordModule.getRecords(self.APP_ID, query, [self.RECORD_TEXT_FIELD], true)
                    }.then {response in
                        expect(response.getTotalCount()!).to(equal(2))
                        for record in response.getRecords()! {
                            for (_, value) in record {
                                expect(value.getValue() as? String).to(equal(self.recordTextValue))
                            }
                        }
                    }.then {_ -> Promise<BulkRequestResponse> in
                        let bulkRequestModule = BulkRequest(self.conn)
                        self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
                        self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                        for id in recordIDs {
                            _ = try bulkRequestModule.updateRecordByID(self.APP_ID, id, self.testData, nil)
                        }
                        _ = try bulkRequestModule.deleteRecords(self.APP_ID, recordIDs)
                        
                        return bulkRequestModule.execute()
                    }.then {response -> Promise<GetRecordsResponse> in
                        expect(response.getResults()?.count).to(equal(3))
                        let query = RecordUtils.getRecordsQuery(recordIDs)
                        
                        return self.recordModule.getRecords(self.APP_ID, query, [self.RECORD_TEXT_FIELD], true)
                    }.then {response in
                        expect(response.getRecords()?.count).to(equal(0))
                    }.catch {err in
                        expect(err).to(beNil())
                }
                _ = waitForPromises(timeout: Double(TestConstant.Common.PROMISE_TIMEOUT))
            }
            
            it("Test_002_Success_ValidRequestApi") {
                self.bulkRequestModule = BulkRequest(self.conn)
                
                var recordIDs = [Int]()
                self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                do {
                    _ = try self.bulkRequestAPI.addRecord(self.APP_ID, self.testData)
                    _ = try self.bulkRequestAPI.addRecords(self.APP_ID, [self.testData])
                } catch let err {
                    expect(err).to(beNil())
                }
                
                self.bulkRequestAPI.execute()
                    .then {responses -> Promise<GetRecordsResponse> in
                        //confirm the number record is 2
                        expect(responses.getResults()?.count).to(equal(2))
                        for item in responses.getResults()! {
                            if let addRecordResponse = item as? AddRecordResponse {
                                recordIDs.append(addRecordResponse.getId()!)
                            } else if let addRecordsResponse = item as? AddRecordsResponse {
                                recordIDs.append(contentsOf: addRecordsResponse.getIDs()!)
                                for (_, value) in (addRecordsResponse.getRevisions()!.enumerated()) {
                                    // confirm revision is 1
                                    expect(value).to(equal(1))
                                }
                            }
                        }
                        let query = RecordUtils.getRecordsQuery(recordIDs)
                        
                        return self.recordModule.getRecords(self.APP_ID, query, [self.RECORD_TEXT_FIELD], true)
                    }.then {response in
                        expect(response.getTotalCount()).to(equal(2))
                        for record in response.getRecords()! {
                            for (_, value) in record {
                                expect(value.getValue() as? String).to(equal(self.recordTextValue))
                            }
                        }
                    }.then {_ -> Promise<BulkRequestResponse> in
                        let bulkRequestModule = BulkRequest(self.connAPI)
                        self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
                        self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                        for id in recordIDs {
                            _ = try bulkRequestModule.updateRecordByID(self.APP_ID, id, self.testData, nil)
                        }
                        
                        return bulkRequestModule.execute()
                    }.then {response -> Promise<GetRecordsResponse> in
                        expect(response.getResults()?.count).to(equal(2))
                        let query = RecordUtils.getRecordsQuery(recordIDs)
                        
                        return self.recordModule.getRecords(self.APP_ID, query, [self.RECORD_TEXT_FIELD], true)
                    }.then {response in
                        expect(response.getTotalCount()!).to(equal(2))
                        for record in response.getRecords()! {
                            for (_, value) in record {
                                expect(value.getValue() as? String).to(equal(self.recordTextValue))
                            }
                        }
                    }.then {_ -> Promise<BulkRequestResponse> in
                        let bulkRequestModule = BulkRequest(self.connAPI)
                        self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
                        self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                        for id in recordIDs {
                            _ = try bulkRequestModule.updateRecordByID(self.APP_ID, id, self.testData, nil)
                        }
                        _ = try bulkRequestModule.deleteRecords(self.APP_ID, recordIDs)
                        
                        return bulkRequestModule.execute()
                    }.then {response -> Promise<GetRecordsResponse> in
                        expect(response.getResults()?.count).to(equal(3))
                        let query = RecordUtils.getRecordsQuery(recordIDs)
                        
                        return self.recordModule.getRecords(self.APP_ID, query, [self.RECORD_TEXT_FIELD], true)
                    }.then {response in
                        expect(response.getRecords()?.count).to(equal(0))
                    }.catch {err in
                        expect(err).to(beNil())
                }
                _ = waitForPromises(timeout: Double(TestConstant.Common.PROMISE_TIMEOUT))
            }
            
            it("Test_002_Success_ValidRequestGuestSpace") {
                self.bulkRequestModule = BulkRequest(self.conn)
                
                var recordIDs = [Int]()
                self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                do {
                    _ = try self.bulkRequestModuleGuestSpace.addRecord(self.APP_ID_GUESTSPACE, self.testData)
                    _ = try self.bulkRequestModuleGuestSpace.addRecords(self.APP_ID_GUESTSPACE, [self.testData])
                } catch let err {
                    expect(err).to(beNil())
                }
                
                self.bulkRequestModuleGuestSpace.execute()
                    .then {responses -> Promise<GetRecordsResponse> in
                        //confirm the number record is 2
                        expect(responses.getResults()?.count).to(equal(2))
                        for item in responses.getResults()! {
                            if let addRecordResponse = item as? AddRecordResponse {
                                recordIDs.append(addRecordResponse.getId()!)
                            } else if let addRecordsResponse = item as? AddRecordsResponse {
                                recordIDs.append(contentsOf: addRecordsResponse.getIDs()!)
                                for (_, value) in (addRecordsResponse.getRevisions()!.enumerated()) {
                                    // confirm revision is 1
                                    expect(value).to(equal(1))
                                }
                            }
                        }
                        let query = RecordUtils.getRecordsQuery(recordIDs)
                        
                        return self.recordModuleGuestSpace.getRecords(self.APP_ID_GUESTSPACE, query, [self.RECORD_TEXT_FIELD], true)
                    }.then {response in
                        expect(response.getTotalCount()).to(equal(2))
                        for record in response.getRecords()! {
                            for (_, value) in record {
                                expect(value.getValue() as? String).to(equal(self.recordTextValue))
                            }
                        }
                    }.then {_ -> Promise<BulkRequestResponse> in
                        let bulkRequestModule = BulkRequest(self.connGuestSpace)
                        self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
                        self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                        for id in recordIDs {
                            _ = try bulkRequestModule.updateRecordByID(self.APP_ID_GUESTSPACE, id, self.testData, nil)
                        }
                        
                        return bulkRequestModule.execute()
                    }.then {response -> Promise<GetRecordsResponse> in
                        expect(response.getResults()?.count).to(equal(2))
                        let query = RecordUtils.getRecordsQuery(recordIDs)
                        
                        return self.recordModuleGuestSpace.getRecords(self.APP_ID_GUESTSPACE, query, [self.RECORD_TEXT_FIELD], true)
                    }.then {response in
                        expect(response.getTotalCount()!).to(equal(2))
                        for record in response.getRecords()! {
                            for (_, value) in record {
                                expect(value.getValue() as? String).to(equal(self.recordTextValue))
                            }
                        }
                    }.then {_ -> Promise<BulkRequestResponse> in
                        let bulkRequestModule = BulkRequest(self.connGuestSpace)
                        self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
                        self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                        for id in recordIDs {
                            _ = try bulkRequestModule.updateRecordByID(self.APP_ID_GUESTSPACE, id, self.testData, nil)
                        }
                        _ = try bulkRequestModule.deleteRecords(self.APP_ID_GUESTSPACE, recordIDs)
                        
                        return bulkRequestModule.execute()
                    }.then {response -> Promise<GetRecordsResponse> in
                        expect(response.getResults()?.count).to(equal(3))
                        let query = RecordUtils.getRecordsQuery(recordIDs)
                        
                        return self.recordModuleGuestSpace.getRecords(self.APP_ID_GUESTSPACE, query, [self.RECORD_TEXT_FIELD], true)
                    }.then {response in
                        expect(response.getRecords()?.count).to(equal(0))
                    }.catch {err in
                        expect(err).to(beNil())
                }
                _ = waitForPromises(timeout: Double(TestConstant.Common.PROMISE_TIMEOUT))
            }
            
            it("Test_004_Error_InputTextToNumberWithAddRecord") {
                self.bulkRequestModule = BulkRequest(self.conn)
                
                self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
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
                
                self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
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
                
                self.recordTextValue = DataRandomization.generateRandomString(length: 64, refix: "")
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
                self.recordTextValue = DataRandomization.generateRandomString(length: 10, refix: "")
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID_UPDATE_KEY, self.testData)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                
                //Prepare data to update
                self.recordTextValue = DataRandomization.generateRandomString(length: 10, refix: "")
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

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
    // --> declare connect
    private var conn: Connection!
    private var connAPI: Connection!
    private var connGuestSpace: Connection!
    
    // --> declare bulk module
    private var bulkRequestModule: BulkRequest!
    private var bulkRequestAPI: BulkRequest!
    private var bulkRequestModuleGuestSpace: BulkRequest!
    
    //--> declare record module
    private var recordModule: Record!
    private var recordModuleAPI: Record!
    private var recordModuleGuestSpace: Record!
    
    //--> app test
    private let APP_ID = 34
    private let API_TOKEN: String = "tXbzzErsSkqLrQYN1E6H0f0S1Iy8HlGiD6iZyO0z"
    private let GUEST_SPACE_ID: Int = 5
    private let APP_ID_GUESTSPACE: Int = 45
    
    //--> key of field
    private let RECORD_TEXT_FIELD: String = "text"
    private let RECORD_NUMBER_FILED: String = "number"
    
    //--> store data
    private var recordTextValue: String!
    private var testData: Dictionary<String, FieldValue>!
    
    override func spec() {
        beforeSuite {
            self.conn = TestCommonHandling.createConnection()
            self.connAPI = TestCommonHandling.createConnection(self.API_TOKEN)
            self.connGuestSpace = TestCommonHandling.createConnection(TestConstant.Connection.ADMIN_USERNAME,
                                                                      TestConstant.Connection.ADMIN_PASSWORD,
                                                                      self.GUEST_SPACE_ID)
            
            self.bulkRequestModule = BulkRequest(self.conn)
            self.bulkRequestAPI = BulkRequest(self.connAPI)
            self.bulkRequestModuleGuestSpace = BulkRequest(self.connGuestSpace)
            
            self.recordModule = Record(self.conn)
            self.recordModuleAPI = Record(self.connAPI)
            self.recordModuleGuestSpace = Record(self.connGuestSpace)
        }
        
        describe("") {
            it("Test_002_Success_ValidRequest") {
                var recordIDs = [Int]()
                self.recordTextValue = DataRandomization.generateString()
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
                        self.recordTextValue = DataRandomization.generateString()
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
                        self.recordTextValue = DataRandomization.generateString()
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
                var recordIDs = [Int]()
                
                self.recordTextValue = DataRandomization.generateString()
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                do {
                    _ = try self.bulkRequestAPI.addRecord(self.APP_ID, self.testData)
                    _ = try self.bulkRequestAPI.addRecords(self.APP_ID, [self.testData])
                } catch let err {
                    print("ERROR: \(err)")
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
                        self.recordTextValue = DataRandomization.generateString()
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
                        self.recordTextValue = DataRandomization.generateString()
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
                var recordIDs = [Int]()
                
                self.recordTextValue = DataRandomization.generateString()
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue)
                do {
                    _ = try self.bulkRequestModuleGuestSpace.addRecord(self.APP_ID_GUESTSPACE, self.testData)
                    _ = try self.bulkRequestModuleGuestSpace.addRecords(self.APP_ID_GUESTSPACE, [self.testData])
                } catch let err {
                    print("ERROR: \(err)")
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
                        self.recordTextValue = DataRandomization.generateString()
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
                        self.recordTextValue = DataRandomization.generateString()
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
        }
    }
}

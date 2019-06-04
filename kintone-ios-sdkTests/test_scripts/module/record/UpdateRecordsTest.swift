///**
/**
 kintone-ios-sdkTests
 Created on 5/8/19
 */

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class UpdateRecordsTest: QuickSpec {
    let APP_ID = 1
    let APP_UPDATE_KEY_GUEST_SPACE_ID = 2
    let APP_BLANK_ID = 6 // Create app without fields
    let APP_HAVE_REQUIRED_FIELD_ID = 2
    let APP_HAVE_NUMBER_FIELD_ID = 4
    let APP_HAVE_PROHIBIT_DUPLICATE_VALUE_FIELD_ID = 5
    
    let RECORD_TEXT_FIELD: String! = "text"
    let RECORD_TEXT_KEY: String! = "key"
    let RECORD_NUMBER_FILED: String = "number"
    var recordIDs =  [Int]()
    var recordIDGuestSpace: Int!
    var recordTextValue =  [String]()
    var recordTextKeyValue = [String]()
    var testData: Dictionary<String, FieldValue>!
    
    let API_TOKEN: String = "MCzGNV14RBJ83ToijXT3Srqv9xqvZZQNJvQR4HFJ"
    
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("") {
            it("") {
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record"))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue[self.recordTextValue.count-1])
                var addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                self.recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record"))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue[self.recordTextValue.count-1])
                addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_ID, self.testData)) as! AddRecordResponse
                self.recordIDs.append(addRecordResponse.getId()!)
                self.recordTextValue.append(DataRandomization.generateString(prefix: "Record"))
                self.testData = RecordUtils.setRecordData([:], self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT, self.recordTextValue[self.recordTextValue.count-1])
                var recordsUpdateItem = [RecordUpdateItem]()
                for id in self.recordIDs {
                    recordsUpdateItem.append(RecordUpdateItem(id, nil, nil, self.testData))
                }
                let updateRecordsResponse = TestCommonHandling.awaitAsync(recordModule.updateRecords(self.APP_ID, recordsUpdateItem)) as! UpdateRecordsResponse
                for record in updateRecordsResponse.getRecords()! {
                    XCTAssert(record.getRevision() == 2)
                    let result = TestCommonHandling.awaitAsync(recordModule.getRecord(self.APP_ID, record.getID()!)) as! GetRecordResponse
                    for(key, value) in result.getRecord()! {
                        if(key == self.RECORD_TEXT_FIELD) {
                            XCTAssertEqual(self.recordTextValue[self.recordTextValue.count-1], (value.getValue() as! String))
                        }
                    }
                }
            }
        }
    }
}

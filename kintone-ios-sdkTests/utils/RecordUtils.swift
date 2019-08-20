//
// kintone-ios-sdkTests
// Created on 5/30/19
//

@testable import Promises
@testable import kintone_ios_sdk

class RecordUtils {
    /// Set single field data to record data dictionary
    ///
    /// - Paramaters:
    ///   - recordData: Dictionary<String, FieldValue> | the Dictionary record data
    ///   - code: String | the code of field on record
    ///   - type: FieldType | the type of field on record
    ///   - value: Any | the vaule of field on record
    ///
    /// - Returns: record data in Dictionary type
    public static func setRecordData(_ recordData: Dictionary<String, FieldValue>,
                                     _ code: String,
                                     _ type: FieldType,
                                     _ value: Any) -> Dictionary<String, FieldValue> {
        var recData = recordData
        let field = FieldValue()
        field.setType(type)
        field.setValue(value)
        recData[code] = field
        
        return recData
    }
    
    /// Create query to get records
    ///
    /// - Parameter recordIDs: [Int] | the array id of records to select
    /// - Returns: String | the query to select records
    public static func getRecordsQuery(_ recordIDs: [Int]) -> String {
        var idsString = "("
        for id in recordIDs {
            if idsString == "(" {
                idsString += String(id)
            } else {
                idsString += "," + String(id)
            }
        }
        let query = "$id in " + idsString + ")" +  " order by $id asc"
        
        return query
    }
    
    /// Delete all records of an App
    ///
    /// - Parameters:
    ///   - recordModule: Record | Record module
    ///   - appID: Int | App ID
    public static func deleteAllRecords(recordModule: Record, appID: Int) {
        var flag = true
        while(flag) {
            var recordIDs = [Int]()
            recordModule.getRecords(appID, nil, nil, nil).then {result in
                if(!result.getRecords()!.isEmpty) { // replaced for result.getRecords()!.count != 0
                    for (_, dval) in (result.getRecords()!.enumerated()) {
                        for (code, value) in dval {
                            if (code == "$id") {
                                let text: String = value.getValue()! as! String
                                let number: Int = Int(text)!
                                recordIDs.append(number)
                            }
                        }
                    }
                    recordModule.deleteRecords(appID, recordIDs).then {
                        print("Delete: \(recordIDs.count) record in App(\(appID))")
                    }
                } else {
                    flag = false
                }
                }.catch {error in
                    let errorVal = error as! KintoneAPIException
                    print("Error: \(errorVal.getErrorResponse()?.getMessage()! ?? "Can not catch Error")")
            }
            _ = waitForPromises(timeout: Double(TestConstant.Common.PROMISE_TIMEOUT))
        }
    }
    
    /// add records with enter the number of records
    ///
    /// - Parameters:
    ///   - recordModule: Record | Record module
    ///   - appId: Int | App ID
    ///   - numberOfRecords: Int | Number of records
    ///   - textField: String | Code of Field
    /// - Returns: [Int] | Array of records id
    public static func addRecords(_ recordModule: Record, _ appId: Int, _ numberOfRecords: Int, _ textField: String) -> [Int] {
        var textFieldValues = [String]()
        var testDataList = [Dictionary<String, FieldValue>]()
        var recordIds = [Int]()
        let integerNumber = Int(numberOfRecords / 100)
        
        if(integerNumber == 0) {
            for i in 0...numberOfRecords - 1 {
                textFieldValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                testDataList.append(testData)
            }
            
            let addRecordsRsp = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
            recordIds.append(contentsOf: addRecordsRsp.getIDs()!)
        } else {
            let surplusNumber = numberOfRecords % 100
            if(surplusNumber == 0) {
                for _ in 0...integerNumber-1 {
                    textFieldValues.removeAll()
                    testDataList.removeAll()
                    for i in 0...99 {
                        textFieldValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                        let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                        testDataList.append(testData)
                    }
                    
                    let addRecordsRsp = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                    recordIds.append(contentsOf: addRecordsRsp.getIDs()!)
                }
            } else {
                for _ in 0...integerNumber-1 {
                    textFieldValues.removeAll()
                    testDataList.removeAll()
                    for i in 0...99 {
                        textFieldValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                        let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                        testDataList.append(testData)
                    }
                    
                    let addRecordsRsp = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                    recordIds.append(contentsOf: addRecordsRsp.getIDs()!)
                }
                
                textFieldValues.removeAll()
                testDataList.removeAll()
                for i in 0...surplusNumber - 1 {
                    textFieldValues.append(DataRandomization.generateString(prefix: "AddRecords", length: 10))
                    let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, textFieldValues[i])
                    testDataList.append(testData)
                }
                
                let addRecordsRsp = TestCommonHandling.awaitAsync(recordModule.addRecords(appId, testDataList)) as! AddRecordsResponse
                recordIds.append(contentsOf: addRecordsRsp.getIDs()!)
            }
        }
        
        return recordIds
    }
}

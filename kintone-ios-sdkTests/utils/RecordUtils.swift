///**
/**
 kintone-ios-sdkTests
 Created on 5/30/19
 */

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
        while(flag){
            var recordIDs = [Int]()
            recordModule.getRecords(appID, nil, nil, nil).then{result in
                if(result.getRecords()!.count != 0){
                    for (_, dval) in (result.getRecords()!.enumerated()) {
                        for (code, value) in dval {
                            if (code == "$id") {
                                let text:String = value.getValue()! as! String
                                let number:Int = Int(text)!
                                recordIDs.append(number)
                            }
                        }
                    }
                    recordModule.deleteRecords(appID, recordIDs).then{
                        print("Delete: \(recordIDs.count) record in App(\(appID))")
                    }
                } else {
                    flag = false;
                }
                }.catch{error in
                    let errorVal = error as! KintoneAPIException
                    print("Error: \(errorVal.getErrorResponse()?.getMessage()! ?? "Can not catch Error")")
            }
            _ = waitForPromises(timeout: Double(TestConstant.Common.PROMISE_TIMEOUT))
        }
    }
}

///**
/**
 kintone-ios-sdkTests
 Created on 5/30/19
 */

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
    
    /// create query to get records
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
}

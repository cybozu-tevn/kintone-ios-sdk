//
//  KintoneError.swift
//  kintone-ios-sdkTests
//
//  Created by Hoang Van Phong on 5/6/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

internal class KintoneErrorMessage: Codable {
    var API_TOKEN_ERROR: KintoneError!
    var PERMISSION_ERROR: KintoneError!
    
    var MISSING_APPS_ERROR: KintoneError!
    var MISSING_APP_ERROR: KintoneError!
    var MISSING_APP_ID_ERROR: KintoneError!
    var MISSING_APPS_ID_ERROR: KintoneError!
    var MISSING_NAME_ERROR: KintoneError!
    var MISSING_FIELD_ADD_UPDATE_FORM_ERROR: KintoneError!
    var MISSING_FIELD_DELETE_FORM_ERROR: KintoneError!
    var MISSING_SPACE_ERROR: KintoneError!
    var MISSING_THREAD_ERROR: KintoneError!
    var MISSING_LAYOUT_ERROR: KintoneError!
    var MISSING_ICON_TYPE_ERROR: KintoneError!
    var MISSING_ICON_KEY_ERROR: KintoneError!
    var MISSING_COMMENT_MENTIONS_CODE_ERROR: KintoneError!
    var MISSING_RECORD_ID_ERROR: KintoneError!
    var MISSING_COMMENT_OBJECT_ERROR: KintoneError!
    var MISSING_COMMENT_TEXT_ERROR: KintoneError!
    var MISSING_COMMENT_MENTIONS_TYPE_ERROR: KintoneError!
    var MISSING_DELETE_COMMENT_OBJECT_ERROR: KintoneError!
    var MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR : KintoneError!
    var MISSING_VIEWS_INDEX_ERROR: KintoneError!
    var MISSING_VIEWS_TYPE_ERROR: KintoneError!
    var MISSING_ASSIGNEE_ERROR: KintoneError!
    var MISSING_RECORD_ID_UPDATE_RECORDS_ERROR: KintoneError!
    
    var NEGATIVE_APPID_ERROR: KintoneError!
    var NEGATIVE_APP_ID_ERROR: KintoneError!
    var NEGATIVE_APPS_ID_ERROR: KintoneError!
    var NEGATIVE_LIMIT_ERROR: KintoneError!
    var NEGATIVE_OFFSET_ERROR: KintoneError!
    var NEGATIVE_SPACE_ERROR: KintoneError!
    var NEGATIVE_THREAD_ERROR: KintoneError!
    var NEGATIVE_RECORD_ID_ERROR: KintoneError!
    var NEGATIVE_RECORD_ERROR: KintoneError!
    var NEGATIVE_REVISION_ERROR: KintoneError!
    var NEGATIVE_COMMENT_ID_ERROR: KintoneError!
    
    var INVALID_LANGUAGE_ERROR: KintoneError!
    var INVALID_APP_ID_ERROR: KintoneError!
    var INVALID_APPS_ID_ERROR: KintoneError!
    var INVALID_REVISION_ERROR: KintoneError!
    var INVALID_REVERT_ERROR: KintoneError!
    var INVALID_FIELD_TYPE_ERROR: KintoneError!
    var INVALID_FIELD_CODE_ERROR: KintoneError!
    var INVALID_FIELD_TYPE_UPDATE_LAYOUT_ERROR: KintoneError!
    var INVALID_FIELD_CODE_UPDATE_LAYOUT_ERROR: KintoneError!
    var INVALID_LAYOUT_TYPE_ERROR: KintoneError!
    var INVALID_THEME_ERROR: KintoneError!
    var INVALID_COMMENT_ORDER_ERROR: KintoneError!
    var INVALID_COMMENT_MENTIONS_TYPE_ERROR: KintoneError!
    var INVALID_QUERY_GET_DATA_ERROR: KintoneError!
    var INVALID_FIELD_TYPE_NUMBER_ERROR: KintoneError!
    var INVALID_VALUE_DUPLICATED_ERROR: KintoneError!
    var INVALID_VIEWS_TYPE_ERROR: KintoneError!
    var INVALID_VIEWS_KEY_ERROR: KintoneError!
    var INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR: KintoneError!
    var INVALID_UPDATEKEY_NOT_UNIQUE: KintoneError!
    
    var NONEXISTENT_APP_ID_ERROR: KintoneError!
    var NONEXISTENT_APP_ID_GUEST_SPACE_ERROR: KintoneError!
    var NONEXISTENT_SPACE_ERROR: KintoneError!
    var NONEXISTENT_THREAD_ERROR: KintoneError!
    var NONEXISTENT_FIELD_CODE_UPDATE_LAYOUT_ERROR: KintoneError!
    var NONEXISTENT_COMMENT_ID_ERROR: KintoneError!
    var NONEXISTENT_RECORD_ID_ERROR: KintoneError!
    var NONEXISTENT_USER_ERROR: KintoneError!
    var NONEXISTENT_FIELD_IN_TABLE_UPDATE_LAYOUT_ERROR: KintoneError!
    
    var INCORRECT_UPDATEKEY_VALUE_ERROR: KintoneError!
    var INCORRECT_UPDATEKEY_FIELD_ERROR: KintoneError!
    var INCORRECT_REVISION_ERROR: KintoneError!
    var INCORRECT_REVISION_RECORD_ERROR: KintoneError!
    var INCORRECT_FILE_KEY_DOWNLOAD: KintoneError!
    
    
    var DUPLICATE_APP_ID_ERROR: KintoneError!
    
    var LIMIT_LARGER_THAN_10_ERRORS: KintoneError!
    var LIMIT_LARGER_THAN_100_ERRORS: KintoneError!
    var LIMIT_LARGER_THAN_500_ERROR: KintoneError!
    var APP_ID_LARGER_THAN_300_ERROR: KintoneError!
    var APP_ID_LARGER_THAN_100_ERROR: KintoneError!
    var RECORD_ID_LARGER_THAN_100_ERROR: KintoneError!
    var RECORD_ID_LARGER_THAN_100_ERROR_ADD_RECORD: KintoneError!
    var CODES_LARGER_THAN_100_ERROR: KintoneError!
    var SPACE_ID_LARGER_THAN_100_ERROR: KintoneError!
    var OFFSET_LARGER_THAN_2147483647_ERROR: KintoneError!
    var NAME_LARGER_THAN_64_CHARACTERS_ERROR: KintoneError!
    var FIELDS_LARGER_THAN_100_ERROR: KintoneError!
    var ASSIGNEES_MORE_THAN_100_ERROR: KintoneError!
    var MORE_THAN_100_UPDATE_RECORDS_ERROR: KintoneError!
    
    var COMMENTS_FEATURE_DISABLED_ERROR: KintoneError!
    var DELETE_OTHER_USER_COMMENT_ERROR: KintoneError!
    var MORE_THAN_300_APP_IDS: KintoneError!
    var NEGATIVE_APPS_ID: KintoneError!
    var PROCESS_MANAGEMENT_DISABLED_ERROR: KintoneError!
    var NOT_ASSIGNEE_CHANGE_STATUS_ERROR: KintoneError!
    var UNSPECIFIED_ASSIGNEE_UPDATED_STATUS_ERROR: KintoneError!
    var INVALID_STATUS_ERROR: KintoneError!
}

struct KintoneError: Codable {
    var code: String!
    var message: String!
    var errors: [String: [String: Array<String>]]?
    
    init(code: String, message: String) {
        self.code = code
        self.message = message
    }
    
    init(code: String, message: String, errors: [String: [String: Array<String>]]){
        self.code = code
        self.message = message
        self.errors = errors
    }
    
    private func changeKeyOfErrors(dictionary: [String: [String: Array<String>]], oldKey: String, newKey: String) -> [String: [String: Array<String>]]{
        var result = dictionary
        let tempDict = dictionary
        result.removeValue(forKey: oldKey)
        result.updateValue(tempDict[oldKey]!, forKey: newKey)
        return result
    }
    
    private func replaceMultiple(inputString: String, oldTemplate: String, newTemplates:[String]) -> String {
        var result = ""
        var iterator = newTemplates.makeIterator()
        var searchRange = inputString.startIndex..<self.message.endIndex
        while let placeHolderRange = inputString.range(of: oldTemplate, options: [], range: searchRange, locale: nil) {
            guard let replacement = iterator.next() else {
                break
            }
            result.append(contentsOf: inputString[searchRange.lowerBound..<placeHolderRange.lowerBound])
            result.append(contentsOf: replacement)
            searchRange = placeHolderRange.upperBound..<searchRange.upperBound
        }
        result.append(contentsOf: self.message[searchRange])
        return result
    }
    
    func getMessage() -> String {
        return self.message!
    }
    
    func getCode() -> String {
        return self.code
    }
    
    func getErrors() -> [String: [String: Array<String>]]? {
        return self.errors
    }
    
    mutating func replaceMessage(oldTemplate: String, newTemplate:String) {
        self.message = self.message.replacingOccurrences(of: oldTemplate, with: newTemplate)
    }
    
    mutating func replaceMessage(oldTemplate: String, newTemplates:[String]) {
        self.message = replaceMultiple(inputString: self.message, oldTemplate: oldTemplate, newTemplates: newTemplates)
    }
    
    mutating func replaceKeyError(oldTemplate: String, newTemplate:String) {
        for(_, value) in (self.errors!.enumerated()){
            if(value.key.range(of: oldTemplate) != nil){
                self.errors = changeKeyOfErrors(
                    dictionary: self.errors!,
                    oldKey: value.key,
                    newKey: value.key.replacingOccurrences(of: oldTemplate, with: newTemplate))
            }
        }
    }
    
    mutating func replaceKeyError(oldTemplate: String, newTemplates:[String]) {
        for(_, value) in (self.errors!.enumerated()){
            if(value.key.range(of: oldTemplate) != nil){
                self.errors = changeKeyOfErrors(
                    dictionary: self.errors!,
                    oldKey: value.key,
                    newKey: replaceMultiple(inputString: value.key, oldTemplate: oldTemplate, newTemplates: newTemplates))
            }
        }
    }
    
    mutating func replaceValueError(_key: String, oldTemplate: String, newTemplate:String){
        for (keyError, dval) in self.errors! {
            if(keyError == _key) {
                for (key, _) in dval {
                    self.errors![keyError]![key]![0] = self.errors![keyError]![key]![0].replacingOccurrences(of: oldTemplate, with: newTemplate)
                }
            }
        }
    }
}

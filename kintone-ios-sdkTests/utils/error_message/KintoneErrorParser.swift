//
//  KintoneErrorParser.swift
//  kintone-ios-sdkTests
//

class KintoneErrorParser {
    static let result = TestCommonHandling.handleDoTryCatch {try JSONHandler("KintoneErrorMessage").parseJSON(KintoneErrorMessage.self)} as! KintoneErrorMessage
    
    static func API_TOKEN_ERROR() -> KintoneError? {
        return result.API_TOKEN_ERROR
    }
    
    static func PERMISSION_ERROR() -> KintoneError? {
        return result.PERMISSION_ERROR
    }
    
    static func PERMISSION_EDIT_FIELD_ERROR() -> KintoneError? {
        return result.PERMISSION_EDIT_FIELD_ERROR
    }
    
    static func MISSING_APPS_ERROR() -> KintoneError? {
        return result.MISSING_APPS_ERROR
    }
    
    static func MISSING_SPACE_ERROR() -> KintoneError? {
        return result.MISSING_SPACE_ERROR
    }
    
    static func MISSING_THREAD_ERROR() -> KintoneError? {
        return result.MISSING_THREAD_ERROR
    }
    
    static func MISSING_ICON_TYPE_ERROR() -> KintoneError? {
        return result.MISSING_ICON_TYPE_ERROR
    }
    
    static func MISSING_ICON_KEY_ERROR() -> KintoneError? {
        return result.MISSING_ICON_KEY_ERROR
    }
    
    static func MISSING_COMMENT_MENTIONS_CODE_ERROR() -> KintoneError? {
        return result.MISSING_COMMENT_MENTIONS_CODE_ERROR
    }
    
    static func MISSING_COMMENT_OBJECT_ERROR() -> KintoneError? {
        return result.MISSING_COMMENT_OBJECT_ERROR
    }
    
    static func MISSING_COMMENT_TEXT_ERROR() -> KintoneError? {
        return result.MISSING_COMMENT_TEXT_ERROR
    }
    
    static func MISSING_COMMENT_MENTIONS_TYPE_ERROR() -> KintoneError? {
        return result.MISSING_COMMENT_MENTIONS_TYPE_ERROR
    }
    
    static func MISSING_DELETE_COMMENT_OBJECT_ERROR() -> KintoneError? {
        return result.MISSING_DELETE_COMMENT_OBJECT_ERROR
    }
    
    static func MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR() -> KintoneError? {
        return result.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR
    }
    
    static func MISSING_VIEWS_INDEX_ERROR() -> KintoneError? {
        return result.MISSING_VIEWS_INDEX_ERROR
    }
    
    static func MISSING_VIEWS_TYPE_ERROR() -> KintoneError? {
        return result.MISSING_VIEWS_TYPE_ERROR
    }
    
    static func INVALID_LANGUAGE_ERROR() -> KintoneError? {
        return result.INVALID_LANGUAGE_ERROR
    }
    
    static func INVALID_APP_ID_ERROR() -> KintoneError? {
        return result.INVALID_APP_ID_ERROR
    }
    
    static func INVALID_APPS_ID_ERROR() -> KintoneError? {
        return result.INVALID_APPS_ID_ERROR
    }
    
    static func INVALID_REVISION_ERROR() -> KintoneError? {
        return result.INVALID_REVISION_ERROR
    }
    
    static func INVALID_REVERT_ERROR() -> KintoneError? {
        return result.INVALID_REVERT_ERROR
    }
    
    static func INVALID_FIELD_TYPE_ERROR() -> KintoneError? {
        return result.INVALID_FIELD_TYPE_ERROR
    }
    
    static func INVALID_FIELD_CODE_ERROR() -> KintoneError? {
        return result.INVALID_FIELD_CODE_ERROR
    }
    
    static func INVALID_FIELD_TYPE_UPDATE_LAYOUT_ERROR() -> KintoneError? {
        return result.INVALID_FIELD_TYPE_UPDATE_LAYOUT_ERROR
    }
    
    static func INVALID_LAYOUT_TYPE_ERROR() -> KintoneError? {
        return result.INVALID_LAYOUT_TYPE_ERROR
    }
    
    static func INVALID_THEME_ERROR() -> KintoneError? {
        return result.INVALID_THEME_ERROR
    }
    
    static func INVALID_COMMENT_ORDER_ERROR() -> KintoneError? {
        return result.INVALID_COMMENT_ORDER_ERROR
    }
    
    static func INVALID_COMMENT_MENTIONS_TYPE_ERROR() -> KintoneError? {
        return result.INVALID_COMMENT_MENTIONS_TYPE_ERROR
    }
    
    static func INVALID_QUERY_GET_DATA_ERROR() -> KintoneError? {
        return result.INVALID_QUERY_GET_DATA_ERROR
    }
    
    static func INVALID_FIELD_TYPE_NUMBER_ERROR() -> KintoneError? {
        return result.INVALID_FIELD_TYPE_NUMBER_ERROR
    }
    
    static func INVALID_VALUE_DUPLICATED_ERROR() -> KintoneError? {
        return result.INVALID_VALUE_DUPLICATED_ERROR
    }
    
    static func INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR() -> KintoneError? {
        return result.INVALID_STRICT_FIELD_TYPE_UPDATE_RECORD_ERROR
    }
    
    static func INVALID_UPDATEKEY_NOT_UNIQUE() -> KintoneError? {
        return result.INVALID_UPDATEKEY_NOT_UNIQUE
    }
    
    static func INVALID_VIEWS_TYPE_ERROR() -> KintoneError? {
        return result.INVALID_VIEWS_TYPE_ERROR
    }
    
    static func INVALID_VIEWS_KEY_ERROR() -> KintoneError? {
        return result.INVALID_VIEWS_KEY_ERROR
    }
    
    static func NEGATIVE_APPID_ERROR() -> KintoneError? {
        return result.NEGATIVE_APPID_ERROR
    }
    
    static func NEGATIVE_APP_ID_ERROR() -> KintoneError? {
        return result.NEGATIVE_APP_ID_ERROR
    }
    
    static func NEGATIVE_APPS_ID_ERROR() -> KintoneError? {
        return result.NEGATIVE_APPS_ID_ERROR
    }
    
    static func NEGATIVE_LIMIT_ERROR() -> KintoneError? {
        return result.NEGATIVE_LIMIT_ERROR
    }
    
    static func NEGATIVE_OFFSET_ERROR() -> KintoneError? {
        return result.NEGATIVE_OFFSET_ERROR
    }
    
    static func NEGATIVE_SPACE_ERROR() -> KintoneError? {
        return result.NEGATIVE_SPACE_ERROR
    }
    
    static func NEGATIVE_THREAD_ERROR() -> KintoneError? {
        return result.NEGATIVE_THREAD_ERROR
    }
    
    static func NEGATIVE_RECORD_ID_ERROR() -> KintoneError? {
        return result.NEGATIVE_RECORD_ID_ERROR
    }
    
    static func NEGATIVE_REVISION_ERROR() -> KintoneError? {
        return result.NEGATIVE_REVISION_ERROR
    }
    
    static func NEGATIVE_COMMENT_ID_ERROR() -> KintoneError? {
        return result.NEGATIVE_COMMENT_ID_ERROR
    }
    
    static func NONEXISTENT_APP_ID_ERROR() -> KintoneError? {
        return result.NONEXISTENT_APP_ID_ERROR
    }
    
    static func NONEXISTENT_APP_ID_GUEST_SPACE_ERROR() -> KintoneError? {
        return result.NONEXISTENT_APP_ID_GUEST_SPACE_ERROR
    }
    
    static func NONEXISTENT_SPACE_ERROR() -> KintoneError? {
        return result.NONEXISTENT_SPACE_ERROR
    }
    
    static func NONEXISTENT_THREAD_ERROR() -> KintoneError? {
        return result.NONEXISTENT_THREAD_ERROR
    }
    
    static func NONEXISTENT_FIELD_CODE_UPDATE_LAYOUT_ERROR() -> KintoneError? {
        return result.NONEXISTENT_FIELD_CODE_UPDATE_LAYOUT_ERROR
    }
    
    static func NONEXISTENT_COMMENT_ID_ERROR() -> KintoneError? {
        return result.NONEXISTENT_COMMENT_ID_ERROR
    }
    
    static func NONEXISTENT_RECORD_ID_ERROR() -> KintoneError? {
        return result.NONEXISTENT_RECORD_ID_ERROR
    }
    
    static func NONEXISTENT_USER_ERROR() -> KintoneError? {
        return result.NONEXISTENT_USER_ERROR
    }
    
    static func INCORRECT_UPDATEKEY_VALUE_ERROR() -> KintoneError? {
        return result.INCORRECT_UPDATEKEY_VALUE_ERROR
    }
    
    static func INCORRECT_UPDATEKEY_FIELD_ERROR() -> KintoneError? {
        return result.INCORRECT_UPDATEKEY_FIELD_ERROR
    }
    
    static func INCORRECT_REVISION_ERROR() -> KintoneError? {
        return result.INCORRECT_REVISION_ERROR
    }
    
    static func INCORRECT_REVISION_RECORD_ERROR() -> KintoneError? {
        return result.INCORRECT_REVISION_RECORD_ERROR
    }
    
    static func INCORRECT_FILE_KEY_DOWNLOAD() -> KintoneError? {
        return result.INCORRECT_FILE_KEY_DOWNLOAD
    }
    
    static func DUPLICATE_APP_ID_ERROR() -> KintoneError? {
        return result.DUPLICATE_APP_ID_ERROR
    }
    
    static func LIMIT_LARGER_THAN_10_ERRORS() -> KintoneError? {
        return result.LIMIT_LARGER_THAN_10_ERRORS
    }
    
    static func LIMIT_LARGER_THAN_100_ERRORS() -> KintoneError? {
        return result.LIMIT_LARGER_THAN_100_ERRORS
    }
    
    static func LIMIT_LARGER_THAN_500_ERROR() -> KintoneError? {
        return result.LIMIT_LARGER_THAN_500_ERROR
    }
    
    static func APP_ID_LARGER_THAN_300_ERROR() -> KintoneError? {
        return result.APP_ID_LARGER_THAN_300_ERROR
    }
    
    static func APP_ID_LARGER_THAN_100_ERROR() -> KintoneError? {
        return result.APP_ID_LARGER_THAN_100_ERROR
    }
    
    static func RECORD_ID_LARGER_THAN_100_ERROR_ADD_RECORD() -> KintoneError? {
        return result.RECORD_ID_LARGER_THAN_100_ERROR_ADD_RECORD
    }
    
    static func CODES_LARGER_THAN_100_ERROR() -> KintoneError? {
        return result.CODES_LARGER_THAN_100_ERROR
    }
    
    static func SPACE_ID_LARGER_THAN_100_ERROR() -> KintoneError? {
        return result.SPACE_ID_LARGER_THAN_100_ERROR
    }
    
    static func OFFSET_LARGER_THAN_2147483647_ERROR() -> KintoneError? {
        return result.OFFSET_LARGER_THAN_2147483647_ERROR
    }
    
    static func NAME_LARGER_THAN_64_CHARACTERS_ERROR() -> KintoneError? {
        return result.NAME_LARGER_THAN_64_CHARACTERS_ERROR
    }
    
    static func FIELDS_LARGER_THAN_100_ERROR() -> KintoneError? {
        return result.FIELDS_LARGER_THAN_100_ERROR
    }
    
    static func RECORD_ID_LARGER_THAN_100_ERROR() -> KintoneError? {
        return result.RECORD_ID_LARGER_THAN_100_ERROR
    }
    
    static func RECORD_ID_AND_REVISION_LARGER_THAN_100_ERROR() -> KintoneError? {
        return result.RECORD_ID_AND_REVISION_LARGER_THAN_100_ERROR
    }
    
    static func COMMENTS_FEATURE_DISABLED_ERROR() -> KintoneError? {
        return result.COMMENTS_FEATURE_DISABLED_ERROR
    }
    
    static func DELETE_OTHER_USER_COMMENT_ERROR() -> KintoneError? {
        return result.DELETE_OTHER_USER_COMMENT_ERROR
    }
    
    static func MORE_THAN_300_APP_IDS() -> KintoneError? {
        return result.MORE_THAN_300_APP_IDS
    }
    
    static func MISSING_APP_ID_ERROR() -> KintoneError? {
        return result.MISSING_APP_ID_ERROR
    }
    
    static func MISSING_APP_ERROR() -> KintoneError? {
        return result.MISSING_APP_ERROR
    }
    
    static func MISSING_FIELD_ADD_UPDATE_FORM_ERROR() -> KintoneError? {
        return result.MISSING_FIELD_ADD_UPDATE_FORM_ERROR
    }
    
    static func MISSING_FIELD_DELETE_FORM_ERROR() -> KintoneError? {
        return result.MISSING_FIELD_DELETE_FORM_ERROR
    }
    
    static func ASSIGNEES_MORE_THAN_100_ERROR() -> KintoneError? {
        return result.ASSIGNEES_MORE_THAN_100_ERROR
    }
    
    static func PROCESS_MANAGEMENT_DISABLED_ERROR() -> KintoneError? {
        return result.PROCESS_MANAGEMENT_DISABLED_ERROR
    }
    
    static func NOT_ASSIGNEE_CHANGE_STATUS_ERROR() -> KintoneError? {
        return result.NOT_ASSIGNEE_CHANGE_STATUS_ERROR
    }
    
    static func MISSING_ASSIGNEE_ERROR() -> KintoneError? {
        return result.MISSING_ASSIGNEE_ERROR
    }
    
    static func UNSPECIFIED_ASSIGNEE_UPDATED_STATUS_ERROR() -> KintoneError? {
        return result.UNSPECIFIED_ASSIGNEE_UPDATED_STATUS_ERROR
    }
    
    static func INVALID_STATUS_ERROR() -> KintoneError? {
        return result.INVALID_STATUS_ERROR
    }
    
    static func MISSING_RECORD_ID_UPDATE_RECORDS_ERROR() -> KintoneError? {
        return result.MISSING_RECORD_ID_UPDATE_RECORDS_ERROR
    }
    
    static func MORE_THAN_100_UPDATE_RECORDS_ERROR() -> KintoneError? {
        return result.MORE_THAN_100_UPDATE_RECORDS_ERROR
    }
    
    static func NONEXISTENT_FIELD_IN_TABLE_UPDATE_LAYOUT_ERROR() -> KintoneError? {
        return result.NONEXISTENT_FIELD_IN_TABLE_UPDATE_LAYOUT_ERROR
    }
    
    static func NEGATIVE_RECORD_ERROR() -> KintoneError? {
        return result.NEGATIVE_RECORD_ERROR
    }
    
    static func INVALID_CURSOR_ID() -> KintoneError? {
        return result.INVALID_CURSOR_ID
    }
    
    static func INVALID_CURSOR_NEGATIVE_SIZE() -> KintoneError? {
        return result.INVALID_CURSOR_NEGATIVE_SIZE
    }
    
    static func MAXIMUM_LIMIT_CURSOR() -> KintoneError? {
        return result.MAXIMUM_LIMIT_CURSOR
    }
    
    static func EXCEED_CURSOR_SIZE_LIMIT() -> KintoneError? {
        return result.EXCEED_CURSOR_SIZE_LIMIT
    }
}

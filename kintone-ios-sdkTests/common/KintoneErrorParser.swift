//
//  KintoneErrorParser.swift
//  kintone-ios-sdkTests
//
//  Created by Hoang Van Phong on 5/6/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

class KintoneErrorParser {
    static func NONEXISTENT_APP_ID_ERROR() -> KintoneError? {
        let result = TestCommonHandling.handleDoTryCatch{try JSONHandler().parseJSON(KintoneErrorMessage.self)} as! KintoneErrorMessage
        return result.NONEXISTENT_APP_ID_ERROR
    }
    
    static func NEGATIVE_APPID_ERROR() -> KintoneError? {
        let result = TestCommonHandling.handleDoTryCatch{try JSONHandler().parseJSON(KintoneErrorMessage.self)} as! KintoneErrorMessage
        return result.NEGATIVE_APPID_ERROR
    }
}

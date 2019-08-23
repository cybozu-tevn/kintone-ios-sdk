//
// kintone-ios-sdkTests
// Created on 8/22/19
// 

import Foundation

open class UpdateRecordPermissionsResponse: NSObject, Codable {
    private var success: Bool!
    
    public func setStatus() -> Bool {
         return self.success
    }
}

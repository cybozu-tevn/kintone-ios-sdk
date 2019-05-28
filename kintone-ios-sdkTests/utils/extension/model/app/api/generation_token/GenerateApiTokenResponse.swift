//
//  GenerateTokenResponse.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/28/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import Foundation

open class GenerateApiTokenResponse: NSObject, Codable {
    private var result: ApiTokenItem!
    private var success: Bool!
    
    public func getSuccess() -> Bool {
        return self.success
    }
    
    open func getResult() -> ApiTokenItem {
        return self.result
    }
    
    open func setResult(_ apiItem: ApiTokenItem) {
        self.result = apiItem
    }
    
    public func setSuccess(_ success: Bool) {
        self.success = success
    }
    
    public init(_ result: ApiTokenItem, _ success: Bool) {
        self.result = result
        self.success = success
    }
}

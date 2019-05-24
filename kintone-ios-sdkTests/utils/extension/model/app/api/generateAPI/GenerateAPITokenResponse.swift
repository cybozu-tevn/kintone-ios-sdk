//
//  GenerateTokenResponse.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/28/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import Foundation

open class GenerateAPITokenResponse: NSObject, Codable {
    private var result: APIItem!
    private var success: Bool!
    
    public func getSuccess() -> Bool {
        return self.success
    }
    
    open func getResult() -> APIItem {
        return self.result
    }
    
    open func setResult(_ apiItem: APIItem) {
        self.result = apiItem
    }
    
    public func setSuccess(_ success: Bool) {
        self.success = success
    }
    
    public init(_ result: APIItem, _ success: Bool) {
        self.result = result
        self.success = success
    }
}

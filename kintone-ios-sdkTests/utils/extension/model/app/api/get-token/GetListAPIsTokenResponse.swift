//
//  GetListAPIsResponse.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/2/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class GetListAPIsTokenResponse: NSObject, Codable {
    private var result: ItemsAPI!
    private var success: Bool!
    
    public func getSuccess() -> Bool {
        return self.success
    }
    
    public func setSuccess(_ success: Bool) {
        self.success = success
    }
    
    public func getResult() -> ItemsAPI {
        return self.result
    }
    
    public func setResult(_ itemsAPI: ItemsAPI) {
        self.result = itemsAPI
    }
    
    public init(_ result: ItemsAPI, _ success: Bool) {
        self.result = result
        self.success = success
    }
}

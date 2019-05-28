//
//  GetListAPIsResponse.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/2/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class GetListApisTokenResponse: NSObject, Codable {
    private var result: ApiTokenItems!
    private var success: Bool!
    
    public func getSuccess() -> Bool {
        return self.success
    }
    
    public func setSuccess(_ success: Bool) {
        self.success = success
    }
    
    public func getResult() -> ApiTokenItems {
        return self.result
    }
    
    public func setResult(_ itemsAPI: ApiTokenItems) {
        self.result = itemsAPI
    }
    
    public init(_ result: ApiTokenItems, _ success: Bool) {
        self.result = result
        self.success = success
    }
}

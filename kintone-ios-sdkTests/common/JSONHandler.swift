//
//  HandleJSON.swift
//  kintone-ios-sdkTests
//
//  Created by Hoang Van Phong on 5/6/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

class JSONHandler {
    var jsonResult: Data!
    
    init (_ fileName: String){
        let testJSON = Bundle(for:type(of: self))
        if let url = testJSON.url(forResource: fileName, withExtension: "json"){
            do {
                self.jsonResult = try Data(contentsOf: url, options: .mappedIfSafe)
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    func parseJSON<T>(_ type: T.Type) throws -> T where T : Decodable {
        do {
            return try JSONDecoder().decode(type, from: self.jsonResult)
        } catch {
            throw error
        }
    }
    
    func getJSONResult() -> Data! {
        return jsonResult
    }
    
}

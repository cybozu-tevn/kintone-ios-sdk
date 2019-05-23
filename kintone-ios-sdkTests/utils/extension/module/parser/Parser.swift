//
//  Parser.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/24/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//
import Foundation
internal class Parser: NSObject {
    
    public func parseObject<T>(_ data: T) throws -> Data where T : Encodable {
        do {
            return try JSONEncoder().encode(data)
        } catch let err{
            throw err
        }
    }
    
    public func parseJson<T>(_ type: T.Type, _ data: Data) throws -> T where T : Decodable {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch let err{
            throw err
        }
    }
    
}

///**
/**
 kintone-ios-sdkTests
 Created on 5/24/19
*/

import Foundation

class DataRandomization {
    /// generate random the String value
    ///
    /// - Parameters:
    ///   - length: Int | the expected length of the string
    ///   - refix: String | the refix of random string
    /// - Returns: the random String value
    public static func generateRandomString(length: Int, refix: String = "") -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        if (refix == "") {
            return "\(refix)-" + String((0...length-1).map { _ in letters.randomElement()! })
        }
        
        return String((0...length-1).map { _ in letters.randomElement()! })
    }
    
    /// generate random the Int value
    ///
    /// - Parameter length: Int | the expected length of the string
    /// - Returns: the random Int value
    public func generateRandomInt(length: Int) -> Int {
        let numbers = "0123456789"
        return Int(String((0...length-1).map { _ in numbers.randomElement()! }))!
    }
}

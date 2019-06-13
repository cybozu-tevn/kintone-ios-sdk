///**
/**
 kintone-ios-sdkTests
 Created on 5/24/19
 */

import Foundation

class DataRandomization {
    
    /// Generate random string with uppercase letters only
    ///
    /// - Parameter length: Int | the expected length of the string
    /// - Returns: the random String value
    public static func generateString(length: Int = 64) -> String {
        let seed = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0...length-1).map { _ in seed.randomElement()!})
    }
    
    /// Generate random the String value
    ///
    /// - Parameters:
    ///   - length: Int | the expected length of the string
    ///   - prefix: String | the prefix of random string
    /// - Returns: the random String value
    public static func generateString(prefix: String = "", length: Int = 64) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        if (prefix != "") {
            return "\(prefix)-" + String((0...length-1).map { _ in letters.randomElement()! })
        }
        
        return String((0...length-1).map { _ in letters.randomElement()! })
    }
    
    /// Generate random number
    ///
    /// - Parameter length: Int | the expected length of the number
    /// - Returns: the random number
    public func generateNumber(_ length: Int) -> Int {
        let numbers = "0123456789"
        return Int(String((0...length-1).map { _ in numbers.randomElement()! }))!
    }
}

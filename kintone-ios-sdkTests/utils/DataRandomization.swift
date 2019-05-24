///**
/**
 kintone-ios-sdkTests
 Created on 5/21/19
 */

import Foundation

class DataRandomization {
    public static func randomString(length: Int, refix: String) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return "\(refix)-" + String((0...length-1).map{ _ in letters.randomElement()! })
    }
}

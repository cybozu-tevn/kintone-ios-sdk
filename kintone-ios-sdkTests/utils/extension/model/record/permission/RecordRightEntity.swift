//
// kintone-ios-sdkTests
// Created on 8/22/19
//

import Foundation

open class RecordRightEntity: NSObject, Codable {
    private var entities: [RightEntity]!
    
    public func getEntities() -> [RightEntity] {
        return self.entities
    }
    
    public func setEntities(_ entities: [RightEntity]) {
        self.entities = entities
    }
    
    public init(entities: [RightEntity]) {
        self.entities = entities
    }
}

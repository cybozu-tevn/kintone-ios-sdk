//
//  FieldValue.swift
//  kintone-ios-sdk
//
//  Created by y001112 on 2018/09/05.
//  Copyright © 2018年 Cybozu. All rights reserved.
//


open class FieldValue: NSObject, Codable{
    
    private var type: FieldType?
    private var value: Any?
    
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    public override init() {
    }
    
    open func getType() -> FieldType? {
        return self.type
    }
    
    open func setType(_ type: FieldType) {
        self.type = type
    }
    
    open func getValue() -> Any? {
        return self.value
    }
    
    open func setValue(_ value: Any?) {
        self.value = value
    }
    /// Convert Json to fieldValue.class
    ///
    /// - Parameter decoder:
    /// - Throws:
    public required init(from decoder: Decoder) throws {
        do {
            let parser = RecordParser()
            let fv = try parser.parseJsonToFieldValue(decoder)
            self.type = fv.getType()
            self.value = fv.getValue()
        }
    }
    /// convert fieldValue.class to Json
    ///
    /// - Parameter encoder:
    /// - Throws:
    open func encode(to encoder: Encoder) throws {
        do {
            guard self.type == nil else {
                let type: FieldType = self.type!
                let parser = RecordParser()
                try parser.parseFieldValueToJson(encoder, type, self.value)
                return
            }
        }
    }
}

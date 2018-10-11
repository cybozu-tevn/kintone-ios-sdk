// Copyright (c) 2018 Cybozu, Inc.

public class AbstractInputField: Field
{
    internal var label: String?
    internal var noLabel: Bool?
    internal var required: Bool?
    
    enum AbstractCodingKeys: CodingKey {
        case label
        case noLabel
        case required
    }
    
    public override init() {
        super.init()
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AbstractCodingKeys.self)
        self.label = try container.decode(String.self, forKey: AbstractCodingKeys.label)
        self.noLabel = try container.decode(Bool.self, forKey: AbstractCodingKeys.noLabel)
        self.required = try container.decode(Bool.self, forKey: AbstractCodingKeys.required)
        try super.init(from: decoder)
    }
    
    public func getLabel() -> String? {
        return self.label
    }
    
    public func setLabel(_ label: String?) {
        self.label = label
    }
    
    public func getNoLabel() -> Bool? {
        return self.noLabel
    }
    
    public func setNoLabel(_ noLabel: Bool?) {
        self.noLabel = noLabel
    }
    
    public func getRequired() -> Bool? {
        return self.required
    }
    
    public func setRequired(_ required: Bool?) {
        self.required = required
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AbstractCodingKeys.self)
        if(self.label != nil){
            try container.encode(self.label, forKey: AbstractCodingKeys.label)
        }
        if(self.required != nil){
            try container.encode(self.required, forKey: AbstractCodingKeys.required)
        }
        if(self.noLabel != nil){
            try container.encode(self.noLabel, forKey: AbstractCodingKeys.noLabel)
        }
        try super.encode(to: encoder)
    }
}
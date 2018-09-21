//
//  GetFormFieldsRequest.swift
//  kintone-ios-sdk
//
//  Created by Trinh Hung Anh on 9/19/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

class GetFormFieldsRequest: NSObject, Codable {
    private var app: Int?
    private var lang: LanguageSetting?
    
    public func getApp() -> Int? {
        return self.app
    }
    public func setApp(app: Int) {
        self.app = app
    }
    public func getLang() -> LanguageSetting? {
        return self.lang
    }
    public func setLang(lang: LanguageSetting) {
        self.lang = lang
    }
    
    public init(_ app: Int, _ lang: LanguageSetting) {
        self.app = app
        self.lang = lang
    }
}

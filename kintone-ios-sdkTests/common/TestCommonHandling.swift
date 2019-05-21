//
//  TestCommonHandling.swift
//  kintone-ios-sdkTests
//
//  Created by Vu Tran on 5/6/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import XCTest
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class TestCommonHandling {
    /// Initializes a new connection with username and password
    ///
    /// - Parameters:
    ///   - username: String | the username of login user
    ///   - password: String | the password of login user
    /// - Returns: conn | the connection create by username and password option
    static func createConnection(_ username: String = TestConstant.Connection.ADMIN_USERNAME, _ password: String = TestConstant.Connection.ADMIN_PASSWORD) -> Connection {
        let auth = Auth.init().setPasswordAuth(username, password)
        let conn = Connection(TestConstant.Connection.DOMAIN , auth)
        return conn
    }
    
    /// Initializes a new connection with token in the application
    ///
    /// - Parameter apiToken: String | The token of API
    /// - Returns: conn | the connection create by api token
    static func createConnection(_ apiToken: String) -> Connection {
        let auth = Auth.init().setApiToken(apiToken)
        let conn = Connection(TestConstant.Connection.DOMAIN , auth)
        return conn
    }
    
    /// Initializes a new connection with username, password and guest space
    ///
    /// - Parameters:
    ///   - username: String | the username of login user
    ///   - password: String | the password of login user
    ///   - guestSpaceId: Int | the id of the guest space
    /// - Returns: conn | the connection create by username, password and guest space id
    static func createConnection(_ username: String, _ password: String, _ guestSpaceId: Int) -> Connection {
        let auth = Auth.init().setPasswordAuth(username, password)
        let conn = Connection(TestConstant.Connection.DOMAIN , auth, guestSpaceId)
        return conn
    }
    
    /// handling the promise
    ///
    /// - Parameter promise: Promise<T> | the promise will be handled
    /// - Returns: response | the respone of the promise
    /// - Throws: throws error
    static func awaitAsync<T>(_ promise: Promise<T>) -> Any{
        let expectation = XCTestExpectation(description: "Async call")
        var response: Any? = nil
        var error: Any? = nil
        
        promise.then { asyncResult in
            response = asyncResult
            expectation.fulfill()
            }.catch{ err in
                error = err
                expectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [expectation], timeout: TestConstant.Common.PROMISE_TIMEOUT)
        return (response != nil) ? (response as Any) : (error as Any)
    }
    
    /// handling DO TRY CATCH
    ///
    /// - Parameter closure: the closure to handel DO TRY CATCH
    /// - Returns: the result or error after handled
    /// - Throws: throws error
    public static func handleDoTryCatch<T>(closure:() throws -> T) -> Any {
        do {
            let result = try closure()
            return result
        } catch let error {
            dump(error)
            return error
        }
    }
    
    /// generate random the string value
    ///
    /// - Parameter length: Int | the expected length of the string
    /// - Returns: the random string value
    public static func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    /// fill single data to Dictionary record data
    ///
    /// - Paramaters:
    ///   - recordData: Dictionary<String, FieldValue> | the Dictionary record data
    ///   - code: String | the code of field on record
    ///   - type: FieldType | the type of field on record
    ///   - value: Any | the vaule of field on record
    ///
    /// - Returns: the Dictionary record data of kintone application
    public static func addData(_ recordData: Dictionary<String, FieldValue>,
                               _ code: String,
                               _ type: FieldType,
                               _ value: Any) -> Dictionary<String, FieldValue> {
        var recData = recordData
        let field = FieldValue()
        field.setType(type)
        field.setValue(value)
        recData[code] = field
        
        return recData
    }
    
    /// compare the expected kintone error message with actual kintone error message result
    ///
    /// - Parameters:
    ///   - KintoneError: KintoneError | the Error of kintone
    ///   - ErrorResponse: ErrorResponse | the Error return from respone
    /// - Returns:
    static func compareError(_ expectedError: KintoneError, _ actualError: ErrorResponse) {
        /// Get code, message and errors of the expected kintone error
        let expectedErrorCode = expectedError.getCode()
        let expectedErrorMessage = expectedError.getMessage()
        let expectedErrors = expectedError.getErrors()
        
        /// Get code, message and errors of the acutal kintone error respone
        let actualErrorCode = actualError.getCode()
        let actualErrorMessage = actualError.getMessage()
        let actualErrors = actualError.getErrors()
        
        /// using Nimble to compare expected and actual kintone error message
        expect(expectedErrorCode).to(equal(actualErrorCode), description: "The error code incorrectly")
        expect(expectedErrorMessage).to(equal(actualErrorMessage), description: "The error message incorrectly")
        if(expectedErrors != nil){
            expect(expectedErrors).to(equal(actualErrors), description: "The errors incorrectly")
        }
    }
}

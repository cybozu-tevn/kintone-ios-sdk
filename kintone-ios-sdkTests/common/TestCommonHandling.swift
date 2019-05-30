//
//  TestCommonHandling.swift
//  kintone-ios-sdkTests
//

import XCTest
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class TestCommonHandling {
    /// Initialize a new connection with username and password
    ///
    /// - Parameters:
    ///   - username: String | the username of login user
    ///   - password: String | the password of login user
    /// - Returns: Connection | the connection create by username and password option
    static func createConnection(_ username: String = TestConstant.Connection.ADMIN_USERNAME, _ password: String = TestConstant.Connection.ADMIN_PASSWORD) -> Connection {
        let auth = Auth.init().setPasswordAuth(username, password)
        let conn = Connection(TestConstant.Connection.DOMAIN, auth)
        return conn
    }
    
    /// Initialize a new connection with API Token
    ///
    /// - Parameter apiToken: String | the API Token
    /// - Returns: Connection | the connection create by api token
    static func createConnection(_ apiToken: String) -> Connection {
        let auth = Auth.init().setApiToken(apiToken)
        let conn = Connection(TestConstant.Connection.DOMAIN, auth)
        return conn
    }
    
    /// Initialize a new connection with username, password and guest space
    ///
    /// - Parameters:
    ///   - username: String | the username of login user
    ///   - password: String | the password of login user
    ///   - guestSpaceId: Int | the id of the guest space
    /// - Returns: Connection | the connection create by username, password and guest space id
    static func createConnection(_ username: String, _ password: String, _ guestSpaceId: Int) -> Connection {
        let auth = Auth.init().setPasswordAuth(username, password)
        let conn = Connection(TestConstant.Connection.DOMAIN, auth, guestSpaceId)
        return conn
    }
    
    /// Handle the promise
    ///
    /// - Parameter promise: Promise<T> | the promise will be handled
    /// - Returns: response | the respone of the promise
    /// - Throws: throws error
    static func awaitAsync<T>(_ promise: Promise<T>) -> Any {
        let expectation = XCTestExpectation(description: "Async call")
        var response: Any?
        var error: Any?
        
        promise.then { asyncResult in
            response = asyncResult
            expectation.fulfill()
            }.catch { err in
                error = err
                expectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [expectation], timeout: TestConstant.Common.PROMISE_TIMEOUT)
        return (response != nil) ? (response as Any) : (error as Any)
    }
    
    /// Handle DO TRY CATCH
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
    
    /// Compare the expected kintone error message with actual kintone error message result
    ///
    /// - Parameters:
    ///   - actualError: ErrorResponse | the Error return from respone
    ///   - expectedError: KintoneError | the Error of kintone
    static func compareError(_ actualError: ErrorResponse!, _ expectedError: KintoneError) {
        /// Get code, message and errors of the expected kintone error
        let expectedErrorCode = expectedError.getCode()
        let expectedErrorMessage = expectedError.getMessage()
        let expectedErrors = expectedError.getErrors()
        
        /// Get code, message and errors of the acutal kintone error respone
        let actualErrorCode = actualError.getCode()
        let actualErrorMessage = actualError.getMessage()
        let actualErrors = actualError.getErrors()
        
        /// using Nimble to compare expected and actual kintone error message
        expect(actualErrorCode).to(equal(expectedErrorCode), description: "The error code is incorrect")
        expect(actualErrorMessage).to(equal(expectedErrorMessage), description: "The error message is incorrect")
        if(expectedErrors != nil) {
            expect(actualErrors).to(equal(expectedErrors), description: "The error description is incorrect")
        }
    }
}

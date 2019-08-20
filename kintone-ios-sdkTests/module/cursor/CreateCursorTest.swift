//
//  CursorRecordTest.swift
//  kintone-ios-sdkTests
//
//  Created by Ho Kim Cuc on 8/15/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import XCTest
@testable import kintone_ios_sdk
@testable import Promises

class CreateCursorTest: XCTestCase {
    private var recordCursor: RecordCursor?
    
    override func setUp() {
        super.setUp()
        
        // set auth
        var auth = Auth()
        auth = auth.setPasswordAuth(TestsConstants.ADMIN_USERNAME, TestsConstants.ADMIN_PASSWORD)
        let conn = Connection(TestsConstants.DOMAIN, auth, -1)
        
        // instance of Cursor class
        self.recordCursor = Cursor(conn)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func getErrorMessage(_ error: Any) -> String {
        if error is KintoneAPIException {
            return (error as! KintoneAPIException).toString()!
        }
        else {
            return (error as! Error).localizedDescription
        }
    }
    
    func testCreateCursorSuccess() {
        self.recordCursor?.createCursor(RecordTestConstants.APP_ID, nil, nil, nil).then{ rsp in
            XCTAssert(type(of: rsp.getId()) == String.self)
            XCTAssert(type(of: rsp.getTotalCount()) == Int.self)
        }.catch{ error in
            var errorString = ""
            if (type(of: error) == KintoneAPIException.self) {
                errorString = (error as! KintoneAPIException).toString()!
            } else {
                errorString = error.localizedDescription
            }
            XCTFail(errorString)
        }
        XCTAssert(waitForPromises(timeout: 5))
    }
    
    func testCreateCursorFailWhenAppIdNotExist() {
        self.recordCursor?.createCursor(-214, nil, nil, nil).then{ rsp in
            XCTFail(self.getErrorMessage("CAN GET UNEXIST APP"))
        }.catch { error in
            XCTAssert(type(of: error) == KintoneAPIException.self)
        }
        XCTAssert(waitForPromises(timeout: 5))
    }
}

//
// kintone-ios-sdkTests
// Created on 8/19/19
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class GetRecordsByCursorTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let recordModule = Record(TestCommonHandling.createConnection())
        let cursorModule = Cursor(TestCommonHandling.createConnection())
        
        let appId = TestConstant.InitData.SPACE_APP_ID!
        let textField: String = TestConstant.InitData.TEXT_FIELD
        let queryOfCursor = "Created_by in (LOGINUSER()) and Created_datetime = TODAY() order by $id asc"
        var recordIds = [Int]()
        
        describe("GetRecordsByCursor") {
            it("AddTestData_BeforeSuiteWorkaround") {
                recordIds = RecordUtils.addRecords(recordModule, appId, 500, textField)
            }
            
            it("Test_035_Success_ValidRequest_GetRecordsByCursorId") {
                let sizeOfCursor = 10
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(sizeOfCursor).to(equal(getRecordCursorRsp.getRecords().count))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_036_Success_ValidRequest_GetRecordsIsCorrectly") {
                let sizeOfCursor = 10
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                let fieldCodeArray = Array(getRecordCursorRsp.getRecords()[0].keys)

                expect(fieldCodeArray.count).to(equal(1))
                expect(fieldCodeArray[0] as String).to(equal(textField))
                expect(getRecordCursorRsp.getRecords()).toNot(beNil())
                expect(getRecordCursorRsp.getNext()).toNot(beNil())
                expect(getRecordCursorRsp.getRecords().count).to(equal(sizeOfCursor))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_037_Success_ValidRequest_RecordDependentGetRecords") {
                let sizeOfCursor = 500
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                
                // Add new 100 record after created cursor
                let newRecordIds = RecordUtils.addRecords(recordModule, appId, 100, textField)
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(getRecordCursorRsp.getRecords()).toNot(beNil())
                expect(getRecordCursorRsp.getNext()).to(equal(false))
                expect(getRecordCursorRsp.getRecords().count).to(equal(sizeOfCursor))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
                RecordUtils.deleteRecords(recordModule, appId, newRecordIds)
            }
            
            it("Test_038_Success_ValidRequest_OrderOfRecord") {
                let sizeOfCursor = 250
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                let firstGetRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse

                expect(firstGetRecordCursorRsp.getRecords()).toNot(beNil())
                expect(firstGetRecordCursorRsp.getNext()).toNot(beNil())
                expect(firstGetRecordCursorRsp.getRecords().count).to(equal(sizeOfCursor))
                
                let secondGetRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(secondGetRecordCursorRsp.getRecords()).toNot(beNil())
                expect(secondGetRecordCursorRsp.getNext()).toNot(beNil())
                expect(secondGetRecordCursorRsp.getRecords().count).to(equal(sizeOfCursor))
                
                let thirdGetRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! KintoneAPIException
                
                let actualError = thirdGetRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_039_Error_GetRcordWithOtherUser") {
                let usernameHaveAllRecordPermission = TestConstant.Connection.CRED_USERNAME_HAVE_ALL_RECORD_PERMISSION
                let passwordHaveAllRecordPermission = TestConstant.Connection.CRED_PASSWORD_HAVE_ALL_RECORD_PERMISSION
                let cursorModuleOfOtherUser = Cursor(TestCommonHandling.createConnection(usernameHaveAllRecordPermission, passwordHaveAllRecordPermission))

                let sizeOfCursor = 250
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModuleOfOtherUser.getRecords(cursorId)) as! KintoneAPIException
                
                let actualError = getRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_040_Error_InvalidCursorId") {
                let nonexistentCursorId = String(TestConstant.Common.NONEXISTENT_ID)
                let negativeCursorId = String(TestConstant.Common.NEGATIVE_ID)
                let zeroCursorId = String(0)
            
                // Test with cursor id is nonexistent
                var getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(nonexistentCursorId)) as! KintoneAPIException
                
                var actualError = getRecordCursorRsp.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Test with cursor id is negative
                getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(negativeCursorId)) as! KintoneAPIException
                
                actualError = getRecordCursorRsp.getErrorResponse()
                expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Test with cursor id is zero
                getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(zeroCursorId)) as! KintoneAPIException
                
                actualError = getRecordCursorRsp.getErrorResponse()
                expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_043_Error_WithoutViewRecordsPermissionOnApp") {
                let usernameHaveAllRecordPermission = TestConstant.Connection.CRED_USERNAME_HAVE_ALL_RECORD_PERMISSION
                let passwordHaveAllRecordPermission = TestConstant.Connection.CRED_PASSWORD_HAVE_ALL_RECORD_PERMISSION
                let cursorModuleOfOtherUser = Cursor(TestCommonHandling.createConnection(usernameHaveAllRecordPermission, passwordHaveAllRecordPermission))
                let sizeOfCursor = 250
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModuleOfOtherUser.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                _updatePermissionOnApp(appModule, appId, false, false, false, false, false, false, false)
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModuleOfOtherUser.getRecords(cursorId)) as! KintoneAPIException
                
                let actualError = getRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _updatePermissionOnApp(appModule, appId, true, true, true, true, true, true, true)
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("Test_044_Error_WithoutViewRecordsPermissionOnRecord") {
                let usernameHaveAllRecordPermission = TestConstant.Connection.CRED_USERNAME_HAVE_ALL_RECORD_PERMISSION
                let passwordHaveAllRecordPermission = TestConstant.Connection.CRED_PASSWORD_HAVE_ALL_RECORD_PERMISSION
                let cursorModuleOfOtherUser = Cursor(TestCommonHandling.createConnection(usernameHaveAllRecordPermission, passwordHaveAllRecordPermission))
                
                let sizeOfCursor = 250
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModuleOfOtherUser.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                
                // Update permission of user on record
                var defaultUserRights = _getDefaultPermissionOfRecord()
                var updateUserRights = [RightEntity]()
                let user1Permission = RightEntity(entityId: 2, entityType: DevMemberType.USER, viewable: false, editable: false, deletable: false)
                updateUserRights.append(user1Permission)
                updateUserRights.append(contentsOf: defaultUserRights)
                
                var recordRights = RecordRightEntity(entities: updateUserRights)
                RecordUtils.updateRecordPermissions(appModule: appModule, appId: appId, rights: [recordRights])
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModuleOfOtherUser.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(getRecordCursorRsp.getRecords().count).to(equal(0))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
                recordRights = RecordRightEntity(entities: defaultUserRights)
                RecordUtils.updateRecordPermissions(appModule: appModule, appId: appId, rights: [recordRights])
            }
            
            it("Test_046_Error_WithoutViewRecordsPermission_ApiToken") {
                let apiToken = TestConstant.InitData.SPACE_APP_API_TOKEN
                let appApiTokenCursorModule = Cursor(TestCommonHandling.createConnection(apiToken))
                
                let sizeOfCursor = 250
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(appApiTokenCursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                
                var token = TokenEntity(
                    tokenString: apiToken,
                    viewRecord: false,
                    addRecord: false,
                    editRecord: false,
                    deleteRecord: false,
                    editApp: false)
                AppUtils.updateTokenPermission(appModule: appModule, appId: appId, token: token)
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(appApiTokenCursorModule.getRecords(cursorId)) as! KintoneAPIException
                
                let actualError = getRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                token = TokenEntity(
                    tokenString: apiToken,
                    viewRecord: true,
                    addRecord: true,
                    editRecord: true,
                    deleteRecord: true,
                    editApp: true)
                AppUtils.updateTokenPermission(appModule: appModule, appId: appId, token: token)
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("Test_047_Success_ValidRequest_GetRecordsByCursorId_GuestSpace") {
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let guestSpaceRecordModule = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                let guestSpaceCursorModule = Cursor(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                var recordGuestSpaceIds = [Int]()
                recordGuestSpaceIds = RecordUtils.addRecords(guestSpaceRecordModule, guestSpaceAppId, 500, textField)
                
                let sizeOfCursor = 10
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.createCursor(guestSpaceId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                let fieldCodeArray = Array(getRecordCursorRsp.getRecords()[0].keys)
                
                expect(fieldCodeArray.count).to(equal(1))
                expect(fieldCodeArray[0] as String).to(equal(textField))
                expect(getRecordCursorRsp.getRecords()).toNot(beNil())
                expect(getRecordCursorRsp.getNext()).toNot(beNil())
                expect(sizeOfCursor).to(equal(getRecordCursorRsp.getRecords().count))
                
                RecordUtils.deleteRecords(guestSpaceRecordModule, guestSpaceAppId, recordGuestSpaceIds)
                _ = TestCommonHandling.awaitAsync(guestSpaceCursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_048_Success_ValidRequest_LimitationIs500") {
                let sizeOfCursor = 500
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(sizeOfCursor).to(equal(getRecordCursorRsp.getRecords().count))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_049_Success_ValidRequest_LimitationIs500") {
                let newRecordIds = RecordUtils.addRecords(recordModule, appId, 500, textField)
                let sizeOfCursor = 500
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(getRecordCursorRsp.getNext()).to(equal(true))
                expect(sizeOfCursor).to(equal(getRecordCursorRsp.getRecords().count))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
                RecordUtils.deleteRecords(recordModule, appId, newRecordIds)
            }
            
            it("Test_050_Success_ValidRequest_StatusOfNextIsFalse") {
                let sizeOfCursor = 500
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(getRecordCursorRsp.getNext()).to(equal(false))
                expect(sizeOfCursor).to(equal(getRecordCursorRsp.getRecords().count))
            }
            
            it("Test_051_Success_ValidRequest_CursorIsDeleted") {
                let sizeOfCursor = 500
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                var getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(getRecordCursorRsp.getNext()).to(equal(false))
                
                let secondGetdRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! KintoneAPIException
                
                let actualError = secondGetdRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_052_053_Susscess_Combination") {
                let newRecordIds = RecordUtils.addRecords(recordModule, appId, 1500, textField)
                
                let sizeOfCursor = 500
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                var cursorId = addRecordCursorRsp.getId()
                
                // Get getRecords with cursor
                _ = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId))
                
                // Get getAllRecords with cursor
                _ = TestCommonHandling.awaitAsync(cursorModule.getAllRecords(cursorId))
                
                // Get getRecords with cursor
                let fistGetRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! KintoneAPIException
                
                let actualError = fistGetRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Add new cursor
                let sencondAddRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                cursorId = sencondAddRecordCursorRsp.getId()
                
                // Get getRecords with cursor
                let secondGetRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(true).to(equal(secondGetRecordCursorRsp.getNext()))
                expect(sizeOfCursor).to(equal(secondGetRecordCursorRsp.getRecords().count))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
                RecordUtils.deleteRecords(recordModule, appId, newRecordIds)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                RecordUtils.deleteRecords(recordModule, appId, recordIds)
            }
            
            func _getDefaultPermissionOfRecord () -> [RightEntity] {
                var defaultUserRights = [RightEntity]()
                let user4Permission = RightEntity(entityId: 5, entityType: DevMemberType.USER, viewable: true, editable: true, deletable: false)
                let user5Permission = RightEntity(entityId: 6, entityType: DevMemberType.USER, viewable: true, editable: false, deletable: true)
                let user6Permission = RightEntity(entityId: 7, entityType: DevMemberType.USER, viewable: true, editable: false, deletable: false)
                let everyonePermission = RightEntity(entityId: 7532782697181632513, entityType: DevMemberType.GROUP, viewable: true, editable: true, deletable: true)
                
                defaultUserRights.append(user4Permission)
                defaultUserRights.append(user5Permission)
                defaultUserRights.append(user6Permission)
                defaultUserRights.append(everyonePermission)
                
                return defaultUserRights
            }
            func _updatePermissionOnApp(
                _ appModule: App,
                _ appId: Int,
                _ appEditable: Bool,
                _ recordViewable: Bool,
                _ recordAddable: Bool,
                _ recordEditable: Bool,
                _ recordDeletable: Bool,
                _ recordImportable: Bool,
                _ recordExportable: Bool) {
                var rights = AppUtils.getAppPermissions(appId: appId)
                rights[0].setAppEditable(appEditable)
                rights[0].setRecordViewable(recordViewable)
                rights[0].setRecordAddable(recordAddable)
                rights[0].setRecordEditable(recordEditable)
                rights[0].setRecordDeletable(recordDeletable)
                rights[0].setRecordExportable(recordImportable)
                rights[0].setRecordImportable(recordExportable)
                
                _ = AppUtils.updateAppPermissions(appModule: appModule, appId: appId, rights: rights)
            }
        }
    }
}

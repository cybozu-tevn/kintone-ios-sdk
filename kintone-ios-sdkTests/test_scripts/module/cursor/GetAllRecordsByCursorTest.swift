//
// kintone-ios-sdkTests
// Created on 8/23/19
// 

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class GetAllRecordsByCursorTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let recordModule = Record(TestCommonHandling.createConnection())
        let cursorModule = Cursor(TestCommonHandling.createConnection())
        
        let appId = TestConstant.InitData.SPACE_APP_ID!
        let textField: String = TestConstant.InitData.TEXT_FIELD
        let queryOfCursor = "Created_by in (LOGINUSER()) and Created_datetime = TODAY() order by $id asc"
        var recordIds = [Int]()
        
        describe("GetAllRecordsByCursor") {
            it("AddTestData_BeforeSuiteWorkaround") {
                recordIds = RecordUtils.addRecords(recordModule, appId, 500, textField)
            }
            
            it("Test_054_ValidRequest_GetRecordsByCursorId") {
                let sizeOfCursor = 100
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                let totalCount = addCursorRsp.getTotalCount()
                let getRecordsRsp = TestCommonHandling.awaitAsync(cursorModule.getAllRecords(cursorId)) as! GetRecordsResponse
                
                expect(getRecordsRsp.getRecords()).toNot(beNil())
                expect(getRecordsRsp.getTotalCount()).to(equal(totalCount))
            }
            
           it("Test_055_Success_ValidRequest_GetRecordsIsCorrectly") {
                let sizeOfCursor = 100
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                let totalCount = addCursorRsp.getTotalCount()

                let getRecordsRsp = TestCommonHandling.awaitAsync(cursorModule.getAllRecords(cursorId)) as! GetRecordsResponse
                let fieldCodeArray = Array(getRecordsRsp.getRecords()![0].keys)
                
                expect(fieldCodeArray.count).to(equal(1))
                expect(fieldCodeArray[0] as String).to(equal(textField))
                expect(getRecordsRsp.getRecords()).toNot(beNil())
                expect(getRecordsRsp.getTotalCount()).to(equal(totalCount))
            }
            
            it("Test_056_Success_ValidRequest_RecordDependentGetAllRecords") {
                let sizeOfCursor = 500
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                let totalCount = addCursorRsp.getTotalCount()

                // Add new 100 record after created cursor
                let newRecordIds = RecordUtils.addRecords(recordModule, appId, 100, textField)
                
                let getRecordsRsp = TestCommonHandling.awaitAsync(cursorModule.getAllRecords(cursorId)) as! GetRecordsResponse

                expect(getRecordsRsp.getRecords()).toNot(beNil())
                expect(getRecordsRsp.getTotalCount()).to(equal(totalCount))
                
                RecordUtils.deleteRecords(recordModule, appId, newRecordIds)
            }
            
            it("Test_057_Error_CanNotGetRecordByOtherUser") {
                let username = TestConstant.Connection.CRED_USERNAME_HAVE_ALL_RECORD_PERMISSION
                let password = TestConstant.Connection.CRED_PASSWORD_HAVE_ALL_RECORD_PERMISSION
                let cursorModuleOfOtherUser = Cursor(TestCommonHandling.createConnection(username, password))
                
                let sizeOfCursor = 100
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                let getRecordsRsp = TestCommonHandling.awaitAsync(cursorModuleOfOtherUser.getAllRecords(cursorId)) as! KintoneAPIException
                
                let actualError = getRecordsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("Test_058_Error_InvalidCursorId") {
                let nonexistentCursorId = String(TestConstant.Common.NONEXISTENT_ID)
                let negativeCursorId = String(TestConstant.Common.NEGATIVE_ID)
                let zeroCursorId = String(0)
                
                // Get all record with cursor id is nonexistent
                var getRecordsRsp = TestCommonHandling.awaitAsync(cursorModule.getAllRecords(nonexistentCursorId)) as! KintoneAPIException

                var actualError = getRecordsRsp.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Get all record with cursor id is negative
                getRecordsRsp = TestCommonHandling.awaitAsync(cursorModule.getAllRecords(negativeCursorId)) as! KintoneAPIException

                actualError = getRecordsRsp.getErrorResponse()
                expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Get all record with cursor id is zero
                getRecordsRsp = TestCommonHandling.awaitAsync(cursorModule.getAllRecords(zeroCursorId)) as! KintoneAPIException

                actualError = getRecordsRsp.getErrorResponse()
                expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_061_Error_WithoutViewRecordsPermissionOnApp") {
                let usernameHasAllRecordPermission = TestConstant.Connection.CRED_USERNAME_HAVE_ALL_RECORD_PERMISSION
                let passwordHasAllRecordPermission = TestConstant.Connection.CRED_PASSWORD_HAVE_ALL_RECORD_PERMISSION
                let cursorModuleHasAllRecordPermission = Cursor(TestCommonHandling.createConnection(
                    usernameHasAllRecordPermission,
                    passwordHasAllRecordPermission))
                
                let sizeOfCursor = 500
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModuleHasAllRecordPermission.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addRecordCursorRsp.getId()
                
                // Deny all permission
                _updatePermissionOnApp(appModule, appId, false, false, false, false, false, false, false)

                let getRecordsRsp = TestCommonHandling.awaitAsync(cursorModuleHasAllRecordPermission.getAllRecords(cursorId)) as! KintoneAPIException

                let actualError = getRecordsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _updatePermissionOnApp(appModule, appId, true, true, true, true, true, true, true)
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("Test_062_Error_WithoutViewRecordsPermissionOnRecord") {
                let usernameHasAllRecordPermission = TestConstant.Connection.CRED_USERNAME_HAVE_ALL_RECORD_PERMISSION
                let passwordHasAllRecordPermission = TestConstant.Connection.CRED_PASSWORD_HAVE_ALL_RECORD_PERMISSION
                let cursorModuleHasAllRecordPermission = Cursor(TestCommonHandling.createConnection(usernameHasAllRecordPermission, passwordHasAllRecordPermission))
                
                let sizeOfCursor = 250
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModuleHasAllRecordPermission.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                // Deny all permission of user
                let defaultUserRights = _getDefaultPermissionOfRecord()
                var updateUserRights = [RightEntity]()
                let user1 = DevMemberEntity(DevMemberType.USER, "user1")
                let user1Permission = RightEntity(entity: user1, viewable: false, editable: false, deletable: false)
                updateUserRights.append(user1Permission)
                updateUserRights.append(contentsOf: defaultUserRights)
                
                var recordRights = RecordRightEntity(entities: updateUserRights)
                RecordUtils.updateRecordPermissions(appModule: appModule, appId: appId, rights: [recordRights])
                
                let getRecordsRsp = TestCommonHandling.awaitAsync(cursorModuleHasAllRecordPermission.getAllRecords(cursorId)) as! GetRecordsResponse
                
                expect(getRecordsRsp.getTotalCount()).to(equal(0))
                
                recordRights = RecordRightEntity(entities: defaultUserRights)
                RecordUtils.updateRecordPermissions(appModule: appModule, appId: appId, rights: [recordRights])
                _ = TestCommonHandling.awaitAsync(cursorModuleHasAllRecordPermission.deleteCursor(cursorId))
            }
            
            it("Test_064_Error_WithoutViewRecordsPermission_ApiToken") {
                let apiToken = TestConstant.InitData.SPACE_APP_API_TOKEN
                let appApiTokenCursorModule = Cursor(TestCommonHandling.createConnection(apiToken))
                
                let sizeOfCursor = 250
                let addCursorRsp = TestCommonHandling.awaitAsync(appApiTokenCursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                var token = TokenEntity(
                    tokenString: apiToken,
                    viewRecord: false,
                    addRecord: false,
                    editRecord: false,
                    deleteRecord: false,
                    editApp: false)
                AppUtils.updateTokenPermission(appModule: appModule, appId: appId, token: token)
                
                let getRecordsRsp = TestCommonHandling.awaitAsync(appApiTokenCursorModule.getAllRecords(cursorId)) as! KintoneAPIException
                
                let actualError = getRecordsRsp.getErrorResponse()
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
                _ = TestCommonHandling.awaitAsync(appApiTokenCursorModule.deleteCursor(cursorId))
            }
            
            it("Test_065_Success_ValidRequest_GetRecordsByCursorId_GuestSpace") {
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
                var guestSpaceRecordIds = [Int]()
                guestSpaceRecordIds = RecordUtils.addRecords(guestSpaceRecordModule, guestSpaceAppId, 500, textField)
                
                let sizeOfCursor = 250
                let addCursorRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.createCursor(guestSpaceId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                let totalCount = addCursorRsp.getTotalCount()

                let getRecordsRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.getAllRecords(cursorId)) as! GetRecordsResponse
                let fieldCodeArray = Array(getRecordsRsp.getRecords()![0].keys)
                
                expect(fieldCodeArray.count).to(equal(1))
                expect(fieldCodeArray[0] as String).to(equal(textField))
                expect(getRecordsRsp.getRecords()).toNot(beNil())
                expect(getRecordsRsp.getTotalCount()).to(equal(totalCount))
                
                RecordUtils.deleteRecords(guestSpaceRecordModule, guestSpaceAppId, guestSpaceRecordIds)
            }
            
            // Because of this case spend a lot of time, so we will skip it
            // And please set PROMISE_TIMEOUT = 60.0 when run it.
            xit("Test_066_Success_PerformanceWith15000Records") {
                let newRecordIds = RecordUtils.addRecords(recordModule, appId, 15000, textField)
                recordIds.append(contentsOf: newRecordIds)
                
                let sizeOfCursor = 500
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                let totalCount = addCursorRsp.getTotalCount()
                
                let getRecordsRsp = TestCommonHandling.awaitAsync(cursorModule.getAllRecords(cursorId)) as! GetRecordsResponse
                
                expect(getRecordsRsp.getRecords()).toNot(beNil())
                expect(getRecordsRsp.getTotalCount()).to(equal(totalCount))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                RecordUtils.deleteRecords(recordModule, appId, recordIds)
            }
            
            func _getDefaultPermissionOfRecord () -> [RightEntity] {
                var defaultUserRights = [RightEntity]()
                let user4 = DevMemberEntity(DevMemberType.USER, "user4")
                let user5 = DevMemberEntity(DevMemberType.USER, "user5")
                let user6 = DevMemberEntity(DevMemberType.USER, "user6")
                let everyone = DevMemberEntity(DevMemberType.GROUP, "everyone")
                let user4Permission = RightEntity(entity: user4, viewable: true, editable: true, deletable: false)
                let user5Permission = RightEntity(entity: user5, viewable: true, editable: false, deletable: true)
                let user6Permission = RightEntity(entity: user6, viewable: true, editable: false, deletable: false)
                let everyonePermission = RightEntity(entity: everyone, viewable: true, editable: true, deletable: true)
                
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

//
//  UpdateRecordStatusTest.swift
//  kintone-ios-sdkTests
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class UpdateRecordStatusTest: QuickSpec {
    /**
     * Initial app with process management
     * Actions     |  Status After Action Taken
     * ------------|------------------------------
     *  Start      |  In progress -> One assignee in the list must take action
     *             |                    (user1, user2, cybozu, Administrator)
     *  Test       |  Testing     -> User chooses on assignee from the list to take action
     *             |                    (user1, cybozu)
     *  Review     |  Reviewing   -> All assignees in the list must take action
     *             |                    (user1, user2, cybozu)
     *  Complete   |  Completed
     */
    override func spec() {
        let appId = TestConstant.InitData.APP_ID_HAS_PROCESS!
        let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let textField: String! = TestConstant.InitData.TEXT_FIELD
        var recordId: Int!
        var revision: Int!
        let startAction = TestConstant.InitData.ACTION_START
        let testAction = TestConstant.InitData.ACTION_TEST
        let reviewAction = TestConstant.InitData.ACTION_REVIEW
        let completeAction = TestConstant.InitData.ACTION_COMPLETE
        let inProgressStatus = TestConstant.InitData.STATE_IN_PROGRESS
        let testingStatus = TestConstant.InitData.STATE_TESTING
        let reviewingStatus = TestConstant.InitData.STATE_REVIEWING
        let completedStatus = TestConstant.InitData.STATE_COMPLETED
        
        let recordModule = Record(TestCommonHandling.createConnection())
        
        // ---------------- NORMAL SPACE
        describe("UpdateRecordStatus_1") {
            beforeEach {
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let addRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                revision = addRecordResponse.getRevision()
            }
            
            afterEach {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId]))
            }
            
            it("Test_176_180_Success_StatusOnly") {
                // cybozu updates status: Start action -> In progress status
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                expect(updateRecordResponse.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_177_Success_StatusAndAssignee") {
                // Update record status
                // 1. cybozu updates status: Start action -> In progress status
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil))
                revision = revision + 2
                
                // 2. cybozu updates status: Test action + assignee (user1) -> Testing status
                let assignee = TestConstant.InitData.USERS[0]
                var updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, testAction, assignee.username, nil)) as! UpdateRecordResponse
                revision = revision + 2
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                var recordData = getRecordResponse.getRecord()!
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(testingStatus))
                
                // 3. assignee (user1) updates status: Review action -> Reviewing status
                let recordModuleUser1 = Record(TestCommonHandling.createConnection(
                    assignee.username, assignee.password))
                updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleUser1.updateRecordStatus(appId, recordId, reviewAction, nil, nil)) as! UpdateRecordResponse
                revision = revision + 2
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
            }
            
            it("Test_178_Error_NotAssigneeChangeStatus") {
                // Update record status
                // 1. cybozu updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil))
                
                // 2. cybozu updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, testAction, assignee.username, nil))
                
                // 3. non-assignee (user2) updates status: Review action
                let notAssignee = TestConstant.InitData.USERS[1]
                let recordModuleUser2 = Record(TestCommonHandling.createConnection(
                    notAssignee.username, notAssignee.password))
                let result = TestCommonHandling.awaitAsync(
                    recordModuleUser2.updateRecordStatus(appId, recordId, reviewAction, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.NOT_ASSIGNEE_CHANGE_STATUS_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            //
            //            it("Test_179_LocalizationStatus_JA") {
            //                // Change language of user to JA => this is currently MANUAL
            //                //        let STATUS_JA = "In progress JA"
            //                //        let ACTION_JA = "Start JA"
            //                //        let updateRecordResponse = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(AppId, recordId, ACTION_JA, nil, nil)) as! UpdateRecordResponse
            //                //
            //                //        // Revision is increased by 2: execute Action + change status
            //                //        expect(updateRecordResponse.getRevision()).to(equal(revision + 2))
            //                //
            //                //        // Status is changed is added
            //                //        let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
            //                //        let resultData:  Dictionary<String, FieldValue> = getRecordResponse.getRecord()!
            //                //
            //                //        expect(resultData["Status"]?.getValue() as? String).to(equal(STATUS_JA))
            //            }
            //
            //            it("Test_179_LocalizationStatus_ZH") {
            //                // Change language of user to ZH => this is currently MANUAL
            //                //        let STATUS_ZH = "In progress ZH"
            //                //        let ACTION_ZH = "Start ZH"
            //                //        let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(AppId, recordId, ACTION_ZH, nil, nil)) as! UpdateRecordResponse
            //                //
            //                //        // Revision is increased by 2: execute Action + change status
            //                //        expect(result.getRevision()).to(equal(revision + 2))
            //                //
            //                //        // Status is changed is added
            //                //        let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
            //                //        let resultData:  Dictionary<String, FieldValue> = getRecordResponse.getRecord()!
            //                //
            //                //        expect(resultData["Status"]?.getValue() as? String).to(equal(STATUS_ZH))
            //            }
            //
            //            it("Test_179_LocalizationStatus_EN") {
            //                // Change language of user to EN => this is currently MANUAL
            //                //        let STATUS_EN = "In progress EN"
            //                //        let ACTION_EN = "Start EN"
            //                //        let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(AppId, recordId, ACTION_EN, nil, nil)) as! UpdateRecordResponse
            //                //
            //                //        // Revision is increased by 2: execute Action + change status
            //                //        expect(result.getRevision()).to(equal(revision + 2))
            //                //
            //                //        // Status is changed is added
            //                //        let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
            //                //        let resultData:  Dictionary<String, FieldValue> = getRecordResponse.getRecord()!
            //                //
            //                //        expect(resultData["Status"]?.getValue() as? String).to(equal(STATUS_EN))
            //            }
            //
            it("Test_181_Error_ChangeStatusWithoutAsssignee") {
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil))
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, testAction, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.MISSING_ASSIGNEE_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_182_Error_ChangeStatusWithAssigneeForStartAction") {
                let assignee = TestConstant.InitData.USERS[1]
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, assignee.username, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.UNSPECIFIED_ASSIGNEE_UPDATED_STATUS_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_183_Error_InvalidAction") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, "Invalid_action", nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.INVALID_STATUS_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_185_Error_NonexistentAssignee") {
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil))
                let nonexistentUser = "nonexistent user blah blah"
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, testAction, nonexistentUser, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_USER_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: nonexistentUser)
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_186_Error_InvalidRevision") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, 9999)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_187_Success_DefaultRevision") {
                let defaultRevision = -1
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, defaultRevision)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                expect(updateRecordResponse.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_188_Error_RecordHasAssignee") {
                // same with 178
            }
            
            it("Test_189_Success_RecordHasAssignee") {
                // 1. cybozu updates status: Start action
                var updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                var recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
                
                // 2. cybozu updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, testAction, assignee.username, nil)) as! UpdateRecordResponse
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(testingStatus))
                
                // 3. user1 updates status: Review action
                let recordModuleUser1 = Record(TestCommonHandling.createConnection(
                    assignee.username, assignee.password))
                updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleUser1.updateRecordStatus(appId, recordId, reviewAction, nil, nil)) as! UpdateRecordResponse
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
                
                // 3. all users (cybozu, user1, user2) update status: Complete action
                // 3.1. updated by user user1
                updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleUser1.updateRecordStatus(appId, recordId, completeAction, nil, nil)) as! UpdateRecordResponse
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
                
                // 3.2. updated by user user2
                let user2 = TestConstant.InitData.USERS[1]
                let recordModuleUser2 = Record(TestCommonHandling.createConnection(
                    user2.username, user2.password))
                updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleUser2.updateRecordStatus(appId, recordId, completeAction, nil, nil)) as! UpdateRecordResponse
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
                
                // 3.3. updated by user cybozu
                updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, completeAction, nil, nil)) as! UpdateRecordResponse
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(completedStatus))
            }
            
            it("Test_190_Error_NoPermissionApp") {
                let recordModuleWithoutPermissionApp = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermissionApp.updateRecordStatus(
                        appId, recordId, startAction, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_191_Error_NoPermissionRecord") {
                let recordModuleWithoutPermissionRecord = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermissionRecord.updateRecordStatus(
                        appId, recordId, startAction, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_192_Success_NoPermissionField") {
                let recordModuleWithoutPermissionField = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermissionField.updateRecordStatus(
                        appId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                expect(updateRecordResponse.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_193_Error_InvalidAppID") {
                // nonexistent appID
                var result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(TestConstant.Common.NONEXISTENT_ID, recordId, startAction, nil, nil)) as! KintoneAPIException
                var errorMessage = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                errorMessage.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(result.getErrorResponse(), errorMessage)
                
                // negative appID
                result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(-1, recordId, startAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
                
                // zero appID
                result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(0, recordId, startAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
            }
            
            //            it("Test_194_Error_MissingAppID") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(nil, recordId, startAction, nil, nil))
            //            }
            //
            //            it("Test_195_Error_MissingRecordID") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(1, nil, startAction, nil, nil))
            //            }
            //
            //            it("Test_196_Error_MissingAssignees") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(1, recordId, nil, nil, nil))
            //            }
            //
            //            it("Test_198_Error_InvalidInputType") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus("9", recordId, assignee, nil, nil))
            //            }
            
            //            it("Test_199_Error_DisableProcessManagement") {
            //                // Currently the process management must be disabled by MANUAL
            //                // -> You should set break point here, then disable process management by manual
            //                let result = TestCommonHandling.awaitAsync(
            //                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil)) as! KintoneAPIException
            //
            //                let actualError = result.getErrorResponse()
            //                let expectedError = KintoneErrorParser.PROCESS_MANAGEMENT_DISABLED_ERROR()!
            //                TestCommonHandling.compareError(actualError, expectedError)
            //            }
        }
        
        // ---------------- GUEST SPACE
        describe("UpdateRecordStatus_2") {
            let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                TestConstant.Connection.CRED_ADMIN_USERNAME,
                TestConstant.Connection.CRED_ADMIN_PASSWORD,
                TestConstant.InitData.GUEST_SPACE_ID!))
            
            beforeEach {
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let addRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.addRecord(guestSpaceAppId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                revision = addRecordResponse.getRevision()
            }
            
            afterEach {
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.deleteRecords(guestSpaceAppId, [recordId]))
            }
            
            it("Test_176_Success_StatusOnly_GuestSpace") {
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                expect(updateRecordResponse.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_177_Success_StatusAndAssignee_GuestSpace") {
                // 1. cybozu updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, nil))
                revision = revision + 2
                
                // 2. cybozu updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                var updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, testAction, assignee.username, nil)) as! UpdateRecordResponse
                revision = revision + 2
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                var recordData = getRecordResponse.getRecord()!
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(testingStatus))
                
                // 3. user1 updates status: Review action
                let conn = TestCommonHandling.createConnection(assignee.username, assignee.password, TestConstant.InitData.GUEST_SPACE_ID!)
                let recordModuleGuestSpaceUser1 = Record(conn)
                updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpaceUser1.updateRecordStatus(guestSpaceAppId, recordId, reviewAction, nil, nil)) as! UpdateRecordResponse
                revision = revision + 2
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
            }
            
            it("Test_178_Error_NotAssigneeChangeStatus_GuestSpace") {
                // 1. cybozu updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, nil))
                
                // 2. cybozu updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, testAction, assignee.username, nil))
                
                // 3. non-assignee (user2) updates status: Review action
                let user2 = TestConstant.InitData.USERS[1]
                let conn = TestCommonHandling.createConnection(user2.username, user2.password, TestConstant.InitData.GUEST_SPACE_ID!)
                let recordModuleGuestSpaceUser2 = Record(conn)
                let result = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpaceUser2.updateRecordStatus(guestSpaceAppId, recordId, reviewAction, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.NOT_ASSIGNEE_CHANGE_STATUS_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_181_Error_ChangeStatusWithoutAsssignee_GuestSpace") {
                // 1. cybozu updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, nil))
                
                // 2. cybozu updates status: Test action + without assignee
                let result = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, testAction, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.MISSING_ASSIGNEE_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_187_Success_DefaultRevision_GuestSpace") {
                // Update record status
                let defaultRevision = -1
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, defaultRevision)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                expect(updateRecordResponse.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
        }
        
        // ---------------- API TOKEN
        describe("UpdateRecordStatus_3") {
            let recordModuleAPIToken = Record(TestCommonHandling.createConnection(TestConstant.InitData.APP_WITH_PROCESS_API_TOKEN))
            
            beforeEach {
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let addRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.addRecord(appId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                revision = addRecordResponse.getRevision()
            }
            
            afterEach {
                _ = TestCommonHandling.awaitAsync(
                    recordModule.deleteRecords(appId, [recordId]))
            }
            
            it("Test_176_Success_StatusOnly_APIToken") {
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(appId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                expect(updateRecordResponse.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_177_Success_StatusAndAssignee_APIToken") {
                // 1. Updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(appId, recordId, startAction, nil, nil))
                revision = revision + 2
                
                // 2. Updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                var updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(appId, recordId, testAction, assignee.username, nil)) as! UpdateRecordResponse
                revision = revision + 2
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.getRecord(appId, recordId)) as! GetRecordResponse
                var recordData = getRecordResponse.getRecord()!
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(testingStatus))
                
                // 3. user1 updates status: Review action
                // This step confirms that the update status with assignee from above step is reflected, and user1 can process this step normally
                let recordModuleUser1 = Record(TestCommonHandling.createConnection(
                    assignee.username, assignee.password))
                updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleUser1.updateRecordStatus(appId, recordId, reviewAction, nil, nil)) as! UpdateRecordResponse
                revision = revision + 2
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
            }
            
            it("Test_178_Error_NotAssigneeChangeStatus_APIToken") {
                // 1. cybozu updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(appId, recordId, startAction, nil, nil))
                
                // 2. cybozu updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, testAction, assignee.username, nil))
                
                // 3. non-assignee (in this case, API Token is presented for Administrator user who is non-assignee) updates status: Review action
                let result = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(appId, recordId, reviewAction, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.NOT_ASSIGNEE_CHANGE_STATUS_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_181_Error_ChangeStatusWithoutAsssignee_APIToken") {
                _ = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(appId, recordId, startAction, nil, nil))
                let result = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(appId, recordId, testAction, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.MISSING_ASSIGNEE_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_187_Success_DefaultRevision_APIToken") {
                let defaultRevision = -1
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(appId, recordId, startAction, nil, defaultRevision)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                expect(updateRecordResponse.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
        }
    }
}

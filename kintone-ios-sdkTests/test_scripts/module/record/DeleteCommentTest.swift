//
// kintone-ios-sdkTests
// Created on 6/12/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class DeleteCommentTest: QuickSpec {
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        let appId: Int = TestConstant.InitData.SPACE_APP_ID!
        let guestSpaceId: Int = TestConstant.InitData.GUEST_SPACE_ID!
        let guestSpaceAppId: Int = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let noneExistentId = TestConstant.Common.NONEXISTENT_ID
        var recordId: Int!
        var commentId: Int!
        
        // Comment Data
        let mentionCode: String = "cybozu"
        let mentionType: String = "USER"
        let commentContent: String = DataRandomization.generateString(prefix: "DeleteComment", length: 10)
        var mention: CommentMention!
        var comment: CommentContent!
        var mentionList = [CommentMention]()
        let addData: Dictionary<String, FieldValue> = [:]
        
        describe("DeleteComment") {
            it("AddTestData_BeforeSuiteWorkaround") {
                // Add record to contains comments
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, addData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                
                mention = CommentMention()
                mention.setCode(mentionCode)
                mention.setType(mentionType)
                mentionList.append(mention)
                
                comment = CommentContent()
                comment.setText(commentContent)
                comment.setMentions(mentionList)
            }

            it("Test_256_Success_ValidData") {
                let addCommentResponse = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment)) as! AddCommentResponse
                commentId = addCommentResponse.getId()
                _ = TestCommonHandling.awaitAsync(recordModule.deleteComment(appId, recordId, commentId))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
            }
            
            it("Test_256_Success_ValidData_GuestSpace") {
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(guestSpaceAppId, addData)) as! AddRecordResponse
                let recordGuestSpaceId = addRecordGuestSpaceResponse.getId()!
                
                let addCommentRsp = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(
                    guestSpaceAppId,
                    recordGuestSpaceId,
                    comment)) as! AddCommentResponse
                commentId = addCommentRsp.getId()!
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteComment(guestSpaceAppId, recordGuestSpaceId, commentId))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(guestSpaceAppId, [recordGuestSpaceId]))
            }
            
            it("Test_256_Success_ValidData_ApiToken") {
                let apiToken: String = TestConstant.InitData.SPACE_APP_API_TOKEN
                let recordModuleApiToken = Record(TestCommonHandling.createConnection(apiToken))
                let addCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(appId, recordId, comment)) as! AddCommentResponse
                commentId = addCommentResponse.getId()
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.deleteComment(appId, recordId, commentId))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
            }
            
            it("Test_257_Error_InvalidCommentId") {
                let result = TestCommonHandling.awaitAsync(recordModule.deleteComment(appId, recordId, noneExistentId)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_COMMENT_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_258_Error_NoPermissionForApp") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(appId, recordId, commentId)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_259_Error_NoPermissionForRecord") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(appId, recordId, commentId)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_260_Error_NoPermissionForField") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                let addCommentResponse = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(appId, recordId, comment)) as! AddCommentResponse
                commentId = addCommentResponse.getId()
                _ = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(appId, recordId, commentId))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
            }
            
            it("Test_261_Error_InvalidAppId") {
                let result = TestCommonHandling.awaitAsync(recordModule.deleteComment(noneExistentId, recordId, commentId)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_262_Error_InvalidRecordId") {
                let result = TestCommonHandling.awaitAsync(recordModule.deleteComment(appId, noneExistentId, commentId)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_269_Error_DeleteOtherUserComment") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                let addCommentResponse = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment)) as! AddCommentResponse
                commentId = addCommentResponse.getId()
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(appId, recordId, commentId)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.DELETE_OTHER_USER_COMMENT_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(commentId))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId]))
            }
        }
    }
}

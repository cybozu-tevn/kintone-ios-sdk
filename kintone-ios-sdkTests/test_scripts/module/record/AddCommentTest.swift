//
// kintone-ios-sdkTests
// Created on 6/12/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class AddCommentTest: QuickSpec {
    override func spec() {
        let appId: Int = TestConstant.InitData.SPACE_APP_ID!
        let nonexistentId = TestConstant.Common.NONEXISTENT_ID
        let apiToken: String = TestConstant.InitData.SPACE_APP_API_TOKEN
        var recordId: Int!
        
        // Comment Data
        let mentionUserCode: String = "cybozu"
        let mentionUserType: String = "USER"
        let commentContent: String = DataRandomization.generateString(prefix: "AddComment", length: 10)
        var mentionUser = CommentMention()
        var comment: CommentContent!
        
        let recordModule = Record(TestCommonHandling.createConnection())
        
        describe("AddComment_1") {
            beforeSuite {
                // Add record
                let addData: Dictionary<String, FieldValue> = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, addData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                mentionUser = CommentMention()
                mentionUser.setCode(mentionUserCode)
                mentionUser.setType(mentionUserType)
            }
            
            afterSuite {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId]))
            }
            
            beforeEach {
                // Set comment text
                comment = CommentContent()
                comment.setText(commentContent)
            }
            
            it("Test_236_Success_ValidData") {
                // Get and count existing comments
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                
                // Set and add comment content with mention
                let mentionList = [mentionUser]
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                // Verify total comment and the added comment content (comment text and mention)
                expect(totalComment + 1).to(equal(result.getComments()?.count))
                expect(mentionUserCode + " \n" + commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(result.getComments()?[0].getCreator()?.code))
                let actualMentions = result.getComments()?[0].getMentions()
                for user in actualMentions! {
                    expect(mentionUserCode).to(equal(user.getCode()))
                    expect(mentionUserType).to(equal(user.getType()))
                }
                
                // Verify record revision is not increased
                let resultRecord = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))
            }
            
            it("Test_237_Success_SpecialCharacter") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?[0].getText()).to(equal(commentSpecialChars + " "))
            }
            
            it("Test_238_Success_MentionMultiUsers") {
                let mentionUser = CommentMention()
                mentionUser.setCode(mentionUserCode)
                mentionUser.setType(mentionUserType)
                
                let mentionDept = CommentMention()
                mentionDept.setCode(TestConstant.InitData.DEPARTMENT_CODE)
                mentionDept.setType(TestConstant.InitData.DEPARTMENT_TYPE)
                
                let mentionGroup = CommentMention()
                mentionGroup.setCode(TestConstant.InitData.GROUP_CODE)
                mentionGroup.setType(TestConstant.InitData.GROUP_TYPE)
                
                let mentionList = [mentionUser, mentionDept, mentionGroup]
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                let actualMentions = result.getComments()?[0].getMentions()
                expect(actualMentions?[0].getCode()).to(equal(mentionUserCode))
                expect(actualMentions?[0].getType()).to(equal(mentionUserType))
                expect(actualMentions?[1].getCode()).to(equal(TestConstant.InitData.DEPARTMENT_CODE))
                expect(actualMentions?[1].getType()).to(equal(TestConstant.InitData.DEPARTMENT_TYPE))
                expect(actualMentions?[2].getCode()).to(equal(TestConstant.InitData.GROUP_CODE))
                expect(actualMentions?[2].getType()).to(equal(TestConstant.InitData.GROUP_TYPE))
            }
            
            it("Test_240_Success_NoMention") {
                comment.setMentions(nil)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                let mentionResult = result.getComments()?[0].getMentions()
                expect(0).to(equal(mentionResult?.count))
                expect(commentContent + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            it("Test_241_Error_BlankContent") {
                comment = CommentContent()
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_COMMENT_TEXT_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: String("text"))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_242_Error_NonexistentMentionUser") {
                let mentionInvalidUser = CommentMention()
                mentionInvalidUser.setCode("NONEXISTENT_USER")
                mentionInvalidUser.setType(mentionUserType)
                let mentionList = [mentionInvalidUser]
                comment.setMentions(mentionList)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_USER_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String("NONEXISTENT_USER"))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_243_Error_NoPermissionForApp") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(appId, recordId, comment)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_244_Error_NoPermissionForRecord") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(appId, recordId, comment)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_245_Success_NoPermissionForField") {
                let mentionList = [mentionUser]
                comment.setMentions(mentionList)
                
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                _ = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                expect(mentionUserCode + " \n" + commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION).to(equal(result.getComments()?[0].getCreator()?.code))
            }
            
            it("Test_246_Error_InvalidAppId") {
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(nonexistentId, recordId, comment)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(nonexistentId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_247_Error_InvalidRecordId") {
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(appId, nonexistentId, comment)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(nonexistentId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_255_Success_MentionInactiveUserDepartmentGroup") {
                let mentionInactiveUser = CommentMention()
                mentionInactiveUser.setCode(TestConstant.Connection.CRED_USERNAME_INACTIVE)
                mentionInactiveUser.setType(mentionUserType)
                let mentionList = [mentionInactiveUser]
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                let mentionResult = result.getComments()?[0].getMentions()
                expect(mentionResult?[0].getCode()).to(equal(TestConstant.Connection.CRED_USERNAME_INACTIVE))
                expect(mentionResult?[0].getType()).to(equal(mentionUserType))
            }
            
        }
        
        // GUEST SPACE
        describe("AddComment_2") {
            var recordGuestSpaceId: Int!
            let guestSpaceId: Int = TestConstant.InitData.GUEST_SPACE_ID!
            let appGuestSpaceId: Int = TestConstant.InitData.GUEST_SPACE_APP_ID!
            let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                TestConstant.Connection.CRED_ADMIN_USERNAME,
                TestConstant.Connection.CRED_ADMIN_PASSWORD,
                guestSpaceId))
            
            beforeSuite {
                // Add record
                let addData: Dictionary<String, FieldValue> = [:]
                let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(appGuestSpaceId, addData)) as! AddRecordResponse
                recordGuestSpaceId = addRecordGuestSpaceResponse.getId()
            }
            
            afterSuite {
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(appGuestSpaceId, [recordGuestSpaceId]))
            }
            
            beforeEach {
                comment = CommentContent()
                comment.setText(commentContent)
            }
            
            it("Test_236_Success_ValidData_GuestSpace") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(appGuestSpaceId, recordGuestSpaceId, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                
                let mentionList = [mentionUser]
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(appGuestSpaceId, recordGuestSpaceId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(appGuestSpaceId, recordGuestSpaceId, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(totalComment + 1).to(equal(result.getComments()?.count))
                expect(mentionUserCode + " \n" + commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(result.getComments()?[0].getCreator()?.code))
                let mentionResult = result.getComments()?[0].getMentions()
                for user in mentionResult! {
                    expect(mentionUserCode).to(equal(user.getCode()))
                    expect(mentionUserType).to(equal(user.getType()))
                }
                
                // Revision is not increased
                let resultRecord = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(appGuestSpaceId, recordGuestSpaceId)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))
            }
            
            it("Test_237_Success_SpecialCharacter_GuestSpace") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(appGuestSpaceId, recordGuestSpaceId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(appGuestSpaceId, recordGuestSpaceId, nil, nil, nil)) as! GetCommentsResponse
                
                expect(commentSpecialChars + " ").to(equal(result.getComments()?[0].getText()))
                
            }
            
            it("Test_240_Success_NoMention_GuestSpace") {
                comment.setMentions(nil)
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(appGuestSpaceId, recordGuestSpaceId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(appGuestSpaceId, recordGuestSpaceId, nil, nil, nil)) as! GetCommentsResponse
                
                let mentionResult = result.getComments()?[0].getMentions()
                expect(0).to(equal(mentionResult?.count))
                expect(commentContent + " ").to(equal(result.getComments()?[0].getText()))
            }
        }
        
        // API TOKEN
        describe("AddComment_3") {
            beforeEach {
                comment = CommentContent()
                comment.setText(commentContent)
            }
            
            let recordModuleApiToken = Record(TestCommonHandling.createConnection(apiToken))
            
            it("Test_236_Success_ValidData_ApiToken") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                
                let mentionList = [mentionUser]
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                expect(totalComment + 1).to(equal(result.getComments()?.count))
                expect(mentionUserCode + " \n" + commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Common.ADMINISTRATOR_USER).to(equal(result.getComments()?[0].getCreator()?.code))
                let mentionResult = result.getComments()?[0].getMentions()
                for user in mentionResult! {
                    expect(mentionUserCode).to(equal(user.getCode()))
                    expect(mentionUserType).to(equal(user.getType()))
                }
                
                let resultRecord = TestCommonHandling.awaitAsync(recordModuleApiToken.getRecord(appId, recordId)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))
                
            }
            
            it("Test_237_Success_SpecialCharacter_ApiToken") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                expect(commentSpecialChars + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            it("Test_238_239_Success_MentionMultiUsers_ApiToken") {
                let mentionUser = CommentMention()
                mentionUser.setCode(mentionUserCode)
                mentionUser.setType(mentionUserType)
                
                let mentionDept = CommentMention()
                mentionDept.setCode(TestConstant.InitData.DEPARTMENT_CODE)
                mentionDept.setType(TestConstant.InitData.DEPARTMENT_TYPE)
                
                let mentionGroup = CommentMention()
                mentionGroup.setCode(TestConstant.InitData.GROUP_CODE)
                mentionGroup.setType(TestConstant.InitData.GROUP_TYPE)
                
                let mentionList = [mentionUser, mentionDept, mentionGroup]
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                let mentionResult = result.getComments()?[0].getMentions()
                expect(mentionResult?[0].getCode()).to(equal(mentionUserCode))
                expect(mentionResult?[0].getType()).to(equal(mentionUserType))
                expect(mentionResult?[1].getCode()).to(equal(TestConstant.InitData.DEPARTMENT_CODE))
                expect(mentionResult?[1].getType()).to(equal(TestConstant.InitData.DEPARTMENT_TYPE))
                expect(mentionResult?[2].getCode()).to(equal(TestConstant.InitData.GROUP_CODE))
                expect(mentionResult?[2].getType()).to(equal(TestConstant.InitData.GROUP_TYPE))
            }
            
            it("Test_240_Success_NoMention_ApiToken") {
                comment.setMentions(nil)
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                let mentionResult = result.getComments()?[0].getMentions()
                expect(mentionResult?.count).to(equal(0))
                expect(result.getComments()?[0].getText()).to(equal(commentContent + " "))
            }
            
            it("Test_254_Success_CommentPostedByAdministrator_ApiToken") {
                let mentionList = [mentionUser]
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?[0].getCreator()?.code).to(equal(TestConstant.Common.ADMINISTRATOR_USER))
            }
        }
    }
}

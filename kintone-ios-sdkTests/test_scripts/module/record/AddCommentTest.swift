///**
/**
 kintone-ios-sdkTests
 Created on 6/12/19
*/

import Foundation
import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class AddCommentTest: QuickSpec {
    private var recordModule: Record!
    private var recordModuleGuestSpace: Record!
    private var recordModuleApiToken: Record!

    private let APP_ID: Int = 1
    private let GUEST_SPACE_ID: Int = 4
    private let APP_GUEST_SPACE_ID: Int = 224
    private let NONEXISTENT_ID = 99999999
    private let API_TOKEN: String = "DAVEoGAcQLp3qQmAwbISn3jUEKKLAFL9xDTrccxF"

    private var recordID: Int!
    private var recordGuestSpaceID: Int!
    
    // Comment Data
    private let mentionCode: String = "cybozu"
    private let mentionType: String = "USER"
    private let commentContent: String = "add comment test"
    private let RECORD_TEXT_FIELD: String! = "text"

    private var commentID: Int!
    private var commentGuestSpaceID: Int!

    private var mention: CommentMention!
    private var comment: CommentContent!
    private var mentionList = [CommentMention]()
    
    override func spec() {
        describe("AddCommen") {
            beforeSuite {
                self.recordModule = Record(TestCommonHandling.createConnection())
                self.recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.ADMIN_USERNAME,
                    TestConstant.Connection.ADMIN_PASSWORD,
                    self.GUEST_SPACE_ID))
                self.recordModuleApiToken = Record(TestCommonHandling.createConnection(self.API_TOKEN))

                // Add record to contains comments
                let addData: Dictionary<String, FieldValue> = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, addData)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.addRecord(self.APP_GUEST_SPACE_ID, addData)) as! AddRecordResponse
                self.recordGuestSpaceID = addRecordGuestSpaceResponse.getId()
                
                self.mention = CommentMention()
                self.mention.setCode(self.mentionCode)
                self.mention.setType(self.mentionType)
                self.mentionList.append(self.mention)
                
                self.comment = CommentContent()
                self.comment.setText(self.commentContent)
                self.comment.setMentions(self.mentionList)
            }

            afterSuite {
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, [self.recordID]))
                _ = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.deleteRecords(self.APP_GUEST_SPACE_ID, [self.recordGuestSpaceID]))
            }
            
            it("Test_236_ValidData") {
                let getCommentResponse = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                _ = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.APP_ID, self.recordID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(totalComment + 1).to(equal(result.getComments()?.count))
                expect(self.mentionCode + " \n" + self.commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Connection.ADMIN_USERNAME).to(equal(result.getComments()?[0].getCreator()?.code))
                let mentions = result.getComments()?[0].getMentions()
                for user in mentions! {
                    expect(self.mentionCode).to(equal(user.getCode()))
                    expect(self.mentionType).to(equal(user.getType()))
                }
                
                // Revision is not increased
                let resultRecord = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, self.recordID)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))

            }
            
            it("Test_237_SpecialCharacter") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                self.comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.APP_ID, self.recordID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(self.mentionCode + " \n" + commentSpecialChars + " ").to(equal(result.getComments()?[0].getText()))

            }
            
            it("Test_238_MentionMultiUsers") {
                let mentionDept = CommentMention()
                mentionDept.setCode(TestConstant.Connection.DEPARTMENT_CODE)
                mentionDept.setType(TestConstant.Connection.DEPARTMENT_TYPE)
                self.mentionList.append(mentionDept)
                
                let mentionGroup = CommentMention()
                mentionGroup.setCode(TestConstant.Connection.GROUP_CODE)
                mentionGroup.setType(TestConstant.Connection.GROUP_TYPE)
                self.mentionList.append(mentionGroup)

                self.comment.setText(self.commentContent)
                self.comment.setMentions(self.mentionList)
                
                _ = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.APP_ID, self.recordID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?[0].getCode()).to(equal(self.mentionCode))
                expect(mentions?[0].getType()).to(equal(self.mentionType))
                expect(mentions?[1].getCode()).to(equal(TestConstant.Connection.DEPARTMENT_CODE))
                expect(mentions?[1].getType()).to(equal(TestConstant.Connection.DEPARTMENT_TYPE))
                expect(mentions?[2].getCode()).to(equal(TestConstant.Connection.GROUP_CODE))
                expect(mentions?[2].getType()).to(equal(TestConstant.Connection.GROUP_TYPE))
            }
            
            it("Test_240_NoMention") {
                self.comment.setMentions(nil)
                self.comment.setText(self.commentContent)
                
                _ = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.APP_ID, self.recordID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(0).to(equal(mentions?.count))
                expect(self.commentContent + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            it("Test_241_Error_BlankContent") {
                let commentBlank = CommentContent()
                
                let result = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.APP_ID, self.recordID, commentBlank)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_COMMENT_TEXT_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: String(self.RECORD_TEXT_FIELD))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_242_Error_NonexistentMentionUser") {
                let mentionInvalidUser = CommentMention()
                mentionInvalidUser.setCode("NONEXISTENT_USER")
                mentionInvalidUser.setType(self.mentionType)
                self.mentionList.append(mentionInvalidUser)
                self.comment.setMentions(self.mentionList)
                
                let result = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.APP_ID, self.recordID, self.comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NONEXISTENT_USER_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_243_Error_NoPermissionForApp") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(self.APP_ID, self.recordID, self.comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_244_Error_NoPermissionForRecord") {
                self.mentionList.removeAll()
                self.mentionList.append(self.mention)
                self.comment.setMentions(self.mentionList)
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(self.APP_ID, self.recordID, self.comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_245_NoPermissionForField") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_PEMISSION_FIELD,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_PEMISSION_FIELD))
                
                self.mentionList.removeAll()
                self.mentionList.append(self.mention)
                
                self.comment = CommentContent()
                self.comment.setText(self.commentContent)
                self.comment.setMentions(self.mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(self.APP_ID, self.recordID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(self.mentionCode + " \n" + self.commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Connection.CRED_USERNAME_WITHOUT_PEMISSION_FIELD).to(equal(result.getComments()?[0].getCreator()?.code))
            }
            
            it("Test_246_Error_InvalidAppId") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.NONEXISTENT_ID, self.recordID, self.comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))

                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_247_Error_InvalidRecordId") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.APP_ID, self.NONEXISTENT_ID, self.comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("test_255_MentionInactiveUserDepartmentGroup") {
                let mentionInactiveUser = CommentMention()
                mentionInactiveUser.setCode(TestConstant.Connection.CRED_USERNAME_INACTIVE)
                mentionInactiveUser.setType(self.mentionType)
                self.mentionList = [mentionInactiveUser]
                self.comment.setMentions(self.mentionList)
                
                _ = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.APP_ID, self.recordID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?[0].getCode()).to(equal(TestConstant.Connection.CRED_USERNAME_INACTIVE))
                expect(mentions?[0].getType()).to(equal(self.mentionType))
            }
            
            /***
             * GUEST SPACE TESTING
             ***/
            
            it("Test_236_GuestSpace_ValidData") {
                let getCommentResponse = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                _ = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.addComment(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(totalComment + 1).to(equal(result.getComments()?.count))
                expect(self.mentionCode + " \n" + self.commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Connection.ADMIN_USERNAME).to(equal(result.getComments()?[0].getCreator()?.code))
                let mentions = result.getComments()?[0].getMentions()
                for user in mentions! {
                    expect(self.mentionCode).to(equal(user.getCode()))
                    expect(self.mentionType).to(equal(user.getType()))
                }
                
                // Revision is not increased
                let resultRecord = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getRecord(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))
            }
            
            it("Test_237_GuestSpace_SpecialCharacter") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                self.comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.addComment(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(self.mentionCode + " \n" + commentSpecialChars + " ").to(equal(result.getComments()?[0].getText()))
                
            }
            
            it("Test_240_GuestSpace_NoMention") {
                self.comment.setMentions(nil)
                self.comment.setText(self.commentContent)
                
                _ = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.addComment(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(0).to(equal(mentions?.count))
                expect(self.commentContent + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            /***
             * API TOKEN TESTING
             ***/
            
            it("Test_236_APIToken_ValidData") {
                let getCommentResponse = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                _ = TestCommonHandling.awaitAsync(self.recordModuleApiToken.addComment(self.APP_ID, self.recordID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(totalComment + 1).to(equal(result.getComments()?.count))
                expect(self.mentionCode + " \n" + self.commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Connection.CRED_ADMIN).to(equal(result.getComments()?[0].getCreator()?.code))
                let mentions = result.getComments()?[0].getMentions()
                for user in mentions! {
                    expect(self.mentionCode).to(equal(user.getCode()))
                    expect(self.mentionType).to(equal(user.getType()))
                }
                
                // Revision is not increased
                let resultRecord = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getRecord(self.APP_ID, self.recordID)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))
                
            }
            
            it("Test_237_APIToken_SpecialCharacter") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                self.comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(self.recordModuleApiToken.addComment(self.APP_ID, self.recordID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(self.mentionCode + " \n" + commentSpecialChars + " ").to(equal(result.getComments()?[0].getText()))
                
            }
            
            it("Test_238_239_APIToken_MentionMultiUsers") {
                let mentionDept = CommentMention()
                mentionDept.setCode(TestConstant.Connection.DEPARTMENT_CODE)
                mentionDept.setType(TestConstant.Connection.DEPARTMENT_TYPE)
                self.mentionList.append(mentionDept)
                
                let mentionGroup = CommentMention()
                mentionGroup.setCode(TestConstant.Connection.GROUP_CODE)
                mentionGroup.setType(TestConstant.Connection.GROUP_TYPE)
                self.mentionList.append(mentionGroup)
                
                self.comment.setText(self.commentContent)
                self.comment.setMentions(self.mentionList)
                
                _ = TestCommonHandling.awaitAsync(self.recordModuleApiToken.addComment(self.APP_ID, self.recordID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?[0].getCode()).to(equal(self.mentionCode))
                expect(mentions?[0].getType()).to(equal(self.mentionType))
                expect(mentions?[1].getCode()).to(equal(TestConstant.Connection.DEPARTMENT_CODE))
                expect(mentions?[1].getType()).to(equal(TestConstant.Connection.DEPARTMENT_TYPE))
                expect(mentions?[2].getCode()).to(equal(TestConstant.Connection.GROUP_CODE))
                expect(mentions?[2].getType()).to(equal(TestConstant.Connection.GROUP_TYPE))
            }
            
            it("Test_240_APIToken_NoMention") {
                self.comment.setMentions(nil)
                self.comment.setText(self.commentContent)
                
                _ = TestCommonHandling.awaitAsync(self.recordModuleApiToken.addComment(self.APP_ID, self.recordID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?.count).to(equal(0))
                expect(result.getComments()?[0].getText()).to(equal(self.commentContent + " "))
            }
            
            it("Test_254_APIToken_CommentPostedByAdministrator") {
                _ = TestCommonHandling.awaitAsync(self.recordModuleApiToken.addComment(self.APP_ID, self.recordID, self.comment))
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                //dump(result)
                expect(result.getComments()?[0].getCreator()?.code).to(equal(TestConstant.Connection.CRED_ADMIN))
            }
        }
    }
}

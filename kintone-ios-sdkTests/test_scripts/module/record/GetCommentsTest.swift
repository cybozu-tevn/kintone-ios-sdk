//
// kintone-ios-sdkTests
// Created on 6/12/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetCommentsTest: QuickSpec {
    override func spec() {
        let appId: Int = TestConstant.InitData.SPACE_APP_ID!
        let guestSpaceAppId: Int = TestConstant.InitData.GUEST_SPACE_APP_ID!
        var recordId: Int!
        var recordGuestSpaceId: Int!
        let nonexistentId = TestConstant.Common.NONEXISTENT_ID
        let negativeId: Int = TestConstant.Common.NEGATIVE_ID

        // Comment Data
        let mentionCode: String = "cybozu"
        let mentionType: String = "USER"
        let commentContent: String = DataRandomization.generateString(prefix: "GetComments", length: 10)
        var commentId: Int!
        var commentGuestSpaceId: Int!
        var commentIds: [Int] = []
        var commentIdsGuestSpace: [Int] = []
        let totalAddedComments: Int = 15
        let maxNumberOfGetComments: Int = 10

        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            TestConstant.InitData.GUEST_SPACE_ID!))
        let recordModuleApiToken = Record(TestCommonHandling.createConnection(TestConstant.InitData.SPACE_APP_API_TOKEN))
        
        describe("GetComments") {
            it("AddTestData_BeforeSuiteWorkaround") {
                // Prepare record
                let addData: Dictionary<String, FieldValue> = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, addData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(guestSpaceAppId, addData)) as! AddRecordResponse
                recordGuestSpaceId = addRecordGuestSpaceResponse.getId()
                
                // Prepare comments
                let mention = CommentMention()
                mention.setCode(mentionCode)
                mention.setType(mentionType)
                
                let comment = CommentContent()
                comment.setText(commentContent)
                comment.setMentions([mention])
                
                // Add more than 10 comments
                for _ in 0...totalAddedComments - 1 {
                    let addCommentResponse = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment)) as! AddCommentResponse
                    commentId = addCommentResponse.getId()
                    commentIds.append(Int(commentId))
                    
                    let addCommentGuestSpaceResponse = TestCommonHandling.awaitAsync(
                        recordModuleGuestSpace.addComment(guestSpaceAppId, recordGuestSpaceId, comment)) as! AddCommentResponse
                    commentGuestSpaceId = addCommentGuestSpaceResponse.getId()
                    commentIdsGuestSpace.append(Int(commentGuestSpaceId))
                }
            }
            
            it("Test_215_Success_ValidData") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!
                
                // Verify only 10 comments are returned by default
                expect(comments.count).to(equal(maxNumberOfGetComments))
                
                var commentId = Int(commentId)
                for comment in comments {
                    let expectedCommentText = mentionCode + " \n" + commentContent + " "
                    expect(comment.getText()).to(equal(expectedCommentText))
                    expect(comment.getId()).to(equal(commentId))
                    expect(comment.getCreator()?.code).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(user.getCode()).to(equal(mentionCode))
                        expect(user.getType()).to(equal(mentionType))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_Success_SortAscending") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, "asc", nil, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                var commentIndex = 0
                for comment in comments {
                    expect(comment.getId()).to(equal(commentIds[commentIndex]))
                    commentIndex += 1
                }
            }
            
            it("Test_217_Success_SortDescending") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, "desc", nil, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                var commentIndex = totalAddedComments - 1
                for comment in comments {
                    expect(comment.getId()).to(equal(commentIds[commentIndex]))
                    commentIndex -= 1
                }
            }
            
            it("Test_218_Error_InvalidOrder") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, "invalid", nil, nil)) as! KintoneAPIException

                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.INVALID_COMMENT_ORDER_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_219_Success_offset") {
                let offset = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, offset, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                // Only 10 comments are returned by default
                expect(comments.count).to(equal(maxNumberOfGetComments))
                
                var commentIndex = totalAddedComments - 1 - offset
                for comment in comments {
                    expect(comment.getId()).to(equal(commentIds[commentIndex]))
                    commentIndex -= 1
                }
            }
            
            it("Test_220_Success_OffsetIsZero") {
                let offset = 0
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, offset, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                // Only 10 comments are returned by default
                expect(comments.count).to(equal(maxNumberOfGetComments))
                
                var commentId = totalAddedComments
                for comment in comments {
                    expect(comment.getId()).to(equal(commentId))
                    commentId -= 1
                }
            }
            
            it("Test_221_Error_OffsetIsInvalid") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, -10, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_222_Success_Limit") {
                let limit = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, limit)) as! GetCommentsResponse
                
                expect(getCommentResponse.getComments()?.count).to(equal(limit))
            }
            
            it("Test_223_Success_LimitIsZero") {
                let limit = 0
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, limit)) as! GetCommentsResponse
                
                expect(getCommentResponse.getComments()?.count).to(equal(limit))
            }
            
            it("Test_224_Error_LimitIsMoreThan10") {
                let limit = 11
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, limit)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.LIMIT_LARGER_THAN_10_ERRORS()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_225_Success_AscOrderOffsetLimitCombination") {
                let offset = 5
                let limit = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, "asc", offset, limit)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                expect(limit).to(equal(comments.count))
                var expectedCommentId = totalAddedComments - offset - limit + 1
                for comment in comments {
                    expect(comment.getId()).to(equal(expectedCommentId))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_Success_DescOrderOffsetLimitCombination") {
                let offset = 5
                let limit = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, "desc", offset, limit)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                expect(comments.count).to(equal(limit))
                var commentId = Int(commentId) - offset
                for comment in comments {
                    expect(comment.getId()).to(equal(commentId))
                    commentId -= 1
                }
            }
            
            it("Test_227_Error_NoPermissionForApp") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermission.getComments(appId, recordId, nil, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_228_Error_NoPermissionForRecord") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermission.getComments(appId, recordId, nil, nil, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_229_Error_NoPermissionForField") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                let getCommentResponse = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermission.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                expect(getCommentResponse.getComments()?.count).to(equal(maxNumberOfGetComments))
            }
            
            it("Test_230_Error_InvalidAppId") {
                var result = TestCommonHandling.awaitAsync(recordModule.getComments(nonexistentId, recordId, nil, nil, nil)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(nonexistentId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(recordModule.getComments(negativeId, recordId, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(recordModule.getComments(0, recordId, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_231_Error_InvalidRecordId") {
                var result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, nonexistentId, nil, nil, nil)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(nonexistentId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, negativeId, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // GUEST SPACE
            it("Test_215_Success_ValidData_GuestSpace") {
                let getCommentResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, nil, nil, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                // Only 10 comments are returned by default
                expect(comments.count).to(equal(maxNumberOfGetComments))
                
                var commentId = Int(commentGuestSpaceId)
                for comment in comments {
                    let expectedCommentText = mentionCode + " \n" + commentContent + " "
                    expect(comment.getText()).to(equal(expectedCommentText))
                    expect(comment.getId()).to(equal(commentId))
                    expect(comment.getCreator()?.code).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))

                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(user.getCode()).to(equal(mentionCode))
                        expect(user.getType()).to(equal(mentionType))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_Success_SortAscending_GuestSpace") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, "asc", nil, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                var commentIndex = 0
                for comment in comments {
                    expect(comment.getId()).to(equal(commentIds[commentIndex]))
                    commentIndex += 1
                }
            }
            
            it("Test_217_Success_SortDescending_GuestSpace") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, "desc", nil, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                var commentIndex = commentIdsGuestSpace.count - 1
                for comment in comments {
                    expect(comment.getId()).to(equal(commentIds[commentIndex]))
                    commentIndex -= 1
                }
            }
            
            it("Test_219_Success_Offset_GuestSpace") {
                let offset = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, nil, offset, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                // Only 10 comments are returned by default
                expect(comments.count).to(equal(maxNumberOfGetComments))
                
                var commentIndex = commentIdsGuestSpace.count - 1 - offset
                for comment in comments {
                    expect(commentIdsGuestSpace[commentIndex]).to(equal(comment.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_222_Success_Limit_GuestSpace") {
                let limit = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, nil, nil, limit)) as! GetCommentsResponse
                
                expect(getCommentResponse.getComments()?.count).to(equal(limit))
            }
            
            it("Test_225_Success_AscOrderOffsetLimitCombination_GuestSpace") {
                let offset = 5
                let limit = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, "asc", offset, limit)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                expect(limit).to(equal(comments.count))
                var expectedCommentId = commentIdsGuestSpace.count - offset - limit + 1
                for comment in comments {
                    expect(comment.getId()).to(equal(expectedCommentId))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_Success_DescOrderOffsetLimitCombination_GuestSpace") {
                let offset = 5
                let limit = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, "desc", offset, limit)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                expect(limit).to(equal(comments.count))
                var commentId = Int(commentGuestSpaceId) - offset
                for comment in comments {
                    expect(comment.getId()).to(equal(commentId))
                    commentId -= 1
                }
            }
            
            // API TOKEN
            it("Test_215_Success_ValidData_ApiToken") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                // Only 10 comments are returned by default
                expect(comments.count).to(equal(maxNumberOfGetComments))
                
                var commentId = Int(commentId)
                for comment in comments {
                    let expectedCommentText = mentionCode + " \n" + commentContent + " "
                    expect(comment.getText()).to(equal(expectedCommentText))
                    expect(comment.getId()).to(equal(commentId))
                    expect(comment.getCreator()?.code).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))

                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(user.getCode()).to(equal(mentionCode))
                        expect(user.getType()).to(equal(mentionType))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_Success_SortAscending_ApiToken") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, "asc", nil, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                var commentIndex = 0
                for comment in comments {
                    expect(comment.getId()).to(equal(commentIds[commentIndex]))
                    commentIndex += 1
                }
            }
            
            it("Test_217_SortDescending_ApiToken") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, "desc", nil, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                var commentIndex = totalAddedComments - 1
                for comment in comments {
                    expect(comment.getId()).to(equal(commentIds[commentIndex]))
                    commentIndex -= 1
                }
            }
            
            it("Test_219_Success_Offset_ApiToken") {
                let offset = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, offset, nil)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                // Only 10 comments are returned by default
                expect(comments.count).to(equal(maxNumberOfGetComments))
                
                var commentIndex = totalAddedComments - 1 - offset
                for comment in comments {
                    expect(comment.getId()).to(equal(commentIds[commentIndex]))
                    commentIndex -= 1
                }
            }
            
            it("Test_222_Success_Limit_ApiToken") {
                let limit = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, limit)) as! GetCommentsResponse
                
                expect(getCommentResponse.getComments()?.count).to(equal(limit))
            }
            
            it("Test_225_Success_AscOrderOffsetLimitCombination_ApiToken") {
                let offset = 5
                let limit = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, "asc", offset, limit)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                expect(limit).to(equal(comments.count))
                var expectedCommentId = totalAddedComments - offset - limit + 1
                for comment in comments {
                    expect(comment.getId()).to(equal(expectedCommentId))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_ApiToken_DescOrderOffsetLimitCombination") {
                let offset = 5
                let limit = 5
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, "desc", offset, limit)) as! GetCommentsResponse
                let comments = getCommentResponse.getComments()!

                expect(limit).to(equal(comments.count))
                var commentId = Int(commentId) - offset
                for comment in comments {
                    expect(comment.getId()).to(equal(commentId))
                    commentId -= 1
                }
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId]))
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(guestSpaceAppId, [recordGuestSpaceId]))
            }
        }
    }
}

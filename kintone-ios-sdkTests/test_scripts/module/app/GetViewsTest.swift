//
// kintone-ios-sdkTests
// Created on 6/25/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetViewsTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let appModuleGuestSpace = App(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            TestConstant.InitData.GUEST_SPACE_ID!))
        let appModuleWithoutPermission = App(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
            TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
        let appId = TestConstant.InitData.SPACE_APP_ID!
        let guetsSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
        
        // View Data
        var viewEntry: [String: ViewModel] = [String: ViewModel]()
        var viewEntryPrelive: [String: ViewModel] = [String: ViewModel]()
        let updateViewModel: ViewModel = ViewModel()
        let updateViewModelPrelive: ViewModel = ViewModel()
        let viewName = DataRandomization.generateString(prefix: "LiveViewTest", length: 5)
        let viewNamePrelive = DataRandomization.generateString(prefix: "PreliveViewTest", length: 5)
        let viewSort = "Record_number desc"
        let viewType = ViewModel.ViewType.LIST
        let viewFilter = "Created_datetime = LAST_WEEK()"
        let viewIndex = 1
        let viewPreliveIndex = 2
        let viewFields = TestConstant.InitData.FIELD_CODES
        
        var isPreview = true
        var totalLiveViews: Int = 0
        var totalViews: Int = 0
        var initialViews: [String: ViewModel] = [String: ViewModel]()
        
        describe("GetViews") {
            it("AddTestData_BeforeSuiteWorkaround") {
                var getViewsResponse = TestCommonHandling.awaitAsync(appModule.getViews(appId, LanguageSetting.DEFAULT, false)) as! GetViewsResponse
                initialViews = getViewsResponse.getViews()!
                
                // Add 1 Live View + 1 Prelive View for testing
                viewEntry = initialViews
                updateViewModel.setName(viewName)
                updateViewModel.setSort(viewSort)
                updateViewModel.setType(viewType)
                updateViewModel.setFilterCond(viewFilter)
                updateViewModel.setIndex(viewIndex)
                updateViewModel.setFields(viewFields)
                viewEntry[viewName] = updateViewModel
                totalLiveViews = viewEntry.count
                
                _ = TestCommonHandling.awaitAsync(appModule.updateViews(appId, viewEntry))
                let previewApp: PreviewApp? = PreviewApp(appId, -1)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp!], false))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
                
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateViews(guetsSpaceAppId, viewEntry))
                let previewAppGuestSpace: PreviewApp? = PreviewApp(guetsSpaceAppId, -1)
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.deployAppSettings([previewAppGuestSpace!], false))
                AppUtils.waitForDeployAppSucceed(appModule: appModuleGuestSpace, appId: guetsSpaceAppId)
                
                getViewsResponse = TestCommonHandling.awaitAsync(appModule.getViews(appId, LanguageSetting.DEFAULT, false)) as! GetViewsResponse
                viewEntryPrelive = getViewsResponse.getViews()!
                updateViewModelPrelive.setName(viewNamePrelive)
                updateViewModelPrelive.setSort(viewSort)
                updateViewModelPrelive.setType(viewType)
                updateViewModelPrelive.setFilterCond(viewFilter)
                updateViewModelPrelive.setIndex(viewPreliveIndex)
                updateViewModelPrelive.setFields(viewFields)
                viewEntryPrelive[viewNamePrelive] = updateViewModelPrelive
                totalViews = viewEntryPrelive.count
                
                _ = TestCommonHandling.awaitAsync(appModule.updateViews(appId, viewEntryPrelive))
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateViews(guetsSpaceAppId, viewEntryPrelive))
            }
            
            // API TOKEN
            it("Test_003_Error_ApiTokenAuthentication_ApiToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.getViews(appId, LanguageSetting.DEFAULT, true)) as! KintoneAPIException

                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // NORMAL SPACE
            it("Test_004_008_Success_ValidRequest") {
                // Prelive view settings is returned when specifying isPreview is True
                isPreview = true
                let result = TestCommonHandling.awaitAsync(appModule.getViews(appId, LanguageSetting.DEFAULT, isPreview)) as! GetViewsResponse
                let viewList = result.getViews()!
                
                _verifyViewsInfoInViewList(viewList: viewList, totalViews: totalViews, viewName: viewName, viewIndex: viewIndex)
            }
            
            it("Test_005_Success_WithoutIsPreview") {
                // Live view settings is returned when not specifying isPreview
                let result = TestCommonHandling.awaitAsync(appModule.getViews(appId, LanguageSetting.DEFAULT)) as! GetViewsResponse
                let viewList = result.getViews()!
                
                _verifyViewsInfoInViewList(viewList: viewList, totalViews: totalLiveViews, viewName: viewNamePrelive, viewIndex: viewPreliveIndex)
            }
            
            it("Test_008_Success_IsPreviewFalse") {
                // Live view settings is returned when specifying isPreview False
                isPreview = false
                let result = TestCommonHandling.awaitAsync(appModule.getViews(appId, LanguageSetting.DEFAULT, isPreview)) as! GetViewsResponse
                let viewList = result.getViews()!
                
                _verifyViewsInfoInViewList(viewList: viewList, totalViews: totalLiveViews, viewName: viewNamePrelive, viewIndex: viewPreliveIndex)
            }
            
            it("Test_009_Error_InvalidAppId") {
                var result = TestCommonHandling.awaitAsync(appModule.getViews(TestConstant.Common.NONEXISTENT_ID, LanguageSetting.DEFAULT, isPreview)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(appModule.getViews(TestConstant.Common.NEGATIVE_ID, LanguageSetting.DEFAULT, isPreview)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)

                result = TestCommonHandling.awaitAsync(appModule.getViews(0, LanguageSetting.DEFAULT, isPreview)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_011_Success_InvalidLanguage") {
                // KCB-613 -> return default language when inputting invalid language
                let result = TestCommonHandling.awaitAsync(appModule.getViews(appId, LanguageSetting.init(rawValue: "invalid"), isPreview)) as! GetViewsResponse
                let viewList = result.getViews()!
                
                _verifyViewsInfoInViewList(viewList: viewList, totalViews: totalLiveViews, viewName: viewNamePrelive, viewIndex: viewPreliveIndex)
            }
            
            it("Test_012_Error_LiveAppWithoutManageAppPermission") {
                isPreview = false
                let result = TestCommonHandling.awaitAsync(appModuleWithoutPermission.getViews(appId, LanguageSetting.DEFAULT, isPreview)) as! KintoneAPIException

                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_013_Error_PreliveAppWithoutManageAppPermission") {
                isPreview = true
                let result = TestCommonHandling.awaitAsync(appModuleWithoutPermission.getViews(appId, LanguageSetting.DEFAULT, isPreview)) as! KintoneAPIException

                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // GUEST SPACE
            it("Test_004_Success_ValidRequest_GuestSpace") {
                isPreview = true
                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.getViews(guetsSpaceAppId, LanguageSetting.DEFAULT, isPreview)) as! GetViewsResponse
                
                let viewList = result.getViews()!
                _verifyViewsInfoInViewList(viewList: viewList, totalViews: totalViews, viewName: viewName, viewIndex: viewIndex)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                // Reset views of app into initial views
                _ = TestCommonHandling.awaitAsync(appModule.updateViews(appId, initialViews))
                let previewApp: PreviewApp? = PreviewApp(appId, -1)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp!], false))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)

                // Reset views of guest space app into initial views
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateViews(guetsSpaceAppId, initialViews))
                let previewGuestSpaceApp: PreviewApp? = PreviewApp(guetsSpaceAppId, -1)
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.deployAppSettings([previewGuestSpaceApp!], false))
                AppUtils.waitForDeployAppSucceed(appModule: appModuleGuestSpace, appId: guetsSpaceAppId)
            }
        }
        
        func _verifyViewsInfoInViewList(viewList: [String: ViewModel], totalViews: Int, viewName: String, viewIndex: Int) {
            expect(viewList.count).to(equal(totalViews))

            for view in viewList {
                if(view.key == viewName) {
                    expect(view.key).to(equal(viewName))
                    expect(view.value.getName()).to(equal(viewName))
                    expect(view.value.getSort()).to(equal(viewSort))
                    expect(view.value.getType()).to(equal(viewType))
                    expect(view.value.getFilterCond()).to(equal(viewFilter))
                    expect(view.value.getIndex()).to(equal(viewIndex))
                    expect(view.value.getFields()).to(equal(viewFields))
                }
            }

        }
    }
}

@testable import Promises
@testable import kintone_ios_sdk

public enum ConnectionType: String, Codable {
    case DEFAULT = "full permission"
    case WITHOUT_PERMISSION = "without permission"
    case GUEST_SPACE = "guest space"
    case API_TOKEN = "api token"
    case GUEST_SPACE_WITHOUT_PERMISSION = "guest space without permission"
    case API_TOKEN_WITHOUT_PERMISSION = "api token without permission"
}

class AppUtils {
    static var APIToken: String!
    static var auth: Auth!
    static var conn: Connection!
    static var appModule: App!
    static let devAuth = DevAuth().setPasswordAuth(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD)
    static let devConn = DevConnection(TestConstant.Connection.DOMAIN, devAuth)
    static let devAppModule = DevApp(devConn)
    
    /// Set API Token
    ///
    /// - Parameter apiToken: String | API Token
    static func setAPIToken(_ apiToken: String) {
        APIToken = apiToken
    }
    
    /// Init App module with default connection for Admin user
    static func initAppModule() {
        auth = Auth().setPasswordAuth(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD)
        conn = Connection(TestConstant.Connection.DOMAIN, auth)
        appModule = App(conn)
    }
    
    /// Init App module with connection for specific cases
    ///
    /// - Parameters:
    ///   - connectionType: ConnectionType | connection type
    ///   - username: String | username
    ///   - password: String | password
    ///   - apiToken: String | API Token
    static func initAppModule(connectionType: ConnectionType, username: String = "", password: String = "", apiToken: String = "") {
        switch connectionType {
        case .WITHOUT_PERMISSION:
            if(username == "" || password == "") {
                fatalError("Please define username and password for this module")
            }
            auth = Auth().setPasswordAuth(username, password)
            conn = Connection(TestConstant.Connection.DOMAIN, AppUtils.auth)
            appModule = App(conn)
        case .GUEST_SPACE:
            auth = Auth().setPasswordAuth(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD)
            conn = Connection(TestConstant.Connection.DOMAIN, auth, TestConstant.InitData.GUEST_SPACE_ID!)
            appModule = App(conn)
        case .GUEST_SPACE_WITHOUT_PERMISSION:
            if(username == "" || password == "") {
                fatalError("Please define username and password for this module")
            }
            auth = Auth().setPasswordAuth(username, password)
            conn = Connection(TestConstant.Connection.DOMAIN, auth, TestConstant.InitData.GUEST_SPACE_ID!)
            appModule = App(conn)
        case .API_TOKEN:
            if(apiToken == "") {
                fatalError("Please define apiToken for this module")
            }
            setAPIToken(apiToken)
            auth = Auth().setApiToken(APIToken)
            conn = Connection(TestConstant.Connection.DOMAIN, auth)
            appModule = App(conn)
        case .API_TOKEN_WITHOUT_PERMISSION:
            if(apiToken == "") {
                fatalError("Please define apiToken for this module")
            }
            setAPIToken(apiToken)
            auth = Auth().setApiToken(APIToken)
            conn = Connection(TestConstant.Connection.DOMAIN, auth)
            appModule = App(conn)
            
        default:
            initAppModule()
        }
    }
    
    /// Create App
    ///
    /// - Parameters:
    ///   - appModule: App | App module
    ///   - appName: String | The App name
    ///   - spaceId: Int | Space id
    ///   - threadId: Int | Thread id
    /// - Returns: App id
    static func createApp(appModule: App, appName: String = "App created by kintone-ios-sdk test scripts", spaceId: Int? = nil, threadId: Int? = nil) -> Int {
        var apps = [PreviewApp]()
        var appId: Int!
        appModule.addPreviewApp(appName, spaceId, threadId)
            .then { response in
                apps.append(response)
                appId = response.getApp()
                print("Creating app: \(response.getApp()!)")
            }.catch { error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        self.deployApp(appModule: appModule, apps: apps)
        return appId
    }
    
    /// Create Apps
    ///
    /// - Parameters:
    ///   - appModule: App | App module
    ///   - appName: String | The App name
    ///   - spaceId: Int | Space id
    ///   - threadId: Int | Thread id
    ///   - amount: Int | number of Apps
    /// - Returns: array of app ids
    static func createApps(appModule: App, appName: String = "App created by kintone-ios-sdk test scripts", spaceId: Int? = nil, threadId: Int? = nil, amount: Int = 1) -> [Int] {
        var apps = [PreviewApp]()
        var appIds = [Int]()
        for index in 0...amount-1 {
            appModule.addPreviewApp(appName + String(index), spaceId, threadId)
                .then {response in
                    apps.append(response)
                    appIds.append(response.getApp()!)
                    print("Creating app: \(response.getApp()!)")
                }.catch {error in
                    if let errorVal = error as? KintoneAPIException {
                        fatalError(errorVal.toString()!)
                    } else {
                        fatalError(error.localizedDescription)
                    }
            }
            _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        }
        self.deployApp(appModule: appModule, apps: apps)
        return appIds
    }
    
    /// Wait for deploy App successfully
    ///
    /// - Parameters:
    ///   - appModule: App | App module
    ///   - appId: Int | App id
    static func waitForDeployAppSucceed(appModule: App, appId: Int) {
        var isDeployed = false
        while (!isDeployed) {
            appModule.getAppDeployStatus([appId])
                .then { response in
                    let status = response.getApps()![0].getStatus()?.rawValue
                    // print("Deploying app status \(String(describing: status))")
                    
                    if(status == AppDeployStatus.Status.SUCCESS.rawValue) {
                        isDeployed = true
                    }
                }.catch { error in
                    if let errorVal = error as? KintoneAPIException {
                        fatalError(errorVal.toString()!)
                    } else {
                        fatalError(error.localizedDescription)
                    }
            }
            _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        }
    }
    
    /// Deploy App
    ///
    /// - Parameters:
    ///   - appModule: App | App module
    ///   - apps: [PreviewApp] | List of Preview apps
    static func deployApp(appModule: App, apps: [PreviewApp]) {
        var appIds = [Int]()
        appModule.deployAppSettings(apps)
            .then {
                for app in apps {
                    appIds.append(app.getApp()!)
                    print("Deploying app: \(app.getApp()!)")
                }
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        
        for id in appIds {
            self.waitForDeployAppSucceed(appModule: appModule, appId: id)
        }
    }
    
    /// Delete App
    ///
    /// - Parameter appId: Int | App id
    static func deleteApp(appId: Int) {
        self.devAppModule.deleteApp(appId)
            .then { _ in
                print("Deleting app: \(appId)")
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
    }
    
    /// Delete Apps
    ///
    /// - Parameter appIds: Int | App id
    static func deleteApps(appIds: [Int]) {
        for appId in appIds {
            self.deleteApp(appId: appId)
        }
    }
    
    /// Get List of API Tokens
    ///
    /// - Parameter appId: Int | App id
    /// - Returns: List of API tokens
    static func getApiTokenList(_ appId: Int) -> [ApiToken] {
        var apiTokenList = [ApiToken]()
        devAppModule.getApiTokenList(appId)
            .then {response in
                apiTokenList = response.getResult().getItems()
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        return apiTokenList
    }
    
    /// Generate an API token without permission
    ///
    /// - Parameters:
    ///   - appModule: App | App module
    ///   - appId: Int | App id
    /// - Returns: String
    static func generateApiToken(_ appModule: App, _ appId: Int) -> String {
        //When update an API Token, it should update other existed tokens
        var apiToken: String!
        let getListAPIsTokenResponse = self.getApiTokenList(appId)
        var tokens = [TokenEntity]()
        for item in getListAPIsTokenResponse {
            tokens.append(item.getToken())
        }
        devAppModule.generateAPIToken(appId).then {response -> Promise<Void> in
            apiToken = response.getResult().getItem()
            tokens.append(TokenEntity(tokenString: apiToken))
            print("Generate API Token app \(appId): \(apiToken!)")
            return devAppModule.updateAPIToken(appId, tokens)
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        self.deployApp(appModule: appModule, apps: [PreviewApp(appId)])
        return apiToken
    }
    
    /// Update token permission
    ///
    /// - Parameters:
    ///   - appModule: App | App module
    ///   - appId: Int | App id
    ///   - token: TokenEntity | token entity
    static func updateTokenPermission(appModule: App, appId: Int, token: TokenEntity) {
        //When update an API Token, it should update other existed tokens
        let getListAPIsTokenResponse = self.getApiTokenList(appId)
        var tokens = [TokenEntity]()
        for item in getListAPIsTokenResponse {
            if(item.getToken().getTokenString() != token.getTokenString()) {
                tokens.append(item.getToken())
            }
        }
        tokens.append(token)
        devAppModule.updateAPIToken(appId, tokens)
            .then {
                print("""
                    ==========================================================================
                    Update permission for API Token in app \(appId): \(token.getTokenString())
                    View Record: \(token.getViewRecord())
                    Add Record: \(token.getAddRecord())
                    Edit Record: \(token.getEditRecord())
                    Delete Record: \(token.getDeleteRecord())
                    Edit App: \(token.getEditApp())
                    ==========================================================================
                    """)
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        self.deployApp(appModule: appModule, apps: [PreviewApp(appId)])
    }
    
    /// Get App Permission
    ///
    /// - Parameter appId: Int | App id
    /// - Returns: [UserRightEntity]
    static func getAppPermissions(appId: Int) -> [AccessRightEntity] {
        var userRights = [AccessRightEntity]()
        devAppModule.getAppPermissions(appId).then {response in
            userRights = response.getRights()
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        return userRights
    }
    
    /// Update App permission
    ///
    /// - Parameters:
    ///   - appModule: App | App module
    ///   - appId: Int | App id
    ///   - accessRight: AccessRightEntity | Access right of member entity
    /// - Returns: <#return value description#>
    static func updateAppPermissions(appModule: App, appId: Int, accessRight: AccessRightEntity) -> String {
        //When update permission, it should update other existed rights
        var revision: String!
        var userRights = self.getAppPermissions(appId: appId)
        userRights.append(accessRight)
        devAppModule.updateAppPermissions(appId, userRights).then {response in
            print("""
                ==========================================================================
                Update permission for \(accessRight.getDevMember().getCode()) in app \(appId):
                Record Viewable: \(accessRight.getRecordViewable())
                Record Addable: \(accessRight.getRecordAddable())
                Record Editable: \(accessRight.getRecordEditable())
                Record Deleteable: \(accessRight.getRecordDeletable())
                Record Importable: \(accessRight.getRecordImportable())
                Record Exportable: \(accessRight.getRecordExportable())
                App Editable: \(accessRight.getAppEditable())
                ==========================================================================
                """)
            revision = response.getRevision()
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        self.deployApp(appModule: appModule, apps: [PreviewApp(appId)])
        return revision
    }
    
    /// Update Misc settings of App
    ///
    /// - Parameters:
    ///   - appModule: App | App module
    ///   - code: String | App code
    ///   - id: Int | App id
    ///   - name: String | App name
    ///   - decimalPrecision: Int | Decimal precision
    ///   - decimalScale: Int | Decimal scale
    ///   - enableBulkDeletion: Bool | Enable bulk deletion
    ///   - fiscalYearStartMonth: Int | Fiscal year start month
    ///   - roundingMode: String | Rounding mode
    ///   - useComment: Bool | Enable using comment
    ///   - useHistory: Bool | Enable using history
    ///   - useThumbnail: Bool | Enable using thumbnail
    static func updateMiscSetting(appModule: App,
                                  code: String,
                                  id: Int,
                                  name: String,
                                  decimalPrecision: Int = 16,
                                  decimalScale: Int = 4,
                                  enableBulkDeletion: Bool = false,
                                  fiscalYearStartMonth: Int = 4,
                                  roundingMode: String = "HALF_EVEN",
                                  useComment: Bool = true,
                                  useHistory: Bool = true,
                                  useThumbnail: Bool = true) {
        devAppModule.updateMiscSettings(code: code, id: id, name: name).then {
            print("""
                ==========================================================================
                Update misc settings in app \(id):
                code: \(code)
                decimalPrecision: \(decimalPrecision)
                decimalScale: \(decimalScale)
                enableBulkDeletion: \(enableBulkDeletion)
                fiscalYearStartMonth: \(fiscalYearStartMonth)
                roundingMode: \(roundingMode)
                useComment: \(useComment)
                useHistory: \(useHistory)
                useThumbnail: \(useThumbnail)
                ==========================================================================
                """)
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        self.deployApp(appModule: appModule, apps: [PreviewApp(id)])
    }
}

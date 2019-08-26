//
// kintone-ios-sdkTests
// Created on 8/22/19
// 

import Promises
import kintone_ios_sdk

open class DevRecord: NSObject {
    var devConnection: DevConnection?
    var parser = DevAppParser()
    let baseDevUrl = "/k/v1/record/{API_NAME}.json"
    
    public init(_ connection: DevConnection?) {
        self.devConnection = connection
    }
    
    func updateRecordPermissions(_ appId: Int, _ rights: [RecordRightEntity]) -> Promise<UpdateRecordPermissionsResponse> {
        return Promise<UpdateRecordPermissionsResponse> {fulfill, reject in
            do {
                let updateAppPermissionsRequest = UpdateRecordPermissionsRequest(appId, rights)
                let body = try self.parser.parseObject(updateAppPermissionsRequest)
                let jsonBody = String(data: body, encoding: .utf8)!
                self.devConnection?.request(self.baseDevUrl, "PUT", "acl", jsonBody).then {response in
                    let parseResponseToJson = try self.parser.parseJson(UpdateRecordPermissionsResponse.self, response)
                    fulfill(parseResponseToJson)
                    }.catch {error in
                        reject(error)
                }
            } catch {
                reject(error)
            }
        }
    }
}

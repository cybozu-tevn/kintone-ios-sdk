//
// kintone-ios-sdkTests
// Created on 5/29/19
//

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class UploadFileTest: QuickSpec {
    override func spec() {
        // the app has attachment field
        let appId: Int! = TestConstant.InitData.APP_ID
        let recordTextField: String! = TestConstant.InitData.TEXT_FIELD
        let recordAttachmentField: String! = TestConstant.InitData.ATTACHMENT_FIELD
        var recordId: Int!

        let conn = TestCommonHandling.createConnection()
        let recordModule = Record(conn)
        let fileModule = File(conn)
    
        describe("UploadFile") {
            afterSuite {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId!]))
            }
            
            it("Test_002_003_Success_UploadFile") {
                let bundleUploadFile = Bundle(for: type(of: self))
                var recordTestData: [String: FieldValue] = [:]
                recordTestData = RecordUtils.setRecordData(
                    recordTestData,
                    recordTextField,
                    FieldType.SINGLE_LINE_TEXT,
                    "Upload single file")
                
                if let uploadFilePath = bundleUploadFile.url(forResource: "test", withExtension: "txt") {
                    let resourcesFile = try! uploadFilePath.resourceValues(forKeys: [.fileSizeKey])
                    let expectedFileSize = resourcesFile.fileSize
                    let expectedFileName = uploadFilePath.lastPathComponent
                    let expectedFileContent = try! String(contentsOf: uploadFilePath, encoding: String.Encoding.unicode)
                    
                    // prepare upload files
                    let uploadFileResponse1 = TestCommonHandling.awaitAsync(fileModule.upload(uploadFilePath.absoluteString)) as! FileModel
                    let uploadFileResponse2 = TestCommonHandling.awaitAsync(fileModule.upload(uploadFilePath.absoluteString)) as! FileModel
                    let fileList = [uploadFileResponse1, uploadFileResponse2]
                    recordTestData = RecordUtils.setRecordData(recordTestData, recordAttachmentField, FieldType.FILE, fileList)
                    
                    //upload files and get data
                    let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, recordTestData)) as! AddRecordResponse
                    recordId = addRecordResponse.getId()!
                    let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                    let fileResults = getRecordResponse.getRecord()![recordAttachmentField]!.getValue() as! [FileModel]
                    for fileResult in fileResults {
                        if let downloadDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                            let filePath = downloadDir.appendingPathComponent(fileResult.getName()!)
                            fileModule.download(fileResult.getFileKey()!, filePath.absoluteString).then {
                                let actualResourcesFile = try! filePath.resourceValues(forKeys: [.fileSizeKey])
                                let actualFileName = filePath.lastPathComponent
                                let actualFileSize = actualResourcesFile.fileSize
                                let actualFileContent = try! String(contentsOf: filePath, encoding: String.Encoding.unicode)
                                expect(actualFileName).to(equal(expectedFileName))
                                expect(actualFileSize).to(equal(expectedFileSize))
                                expect(actualFileContent).to(equal(expectedFileContent))
                                }.catch {error in
                                    expect(error).to(beNil())
                            }
                        }
                    }
                }
            }
            
            it("Test_004_Error_UploadNoneExistFilePath") {
                fileModule.upload("none_exist_file_path").catch { error in
                    expect(error).toNot(beNil())
                }
            }
        }
    }
}

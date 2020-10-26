//
//  DownloadManager.swift
//  PDFSign
//
//  Created by kawu on 9/10/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Zip

protocol DownloadManagerDelegate: class {
    func downloadComplete(filename: String, folderpath: URL?)
}

class DownloadManager {
    static let shared = DownloadManager()
    static var downloadDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    static var downloadDirectoryURL: URL? {
        return FileManager.directoryUrl(in: .documentDirectory, path: "")
    }

    var downloadedDocument: [String: URL] = [:] // Filename: FileURL
    var savedDocument: [String: FormInfo] = [:] // Filename: FormInfo

    weak var delegate: DownloadManagerDelegate?

    private let formService = FormService()

    func downloadPDF(formId: String, custId: String, fileURL: String, filename: String, guid: String) {

        if let fileURL = downloadedDocument[filename] {
            delegate?.downloadComplete(filename: filename, folderpath: fileURL)
            return
        }

        let filepath = "\(fileURL)\(filename)"
        formService.onResponse = { [weak self] (response) in
            guard let targetDirectory = DownloadManager.downloadDirectory,
                let result = response.model as? GetDataResult,
                let encoded = result.dataString.data(using: .utf8),
                let data = Data(base64Encoded: encoded)
            else { return }

            let targetURL = targetDirectory.appendingPathComponent("\(filename)")
            do {
                // Write file to local directory
                try data.write(to: targetURL)

                // Unzip file
                let path = try Zip.quickUnzipFile(targetURL)
                let folder = path.lastPathComponent
                let folderURL = path.appendingPathComponent(folder)

                self?.downloadedDocument[filename] = folderURL
                self?.delegate?.downloadComplete(filename: filename, folderpath: folderURL)
            } catch let error {
                print("Failed to decompress and write PDF data \(error.localizedDescription)")
            }
        }
        formService.getData(custId: custId, filepath: filepath, guid: guid)
    }
}

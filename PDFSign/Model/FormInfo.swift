//
//  FormInfo.swift
//  PDFSign
//
//  Created by kawu on 9/9/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Foundation

struct FormList {
    let forms: [FormInfo]
}

struct FormInfo: Hashable {
    var pdfId: String = ""
    var pdfName: String = ""
    var filename: String = ""
    var fileNameSource: String = ""
    var pageFolder: String = ""
    var firstFormId: String = ""
    var version: String = ""
    var localArchivedURL: URL?

    init(pdfId: String, pdfName: String, filename: String, fileNameSource: String, pageFolder: String, firstFormId: String, version: String) {
        self.pdfId = pdfId
        self.pdfName = pdfName
        self.filename = filename
        self.fileNameSource = fileNameSource
        self.pageFolder = pageFolder
        self.firstFormId = firstFormId
        self.version = version
    }

    init(dict: [String: Any]) {
        self.pdfId = dict["pdfID"] as? String ?? ""
        self.pdfName = dict["pdfName"] as? String ?? ""
        self.filename = dict["pdfFileName"] as? String ?? ""
        self.fileNameSource = dict["pdfFileNameSource"] as? String ?? ""
        self.pageFolder = dict["pageFolder"] as? String ?? ""
        self.firstFormId = dict["firstFormID"] as? String ?? ""
        self.version = dict["version"] as? String ?? ""
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("\(pdfId)_\(filename)")
    }
}

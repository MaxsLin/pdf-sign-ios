//
//  PDFDetails.swift
//  PDFSign
//
//  Created by kawu on 9/9/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit

struct PDFDetails {
    var info: FormInfo
    var pdfHeight: CGFloat
    var pdfWidth: CGFloat
    var allowAttach: Bool = false
    var simpleUIMode: Bool = false
    var pages: [PDFPageDetails] = []

    init(dict: [String: Any]) {
        self.info = FormInfo(dict: dict)
        self.pdfHeight = dict["pdfHeight"] as? CGFloat ?? 0
        self.pdfWidth = dict["pdfWidth"] as? CGFloat ?? 0
        self.allowAttach = dict["allowAttach"] as? Bool ?? false
        self.simpleUIMode = dict["simpleUIMode"] as? Bool ?? false

        if let pages = dict["pageList"] as? [[String: Any]] {
            self.pages = pages.map({ PDFPageDetails(dict: $0) })
        }
    }
}

struct PDFPageDetails {
    var number: Int
    var pageFilename: String
    var blocks: [BlockInfo] = []

    init(dict: [String: Any]) {
        self.number = dict["pageNo"] as? Int ?? 0
        self.pageFilename = dict["pageFileName"] as? String ?? ""

        if let blocks = dict["blockList"] as? [[String: Any]] {
            self.blocks = blocks.map({ BlockInfo(dict: $0) })
        }
    }
}

//
//  UploadManager.swift
//  PDFSign
//
//  Created by kawu on 9/28/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Foundation

class UploadFile {

    var filepath: String = ""
    var filename: String = ""
}

class UploadManager {
    static let shared = UploadManager()

    private let uploadQueue = DispatchQueue(label: "upload")
    private lazy var uploadOperationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "uploadQueue"
        queue.maxConcurrentOperationCount = 1
        queue.underlyingQueue = uploadQueue
        return queue
    }()

    func upload() {

    }
}

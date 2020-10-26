//
//  ArchivedListVC.swift
//  PDFSign
//
//  Created by kawu on 10/25/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Foundation
import UIKit

class ArchivedListVC: UIViewController {

    var files: [String: FormInfo] {
        return DownloadManager.shared.savedDocument
    }
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = .white

        title = "歸檔文件"

        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FormTableCell")
        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension ArchivedListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormTableCell", for: indexPath)
        cell.backgroundColor = .white
        cell.textLabel?.text = Array(files.values)[indexPath.row].pdfName
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile = Array(files.values)[indexPath.row]

        guard let folderpath = selectedFile.localArchivedURL?.deletingLastPathComponent() else { return }

        let vc = PDFViewerVC(folderpath: folderpath, formInfo: selectedFile)
        vc.reloadForm()
        let controller = UINavigationController(rootViewController: vc)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)

    }
}

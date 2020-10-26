//
//  DocumentListVC.swift
//  PDFSign
//
//  Created by kawu on 8/23/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import WebKit
import AVKit
import Zip

class DocumentListVC: UIViewController {

    var custId: String = ""
    var forms: [FormInfo] = []
    var kindFlows: [KindFlow] = []
    var selectedForm: FormInfo?

    private let formService = FormService()
    private let userService = UserService()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        userService.onResponse = { [weak self] (_) in
            self?.loadKindFlows()
        }
        userService.getRunMode(custId: custId)
    }

    func loadAllForms() {
        formService.onResponse = { [weak self] (response) in
            guard
                response.success,
                let forms = response.model as? [FormInfo]
            else { return }

            self?.forms = forms
        }
        formService.getAllForm(custId: custId)
    }

    func loadKindFlows() {
        userService.onResponse = { [weak self] (response) in
            guard let kindFlows = response.model as? [KindFlow] else { return }

            self?.kindFlows = kindFlows
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        userService.getKindFlow(custId: custId)
    }

    func selectForm(_ form: FormInfo) {
        let id = form.pdfId
        let filename = form.pageFolder

        self.selectedForm = form

        formService.onResponse = { [weak self] (response) in
            guard response.success, let result = response.model as? CheckFileResult else { return }

            self?.downloadPdf(formId: id, fileURL: result.fileURL, filename: filename, guid: result.guid)
        }
        formService.checkFile(custId: custId, filename: filename)
    }

    func downloadPdf(formId: String, fileURL: String, filename: String, guid: String) {
        let filepath = "\(fileURL)\(filename)"
        let downloader = DownloadManager.shared
        downloader.delegate = self
        downloader.downloadPDF(formId: formId, custId: custId, fileURL: fileURL, filename: filename, guid: guid)
    }

    private func setupViews() {
        view.backgroundColor = .white

        title = "業務"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(onDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(onSavedFiles))

        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FormTableCell")
        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    @objc private func onSavedFiles() {
        let controller = UINavigationController(rootViewController: ArchivedListVC())
        navigationController?.pushViewController(ArchivedListVC(), animated: true)
    }

    @objc private func onDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension DocumentListVC: DownloadManagerDelegate {
    func downloadComplete(filename: String, folderpath: URL?) {
        guard let path = folderpath, let form = selectedForm else { return }

        DispatchQueue.main.async { [weak self] in
            let vc = PDFViewerVC(folderpath: path, formInfo: form)
            vc.loadFormDetails()
            let controller = UINavigationController(rootViewController: vc)
            controller.modalPresentationStyle = .fullScreen
            self?.present(controller, animated: true, completion: nil)
        }
    }
}

extension DocumentListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return kindFlows.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kindFlows[section].forms.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return kindFlows[section].kindName
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workflow = kindFlows[indexPath.section]
        let cell = UITableViewCell(frame: .zero)
        cell.backgroundColor = .white
        cell.textLabel?.text = workflow.forms[indexPath.row].pdfName
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedForm = kindFlows[indexPath.section].forms[indexPath.row]

        selectForm(selectedForm)
    }
}

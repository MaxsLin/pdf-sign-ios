//
//  PDFSimpleEditorVC.swift
//  PDFSign
//
//  Created by kawu on 9/18/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit

class PDFSimpleEditorVC: UIViewController {
    var pdfDetails: PDFDetails?

    private let scrollView = UIScrollView()
    private let formView = FormView()

    var modifiedBlocks: [String: String] = [:]

    convenience init(pdfDetails: PDFDetails) {
        self.init()
        self.pdfDetails = pdfDetails
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.loadFormDetails()
    }

    func loadFormDetails() {
        guard let blocks = pdfDetails?.pages.first?.blocks else { return }

        for block in blocks {
            if block.type == .text {
                let cell = LabelInputCell()
                cell.label.text = block.name
                cell.textField.autocorrectionType = .no
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.onChange = { [unowned self] (text) in

                }

                formView.addCell(cell)
                formView.axis = .vertical
            }
        }
    }

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(formView)

        scrollView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        formView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.width.equalToSuperview()
        }
    }
}

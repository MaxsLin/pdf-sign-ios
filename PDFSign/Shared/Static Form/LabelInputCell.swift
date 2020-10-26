//
//  LabelInputCell.swift
//  PDFSign
//
//  Created by kawu on 9/18/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit

class LabelInputCell: StaticCell {

    override var definedHeight: CGFloat { return 50 }

    let label = UILabel()
    let textField = TextField()

    override func setup() {
        setupViews()
    }

    var isEditable: Bool = true {
        didSet {
            textField.isEnabled = isEditable
            textField.textColor = isEditable ? .black : .gray
            textField.font = isEditable ? UIFont.systemFont(ofSize: 11) : UIFont.systemFont(ofSize: 11).italics()
        }
    }

    private func setupViews() {
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)

        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 11)

        addSubview(label)
        addSubview(textField)

        label.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview().offset(15)
        }

        textField.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalTo(label.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}

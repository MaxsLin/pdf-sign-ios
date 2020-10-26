//
//  SignatureVC.swift
//  PDFSign
//
//  Created by kawu on 9/25/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit
import UberSignature

protocol SignatureVCDelegate: class {
    func didFinishSign(image: UIImage?)
}

class SignatureVC: UIViewController {

    var signatureView: UIView {
        return signatureController.view
    }
    var signatureColor: UIColor {
        get {
            return signatureController.signatureColor
        }
        set {
            signatureController.signatureColor = newValue
        }
    }

    weak var delegate: SignatureVCDelegate?

    private var signatureController: SignatureDrawingViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        signatureController = SignatureDrawingViewController(image: nil)
//        signatureController.delegate = self

        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(signatureView)

        modalPresentationStyle = .fullScreen
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(onDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone))

        signatureView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        signatureView.setRoundedCorners(cornerRadius: 10)

        let line = UIView()
        line.backgroundColor = .lightGray
        view.addSubview(line)

        let pencil = UIImageView(image: UIImage(systemName: "pencil.and.outline"))
        pencil.tintColor = .lightGray
        view.addSubview(pencil)

        let resetButton = UIButton(type: .system)
        resetButton.setImage(UIImage(systemName: "trash"), for: .normal)
        resetButton.tintColor = .gray
        resetButton.addTarget(self, action: #selector(onReset), for: .touchUpInside)
        view.addSubview(resetButton)

        signatureView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(250)
        }

        line.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalTo(signatureView.snp.bottom).offset(-20)
            make.height.equalTo(1)
        }

        pencil.snp.makeConstraints { (make) in
            make.leading.equalTo(line.snp.leading).offset(5)
            make.bottom.equalTo(line.snp.top).offset(-5)
            make.width.height.equalTo(20)
        }

        resetButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(line.snp.trailing).offset(-5)
            make.bottom.equalTo(line.snp.top).offset(-5)
            make.width.height.equalTo(15)
        }
    }

    @objc private func onReset() {
        signatureController.reset()
    }

    @objc private func onDone() {
        delegate?.didFinishSign(image: signatureController.fullSignatureImage)
        dismiss(animated: true, completion: nil)
    }

    @objc private func onDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

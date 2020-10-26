//
//  ViewController.swift
//  PDFSign
//
//  Created by kawu on 7/20/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    var custId: String = ""
    var password: String = ""
    let service = UserService()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }

    func registerDevice() {
        service.onResponse = { [weak self] (response) in
            guard let message = response.model as? UserRequest.RegisterDeviceMessage else { return }

            switch message {
            case .success:
                print("registerDevice success")

                guard let id = self?.custId, let password = self?.password else { return }
                self?.login(custId: id, password: password)
            case .deviceWasRegistered:
                print("registerDevice deviceWasRegistered")
            case .deviceExceededLimit:
                print("registerDevice: deviceExceededLimit")
            }
        }
        service.registerDevice(custId: custId)
    }

    func login(custId: String, password: String) {
        service.onResponse = { [weak self] (response) in
            guard let message = response.model as? UserRequest.LoginMessage else { return }

            switch message {
            case .success:
                self?.custId = custId
                self?.password = password
                print("Login success")

                UserService.custId = custId

                DispatchQueue.main.async {
                    let vc = DocumentListVC()
                    vc.custId = custId
                    let controller = UINavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    self?.present(controller, animated: true, completion: nil)
                }

                // Staff login
//                self?.service.checkStaffLogin(custId: custId, accountId: "user1", password: "222222")
//                self?.service.changeStaffPassword(custId: custId, accountId: "user2", password: "0000")
                break
            case .changePassword:
                self?.custId = custId
                self?.password = password
                break
            case .deviceNotRegistered:
                self?.custId = custId
                self?.password = password
                self?.registerDevice()
            default:
                break
            }
        }
        service.checkLogin(custId: custId, password: password)
    }

    private func setupViews() {
        loginButton.isEnabled = false

        accountTextField.delegate = self
        passwordTextField.delegate = self
    }

    @IBAction func didTapOnLogin(_ sender: Any) {
        guard let account = accountTextField.text, let password = passwordTextField.text else { return }

        login(custId: account, password: password)
    }
}

extension ViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let account = accountTextField.text, let password = passwordTextField.text {
            loginButton.isEnabled = !account.isEmpty && !password.isEmpty
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        loginButton.isEnabled = false
        return true
    }
}

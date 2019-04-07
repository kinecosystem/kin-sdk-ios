//
//  RestoreViewController.swift
//  KinEcosystem
//
//  Created by Elazar Yifrach on 29/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

protocol RestoreViewControllerDelegate: NSObjectProtocol {
    func restoreViewController(_ viewController: RestoreViewController, importWith password: String) -> RestoreViewController.ImportResult
    func restoreViewControllerDidComplete(_ viewController: RestoreViewController)
}

class RestoreViewController: ViewController {
    weak var delegate: RestoreViewControllerDelegate?

    let qrImage: UIImage?

    // MARK: View

    private var imageView: UIImageView {
        return _view.imageView
    }

    private var passwordInput: PasswordEntryTextField {
        return _view.passwordInput
    }

    private var doneButton: ConfirmButton {
        return _view.doneButton
    }

    var _view: RestoreView {
        return view as! RestoreView
    }

    var classForView: RestoreView.Type {
        return RestoreView.self
    }

    override func loadView() {
        view = classForView.self.init(frame: .zero)
    }

    // MARK: Lifecycle

    init(qrString: String) {
        self.qrImage = QR.encode(string: qrString)

        super.init(nibName: nil, bundle: nil)

        title = "restore.title".localized()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = qrImage

        passwordInput.addTarget(self, action: #selector(passwordInputChanges), for: .editingChanged)
        passwordInput.becomeFirstResponder()

        doneButton.isEnabled = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    @objc
    private func passwordInputChanges(_ textField: PasswordEntryTextField) {
        doneButton.isEnabled = textField.hasText
    }
    
    @objc
    private func doneButtonTapped(_ button: ConfirmButton) {
        guard !navigationItem.hidesBackButton else {
            // Button in mid transition
            return
        }

        guard let delegate = delegate else {
            return
        }

        button.isEnabled = false
        navigationItem.hidesBackButton = true
        
        let importResult = delegate.restoreViewController(self, importWith: passwordInput.text ?? "")

        if importResult == .success {
            button.transitionToConfirmed { () -> () in
                delegate.restoreViewControllerDidComplete(self)
            }
        }
        else {
            button.isEnabled = true
            navigationItem.hidesBackButton = false
            presentErrorAlertController(result: importResult)
        }
    }
}

// MARK: - Import Result

extension RestoreViewController {
    enum ImportResult {
        case success
        case wrongPassword
        case invalidImage
        case internalIssue
    }
}

extension RestoreViewController.ImportResult {
    var errorDescription: String? {
        switch self {
        case .success:
            return nil
        case .wrongPassword:
            return "restore.error.wrong_password".localized()
        case .invalidImage:
            return "restore.error.invalid_image".localized()
        case .internalIssue:
            return "restore.error.internal_issue".localized()
        }
    }
}

// MARK: - Error

extension RestoreViewController {
    fileprivate func presentErrorAlertController(result: ImportResult) {
        let alertController = UIAlertController(title: "restore.alert_error.title".localized(), message: result.errorDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "generic.ok".localized(), style: .cancel))
        present(alertController, animated: true)
    }
}

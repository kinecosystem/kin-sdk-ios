//
//  RestoreFlowController.swift
//  KinEcosystem
//
//  Created by Corey Werner on 23/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit
import KinSDK

class RestoreFlowController: FlowController {
    let kinClient: KinClient
    var importedKinAccount: KinAccount?

    init(kinClient: KinClient, navigationController: UINavigationController) {
        self.kinClient = kinClient
        super.init(navigationController: navigationController)
    }

    private var qrPickerController: QRPickerController?
    
    private lazy var _entryViewController: UIViewController = {
        let viewController = RestoreIntroViewController()
        viewController.delegate = self
        viewController.lifeCycleDelegate = self
        return viewController
    }()
    
    override var entryViewController: UIViewController {
        return _entryViewController
    }
}

extension RestoreFlowController: LifeCycleProtocol {
    func viewController(_ viewController: UIViewController, willAppear animated: Bool) {
        
    }
    
    func viewController(_ viewController: UIViewController, willDisappear animated: Bool) {
        cancelFlowIfNeeded(viewController)
    }
}

// MARK: - Navigation

extension RestoreFlowController {
    fileprivate func presentQRPickerViewController() {
        guard QRPickerController.canOpenImagePicker else {
            delegate?.flowController(self, error: KinBackupRestoreError.cantOpenImagePicker)
            return
        }
        
        let qrPickerController = QRPickerController()
        qrPickerController.delegate = self
        navigationController.present(qrPickerController.imagePickerController, animated: true)
        self.qrPickerController = qrPickerController
    }
    
    fileprivate func pushPasswordViewController(with qrString: String) {
        let restoreViewController = RestoreViewController(qrString: qrString)
        restoreViewController.delegate = self
        restoreViewController.lifeCycleDelegate = self
        navigationController.pushViewController(restoreViewController, animated: true)
    }
}

// MARK: - Flow

extension RestoreFlowController: RestoreIntroViewControllerDelegate {
    func restoreIntroViewControllerDidComplete(_ viewController: RestoreIntroViewController) {
        presentQRPickerViewController()
    }
}

extension RestoreFlowController: QRPickerControllerDelegate {
    func qrPickerControllerDidComplete(_ controller: QRPickerController, with qrString: String?) {
        controller.imagePickerController.presentingViewController?.dismiss(animated: true)
        importedKinAccount = nil

        if let qrString = qrString {
            pushPasswordViewController(with: qrString)
        }
    }
}

extension RestoreFlowController: RestoreViewControllerDelegate {
    func restoreViewController(_ viewController: RestoreViewController, importWith password: String) -> RestoreViewController.ImportResult {
        guard let qrImage = viewController.qrImage, let json = QR.decode(image: qrImage) else {
            return .invalidImage
        }

        do {
            importedKinAccount = try kinClient.importAccount(json, passphrase: password)
            return .success
        }
        catch {
            if case KeyUtilsError.passphraseIncorrect = error {
                return .wrongPassword
            }
            else {
                delegate?.flowController(self, error: error)
                return .internalIssue
            }
        }
    }
    
    func restoreViewControllerDidComplete(_ viewController: RestoreViewController) {
        // Delay to give the UX some time after the button animation.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegate?.flowControllerDidComplete(self)
            self.importedKinAccount = nil
        }
    }
}

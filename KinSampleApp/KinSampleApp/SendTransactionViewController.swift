//
//  SendTransactionViewController.swift
//  KinSampleApp
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK
import KinUtil

class SendTransactionViewController: UIViewController {

    var kinClient: KinClient!
    var kinAccount: KinAccount!

    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sendButton.fill(with: view.tintColor)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        amountTextField.becomeFirstResponder()
    }

    func whitelistTransaction(to url: URL, whitelistEnvelope: WhitelistEnvelope) -> Promise<TransactionEnvelope> {
        let promise: Promise<TransactionEnvelope> = Promise()

        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(whitelistEnvelope)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                promise.signal(error)
                return
            }

            guard let data = data, let envelope = try? JSONDecoder().decode(WhitelistEnvelope.self, from: data) else {
                promise.signal(KinError.unknown)
                return
            }

            promise.signal(envelope.transactionEnvelope)
        }

        task.resume()

        return promise
    }

    @IBAction func sendTapped(_ sender: Any) {
        let amount = Decimal(UInt64(amountTextField.text ?? "0") ?? 0)
        let address = addressTextField.text ?? ""
        
        promise(curry(kinAccount.generateTransaction)(address)(amount)(memoTextField.text))
            .then(on: .main) { [weak self] transactionEnvelope -> Promise<TransactionEnvelope> in
                let urlString = "" // TODO: url to whitelist sever

                guard let strongSelf = self, let url = URL(string: urlString) else {
                    return Promise().signal(KinError.unknown)
                }

                let whitelistEnvelope = WhitelistEnvelope(transactionEnvelope: transactionEnvelope, networkId: .mainNet)

                return strongSelf.whitelistTransaction(to: url, whitelistEnvelope: whitelistEnvelope)
            }
            .then(on: .main) { [weak self] transactionEnvelope -> Promise<TransactionId> in
                guard let strongSelf = self else {
                    return Promise().signal(KinError.unknown)
                }

                return promise(curry(strongSelf.kinAccount.sendTransaction)(transactionEnvelope))
            }
            .then(on: .main, { [weak self] transactionId in
                let message = "Transaction with ID \(transactionId) sent to \(address)"
                let alertController = UIAlertController(title: "Transaction Sent", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Copy Transaction ID", style: .default, handler: { _ in
                    UIPasteboard.general.string = transactionId
                }))
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
            })
            .error({ error in
                DispatchQueue.main.async { [weak self] in
                    let alertController = UIAlertController(title: "Error",
                                                            message: "\(error)",
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alertController, animated: true, completion: nil)
                }
            })
    }

    @IBAction func pasteTapped(_ sender: Any) {
        addressTextField.text = UIPasteboard.general.string
    }
}

extension SendTransactionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let notDigitsSet = CharacterSet.decimalDigits.inverted
        let containsNotADigit = string.unicodeScalars.contains(where: notDigitsSet.contains)

        return !containsNotADigit
    }
}

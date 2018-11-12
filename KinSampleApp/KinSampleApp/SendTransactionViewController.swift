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

    func a(_ transactionEnvelope: TransactionEnvelope) {
        // TODO: send envelope to whitelist server
        // !!!: this is sample code. needs to be moved to correct locations.

        struct WhiteListObj: Codable { // TODO: better object name
            let transactionEnvelope: TransactionEnvelope
            let networkId: NetworkId

            enum CodingKeys: String, CodingKey {
                case transactionEnvelope = "transaction"
                case networkId = "networkId"
            }

            init(transactionEnvelope: TransactionEnvelope, networkId: NetworkId) {
                self.transactionEnvelope = transactionEnvelope
                self.networkId = networkId
            }

            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)

                let transactionEnvelopeData = try values.decode(Data.self, forKey: .transactionEnvelope)
                transactionEnvelope = try XDRDecoder.decode(TransactionEnvelope.self, data: transactionEnvelopeData)

                networkId = try values.decode(NetworkId.self, forKey: .networkId)
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                let transactionEnvelopeData = try XDREncoder.encode(transactionEnvelope)
                try container.encode(transactionEnvelopeData, forKey: .transactionEnvelope)

                try container.encode(networkId, forKey: .networkId)
            }
        }

        let wlo = WhiteListObj(transactionEnvelope: transactionEnvelope, networkId: .mainNet)

        do {
            let data = try JSONEncoder().encode(wlo)
//            let b = try JSONDecoder().decode(WhiteListObj.self, from: data)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            print("\(json)")
        }
        catch {}
    }

    @IBAction func sendTapped(_ sender: Any) {
        let amount = Decimal(UInt64(amountTextField.text ?? "0") ?? 0)
        let address = addressTextField.text ?? ""
        
        promise(curry(kinAccount.generateTransaction)(address)(amount)(memoTextField.text))
            .then(on: .main) { [weak self] transactionEnvelope -> Promise<TransactionId> in
                guard let strongSelf = self else {
                    return Promise().signal(KinError.unknown)
                }

                strongSelf.a(transactionEnvelope)

                return promise(curry(strongSelf.kinAccount.sendTransaction)(transactionEnvelope))
            }
            .then(on: DispatchQueue.main, { [weak self] transactionId in
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

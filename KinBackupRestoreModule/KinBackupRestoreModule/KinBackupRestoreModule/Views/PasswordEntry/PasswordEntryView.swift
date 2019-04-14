//
//  PasswordEntryView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 19/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class PasswordEntryView: KeyboardAdjustingScrollView {
    let passwordInfoLabel = PasswordEntryLabel()
    let passwordTextField = PasswordEntryTextField()
    let passwordConfirmTextField = PasswordEntryTextField()
    private let confirmStackView = UIStackView()
    private let confirmImageView = CheckboxImageView()
    let doneButton = RoundButton()

    // MARK: Lifecycle

    required init(frame: CGRect) {
        super.init(frame: frame)

        addArrangedVerticalSpaceSubview(height: 30)

        let titleLabel = UILabel()
        titleLabel.text = "password_entry.title".localized()
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .kinDarkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addArrangedSubview(titleLabel)

        addArrangedVerticalSpaceSubview(height: 20)

        passwordInfoLabel.instructionsAttributedString = NSAttributedString(attributedStrings: [
            NSAttributedString(string: "password_entry.instructions".localized(), attributes: [.foregroundColor: UIColor.kinDarkGray]),
            NSAttributedString(string: "password_entry.pattern".localized(), attributes: [.foregroundColor: UIColor.kinGray])
            ])
        passwordInfoLabel.mismatchAttributedString = NSAttributedString(string: "password_entry.mismatch".localized(), attributes: [.foregroundColor: UIColor.kinWarning])
        passwordInfoLabel.invalidAttributedString = NSAttributedString(attributedStrings: [
            NSAttributedString(string: "password_entry.invalid".localized(), attributes: [.foregroundColor: UIColor.kinWarning]),
            NSAttributedString(string: "password_entry.pattern".localized(), attributes: [.foregroundColor: UIColor.kinDarkGray])
            ])
        passwordInfoLabel.font = .preferredFont(forTextStyle: .body)
        passwordInfoLabel.numberOfLines = 0
        passwordInfoLabel.textAlignment = .center
        passwordInfoLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addArrangedSubview(passwordInfoLabel)

        addArrangedVerticalSpaceSubview(height: 20)

        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password_entry.password.placeholder".localized(), attributes: [.foregroundColor: UIColor.kinGray])
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addArrangedSubview(passwordTextField)

        passwordConfirmTextField.attributedPlaceholder = NSAttributedString(string: "password_entry.password_confirm.placeholder".localized(), attributes: [.foregroundColor: UIColor.kinGray])
        passwordConfirmTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordConfirmTextField.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addArrangedSubview(passwordConfirmTextField)

        confirmStackView.alignment = .center
        confirmStackView.spacing = contentView.spacing
        contentView.addArrangedSubview(confirmStackView)

        confirmStackView.addArrangedSubview(confirmImageView)

        let confirmLabel = UILabel()
        confirmLabel.text = "password_entry.confirmation".localized()
        confirmLabel.font = .preferredFont(forTextStyle: .footnote)
        confirmLabel.textColor = .kinDarkGray
        confirmLabel.numberOfLines = 0
        confirmLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        confirmStackView.addArrangedSubview(confirmLabel)

        addArrangedVerticalLayoutSubview()

        let doneButtonStackView = UIStackView()
        doneButtonStackView.axis = .vertical
        doneButtonStackView.alignment = .center
        contentView.addArrangedSubview(doneButtonStackView)

        doneButton.isEnabled = false
        doneButton.setTitle("generic.next".localized(), for: .normal)
        doneButton.setContentCompressionResistancePriority(.required, for: .vertical)
        doneButtonStackView.addArrangedSubview(doneButton)
        doneButton.widthAnchor.constraint(equalTo: passwordTextField.widthAnchor).isActive = true

        addArrangedVerticalLayoutSubview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Interaction

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if touches.first?.view == confirmStackView,
            let point = touches.first?.location(in: self),
            hitTest(point, with: event) == confirmStackView
        {
            confirmImageView.isHighlighted = !confirmImageView.isHighlighted
            updateDoneButton()
        }
    }

    // MARK: View Updates

    @objc
    func textFieldDidChange(_ textField: UITextField) {
        updateDoneButton()
    }

    func updateDoneButton() {
        doneButton.isEnabled = passwordTextField.hasText && passwordConfirmTextField.hasText && confirmImageView.isHighlighted
    }
}

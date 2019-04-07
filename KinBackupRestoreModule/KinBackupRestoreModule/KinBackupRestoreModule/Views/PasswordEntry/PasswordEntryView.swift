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
    private let textFieldStackView = UIStackView()
    let passwordTextField = PasswordEntryTextField()
    let passwordConfirmTextField = PasswordEntryTextField()
    private let confirmStackView = UIStackView()
    let confirmLabel = UILabel()
    private let confirmImageView = CheckboxImageView()
    let doneButton = RoundButton()

    // MARK: Lifecycle

    required override init(frame: CGRect) {
        super.init(frame: frame)

        addArrangedVerticalLayoutSubview()

        passwordInfoLabel.font = .preferredFont(forTextStyle: .body)
        passwordInfoLabel.numberOfLines = 0
        passwordInfoLabel.textAlignment = .center
        passwordInfoLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addArrangedSubview(passwordInfoLabel)

        addArrangedVerticalLayoutSubview()

        textFieldStackView.spacing = contentView.spacing
        textFieldStackView.distribution = .fillEqually
        contentView.addArrangedSubview(textFieldStackView)

        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.setContentCompressionResistancePriority(.required, for: .vertical)
        textFieldStackView.addArrangedSubview(passwordTextField)

        passwordConfirmTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordConfirmTextField.setContentCompressionResistancePriority(.required, for: .vertical)
        textFieldStackView.addArrangedSubview(passwordConfirmTextField)

        confirmStackView.alignment = .center
        confirmStackView.spacing = contentView.spacing
        contentView.addArrangedSubview(confirmStackView)

        confirmStackView.addArrangedSubview(confirmImageView)

        confirmLabel.font = .preferredFont(forTextStyle: .footnote)
        confirmLabel.textColor = .kinGray
        confirmLabel.numberOfLines = 0
        confirmLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        confirmStackView.addArrangedSubview(confirmLabel)

        addArrangedVerticalLayoutSubview()

        let doneButtonStackView = UIStackView()
        doneButtonStackView.axis = .vertical
        doneButtonStackView.alignment = .center
        contentView.addArrangedSubview(doneButtonStackView)

        doneButton.appearance = .blue
        doneButton.isEnabled = false
        doneButton.setContentCompressionResistancePriority(.required, for: .vertical)
        doneButtonStackView.addArrangedSubview(doneButton)
        doneButton.widthAnchor.constraint(equalTo: passwordTextField.widthAnchor).isActive = true

        addArrangedVerticalLayoutSubview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        textFieldStackView.axis = traitCollection.verticalSizeClass == .compact ? .horizontal : .vertical
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

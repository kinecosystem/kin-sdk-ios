//
//  RestoreView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 24/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class RestoreView: KeyboardAdjustingScrollView {
    let imageView = UIImageView()
    let passwordInput = PasswordEntryTextField()
    let doneButton = ConfirmButton()

    private var regularConstraints: [NSLayoutConstraint] = []

    // MARK: Lifecycle

    required override init(frame: CGRect) {
        super.init(frame: frame)

        let imageViewStackView = UIStackView()
        imageViewStackView.axis = .vertical
        imageViewStackView.alignment = .center
        imageViewStackView.spacing = contentView.spacing
        contentView.addArrangedSubview(imageViewStackView)

        addArrangedVerticalLayoutSubview(to: imageViewStackView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageViewStackView.addArrangedSubview(imageView)
        imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        regularConstraints += [
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ]

        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = contentView.spacing
        contentView.addArrangedSubview(contentStackView)

        addArrangedVerticalSpaceSubview(to: contentStackView)

        let instructionsLabel = UILabel()
        instructionsLabel.text = "restore.description".localized()
        instructionsLabel.font = .preferredFont(forTextStyle: .body)
        instructionsLabel.textColor = .kinGray
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentStackView.addArrangedSubview(instructionsLabel)

        addArrangedVerticalSpaceSubview(to: contentStackView)

        passwordInput.attributedPlaceholder = NSAttributedString(string: "restore.password.placeholder".localized(), attributes: [.foregroundColor: UIColor.kinGray])
        passwordInput.isSecureTextEntry = true
        passwordInput.setContentCompressionResistancePriority(.required, for: .vertical)
        passwordInput.setContentHuggingPriority(.required, for: .vertical)
        contentStackView.addArrangedSubview(passwordInput)

        doneButton.appearance = .blue
        doneButton.setTitle("generic.next".localized(), for: .normal)
        doneButton.setContentCompressionResistancePriority(.required, for: .vertical)
        doneButton.setContentHuggingPriority(.required, for: .vertical)
        contentStackView.addArrangedSubview(doneButton)

        addArrangedVerticalLayoutSubview(to: contentStackView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.verticalSizeClass == .compact {
            contentView.axis = .horizontal
            contentView.distribution = .fillEqually

            NSLayoutConstraint.deactivate(regularConstraints)
        }
        else {
            contentView.axis = .vertical
            contentView.distribution = .fill

            NSLayoutConstraint.activate(regularConstraints)
        }
    }
}

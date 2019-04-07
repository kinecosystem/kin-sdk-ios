//
//  QRView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 20/03/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class QRView: KeyboardAdjustingScrollView {
    let imageView = UIImageView()
    private let instructionsLabel = UILabel()
    let confirmControl = UIControl()
    private let confirmImageView = CheckboxImageView()
    let doneButton = RoundButton()

    private var regularConstraints: [NSLayoutConstraint] = []

    // MARK: Lifecycle

    required override init(frame: CGRect) {
        super.init(frame: frame)

        let imageViewStackView = UIStackView()
        imageViewStackView.axis = .vertical
        imageViewStackView.alignment = .center
        imageViewStackView.spacing = contentView.spacing
        contentView.addArrangedSubview(imageViewStackView)

        addArrangedVerticalLayoutSubview(to: imageViewStackView, sizeClass: .regular)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageViewStackView.addArrangedSubview(imageView)
        imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        regularConstraints += [
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ]

        addArrangedVerticalSpaceSubview(to: imageViewStackView, height: 10, sizeClass: .regular)

        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = contentView.spacing
        contentView.addArrangedSubview(contentStackView)

        addArrangedVerticalLayoutSubview(to: contentStackView, sizeClass: .compact)

        instructionsLabel.text = "qr.description".localized()
        instructionsLabel.font = .preferredFont(forTextStyle: .body)
        instructionsLabel.textColor = .kinGray
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        instructionsLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentStackView.addArrangedSubview(instructionsLabel)

        addArrangedVerticalSpaceSubview(to: contentStackView, height: 10)

        let reminderView = ReminderView()
        reminderView.tintColor = .kinWarning
        reminderView.setContentCompressionResistancePriority(.required, for: .vertical)
        reminderView.setContentHuggingPriority(.required, for: .vertical)
        contentStackView.addArrangedSubview(reminderView)

        addArrangedVerticalSpaceSubview(to: contentStackView, height: 10)

        confirmControl.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        contentStackView.addArrangedSubview(confirmControl)

        let confirmStackView = UIStackView()
        confirmStackView.translatesAutoresizingMaskIntoConstraints = false
        confirmStackView.axis = .horizontal
        confirmStackView.spacing = contentView.spacing
        confirmStackView.alignment = .center
        confirmStackView.isUserInteractionEnabled = false
        confirmControl.addSubview(confirmStackView)
        confirmStackView.topAnchor.constraint(equalTo: confirmControl.topAnchor).isActive = true
        confirmStackView.leadingAnchor.constraint(greaterThanOrEqualTo: confirmControl.leadingAnchor).isActive = true
        confirmStackView.bottomAnchor.constraint(equalTo: confirmControl.bottomAnchor).isActive = true
        confirmStackView.trailingAnchor.constraint(lessThanOrEqualTo: confirmControl.trailingAnchor).isActive = true
        confirmStackView.centerXAnchor.constraint(equalTo: confirmControl.centerXAnchor).isActive = true

        confirmStackView.addArrangedSubview(confirmImageView)

        let confirmLabel = UILabel()
        confirmLabel.text = "qr.saved".localized()
        confirmLabel.font = .preferredFont(forTextStyle: .body)
        confirmLabel.textColor = .kinGray
        confirmStackView.addArrangedSubview(confirmLabel)

        addArrangedVerticalSpaceSubview(to: contentStackView)

        doneButton.appearance = .blue
        doneButton.setTitle("qr.save".localized(), for: .normal)
        doneButton.setTitle("generic.next".localized(), for: .selected)
        doneButton.setContentCompressionResistancePriority(.required, for: .vertical)
        doneButton.setContentHuggingPriority(.required, for: .vertical)
        contentStackView.addArrangedSubview(doneButton)

        addArrangedVerticalLayoutSubview(to: contentStackView, sizeClass: .compact)
        addArrangedVerticalLayoutSubview(to: contentStackView, sizeClass: .regular)
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

    // MARK: Confirm

    var isConfirmed: Bool {
        return confirmImageView.isHighlighted
    }

    @objc
    private func confirmAction() {
        confirmImageView.isHighlighted = !confirmImageView.isHighlighted
    }
}

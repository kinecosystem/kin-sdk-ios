//
//  ReminderView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 20/03/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class ReminderView: UIView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.setContentHuggingPriority(.required, for: .vertical)
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        let topContainerView = UIView()
        topContainerView.setContentHuggingPriority(.required, for: .vertical)
        stackView.addArrangedSubview(topContainerView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintAdjustmentMode = .normal
        imageView.image = UIImage(named: "Flag", in: .backupRestore, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        topContainerView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: topContainerView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "reminder.title".localized()
        titleLabel.font = .preferredFont(forTextStyle: .callout, symbolicTraits: [.traitBold])
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        topContainerView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topContainerView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 7).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor).isActive = true

        detailLabel.text = "reminder.description".localized()
        detailLabel.font = .preferredFont(forTextStyle: .footnote)
        detailLabel.numberOfLines = 0
        detailLabel.textAlignment = .center
        detailLabel.setContentHuggingPriority(.required, for: .vertical)
        stackView.addArrangedSubview(detailLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Appearance

    override var tintColor: UIColor! {
        didSet {
            imageView.tintColor = tintColor
            titleLabel.textColor = tintColor
            detailLabel.textColor = tintColor
        }
    }
}

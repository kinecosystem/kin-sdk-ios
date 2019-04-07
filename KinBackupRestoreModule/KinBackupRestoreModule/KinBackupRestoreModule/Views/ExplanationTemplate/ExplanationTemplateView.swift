//
//  ExplanationTemplateView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 25/03/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class ExplanationTemplateView: KeyboardAdjustingScrollView {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let doneButton = RoundButton()

    // MARK: Lifecycle

    required override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .kinPrimary

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

        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = contentView.spacing
        contentView.addArrangedSubview(contentStackView)

        addArrangedVerticalSpaceSubview(to: contentStackView, height: 20, sizeClass: .regular)
        addArrangedVerticalLayoutSubview(to: contentStackView, sizeClass: .compact)

        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentStackView.addArrangedSubview(titleLabel)

        addArrangedVerticalSpaceSubview(to: contentStackView, height: 20)

        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentStackView.addArrangedSubview(descriptionLabel)

        addArrangedVerticalSpaceSubview(to: contentStackView, height: 10)

        doneButton.appearance = .white
        doneButton.setContentCompressionResistancePriority(.required, for: .vertical)
        doneButton.setContentHuggingPriority(.required, for: .vertical)
        contentStackView.addArrangedSubview(doneButton)

        addArrangedVerticalLayoutSubview(to: contentStackView, sizeClass: .regular)
        addArrangedVerticalLayoutSubview(to: contentStackView, sizeClass: .compact)

        contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
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
        }
        else {
            contentView.axis = .vertical
            contentView.distribution = .fill
        }
    }
}

//
//  KeyboardAdjustingScrollView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 24/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class KeyboardAdjustingScrollView: UIScrollView {
    let contentView = UIStackView()

    private var contentLayoutGuideBottomConstraint: NSLayoutConstraint?
    private var bottomLayoutHeightConstraint: NSLayoutConstraint?
    var bottomLayoutHeight: CGFloat = 0 {
        didSet {
            let bottomOffset = traitCollection.verticalSizeClass == .compact ? layoutMargins.bottom : layoutMargins.left
            let bottomHeight = bottomLayoutHeight + bottomOffset

            contentLayoutGuideBottomConstraint?.constant = -bottomHeight
            bottomLayoutHeightConstraint?.constant = bottomHeight
        }
    }

    // MARK: Lifecycle

    required override init(frame: CGRect) {
        super.init(frame: frame)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrameNotification(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        backgroundColor = .white

        let contentLayoutGuide = UILayoutGuide()
        addLayoutGuide(contentLayoutGuide)
        contentLayoutGuide.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        contentLayoutGuideBottomConstraint = contentLayoutGuide.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        contentLayoutGuideBottomConstraint?.isActive = true

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.spacing = 10
        addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        let contentViewHeightConstraint = contentView.heightAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.heightAnchor)
        contentViewHeightConstraint.priority = .defaultHigh
        contentViewHeightConstraint.isActive = true

        let bottomLayoutView = UIView()
        bottomLayoutView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomLayoutView)
        bottomLayoutView.topAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomLayoutView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomLayoutHeightConstraint = bottomLayoutView.heightAnchor.constraint(equalToConstant: 0)
        bottomLayoutHeightConstraint?.isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Layout

    private var firstVerticalLayoutViewMap: [UIUserInterfaceSizeClass: UIView] = [:]
    private var regularVerticalViews: [UIView] = []
    private var compactVerticalViews: [UIView] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var compactConstraints: [NSLayoutConstraint] = []

    /**
     Add subview with a dynamic height.
     */
    func addArrangedVerticalLayoutSubview(to stackView: UIStackView? = nil, sizeClass: UIUserInterfaceSizeClass = .unspecified) {
        let layoutView = UIView()
        (stackView ?? contentView).addArrangedSubview(layoutView)
        let constraint: NSLayoutConstraint

        if let firstVerticalLayoutView = firstVerticalLayoutViewMap[sizeClass] {
            constraint = layoutView.heightAnchor.constraint(equalTo: firstVerticalLayoutView.heightAnchor)
        }
        else {
            firstVerticalLayoutViewMap[sizeClass] = layoutView

            constraint = layoutView.heightAnchor.constraint(equalTo: layoutMarginsGuide.heightAnchor, multiplier: 0.1)
            constraint.priority = .defaultLow
        }

        applyVerticalView(layoutView, constraint: constraint, sizeClass: sizeClass)
    }

    /**
     Add subview with a static height.
     */
    func addArrangedVerticalSpaceSubview(to stackView: UIStackView? = nil, height: CGFloat = 0, sizeClass: UIUserInterfaceSizeClass = .unspecified) {
        let spaceView = UIView()
        spaceView.setContentHuggingPriority(.required, for: .vertical)
        (stackView ?? contentView).addArrangedSubview(spaceView)
        let constraint = spaceView.heightAnchor.constraint(equalToConstant: height)
        applyVerticalView(spaceView, constraint: constraint, sizeClass: sizeClass)
    }

    private func applyVerticalView(_ verticalView: UIView, constraint: NSLayoutConstraint, sizeClass: UIUserInterfaceSizeClass) {
        switch sizeClass {
        case .regular:
            regularVerticalViews.append(verticalView)
            regularConstraints.append(constraint)
        case .compact:
            compactVerticalViews.append(verticalView)
            compactConstraints.append(constraint)
        case .unspecified:
            constraint.isActive = true
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.verticalSizeClass == .compact {
            NSLayoutConstraint.deactivate(regularConstraints)
            NSLayoutConstraint.activate(compactConstraints)
            regularVerticalViews.forEach({ $0.isHidden = true })
            compactVerticalViews.forEach({ $0.isHidden = false })
        }
        else {
            NSLayoutConstraint.deactivate(compactConstraints)
            NSLayoutConstraint.activate(regularConstraints)
            compactVerticalViews.forEach({ $0.isHidden = true })
            regularVerticalViews.forEach({ $0.isHidden = false })
        }
    }

    // MARK: Keyboard

    @objc
    private func keyboardWillChangeFrameNotification(_ notification: Notification) {
        let frame = notification.endFrame

        guard frame != .null else {
            return
        }

        // iPhone X keyboard has a height when it's not displayed.
        let bottomHeight = max(0, bounds.height - frame.origin.y - layoutMargins.bottom)

        scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomHeight, right: 0)

        let isViewOnScreen = layer.presentation() != nil

        if isViewOnScreen {
            UIView.animate(withDuration: notification.duration, delay: 0, options: notification.animationOptions, animations: { [weak self] in
                self?.bottomLayoutHeight = bottomHeight
                self?.layoutIfNeeded()
            })
        }
        else {
            bottomLayoutHeight = bottomHeight
        }
    }
}

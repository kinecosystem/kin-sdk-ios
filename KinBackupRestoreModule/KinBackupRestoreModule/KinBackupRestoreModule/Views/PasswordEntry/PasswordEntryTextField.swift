//
//  PasswordEntryTextField.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 20/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class PasswordEntryTextField: UITextField {
    private let paddingView = UIView()

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        isSecureTextEntry = true
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        backgroundColor = .white

        layer.borderWidth = 1
        layer.masksToBounds = true

        leftView = paddingView
        leftViewMode = .always

        let revealButton = UIButton()
        revealButton.setImage(UIImage(named: "Eye", in: .backupRestore, compatibleWith: nil), for: .normal)
        revealButton.addTarget(self, action: #selector(showPassword), for: .touchDown)
        revealButton.addTarget(self, action: #selector(hidePassword), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        revealButton.sizeToFit()
        var revealButtonFrame = revealButton.frame
        revealButtonFrame.size.width += 10
        revealButton.frame = revealButtonFrame
        rightView = revealButton
        rightViewMode = .whileEditing

        updateState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        let halfHeight = bounds.height / 2

        layer.cornerRadius = halfHeight

        var paddingViewFrame = paddingView.frame
        paddingViewFrame.size.width = halfHeight
        paddingView.frame = paddingViewFrame
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = 44
        return size
    }

    // MARK: State

    public var entryState: PasswordState = .default {
        didSet {
            updateState()
        }
    }
    
    private func updateState() {
        switch entryState {
        case .default:
            layer.borderColor = UIColor.kinGray.cgColor
        case .valid:
            layer.borderColor = UIColor.kinPrimary.cgColor
        case .invalid:
            layer.borderColor = UIColor.kinWarning.cgColor
        }
    }

    // MARK: Password
    
    @objc
    private func showPassword() {
        updateText(isSecure: false)
    }
    
    @objc
    private func hidePassword() {
        updateText(isSecure: true)
    }
    
    private func updateText(isSecure: Bool) {
        let isFirst = isFirstResponder

        if isFirst {
            resignFirstResponder()
        }

        isSecureTextEntry = isSecure

        if isFirst {
            becomeFirstResponder()
        }
    }
}

extension PasswordEntryTextField {
    enum PasswordState {
        case `default`
        case valid
        case invalid
    }
}

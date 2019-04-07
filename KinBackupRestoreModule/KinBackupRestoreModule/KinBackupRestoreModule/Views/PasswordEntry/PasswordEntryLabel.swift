//
//  PasswordEntryLabel.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 17/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class PasswordEntryLabel: UILabel {
    var instructionsAttributedString: NSAttributedString? {
        didSet {
            syncState()
        }
    }
    var mismatchAttributedString: NSAttributedString? {
        didSet {
            syncState()
        }
    }
    var invalidAttributedString: NSAttributedString? {
        didSet {
            syncState()
        }
    }

    // MARK: State

    var state: State = .instructions {
        didSet {
            syncState()
        }
    }

    private func syncState() {
        switch state {
        case .instructions:
            attributedText = instructionsAttributedString
        case .mismatch:
            attributedText = mismatchAttributedString
        case .invalid:
            attributedText = invalidAttributedString
        }
    }

    // MARK: Size

    private var instructionsHeight: CGFloat = 0
    private var mismatchHeight: CGFloat = 0
    private var invalidHeight: CGFloat = 0

    private func syncSize() {
        func height(with attributedString: NSAttributedString?) -> CGFloat {
            let string = attributedString?.string ?? ""
            let size = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
            return ceil(string.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height)
        }

        instructionsHeight = height(with: instructionsAttributedString)
        mismatchHeight = height(with: mismatchAttributedString)
        invalidHeight = height(with: invalidAttributedString)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        syncSize()
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize

        for height in [instructionsHeight, mismatchHeight, invalidHeight] {
            size.height = max(size.height, height)
        }

        return size
    }
}

// MARK: - State

extension PasswordEntryLabel {
    enum State {
        case instructions
        case mismatch
        case invalid
    }
}

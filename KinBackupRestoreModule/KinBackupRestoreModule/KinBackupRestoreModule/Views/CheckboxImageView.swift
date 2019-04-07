//
//  CheckboxImageView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 01/04/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class CheckboxImageView: UIImageView {
    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        tintColor = .kinPrimary
        highlightedImage = UIImage(named: "Checkmark", in: .backupRestore, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        layer.borderColor = UIColor.kinGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
        layer.masksToBounds = true
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 18, height: 18)
    }
}

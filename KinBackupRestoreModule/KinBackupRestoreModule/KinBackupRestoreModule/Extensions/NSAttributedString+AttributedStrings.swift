//
//  NSAttributedString+AttributedStrings.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 14/04/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

extension NSAttributedString {
    convenience init(attributedStrings: [NSAttributedString]) {
        let attributedString = NSMutableAttributedString()

        for i in 0..<attributedStrings.count {
            attributedString.append(attributedStrings[i])

            if i < attributedStrings.count - 1 {
                attributedString.append(NSAttributedString(string: "\n"))
            }
        }

        self.init(attributedString: attributedString)
    }
}
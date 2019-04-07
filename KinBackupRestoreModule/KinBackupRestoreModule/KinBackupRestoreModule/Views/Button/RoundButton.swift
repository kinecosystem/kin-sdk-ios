//
//  RoundButton.swift
//  KinEcosystem
//
//  Created by Corey Werner on 17/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    var appearance: Appearance = .blue {
        didSet {
            syncAppearance()
        }
    }

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        syncAppearance()
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = 44
        return size
    }

    // MARK: Interaction
    
    override var isEnabled: Bool {
        didSet {
            syncAppearance()
        }
    }
}

// MARK: Appearance

extension RoundButton {
    enum Appearance {
        case white
        case blue
    }

    fileprivate func syncAppearance() {
        switch appearance {
        case .white:
            backgroundColor = isEnabled ? .white : UIColor.white.withAlphaComponent(0.6)
            setTitleColor(.kinPrimary, for: .normal)
            setTitleColor(UIColor.kinPrimary.withAlphaComponent(0.5), for: .highlighted)
        case .blue:
            backgroundColor = isEnabled ? .kinPrimary : .kinLightGray
            setTitleColor(.white, for: .normal)
            setTitleColor(UIColor(white: 1, alpha: 0.5), for: .highlighted)
        }
    }
}

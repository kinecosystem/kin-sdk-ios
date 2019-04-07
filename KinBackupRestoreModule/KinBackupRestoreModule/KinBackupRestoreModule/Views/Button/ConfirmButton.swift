//
//  ConfirmButton.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 25/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class ConfirmButton: RoundButton {
    fileprivate var transitionToConfirmedCompletion: (()->())?

    override init(frame: CGRect) {
        super.init(frame: frame)

        appearance = .blue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transitionToConfirmed(completion: (()->())? = nil) {
        backgroundColor = .clear
        setBackgroundImage(nil, for: .normal)
        setTitleColor(.clear, for: .normal)
        isEnabled = false

        let shape = CAShapeLayer()
        shape.frame = bounds
        shape.fillColor = UIColor.kinPrimary.cgColor
        shape.strokeColor = UIColor.clear.cgColor
        shape.path = UIBezierPath(roundedRect: shape.bounds, cornerRadius: shape.bounds.height / 2).cgPath
        layer.addSublayer(shape)

        let vShape = CAShapeLayer()
        vShape.bounds = CGRect(x: 0, y: 0, width: 19, height: 15)
        vShape.position = shape.position
        vShape.strokeColor = UIColor.white.cgColor
        vShape.lineWidth = 2

        let vPath = UIBezierPath()
        vPath.move(to: CGPoint(x: 0, y: 7))
        vPath.addLine(to: CGPoint(x: 7, y: vShape.bounds.height))
        vPath.addLine(to: CGPoint(x: vShape.bounds.width, y: 0))
        vShape.path = vPath.cgPath
        vShape.fillColor = UIColor.clear.cgColor
        vShape.strokeStart = 0
        vShape.strokeEnd = 0
        layer.addSublayer(vShape)

        let duration = 0.64
        let pathAnimation = Animations.animation(with: "path", duration: duration * 0.25, beginTime: 0, from: shape.path!, to: UIBezierPath(roundedRect: shape.bounds.insetBy(dx: (shape.bounds.width / 2) - 25, dy: 0), cornerRadius: shape.bounds.height / 2).cgPath)
        let vPathAnimation = Animations.animation(with: "strokeEnd", duration: duration * 0.45, beginTime: duration * 0.55, from: 0, to: 1)
        let shapeGroup = Animations.animationGroup(animations: [pathAnimation], duration: duration)
        let vPathGroup = Animations.animationGroup(animations: [vPathAnimation], duration: duration)
        vPathGroup.delegate = self
        shape.add(shapeGroup, forKey: "shrink")
        vShape.add(vPathGroup, forKey: "vStroke")

        transitionToConfirmedCompletion = completion
    }
}

extension ConfirmButton: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        transitionToConfirmedCompletion?()
        transitionToConfirmedCompletion = nil
    }
}

//
//  BackupIntroViewController.swift
//  KinEcosystem
//
//  Created by Corey Werner on 16/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

class BackupIntroViewController: ExplanationTemplateViewController {
    override init() {
        super.init()

        title = "backup_intro.title".localized()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .kinPrimary
        
        imageView.image = UIImage(named: "Safe", in: .backupRestore, compatibleWith: nil)

        titleLabel.text = "backup_intro.header".localized()

        descriptionLabel.text = "backup_intro.description".localized()

        doneButton.setTitle("backup_intro.next".localized(), for: .normal)
    }
}

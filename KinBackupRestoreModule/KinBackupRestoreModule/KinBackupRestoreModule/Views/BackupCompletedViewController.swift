//
//  BackupCompletedViewController.swift
//  KinEcosystem
//
//  Created by Corey Werner on 17/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

class BackupCompletedViewController: ExplanationTemplateViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        imageView.image = UIImage(named: "Safe", in: .backupRestore, compatibleWith: nil)

        titleLabel.text = "backup_completed.header".localized()

        descriptionLabel.text = "backup_completed.description".localized()

        // TODO: insert the reminder into a blank view which already exists in the template
        if let contentStackView = doneButton.superview as? UIStackView,
            let index = contentStackView.arrangedSubviews.firstIndex(of: doneButton)
        {
            let reminderView = ReminderView()
            reminderView.tintColor = .white
            reminderView.setContentCompressionResistancePriority(.required, for: .vertical)
            reminderView.setContentHuggingPriority(.required, for: .vertical)
            contentStackView.insertArrangedSubview(reminderView, at: index)
        }

        doneButton.isHidden = true
    }
}

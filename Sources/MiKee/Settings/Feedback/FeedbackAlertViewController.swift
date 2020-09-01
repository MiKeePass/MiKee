// FeedbackAlertViewController.swift
// This file is part of MiKee.
//
// Copyright © 2020 Maxime Epain. All rights reserved.
//
// MiKee is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// MiKee is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MiKee. If not, see <https://www.gnu.org/licenses/>.

import UIKit
import MiKit
import Resources
import SafariServices

class FeedbackAlertViewController: AlertViewController {

    @IBOutlet var logoView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var desc1Label: UILabel!
    @IBOutlet var desc2Label: UILabel!
    @IBOutlet var noButton: UIButton!
    @IBOutlet var yesButton: UIButton!

    override func loadView() {
        super.loadView()

        let nib = UINib(nibName: "Feedback", bundle: nil)
        nib.instantiate(withOwner: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView?.backgroundColor = Asset.background.color

        titleLabel.textColor = Asset.textColor.color
        desc1Label.textColor = Asset.textColor.color
        desc2Label.textColor = Asset.textColor.color
        noButton.setTitleColor(Asset.grey.color, for: .normal)
        yesButton.setTitleColor(Asset.purple.color, for: .normal)

        logoView.image = Asset.miKee.image
        titleLabel.text = L10n.thankYouForTestingMiKee
        desc1Label.text = L10n.doYouHaveAFewMinutesToGiveUsFeedbackWeWouldBeVeryInterestedInHearingBackFromYou
        desc2Label.text = L10n.ifItSNotTheRightTimeYouWillStillHaveTheOpportunityToGiveFeedbackFromTheSettingsScreen
    }

    @IBAction func yes(_ sender: Any) {
        let svc = SFSafariViewController(url: feedbackURL)
        svc.preferredBarTintColor = Asset.background.color
        svc.preferredControlTintColor = Asset.purple.color
        svc.dismissButtonStyle = .close
        svc.modalPresentationStyle = .popover

        dismiss(animated: true)
        presentingViewController?.present(svc, animated: true)
    }

    @IBAction func no(_ sender: Any) {
        dismiss(animated: true)
    }

}

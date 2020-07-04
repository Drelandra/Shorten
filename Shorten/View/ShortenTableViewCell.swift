//
//  TableViewCell.swift
//  Shorten
//
//  Created by Andre Elandra on 17/06/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import UIKit

class ShortenTableViewCell: UITableViewCell {

    @IBOutlet weak var urlText: UILabel!
    @IBOutlet weak var clipboardButton: UIButton!

    @IBAction func clipboardPressed(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let pasteboard = UIPasteboard.general
        pasteboard.string = urlText.text
    }
}

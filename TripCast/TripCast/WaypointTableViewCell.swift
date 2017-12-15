//
//  WaypointTableViewCell.swift
//  TripCast
//
//  Created by Andrew D. Sail on 12/4/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit

class WaypointTableViewCell: UITableViewCell {

    @IBOutlet weak var conditionsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

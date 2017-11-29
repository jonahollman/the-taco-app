//
//  Top50TableViewCell.swift
//  tacofinder
//
//  Created by Jonah Ollman on 11/28/17.
//  Copyright © 2017 Jonah Ollman. All rights reserved.
//

import UIKit

class Top50TableViewCell: UITableViewCell {
    
    @IBOutlet var rank: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var openStatus: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var recommended: UILabel!
    @IBOutlet var descriptionImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

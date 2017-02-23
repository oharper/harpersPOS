//
//  orderTableViewCell.swift
//  harpersPOS
//
//  Created by Owen Harper on 22/02/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit

class orderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var singlePriceLabel: UILabel!
    
    @IBOutlet weak var quantityPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

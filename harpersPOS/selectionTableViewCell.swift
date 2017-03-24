//
//  selectionTableViewCell.swift
//  harpersPOS
//
//  Created by Owen Harper on 22/02/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit

class selectionTableViewCell: UITableViewCell {
  
    @IBOutlet weak var selectionNameLabel: UILabel!
    @IBOutlet weak var selectionPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
  }
  
  
}

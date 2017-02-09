//
//  navigationBar.swift
//  harpersPOS
//
//  Created by Owen Harper on 08/02/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit

extension UITabBar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 80 // adjust your size here
        return sizeThatFits
    }
}

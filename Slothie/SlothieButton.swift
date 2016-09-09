//
//  SlothieButton.swift
//  Slothie
//
//  Created by Max Peiros on 7/19/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit

class SlothieButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = bounds.width / 2
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 3
        clipsToBounds = true
    }
    
}

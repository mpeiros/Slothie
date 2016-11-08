//
//  SlothieLabel.swift
//  Slothie
//
//  Created by Max Peiros on 11/8/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit

class SlothieLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 2
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        layer.zPosition = 2
        clipsToBounds = true
    }

}

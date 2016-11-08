//
//  SlothieCell.swift
//  Slothie
//
//  Created by Max Peiros on 7/7/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit

class SlothieCell: UICollectionViewCell {
    
    @IBOutlet weak var slothieImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        slothieImageView.layer.cornerRadius = 2
        layer.cornerRadius = 2
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
    }
    
    func configureCell(_ slothie: Slothie) {
        slothieImageView.image = DataService.instance.imageForPath(slothie.slothieImagePath)
    }
   
}

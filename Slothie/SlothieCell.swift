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
        
        slothieImageView.layer.cornerRadius = 3
        layer.cornerRadius = 3
    }
    
    func configureCell(slothie: Slothie) {
        slothieImageView.image = DataService.instance.imageForPath(slothie.slothieImagePath)
    }
   
}

//
//  SlothieVC.swift
//  Slothie
//
//  Created by Max Peiros on 7/8/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit

class SlothieVC: UIViewController {
    
    @IBOutlet weak var slothieVCImageView: UIImageView!
    
    var slothieVCSlothie: Slothie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Your Slothie"

        slothieVCImageView.image = DataService.instance.imageForPath(slothieVCSlothie.slothieImagePath)
    }
    
}

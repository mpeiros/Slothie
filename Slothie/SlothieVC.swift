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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePressed))

        slothieVCImageView.image = DataService.instance.imageForPath(slothieVCSlothie.slothieImagePath)
    }
  
    func deletePressed() {
        DataService.instance.deleteSlothie(slothieVCSlothie)
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        if let image = slothieVCImageView.image {
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: [])
            activityVC.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.openInIBooks, UIActivityType.assignToContact, UIActivityType.print ]
            present(activityVC, animated: true)
        }
    }
    
}

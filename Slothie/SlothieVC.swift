//
//  SlothieVC.swift
//  Slothie
//
//  Created by Max Peiros on 7/8/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit
import JSSAlertView

class SlothieVC: UIViewController {
    
    @IBOutlet weak var slothieVCImageView: UIImageView!
    
    var slothieVCSlothie: Slothie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Your Slothie"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePressed))
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(shareButtonPressed(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)

        slothieVCImageView.image = DataService.instance.imageForPath(slothieVCSlothie.slothieImagePath)
    }
  
    func deletePressed() {
        let alert = JSSAlertView().danger(self, title: "Delete this slothie?", buttonText: "Yes", cancelButtonText: "No")
        alert.addAction(deleteCallback)
    }
    
    func deleteCallback() {
        DataService.instance.deleteSlothie(slothieVCSlothie)
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    func goBack() {
        navigationController!.popToRootViewController(animated: true)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        if let image = slothieVCImageView.image {
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: [])
            activityVC.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.openInIBooks, UIActivityType.assignToContact, UIActivityType.print ]
            present(activityVC, animated: true)
        }
    }
    
}

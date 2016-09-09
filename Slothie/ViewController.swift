//
//  ViewController.swift
//  Slothie
//
//  Created by Max Peiros on 7/7/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Slothie"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(showCamera))
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        DataService.instance.loadSlothies()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    
    func showCamera() {
        performSegueWithIdentifier(SEGUE_SHOW_CAMERA_VC, sender: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataService.instance.slothies.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SlothieCell", forIndexPath: indexPath) as! SlothieCell
        
        let slothie = DataService.instance.slothies[indexPath.row]
        
        cell.configureCell(slothie)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let slothie = DataService.instance.slothies[indexPath.row]
        
        performSegueWithIdentifier(SEGUE_SHOW_SLOTHIE_VC, sender: slothie)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 2) - 15
        let height = width * (4 / 3)
        return CGSizeMake(width, height)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SHOW_SLOTHIE_VC {
            if let slothieVC = segue.destinationViewController as? SlothieVC {
                if let slothie = sender as? Slothie {
                    slothieVC.slothieVCSlothie = slothie
                }
            }
        }
    }
    
}


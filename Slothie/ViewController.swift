//
//  ViewController.swift
//  Slothie
//
//  Created by Max Peiros on 7/7/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(takeSlothie))
        
        DataService.instance.loadSlothies()
    }
    
    func takeSlothie() {
        let picker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            picker.sourceType = .Camera
            picker.cameraDevice = .Front
        } else {
            picker.sourceType = .PhotoLibrary
        }
        
        picker.delegate = self
        
        let overlayRect = CGRectMake(0, 100, picker.view.frame.width, 100)
        let overlayView = UIView.init(frame: overlayRect)
        overlayView.backgroundColor = UIColor.greenColor()
        
        picker.cameraOverlayView = overlayView
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }

        let imgPath = DataService.instance.saveImageAndCreatePath(newImage)
        
        let slothie = Slothie(imagePath: imgPath)
        DataService.instance.addSlothie(slothie)
        
        collectionView.reloadData()
        
        dismissViewControllerAnimated(true, completion: nil)
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


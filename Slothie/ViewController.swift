//
//  ViewController.swift
//  Slothie
//
//  Created by Max Peiros on 7/7/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit
import AVFoundation
import JSSAlertView

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleImage = UIImage(named: "slothieLogo")
        let titleImageView = UIImageView(image: titleImage)
        titleImageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = titleImageView
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(showCamera))
        
        navigationController!.navigationBar.tintColor = UIColor.white
        navigationController!.navigationBar.barStyle = .black
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(showCamera))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        view.addGestureRecognizer(swipeLeft)
        
        DataService.instance.loadSlothies()
        
        setHeaderText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
        setHeaderText()
    }
    
    func showCamera() {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.authorized {
            performSegue(withIdentifier: SEGUE_SHOW_CAMERA_VC, sender: nil)
        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: SEGUE_SHOW_CAMERA_VC, sender: nil)
                    }
                } else {
                    let alert = JSSAlertView().info(self, title: "Camera access required! Go to Settings > Slothie > Camera.", buttonText: "Settings", cancelButtonText: "Dismiss")
                    alert.addAction(self.goToSettings)
                }
            })
        }
    }
    
    func goToSettings() {
        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.openURL(settingsURL)
        }
    }
    
    // Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataService.instance.slothies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlothieCell", for: indexPath) as! SlothieCell
        
        let slothie = DataService.instance.slothies[indexPath.row]
        
        cell.configureCell(slothie)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let slothie = DataService.instance.slothies[indexPath.row]
        
        performSegue(withIdentifier: SEGUE_SHOW_SLOTHIE_VC, sender: slothie)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 2) - 15
        let height = width * (4 / 3)
        return CGSize(width: width, height: height)
    }
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_SHOW_SLOTHIE_VC {
            if let slothieVC = segue.destination as? SlothieVC {
                if let slothie = sender as? Slothie {
                    slothieVC.slothieVCSlothie = slothie
                }
            }
        }
    }
    
    // Header text
    func setHeaderText() {
        if DataService.instance.slothies.count == 0 {
            headerTextLabel.text = "You have no slothies in your collection. Tap the camera button above or swipe left to take a slothie."
        } else {
            headerTextLabel.text = "You have \(DataService.instance.slothies.count) slothies in your collection. Tap a slothie to share it with your friends!"
        }
    }
    
}


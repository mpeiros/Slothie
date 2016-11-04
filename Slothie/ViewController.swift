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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(showCamera))
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barStyle = .black
        
        DataService.instance.loadSlothies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    
    func showCamera() {
        performSegue(withIdentifier: SEGUE_SHOW_CAMERA_VC, sender: nil)
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_SHOW_SLOTHIE_VC {
            if let slothieVC = segue.destination as? SlothieVC {
                if let slothie = sender as? Slothie {
                    slothieVC.slothieVCSlothie = slothie
                }
            }
        }
    }
    
}


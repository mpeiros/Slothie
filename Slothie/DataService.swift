//
//  DataService.swift
//  Slothie
//
//  Created by Max Peiros on 7/7/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import Foundation
import UIKit

class DataService {
    
    static let instance = DataService()
    
    private var _slothies = [Slothie]()
    
    var slothies: [Slothie] {
        return _slothies
    }
    
    func addSlothie(slothie: Slothie) {
        _slothies.append(slothie)
        saveSlothies()
    }
    
    func saveSlothies() {
        let slothiesData = NSKeyedArchiver.archivedDataWithRootObject(_slothies)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(slothiesData, forKey: KEY_SLOTHIES)
    }
    
    func loadSlothies() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let savedSlothies =  defaults.objectForKey(KEY_SLOTHIES) as? NSData {
            _slothies = NSKeyedUnarchiver.unarchiveObjectWithData(savedSlothies) as! [Slothie]
        }
    }
    
    func saveImageAndCreatePath(image: UIImage) -> String {
        let imagePath = NSUUID().UUIDString
        let fullPath = getDocumentsDirectory().stringByAppendingPathComponent(imagePath)
        
        if let jpegData = UIImageJPEGRepresentation(image, 80) {
            jpegData.writeToFile(fullPath, atomically: true)
        }
        
        return imagePath
    }
    
    func imageForPath(path: String) -> UIImage? {
        let fullPath = getDocumentsDirectory().stringByAppendingPathComponent(path)
        let image = UIImage(contentsOfFile: fullPath)
        return image
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}


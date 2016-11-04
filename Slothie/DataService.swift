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
    
    fileprivate var _slothies = [Slothie]()
    
    var slothies: [Slothie] {
        return _slothies
    }
    
    func addSlothie(_ slothie: Slothie) {
        _slothies.append(slothie)
        saveSlothies()
    }
    
    func deleteSlothie(_ slothie: Slothie) {
        if let index = _slothies.index(of: slothie) {
            _slothies.remove(at: index)
        }
        saveSlothies()
    }
    
    func saveSlothies() {
        let slothiesData = NSKeyedArchiver.archivedData(withRootObject: _slothies)
        
        let defaults = UserDefaults.standard
        defaults.set(slothiesData, forKey: KEY_SLOTHIES)
    }
    
    func loadSlothies() {
        let defaults = UserDefaults.standard
        
        if let savedSlothies =  defaults.object(forKey: KEY_SLOTHIES) as? Data {
            _slothies = NSKeyedUnarchiver.unarchiveObject(with: savedSlothies) as! [Slothie]
        }
    }
    
    func saveImageAndCreatePath(_ image: UIImage) -> String {
        let imagePath = UUID().uuidString
        let fullPath = getDocumentsDirectory().appendingPathComponent(imagePath)
        
        if let jpegData = UIImageJPEGRepresentation(image, 80) {
            try? jpegData.write(to: URL(fileURLWithPath: fullPath), options: [.atomic])
        }
        
        return imagePath
    }
    
    func imageForPath(_ path: String) -> UIImage? {
        let fullPath = getDocumentsDirectory().appendingPathComponent(path)
        let image = UIImage(contentsOfFile: fullPath)
        return image
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
}


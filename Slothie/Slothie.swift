//
//  Slothie.swift
//  Slothie
//
//  Created by Max Peiros on 7/7/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit

class Slothie: NSObject, NSCoding {
    
    fileprivate var _slothieImagePath: String!
    
    var slothieImagePath: String {
        return _slothieImagePath
    }
    
    init(imagePath: String) {
        self._slothieImagePath = imagePath
    }
    
    required init(coder aDecoder: NSCoder) {
        self._slothieImagePath = aDecoder.decodeObject(forKey: KEY_IMAGE_PATH) as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self._slothieImagePath, forKey: KEY_IMAGE_PATH)
    }

}

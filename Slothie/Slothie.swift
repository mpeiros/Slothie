//
//  Slothie.swift
//  Slothie
//
//  Created by Max Peiros on 7/7/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit

class Slothie: NSObject, NSCoding {
    
    private var _slothieImagePath: String!
    
    var slothieImagePath: String {
        return _slothieImagePath
    }
    
    init(imagePath: String) {
        self._slothieImagePath = imagePath
    }
    
    required init(coder aDecoder: NSCoder) {
        self._slothieImagePath = aDecoder.decodeObjectForKey(KEY_IMAGE_PATH) as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self._slothieImagePath, forKey: KEY_IMAGE_PATH)
    }

}

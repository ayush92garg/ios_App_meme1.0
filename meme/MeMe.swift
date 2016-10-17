//
//  File.swift
//  meme
//
//  Created by Ayush Garg on 17/10/16.
//  Copyright © 2016 Headmaster Technologies. All rights reserved.
//

import Foundation
import UIKit


struct Meme {
    
    var topText: String
    var bottomText: String
    var image: UIImage
    var memedImage: UIImage
    
    // Constructor
    init(topText: String, bottomText: String, image: UIImage, memedImage: UIImage){
        self.topText = topText
        self.bottomText = bottomText
        self.image = image
        self.memedImage = memedImage
    }
}

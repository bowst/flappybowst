//
//  Utilities.swift
//  FlappyBowst
//
//  Created by Ben Lambert on 7/23/14.
//  Copyright (c) 2014 Bowst. All rights reserved.
//

import Foundation
import SpriteKit


class Utilities {
    
    
    
    // Class methods
    
    class func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if( value > max ) {
            return max
        } else if( value < min ) {
            return min
        } else {
            return value
        }
    }
}
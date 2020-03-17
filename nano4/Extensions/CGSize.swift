//
//  CGSize.swift
//  nano4
//
//  Created by Felipe Mesquita on 17/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

extension CGSize {
    static func *(point: CGSize, scalar: CGFloat) -> CGSize {
        return CGSize(width: point.width * scalar, height: point.height * scalar)
    }
    
    static func *(point: CGSize, scalar: Double) -> CGSize {
        return CGSize(width: point.width * CGFloat(scalar), height: point.height * CGFloat(scalar))
    }
}

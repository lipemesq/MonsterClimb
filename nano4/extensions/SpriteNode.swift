//
//  SpriteNode.swift
//  nano4
//
//  Created by Felipe Mesquita on 07/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    func turnPhysicsOff(offset: CGPoint = .zero) {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: offset)
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.isDynamic = true
        self.physicsBody?.allowsRotation = false
    }
    
    func turnPhysicsOn() {
        self.removeAllActions()
        self.physicsBody?.affectedByGravity = true
        self.physicsBody!.isDynamic = true
        self.physicsBody?.allowsRotation = true
    }
}

//
//  Foothold.swift
//  nano4
//
//  Created by Felipe Mesquita on 16/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

class Foothold: Equatable {
    
    static func == (lhs: Foothold, rhs: Foothold) -> Bool {
        return lhs.node == rhs.node
    }
    
    enum FaceDirection {
        case right
        case left
        case up
    }
    
    enum Material {
        case diamond
        case gold
    }
    
    var faceTo : FaceDirection
    
    var node : SKSpriteNode
    
    var position : CGPoint {
        get {
            return node.parent!.convert(node.position, to: node.scene!)
        }
    }
    
    var devoured = false
    
    init(faceTo: FaceDirection, size: CGSize, node: SKSpriteNode) {
        self.faceTo = faceTo
        
        self.node = node
    }
    
    func devour() {
        print("trying to devour \(node.name!)")
        
        let sprite = (node.children.first as! SKSpriteNode)
        let actualSize = sprite.size
        
        if faceTo == .left {
            print("face turned to left")
            devoured = true
            sprite.texture = SKTexture(imageNamed: "ouroEsqD")
            sprite.size = (sprite.texture?.size())!
            sprite.position = CGPoint(x: 8, y: 0)
        }
        else if faceTo == .right {
            print("face turned to right")
            devoured = true
            sprite.texture = SKTexture(imageNamed: "ouroDirD")
            sprite.size = (sprite.texture?.size())!
            sprite.position = CGPoint(x: -8, y: 0)
        }
        
        sprite.size = CGSize(width: (actualSize.height/sprite.size.height) * sprite.size.width, height: actualSize.height)
        
    }
    
}

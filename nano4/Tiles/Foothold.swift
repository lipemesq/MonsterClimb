//
//  Foothold.swift
//  nano4
//
//  Created by Felipe Mesquita on 16/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

class Foothold {
    
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
    var material : Material
    
    var hold : SKSpriteNode
    var sprite : SKSpriteNode
    
    init(faceTo: FaceDirection, material: Material, size: CGSize, holdNode: SKSpriteNode) {
        self.faceTo = faceTo
        self.material = material
        
        var texture : SKTexture
        switch self.material {
            
            case .diamond:
                switch self.faceTo {
                    case .left:
                        texture = SKTexture(imageNamed: "diamondLeft")
                    case .right:
                        texture = SKTexture(imageNamed: "diamondRight")
                    case .up:
                        texture = SKTexture(imageNamed: "diamondUp")
            }
            
            case .gold:
                switch self.faceTo {
                    case .left:
                        texture = SKTexture(imageNamed: "goldLeft")
                    case .right:
                        texture = SKTexture(imageNamed: "goldRight")
                    case .up:
                        texture = SKTexture(imageNamed: "goldUp")
            }
            
        }
        
        self.hold = holdNode
        self.sprite = SKSpriteNode(texture: texture, size: size)
        
        self.hold.addChild(sprite)
        sprite.position = .zero
    }
    
    
}

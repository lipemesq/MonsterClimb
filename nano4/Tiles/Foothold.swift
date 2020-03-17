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
    var material : Material
    
    var node : SKSpriteNode
    
    var position : CGPoint {
        get {
            return node.parent!.convert(node.position, to: node.scene!)
        }
    }
    
    var devoured = false
    
    init(faceTo: FaceDirection, material: Material, size: CGSize, node: SKSpriteNode) {
        self.faceTo = faceTo
        self.material = material
        
        self.node = node
    }
    
    func devour() {
        print("trying to devour \(node.name!)")
        
        let sprite = (node.children.first as! SKSpriteNode)
        let actualSize = sprite.size
        
        if faceTo == .left {
            print("face turned to left")
            devoured = true
            if material == .gold {
                print("made of gold")
                sprite.texture = SKTexture(imageNamed: "ouroEsqD")
            }
            else if material == .diamond {
                print("made of diamond")
                sprite.texture = SKTexture(imageNamed: "dimaEsqD")
            }
            sprite.size = (sprite.texture?.size())!
            sprite.position = CGPoint(x: 8, y: 0)
        }
        else if faceTo == .right {
            devoured = true
            if material == .gold {
                
            }
            else {
          
            }
        }
        
        sprite.size = CGSize(width: (actualSize.height/sprite.size.height) * sprite.size.width, height: actualSize.height)
        
    }
    
}

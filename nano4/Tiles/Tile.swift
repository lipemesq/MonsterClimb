//
//  Tile.swift
//  nano4
//
//  Created by Felipe Mesquita on 05/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

class Tile : SKSpriteNode {
    
    var footholds : [SKSpriteNode] = []
    var footholds1 : [Foothold] = []
    
    var enemies : [Enemy] = []
    
    func getProbability() -> Int {
        return (self.userData?["frequency"] as! Int)
    }
    
    func loadFootholds() {
        for c in self.children {
            if c.name!.contains("foothold") {
                (c as! SKSpriteNode).color = .clear
                
                var direction : Foothold.FaceDirection
                var material : Foothold.Material

                let name = c.name!
                if name.contains("right") {
                    direction = .right
                }
                else if name.contains("left") {
                    direction = .left
                }
                else {
                    direction = .up
                }
                            
                if name.contains("diamond") {
                    material = .diamond
                }
                else {
                    material = .gold
                }
                    
                footholds1.append(Foothold(faceTo: direction, material: material, size: (c as! SKSpriteNode).size * 0.9, node: (c as! SKSpriteNode)))
                footholds.append(c as! SKSpriteNode)
            }
        }
    }
    
    func loadEnemies() {
        for c in self.children {
            if c.name!.contains("enemy") {
                let data = c.userData!
                switch data["type"] as! String {
                    case "circular":
                        let circularEnemy = CircularMovementEnemy(scene: self.scene as! GameScene, node: c as! SKSpriteNode, center: convert(c.position, to: scene!), radius: data["radius"] as! CGFloat, initialRotation: data["initialRotation"] as! CGFloat, speed: data["speed"] as! CGFloat)
                        enemies.append(circularEnemy)
                        break
                    
                    case "linear":
                        var points : [CGPoint] = []
                        var i = 0
                        repeat {
                            points.append(CGPoint(x: (data["px\(i)"] as! CGFloat), y: (data["py\(i)"] as! CGFloat)))
                        i += 1
                        } while data["px\(i)"] != nil
                        
                        let linearEnemy = LinearMovementEnemy(scene: self.scene as! GameScene, node: c as! SKSpriteNode, points: points, speed: data["speed"] as! CGFloat)
                        enemies.append(linearEnemy)
                        break
                    
                    default:
                        break
                }
                footholds.append(c as! SKSpriteNode)
            }
        }
    }
    
}
//NSCoder.cgPoint(for: "{x,y}")

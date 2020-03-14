//
//  Enemy.swift
//  nano4
//
//  Created by Felipe Mesquita on 08/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

class Enemy: EnemyMovement {
    
    var scene : GameScene
    
    var node : SKSpriteNode
        
    init (scene: GameScene,node: SKSpriteNode) {
        self.scene = scene
        self.node = node
        self.node.zPosition = 10
    }
    
    func startMoving() {
    }
    
}

protocol EnemyMovement {
    func startMoving()
}

class CircularMovementEnemy: Enemy {
    var center : CGPoint
    var radius : CGFloat
    var speed  : CGFloat
    var initialRotation : CGFloat
    
    init (scene: GameScene, node: SKSpriteNode, center: CGPoint, radius: CGFloat, initialRotation: CGFloat, speed: CGFloat) {
        self.center = center
        self.radius = radius
        self.speed = speed
        self.initialRotation = initialRotation
        
        super.init(scene: scene, node: node)
    }
    
    override func startMoving() {        
        let circlePath = UIBezierPath(ovalIn: CGRect(x: node.position.x - radius, y: node.position.y - radius, width: 2*radius, height: 2*radius))
        circlePath.apply(.init(rotationAngle: initialRotation.toRadians))
        
        let runInCircles = SKAction.repeatForever(SKAction.follow(circlePath.cgPath, asOffset: false, orientToPath: true, speed: speed))
        
        node.run(runInCircles)
    }
}


class LinearMovementEnemy: Enemy {
    var points : [CGPoint]
    var speed  : CGFloat
    
    init (scene: GameScene, node: SKSpriteNode, points: [CGPoint], speed: CGFloat) {
        self.points = points
        self.speed = speed
        
        super.init(scene: scene, node: node)
    }
    
    override func startMoving() {
        let path = UIBezierPath()
        path.move(to: points[0])
        
        for p in points.dropFirst() {
            path.addLine(to: p)
        }
        
        let going = SKAction.follow(path.cgPath, asOffset: false, orientToPath: true, speed: speed)
        
        let returning = SKAction.follow(path.reversing().cgPath, asOffset: false, orientToPath: true, speed: speed)
        
        let runInPath = SKAction.repeatForever(SKAction.sequence([
            going, returning
        ]) )
        
        node.run(runInPath)
    }
}

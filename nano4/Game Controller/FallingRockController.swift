//
//  FallingRockController.swift
//  nano4
//
//  Created by Felipe Mesquita on 25/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

class FallingRockController {
    
    let scene : GameScene
    let node : SKSpriteNode
    
    var minTimeInterval : Double = 8
    var maxTimeInterval : Double = 11
    let minTimeIntervalSpeed : Double = 0.5
    let maxTimeIntervalSpeed : Double = 0.5
    let limitMinTimeInterval : Double = 5
    let limitMaxTimeInterval : Double = 8
    
    var minFallingSpeed : CGFloat = 200
    var maxFallingSpeed : CGFloat = 400
    let minFallingSpeedChangeFactor : CGFloat = 30
    let maxFallingSpeedChangeFactor : CGFloat = 20
    let limitMinFallingSpeed : CGFloat = 350
    let limitMaxFallingSpeed : CGFloat = 450
    
    let minXPosition : CGFloat = -((750-30)/2)
    let maxXPosition : CGFloat = (750-30)/2
    
    let minExtraRockScale : CGFloat = 0
    var maxExtraRockScale : CGFloat = 0.25
    let limitMaxExtraRockScale : CGFloat = 1
    let maxRockScaleSpeed : CGFloat = 0.125
    
    var actualInterval : Double = 0
    var counting = true
        
    init(scene: GameScene, node: SKSpriteNode) {
        self.scene = scene
        
        self.node = node
        
        actualInterval = minTimeInterval
    }
    
    func loadRock() {
        actualInterval = Double.random(in: minTimeInterval...maxTimeInterval)
    }
    
    func dropRock() {
        let rock = (node.copy() as! SKSpriteNode)
        
        let x = CGFloat.random(in: minXPosition...maxXPosition)
        let y = scene.inGameTiles.last!.position.y + scene.inGameTiles.last!.size.height
        rock.position = CGPoint(x: x, y: y)
        
        let extraScale = CGFloat.random(in: (maxExtraRockScale/6)...maxExtraRockScale)
        rock.xScale += extraScale
        rock.yScale += extraScale
        
        let speed = CGFloat.random(in: minFallingSpeed...maxFallingSpeed)
        
        scene.addChild(rock)
        
        let distance = rock.position.distance(to: scene.lava.node.position)
        
        rock.run(SKAction.moveTo(y: scene.lava.node.position.y, duration: TimeInterval(distance/speed)))
    }
    
    func growDifficult() {
        if minTimeInterval > limitMinTimeInterval {
            minTimeInterval -= minTimeIntervalSpeed
        }
        if maxTimeInterval > limitMaxTimeInterval {
            maxTimeInterval -= maxTimeIntervalSpeed
        }
        if maxExtraRockScale < limitMaxExtraRockScale {
            maxExtraRockScale += maxRockScaleSpeed
        }
        if minFallingSpeed > limitMinFallingSpeed {
            minFallingSpeed += minFallingSpeedChangeFactor
        }
        if maxFallingSpeed > limitMaxFallingSpeed {
            maxFallingSpeed += maxFallingSpeedChangeFactor
        }
    }
}

extension FallingRockController: DeltaTimed {
    func update(deltaTime: TimeInterval) {
        actualInterval -= deltaTime
        if actualInterval <= 0 {
            dropRock()
            loadRock()
        }
    }
}

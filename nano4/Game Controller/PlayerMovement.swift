//
//  PlayerMovement.swift
//  nano4
//
//  Created by Felipe Mesquita on 15/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

// ******************************************
// MARK: PLAYER MOVEMENTS

extension GameScene {
    /**
     Animate the player jumping to a point, and do a completion after. Set the player's state to `.jumping`.
     
     Uses the player's `getJumpPath` to get the path of the jump. The speed of animation is 1000, and its linear. At the end change the player's state to `.idle` with the `change` function.
     
     - Parameters:
     - to: The point to which the player will jump.
     - completion: The completion block after the jump animation. Optional. If null, runs `player.change(to: .idle)`.
     */
    func playerJump(to: CGPoint, completion: os_block_t? = nil)  {
        player.status = .jumping
        
        let jumpSpeed : CGFloat = 900
        
        let jumpPath = player.getJumpPath(to: to + CGPoint(x: 0, y: 30))
        let movey = SKAction.follow(jumpPath, asOffset: false, orientToPath: false, speed: jumpSpeed)
        
        let distance = player.node.position.distance(to: to)
        let minDuration = distance / jumpSpeed
        let side : CGFloat = player.node.position.x > to.x ? -1 : 1
        
        let rotate = SKAction.rotate(byAngle: CGFloat(side * 20 ).toRadians, duration: TimeInterval(0.4*minDuration))

        let rotateBack = SKAction.rotate(byAngle: CGFloat(side * -20).toRadians, duration: TimeInterval(0.3*minDuration))
        let seq = SKAction.sequence([rotate, SKAction.wait(forDuration: TimeInterval(0.4*minDuration)), rotateBack])
        
        let group : SKAction
        if minDuration > 0.2 {
            group = SKAction.group([movey, seq])
        }
        else {
            group = SKAction.group([movey])
        }
        
        
        player.node.run(group, completion: {
            if completion != nil {
                completion!()
            }
            else {
                self.player.changeStatus(to: .idle)
            }
        })
    }
    
    
    func playerRotateRight() {
        player.node.xScale = 1
        player.leftFoot.xScale = 1
        player.rightFoot.xScale = 1
        
        player.rightKnee.shouldEnableLimits = true
        player.rightKnee.lowerAngleLimit = -player.kneesMaxAngleLimit.toRadians
        player.rightKnee.upperAngleLimit = player.kneesMinAngleLimit.toRadians
        
        player.leftKnee.shouldEnableLimits = true
        player.leftKnee.lowerAngleLimit = -player.kneesMaxAngleLimit.toRadians
        player.leftKnee.upperAngleLimit = player.kneesMinAngleLimit.toRadians
        
        player.rightLeg.physicsBody!.applyForce(.init(dx: 500, dy: 0))
        player.rightFoot.physicsBody!.applyForce(.init(dx: 500, dy: 0))
    }
    
    
    func playerRotateLeft() {
        player.node.xScale = -1
        player.leftFoot.xScale = -1
        player.rightFoot.xScale = -1
        
        player.rightKnee.shouldEnableLimits = true
        player.rightKnee.lowerAngleLimit = player.kneesMinAngleLimit.toRadians
        player.rightKnee.upperAngleLimit = player.kneesMaxAngleLimit.toRadians
        player.leftKnee.shouldEnableLimits = true
        player.leftKnee.lowerAngleLimit = player.kneesMinAngleLimit.toRadians
        player.leftKnee.upperAngleLimit = player.kneesMaxAngleLimit.toRadians
        
        player.rightLeg.physicsBody!.applyForce(.init(dx: -500, dy: 0))
        player.rightFoot.physicsBody!.applyForce(.init(dx: -500, dy: 0))
    }
}

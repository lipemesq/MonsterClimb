//
//  Camera.swift
//  nano4
//
//  Created by Felipe Mesquita on 15/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit


// ******************************************
// MARK: - MOVE CAMERA

extension GameScene {
    /**
     Move the camera to the player y position and update the last time it was moved.
     
     Move the camera til player's y + 300, so it stays in the first third of the screen. The movement is linear animated, and lasts 0.2 seconds.
     
     - Parameters:
     - currentTime: the current time when the function was called (normally from the `update` function).
     */
    func moveCamera(currentTime: TimeInterval) {
        let moveAnimaton = SKAction.moveTo(y: player.node.position.y+300, duration: camMoveVelocity)
        camNode.run(moveAnimaton)
    }
}


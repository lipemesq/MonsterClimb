//
//  Collisions.swift
//  nano4
//
//  Created by Felipe Mesquita on 15/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

// ******************************************
// MARK: - COLLISION

extension GameScene {
    
    // Trata o início de uma colisão
    func didBegin(_ contact: SKPhysicsContact) {
        if !reseting {
            killPlayer()
        }
    }

}

//
//  Lava.swift
//  nano4
//
//  Created by Felipe Mesquita on 07/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

class Lava {
    var scene : GameScene
    var node : SKSpriteNode
    
    init(scene: GameScene) {
        self.scene = scene
        node = (scene.childNode(withName: "lava") as! SKSpriteNode)
    }
}


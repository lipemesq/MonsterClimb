//
//  Sons.swift
//  nano4
//
//  Created by Felipe Mesquita on 23/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    func initBackgroundMusic() {
        let bg = SKAudioNode(fileNamed: "bg.wav")
        addChild(bg)
        backgroundMusicNode = bg
        backgroundMusicNode.autoplayLooped = true
    }
    
    func playBG() {
        backgroundMusicNode.run(SKAction.changeVolume(to: 0, duration: 0))
        backgroundMusicNode.run(SKAction.group([
            SKAction.play(),
            SKAction.changeVolume(to: 0.01, duration: 1),
        ]))
    }
    
    func pauseBG() {
        backgroundMusicNode.run(SKAction.sequence([
            SKAction.changeVolume(to: 0, duration: 1),
            SKAction.pause(),
        ]))
    }
    
    func lowBG() {
        backgroundMusicNode.run(SKAction.sequence([
            SKAction.changeVolume(to: 0.04, duration: 1),
        ]))
    }
    
    func highBG() {
        backgroundMusicNode.run(SKAction.sequence([
            SKAction.changeVolume(to: 0.05, duration: 1),
            SKAction.pause(),
        ]))
    }
    
}

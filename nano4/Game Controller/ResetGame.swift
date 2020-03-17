//
//  ResetGame.swift
//  nano4
//
//  Created by Felipe Mesquita on 15/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit


// MARK: - RESET GAME

extension GameScene {
    
    func killPlayer() {
        reseting = true

        player.node.turnPhysicsOn()
        player.changeStatus(to: .falling)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        reviveMenu.move(toParent: camNode)
       // camNode.zPosition = 50
        reviveMenu.position = .zero//camNode.position
        
        pointsLabel.text = "\(pontos)"
        
        let loadingBar = SKShapeNode(rectOf: CGSize(width: 36, height: 1), cornerRadius: 1)
        loadingBar.fillColor = .yellow
        loadingBar.lineWidth = 0
        
        reviveMenu.addChild(loadingBar)
        loadingBar.xScale = 1
        loadingBar.yScale = 1
        reviveMenu.position = CGPoint(x: 0, y: 8)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + self.resetTimeDelay/2, execute: {
            self.reviveMenu.run(SKAction.fadeAlpha(to: 0.8, duration: 2*self.resetTimeDelay/3)) {
                loadingBar.run(SKAction.scaleX(to: 0, duration: 5)) {
                    self.resetGame()
                }
            }
        })
        
        // faz surgir os botoes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3*self.resetTimeDelay/4, execute: {
            self.buttonRevive.run(SKAction.group([
                SKAction.fadeAlpha(to: 1, duration: self.resetTimeDelay/2),
                SKAction.repeatForever(SKAction.init(named: "Pulse")!)
            ]), completion: {
                self.reviveMenu.isUserInteractionEnabled = true
            })
        })

        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        
        
    }

    func resetGame() {
        scene?.removeAllActions()
        scene?.removeAllChildren()
        
        let newScene = SKScene(fileNamed: "GameScene")!
        newScene.scaleMode = self.scaleMode
        let animation = SKTransition.fade(withDuration: 2.0)
        self.view?.presentScene(newScene, transition: animation)
        reseting = false
    }
    
    @objc func updateProgress() {
        guard progress <= 0.8 else {
            timer.invalidate()
            return
        }
        progress += (0.01 - progress/84)
        
        for node in scene?.children ?? [] {
            if (node.userData?["slowdown"] as? Bool) != nil {
                node.speed = CGFloat(0.8 - progress)
            }
        }
        //scene!.speed = CGFloat(1 - progress * 1)
        self.physicsWorld.speed = CGFloat(0.8 - progress)
    }
}

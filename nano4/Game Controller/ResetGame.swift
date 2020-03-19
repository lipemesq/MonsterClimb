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
    
    @objc func revive() {
        print("REVIVENDO")
        
        player.node.physicsBody!.affectedByGravity = false
        player.node.physicsBody?.allowsRotation = false
        player.node.physicsBody?.isDynamic = false
        player.changeStatus(to: .idle)
        player.node.physicsBody?.velocity = .zero
        player.node.zRotation =  0
        
        reviveMenu.move(toParent: scene!)
        reviveMenu.position = CGPoint(x: -1000, y: -1000)
        reviveMenu.zPosition = -10
        reviveMenu.isHidden = true
        
        lavaSpeed = (lavaSpeed > 3 ? lavaSpeed - 1 : 2)

        let newHold = nearFootholds[Int(nearFootholds.count/2+1)]
        player.node.run(SKAction.move(to: newHold.position + CGPoint(x: 0, y: 10), duration: 2))
        
        playerCollider.physicsBody?.velocity = .zero
        playerCollider.zRotation = 0
        playerCollider.position = CGPoint(x: -18, y: -11)
        
        playerCollider.physicsBody!.categoryBitMask = 2
        playerCollider.physicsBody!.contactTestBitMask = 2
        playerCollider.physicsBody?.collisionBitMask = 5
        
        if newHold.faceTo == .up || actualFoothold?.faceTo == .up || (actualFoothold?.faceTo != newHold.faceTo) {
            print("XX entrou na position")
            if newHold.position.x > player.node.position.x {
                playerRotateRight()
                print("XX RIGHT")
            }
            else {
                playerRotateLeft()
                print("XX LEFT")
            }
        }
        
        
        canCollide = false
        reseting = false
        showingAd = false
        tapp = false
       isPaused = false
        
        for node in scene?.children ?? [] {
            if (node.userData?["slowdown"] as? Bool) != nil {
                node.speed = 1
            }
        }
        
        progress = 0
        self.physicsWorld.speed = 1
    }
    
    func killPlayer(up: Bool = false) {
        print("INIT KILL")
        reseting = true
        
        playerCollider.physicsBody!.categoryBitMask = 0
        playerCollider.physicsBody!.contactTestBitMask = 0
        playerCollider.physicsBody?.collisionBitMask = 0
        
        player.node.removeAllActions()

        player.node.physicsBody?.affectedByGravity = true
        player.node.physicsBody!.isDynamic = true
        player.node.physicsBody?.allowsRotation = true
        player.changeStatus(to: .falling)
        
        if up {
            player.node.physicsBody?.applyImpulse(CGVector(dx: (-player.node.xScale * 100), dy: 500))
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        print("Morreu: ", pontos)
        let old = UserDefaults.standard.integer(forKey: "high")
        if pontos > old {
            UserDefaults.standard.set(pontos, forKey: "high")
            highscoreLabel.text = "Highscore: \(pontos)"
        }
        else {
            highscoreLabel.text = "Highscore: \(old)"
        }
        
        GameCenterHelper.helper.updateScore(with: pontos)
        
        reviveMenu.zPosition = 40
        reviveMenu.isHidden = false
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
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + self.resetTimeDelay*0.5, execute: {
            self.reviveMenu.run(SKAction.fadeAlpha(to: 0.9, duration: self.resetTimeDelay/3)) {
                loadingBar.run(SKAction.scaleX(to: 0, duration: 5)) {
                    if !self.showingAd {
                        self.resetGame()
                    }
                }
            }
        })
        
        // faz surgir botão de AD
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75*self.resetTimeDelay, execute: {
            self.buttonRevive.run(SKAction.group([
                SKAction.repeatForever(SKAction.init(named: "Pulse")!)
            ]), completion: {
                self.reviveMenu.isUserInteractionEnabled = true
            })
        })
        
        // faz surgir botão de reiniciar
        restartButton.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3*self.resetTimeDelay, execute: {
            self.restartButton.run(SKAction.group([
                SKAction.fadeAlpha(to: 1, duration: self.resetTimeDelay*0.15),
            ]))
        })

        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        
        
    }

    func resetGame() {
//        scene?.removeAllActions()
//        scene?.removeAllChildren()
        print("INIT RESETED")
        let newScene = SKScene(fileNamed: "GameScene")!
        newScene.scaleMode = self.scaleMode
        let animation = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(newScene, transition: animation)
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

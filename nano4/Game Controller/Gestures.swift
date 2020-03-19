//
//  Gestures.swift
//  nano4
//
//  Created by Felipe Mesquita on 15/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

let DEBUG = false
// ******************************************
// MARK: - GESTURES RECOGNIZERS

extension GameScene {
    
    // Tap
    @objc func tapRecognizer(tap: UITapGestureRecognizer) {
        let pos = self.convertPoint(fromView: tap.location(in: view))
        
        if scene!.physicsWorld.speed > 0 && !reseting {
            
            let touchPointMarker = SKSpriteNode(color: .magenta, size: CGSize(width: 10, height: 10))
            touchPointMarker.position = pos
            
            // - Marker point
            tapIndicator.position = pos
            tapIndicator.run(SKAction.group([
                SKAction.init(named: "Pulse")!,
                SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.3),
                    SKAction.wait(forDuration: 0.5),
                    SKAction.fadeOut(withDuration: 0.2)
                ])
            ]))
            
            var nextFoothold : Foothold?
            for foothold in nearFootholds {
                let node = foothold.node
                if foothold != actualFoothold && !foothold.devoured {
                    if self.nodes(at: pos).contains(node) {
                        let distance = self.player.node.position.distance(to: foothold.position)
                        if distance < maxJumpDistance {
                            nextFoothold = foothold
                        }
                    }
                }
            }
            
            if actualFoothold?.faceTo == .up || (actualFoothold?.faceTo != nextFoothold?.faceTo) {
                if pos.x > player.node.position.x {
                    playerRotateRight()
                }
                else {
                    playerRotateLeft()
                }
            }
            
            actualFoothold?.devour()
            if actualFoothold?.devoured ?? false {
                pontos += 1
            }
            
            if nextFoothold != nil {
                actualFoothold = nextFoothold
                if player.status == .idle {
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                    
                    playerJump(to: nextFoothold!.position, completion: {
                        self.player.changeStatus(to: .idle)
                        self.tapp = true
                        
                        if DEBUG {
                            for foothold in self.nearFootholds {
                                let distance = self.player.node.position.distance(to: foothold.position)
                                
                                if foothold.node.children.count > 1 {
                                    (foothold.node.children.last as! SKLabelNode).text = "\(distance)"
                                }
                                else {
                                    let lbl = SKLabelNode(text: "\(distance)")
                                    lbl.fontName = UIFont.boldSystemFont(ofSize: 18).fontName
                                    foothold.node.addChild(lbl)
                                }
                                
                                if distance < self.maxJumpDistance {
                                    foothold.node.color = .blue
                                }
                                else {
                                    foothold.node.color = .orange
                                }
                            }
                        }
                    })
                }
            }
            else if !reseting && canCollide {
                if player.status == .idle && !reseting {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.warning)
                    
                    reseting = true
                    
                    playerJump(to: pos, completion: {
                        self.tapp = true
                        print("INIT KILL BY TAP")

                        self.killPlayer()
                    })
                }
            }
            
        }
        else {
            if canDoInitialTap && !reseting && !self.nodes(at: pos).contains(leaderboard) {
                leaderboard.isHidden = true
                
                if boxTapToStart.parent != nil {
                    boxTapToStart.removeFromParent()
                    titleMonster.run(SKAction.fadeOut(withDuration: 0.8)) {
                        self.titleMonster.removeFromParent()
                    }
                    
                    titleClimb.run(SKAction.fadeOut(withDuration: 0.8)) {
                        self.titleClimb.removeFromParent()
                    }
                    
                }
                
                // deixa os nodes visiveis
                for foothold in nearFootholds.sorted(by: { (u, p) -> Bool in
                    u.position.y < p.position.y
                }).dropFirst(3) {
                    foothold.node.alpha = 1
                }
                
                scene!.isPaused = false
                scene?.physicsWorld.speed = 1
            }
            // gameStart()
        }
    }
}


//
//  Gestures.swift
//  nano4
//
//  Created by Felipe Mesquita on 15/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit


// ******************************************
// MARK: - GESTURES RECOGNIZERS

extension GameScene {
    
    // Tap
    @objc func tapRecognizer(tap: UITapGestureRecognizer) {
        if scene!.physicsWorld.speed > 0 && !reseting {
            let pos = self.convertPoint(fromView: tap.location(in: view))
            
            let touchPointMarker = SKSpriteNode(color: .magenta, size: CGSize(width: 10, height: 10))
            touchPointMarker.position = pos
            
            // TODO: - Marker point
            //addChild(touchPointMarker)
            
            var nextFoothold : CGPoint?
            for (i, sprite) in spritesOfNearFootholds.enumerated() {
                let foothold = nearFootholds[i]
                if foothold != actualFoothold {
                    if self.nodes(at: pos).contains(sprite) {
                        let distance = player.node.position.distance(to: foothold)
                        if distance < maxJumpDistance {
                            nextFoothold = foothold
                        }
                    }
                }
            }
            
            if pos.x > player.node.position.x {
                playerRotateRight()
            }
            else {
                playerRotateLeft()
            }
            
            if nextFoothold != nil {
                actualFoothold = nextFoothold
                if player.status == .idle {
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                    
                    playerJump(to: nextFoothold!, completion: {
                        self.player.changeStatus(to: .idle)
                        self.tapp = true
                        
                        for (i, foothold) in self.nearFootholds.enumerated() {
                            let distance = self.player.node.position.distance(to: foothold)
                            if self.spritesOfNearFootholds[i].children.count > 0 {
                                //  (self.spritesOfNearFootholds[i].children.first as! SKLabelNode).text = "\(distance)"
                            }
                            else {
                                //                            let lbl = SKLabelNode(text: "\(distance)")
                                //                            lbl.fontName = UIFont.boldSystemFont(ofSize: 18).fontName
                                //                            self.spritesOfNearFootholds[i].addChild(lbl)
                            }
                            
                            if distance < self.maxJumpDistance {
                                // self.spritesOfNearFootholds[self.nearFootholds.firstIndex(of: foothold)!].color = .blue
                            }
                            else {
                                //self.spritesOfNearFootholds[self.nearFootholds.firstIndex(of: foothold)!].color = .orange
                            }
                        }
                    })
                }
            }
            else {
                if player.status == .idle {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.warning)
                    
                    reseting = true
                    
                    playerJump(to: pos, completion: {
                        self.tapp = true
                        self.killPlayer()
                    })
                }
            }
            
        }
        else {
            if canDoInitialTap && !reseting{
                if boxTapToStart.parent != nil {
                    boxTapToStart.removeFromParent()
                    titleGame.removeFromParent()
                }
                scene!.isPaused = false
                scene?.physicsWorld.speed = 1
            }
            // gameStart()
        }
    }
}


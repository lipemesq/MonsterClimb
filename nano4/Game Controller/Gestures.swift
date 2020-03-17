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
        if scene!.physicsWorld.speed > 0 && !reseting {
            let pos = self.convertPoint(fromView: tap.location(in: view))
            
            let touchPointMarker = SKSpriteNode(color: .magenta, size: CGSize(width: 10, height: 10))
            touchPointMarker.position = pos
            
            // TODO: - Marker point
            //addChild(touchPointMarker)
            
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
            
            if pos.x > player.node.position.x && (actualFoothold?.faceTo != nextFoothold?.faceTo) {
                playerRotateRight()
            }
            else if actualFoothold?.faceTo != nextFoothold?.faceTo {
                playerRotateLeft()
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


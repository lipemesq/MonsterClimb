//
//  PlayerMovements.swift
//  nano4
//
//  Created by Felipe Mesquita on 04/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

enum PlayerStatus {
    case jumping
    case idle
    case falling
}

class Player {
    var scene : GameScene
    var node : SKSpriteNode
    
    var leftLeg : SKSpriteNode
    var rightLeg : SKSpriteNode
    
    var leftFoot : SKSpriteNode
    var rightFoot : SKSpriteNode
    var nose : SKSpriteNode
    
    init(scene: GameScene) {
        self.scene = scene
        self.node = SKSpriteNode(color: .green, size: .init(width: 80, height: 130))//(imageNamed: "player")
        
        nose = SKSpriteNode(color: .red, size: CGSize(width: 15, height: 15))
        
        rightLeg = SKSpriteNode(color: .cyan, size: .init(width: 30, height: 100))
        rightLeg.anchorPoint = .init(x: 0.5, y: 1)
        
        leftLeg = SKSpriteNode(color: .cyan, size: .init(width: 30, height: 100))
        leftLeg.anchorPoint = .init(x: 0.5, y: 1)
        
        
        rightFoot = SKSpriteNode(color: .systemTeal, size: .init(width: 30, height: 100))
        rightFoot.anchorPoint = .init(x: 0.5, y: 1)
        
        leftFoot = SKSpriteNode(color: .systemTeal, size: .init(width: 30, height: 100))
        leftFoot.anchorPoint = .init(x: 0.5, y: 1)
    }
    
    var status : PlayerStatus = .idle
    
    func changeStatus(to: PlayerStatus) {
        status = to
        
        switch status {
            case .jumping:
                //jump(to: scene.jumpPoint)
                break
            
            case .idle:
                idle()
                break
            
            case .falling:
                fall()
                break
        }
    }
    
    func idle() {
        scene.player.node.color = .init(red: .random(in: 0.3...0.98), green: .random(in: 0.3...0.98), blue: .random(in: 0.3...0.98), alpha: 1)
    }
    
    func fall() {
        scene.player.node.color = .red
    }
    
    func getJumpPath(to: CGPoint) -> CGPath {
        let px = self.node.position.x
        let py = self.node.position.y
        
        let curve = UIBezierPath()
        curve.move(to: self.node.position)
        
        // Deslocamento em x
        let dx = to.x - self.node.position.x
        
        // Deslocamento absoluto em y
        let absdy = abs(to.y - py)
        
        // x do ponto de controle
        var ctrlx : CGFloat
        if to.y > py {
            ctrlx = px + dx*0.65
        }
        else {
            ctrlx = px + 3*dx/5
        }
        
        // y do ponto de controle
        var ctrly : CGFloat
        if to.y > py {
            ctrly = to.y + absdy*0.3
        }
        else {
            ctrly = py - 2*absdy/5
        }
        
        // Ponto de controle da curva
        let control = CGPoint(x: ctrlx, y: ctrly)
        curve.addQuadCurve(to: to, controlPoint: control)
        
        return curve.cgPath
    }
}

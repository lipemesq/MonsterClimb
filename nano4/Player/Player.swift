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

    var rightKnee  : SKPhysicsJointPin!
    var leftKnee  : SKPhysicsJointPin!
    
    let legsLowerAngleLimit : CGFloat = -90
    let legsUpperAngleLimit : CGFloat = 90
    
    let kneesLowerAngleLimit : CGFloat = -60
    let kneesUpperAngleLimit : CGFloat = 0
    
    init(scene: GameScene) {
        self.scene = scene
        self.node = scene.childNode(withName: "player") as! SKSpriteNode
        self.node.position = CGPoint(x: 100, y: -300)
        self.node.zPosition = 10

        let legWidth = 7
        let feetWidth = 30
        
        rightLeg = SKSpriteNode(texture: SKTexture(imageNamed: "pernaa"), size: .init(width: legWidth, height: 60))
        rightLeg.anchorPoint = .init(x: 0.5, y: 1)
        
        leftLeg = SKSpriteNode(texture: SKTexture(imageNamed: "pernaa"), size: .init(width: legWidth, height: 60))
        leftLeg.anchorPoint = .init(x: 0.5, y: 1)
        
        
        rightFoot = SKSpriteNode(texture: SKTexture(imageNamed: "peDireito"), size: .init(width: feetWidth, height: 32*feetWidth/13))
        rightFoot.anchorPoint = .init(x: 0.1, y: 0.9)
        
        leftFoot = SKSpriteNode(texture: SKTexture(imageNamed: "peDireito"), size: .init(width: feetWidth, height: 32*feetWidth/13))
        leftFoot.anchorPoint = .init(x: 0.1, y: 0.9)
        
        
        rightLeg.zPosition = 10
        rightFoot.zPosition = 10
        leftLeg.zPosition = 10
        leftFoot.zPosition = 10
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
        //scene.player.node.color = .init(red: .random(in: 0.3...0.98), green: .random(in: 0.3...0.98), blue: .random(in: 0.3...0.98), alpha: 1)
    }
    
    func fall() {
        //scene.player.node.color = .red
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

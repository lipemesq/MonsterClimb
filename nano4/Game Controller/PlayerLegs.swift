//
//  PlayerLegs.swift
//  nano4
//
//  Created by Felipe Mesquita on 15/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

// ******************************************
// MARK: PLAYER LEGS

extension GameScene {
    
    func addLegsAndFoots() {

        // Cria as pernas
        createLegs()
        
        // Cria os joelhos
        createKnees()
        
        // Remove a colisão das pernas
        removeLegsCollision()
        
        // Liga as pernas no corpo
        pinLegsJoints()
        
        // Liga os joelhos nas pernas
        pinKneesJoints()

    }
    
    
    
    // MARK: - SETUP DAS PERNAS
    
    /// Create the legs and add to the scene
    fileprivate func createLegs() {
        
        // Esquerda
        addChild(player.leftLeg)
        player.leftLeg.position = player.node.position + CGPoint(x: -10, y: -player.node.size.height / 2)
        player.leftLeg.physicsBody = SKPhysicsBody(rectangleOf: player.leftLeg.size)
        player.leftLeg.physicsBody?.isDynamic = true
        player.leftLeg.physicsBody?.affectedByGravity = true
        
        // Direita
        addChild(player.rightLeg)
        player.rightLeg.position = player.node.position + CGPoint(x: 10, y: -player.node.size.height / 2)
        player.rightLeg.physicsBody = SKPhysicsBody(rectangleOf: player.rightLeg.size)
        player.rightLeg.physicsBody?.isDynamic = true
        player.rightLeg.physicsBody?.affectedByGravity = true
    }
    
    
    
    // MARK: - SETUP DOS JOELHOS
    
    /// Create the knees and add to the scene
    fileprivate func createKnees() {
        
        // Esquerdo
        addChild(player.leftFoot)
        player.leftFoot.position = player.leftLeg.position + CGPoint(x: 0, y: -player.leftLeg.size.height)
        player.leftFoot.physicsBody = SKPhysicsBody(rectangleOf: player.leftFoot.size)
        player.leftFoot.physicsBody?.isDynamic = true
        player.leftFoot.physicsBody?.affectedByGravity = true
        
        // Direito
        addChild(player.rightFoot)
        player.rightFoot.position = player.rightLeg.position + CGPoint(x: 0, y: -player.rightLeg.size.height)
        player.rightFoot.physicsBody = SKPhysicsBody(rectangleOf: player.rightFoot.size)
        player.rightFoot.physicsBody?.isDynamic = true
        player.rightFoot.physicsBody?.affectedByGravity = true
    }
    
    
    
    // MARK: - COLISÃO
    
    /// Remove legs collision layer
    fileprivate func removeLegsCollision() {
        // Ninguém colide com elas
        player.rightLeg.physicsBody?.collisionBitMask = 0
        player.leftLeg.physicsBody?.collisionBitMask = 0
        player.rightFoot.physicsBody?.collisionBitMask = 0
        player.leftFoot.physicsBody?.collisionBitMask = 0
        
        // Nào colide com ninguém
        player.rightLeg.physicsBody?.categoryBitMask  = 0
        player.leftLeg.physicsBody?.categoryBitMask  = 0
        player.rightFoot.physicsBody?.categoryBitMask  = 0
        player.leftFoot.physicsBody?.categoryBitMask  = 0
    }
    
    
    
    // MARK: - JUNTAS DAS PERNAS
    
    /// Pin the legs in the body
    fileprivate func pinLegsJoints() {
        
        // Junta da perna esquerda
        let leftLegJoint = SKPhysicsJointPin.joint(
            withBodyA: player.node.physicsBody!,
            bodyB: player.leftLeg.physicsBody!,
            anchor: player.node.position + CGPoint(x: -10, y: -player.node.size.height / 2))
        leftLegJoint.shouldEnableLimits = true
        leftLegJoint.lowerAngleLimit = player.legsLowerAngleLimit.toRadians
        leftLegJoint.upperAngleLimit = player.legsUpperAngleLimit.toRadians
        scene!.physicsWorld.add(leftLegJoint)
        
        // Junta da perna direita
        let rightLegJoint = SKPhysicsJointPin.joint(
            withBodyA: player.node.physicsBody!,
            bodyB: player.rightLeg.physicsBody!,
            anchor: player.node.position + CGPoint(x: 10, y: -player.node.size.height / 2))
        rightLegJoint.shouldEnableLimits = true
        rightLegJoint.lowerAngleLimit = player.legsLowerAngleLimit.toRadians
        rightLegJoint.upperAngleLimit = player.legsUpperAngleLimit.toRadians
        scene!.physicsWorld.add(rightLegJoint)
    }
    
    
    
    // MARK: - JUNTAS DOS JOELHOS
    
    /// Pin the knees in the legs
    fileprivate func pinKneesJoints() {
        
        // Junta do joelho esquerdo
        player.leftKnee = SKPhysicsJointPin.joint(
            withBodyA: player.leftLeg.physicsBody!,
            bodyB: player.leftFoot.physicsBody!,
            anchor: player.leftLeg.position + CGPoint(x: 0, y: -player.leftLeg.size.height))
        player.leftKnee.shouldEnableLimits = true
        player.leftKnee.lowerAngleLimit = player.kneesLowerAngleLimit.toRadians
        player.leftKnee.upperAngleLimit = player.kneesUpperAngleLimit.toRadians
        scene!.physicsWorld.add(player.leftKnee)
        
        // Junta do joelho direito
        player.rightKnee = SKPhysicsJointPin.joint(
            withBodyA: player.rightLeg.physicsBody!,
            bodyB: player.rightFoot.physicsBody!,
            anchor: player.rightLeg.position + CGPoint(x: 0, y: -player.rightLeg.size.height))
        player.rightKnee.shouldEnableLimits = true
        player.rightKnee.lowerAngleLimit = player.kneesLowerAngleLimit.toRadians
        player.rightKnee.upperAngleLimit = player.kneesUpperAngleLimit.toRadians
        scene!.physicsWorld.add(player.rightKnee)
    }
    
    
}


//
//  GameScene.swift
//  nano4
//
//  Created by Felipe Mesquita on 04/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    deinit{print("GameScene deinited")}

    
    // ******************************************
    // MARK: - PROPERTIES
    
    // Tiles
    var presetTiles : [Tile] = []
    var inGameTiles : [Tile] = []
    var tilesProbabilityList : [Int] = []
    var lastTileAdded = -1
    
    // Player
    var player : Player!
    let maxJumpDistance : CGFloat = 700
    
    // Camera
    var cam : SKCameraNode = SKCameraNode()
    /// The node where the camera's inside. Used for the camera's move animation.
    var camNode : SKNode = SKNode()
    var lastCameraUpdate : TimeInterval = TimeInterval(0)
    var camUpdateInterval : TimeInterval = 0.175
    var camMoveVelocity : TimeInterval = 0.175
    
    // Lava
    var lava : Lava!
    var lavaSpeed : CGFloat = 1//3
    let maxLavaSpeed : CGFloat = 6
    let lavaAcceleration : CGFloat = 0.00001
    
    // Próximos pontos de apoio
    var nearFootholds : [CGPoint] = []
    var spritesOfNearFootholds : [SKSpriteNode] = []
    var actualFoothold : CGPoint?

    
    // ******************************************
    // MARK: - START
    
    override func didMove(to view: SKView) {
        
        // Adiciona o pan pro swipe
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longRecognizer(long:)))
//        view.addGestureRecognizer(longPress)
        
        // e o tap pro toque
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognizer(tap:)))
        view.addGestureRecognizer(tap)
        
        // Colisões
        physicsWorld.contactDelegate = self
        
        // Cria o player
        player = Player(scene: self)
        player.node.turnPhysicsOff()
        player.node.blendMode = .replace
        addChild(player.node)
        player.node.physicsBody?.isDynamic = false
        
        player.nose.blendMode = .replace
        player.nose.position = CGPoint(x: 30, y: 0)
        player.node.addChild(player.nose)
        

        
        // coloca o circulo de raio
        let circle = SKShapeNode(circleOfRadius: maxJumpDistance ) // Size of Circle
        player.node.addChild(circle)
        circle.position = .zero
        circle.strokeColor = SKColor.green
        circle.glowWidth = 1.0
        
        
        // Adicina as pernas e pés do monstrinho à cena
        addLegsAndFoots()
        
        
        // Máscara de colisão do player
        player.node.physicsBody!.categoryBitMask = 2
        player.node.physicsBody!.contactTestBitMask = 2
        player.node.physicsBody?.collisionBitMask = 5
        player.node.physicsBody?.usesPreciseCollisionDetection = true
        
        // Inicia a camera
        addChild(camNode)
        camera = cam
        camNode.addChild(camera!)
        
        // Pega os prefabs de fase
        for i in 1...7 {
            let tile = self.childNode(withName: "fase\(i)") as! Tile
            presetTiles.append(tile)
            for _ in 1...tile.getProbability() {
                tilesProbabilityList.append(i-1)
            }
        }
        
        // Ordena as próximas fases
        for _ in 0...2 {
            let tile = presetTiles[drawNextTileNumber()].copy() as! Tile
            inGameTiles.append(tile)
            insertChild(tile, at: 0)
        }
        
        // Adiciona os tiles na cena, cada um com sua altura
        var yoffset : CGFloat = 0
        for i in inGameTiles.indices {
            let tile = inGameTiles[i]
            tile.position.y = yoffset
            tile.position.x = 0
            yoffset += tile.size.height
            
            tile.loadFootholds()
            spritesOfNearFootholds.append(contentsOf: tile.footholds)
            nearFootholds.append(contentsOf: tile.footholds.map({ (f) -> CGPoint in
                let point =  tile.convert(f.position, to: scene!)
                return point
            }))
            
            tile.loadEnemies()
            for enemy in tile.enemies {
                setupEnemy(enemy: enemy.node)
                enemy.startMoving()
            }
        }
        
        
        // Setup Lava
        lava = Lava(scene: self)
        lava.node.blendMode = .replace
        lava.node.turnPhysicsOff()
        lava.node.physicsBody?.isResting = true
//        lava.node.physicsBody?.isDynamic = false
        lava.node.physicsBody!.categoryBitMask = 1//player.node.physicsBody!.collisionBitMask
        lava.node.physicsBody!.contactTestBitMask = player.node.physicsBody!.categoryBitMask
        lava.node.physicsBody!.collisionBitMask = 0
    }
    
    
    // ******************************************
    // MARK: - UPDATE
    var initialTime : TimeInterval!
    var firstUpdate = true
    override func update(_ currentTime: TimeInterval) {
        
        if firstUpdate {
            firstUpdate = false
            initialTime = currentTime
        }
        
        // Atualizações periódicas
        if abs(currentTime.distance(to: lastCameraUpdate)) > camUpdateInterval {
            
            // Move a câmera
            moveCamera(currentTime: currentTime)
            
            // Verifica se daqui a pouco o player chega num tile novo
            let lastTile = inGameTiles.last!
            let top = lastTile.position.y + lastTile.size.height
            let dyTilTop = top - player.node.position.y
            
            // se vai chegar (agora a 1,5 tile do topo)
            if dyTilTop < lastTile.size.height * 2 {
                
                // Coloca um novo tile lá em cima
                pushNewTile(y: top)
            }
        }
        
        // Sobe a lava
        if lavaSpeed < maxLavaSpeed {
            lavaSpeed += lavaAcceleration
        }
        else {
            lavaSpeed = maxLavaSpeed
        }
        
        let x = (currentTime - initialTime)
        let yVariationControl = (lavaSpeed / maxLavaSpeed)
        let lavaSpeedVariation = CGFloat(1.5*sin(x*0.22)) * yVariationControl
        
        let lavaAdvance = lavaSpeed + (lavaSpeedVariation > 0 ? lavaSpeedVariation : 0)
        print("lava speed: ", lavaSpeed)
        
        lava.node.position.y += lavaAdvance
        removeBottomTileIfBelowLava()
    }
    
    
    func setupEnemy(enemy: SKSpriteNode) {
        // turn off physics and add collision
        enemy.turnPhysicsOff()
        enemy.physicsBody?.categoryBitMask = 4
        enemy.physicsBody?.collisionBitMask = 0//player.node.physicsBody!.categoryBitMask
        enemy.physicsBody!.contactTestBitMask = player.node.physicsBody!.categoryBitMask
    }
    
    
    
    /**
     Animate the player jumping to a point, and do a completion after. Set the player's state to `.jumping`.
     
     Uses the player's `getJumpPath` to get the path of the jump. The speed of animation is 1000, and its linear. At the end change the player's state to `.idle` with the `change` function.
     
     - Parameters:
         - to: The point to which the player will jump.
         - completion: The completion block after the jump animation. Optional. If null, runs `player.change(to: .idle)`.
     */
    func playerJump(to: CGPoint, completion: os_block_t? = nil)  {
        player.status = .jumping
        
        let jumpSpeed : CGFloat = 900
        
        let jumpPath = player.getJumpPath(to: to)
        let movey = SKAction.follow(jumpPath, asOffset: false, orientToPath: false, speed: jumpSpeed)
        
        let distance = player.node.position.distance(to: to)
        let minDuration = distance / jumpSpeed
        let side : CGFloat = player.node.position.x > to.x ? -1 : 1
        
        let rotate = SKAction.rotate(byAngle: CGFloat(side * 20 ).toRadians, duration: TimeInterval(0.4*minDuration))
//         rotate.timingFunction = {
//            time in
//            if time > 0.98 {
//                return 1
//            }
//            let ts = time * time
//            //let tq = ts * time
//            return 0.03617559 - 0.5075462*time + 1.418831*ts// + 1.418831*tq//-0.001634018 + 0.739019*time - 1.295628*ts + 1.557971*tq
//        }
        let rotateBack = SKAction.rotate(byAngle: CGFloat(side * -20).toRadians, duration: TimeInterval(0.3*minDuration))
        let seq = SKAction.sequence([rotate, SKAction.wait(forDuration: TimeInterval(0.4*minDuration)), rotateBack])
        
        let group : SKAction
        if minDuration > 0.35 {
            group = SKAction.group([movey, seq])
        }
        else {
            group = SKAction.group([movey])
        }
            
        
        player.node.run(group, completion: {
            if completion != nil {
                completion!()
            }
            else {
                self.player.changeStatus(to: .idle)
            }
        })
    }
    
    
    
    /**
     Add to the top of tiles a new one, from the preset list, that's granted different from the last one.
     
     Random a new tile from the `presetTiles` list that's different from the last one. This tile is a copy, not the original. Append to the scene and to `inGameTiles`. Load the footholds into `nearFootholds`.
     
     - Parameters:
         - y: the y position where the block will be inserted.
     */
    func pushNewTile(y: CGFloat) {
        // draw a random tile that is different from the last one,
        // set up the tile and insert into some things
        let tile = presetTiles[drawNextTileNumber()].copy() as! Tile
        tile.position = CGPoint(x: 0, y: y)
        inGameTiles.append(tile)
        insertChild(tile, at: 0)
        
        // get the footholds
        tile.loadFootholds()
        spritesOfNearFootholds.append(contentsOf: tile.footholds)
        nearFootholds.append(contentsOf: tile.footholds.map({ (f) -> CGPoint in
            let point =  tile.convert(f.position, to: scene!)
            return point
        }))
        
        // get the enemies in the tile
        tile.loadEnemies()
        for enemy in tile.enemies {
            setupEnemy(enemy: enemy.node)
            enemy.startMoving()
        }
        
        // accelerate the lava
        if lavaSpeed < maxLavaSpeed {
            print("lava speed: ", lavaSpeed)
            lavaSpeed += lavaAcceleration
        }
    }
    
    
    
    func drawNextTileNumber() -> Int {
        var randomTileNumber : Int
        var randomIndex : Int
        repeat {
            randomIndex = Int.random(in: tilesProbabilityList.indices)
            randomTileNumber = tilesProbabilityList[randomIndex]
        } while randomTileNumber == lastTileAdded
        lastTileAdded = randomTileNumber
        
        return randomTileNumber
    }
    

    /**
     Verify if the bottom tile is below the lava, and if it is, removes the tile and erases its presence, as well as that of its footholds.
     
     The tile is removed from the superview and from `inGameTiles`. Its footholds are removed together from the superview, and from `nearFootholds`.
     */
    func removeBottomTileIfBelowLava() {
        // Tile mais abaixo
        let firstTile = inGameTiles.first!
        
        // Se ele tiver abaixo da lava
        if firstTile.position.y < lava.node.position.y {
            // Remove os footholds da lista
            nearFootholds.removeFirst(firstTile.footholds.count)
            spritesOfNearFootholds.removeFirst(firstTile.footholds.count)
            
            // Remove o tile
            firstTile.removeFromParent()
            inGameTiles.remove(at: 0)
        }
    }

}

// ******************************************
// MARK: - COLLISION

extension GameScene {
    
    // Trata o início de uma colisão
    func didBegin(_ contact: SKPhysicsContact) {
        print("A: \(contact.bodyA), B: \(contact.bodyB)")
        player.node.turnPhysicsOn()
        player.changeStatus(to: .falling)
        
//        scene!.speed = 0.4
//        self.physicsWorld.speed = 0.4
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
//            self.resetGame()
//        })

    }
    
    func resetGame() {
        scene?.removeAllActions()
        scene?.removeAllChildren()
        
        let newScene = SKScene(fileNamed: "GameScene")!
        newScene.scaleMode = self.scaleMode
        //let animation = SKTransition.fade(withDuration: 2.0)
        self.view?.presentScene(newScene)
    }
    
}


// ******************************************
// MARK: - MOVE CAMERA

extension GameScene {
    /**
     Move the camera to the player y position and update the last time it was moved.
     
     Move the camera til player's y + 300, so it stays in the first third of the screen. The movement is linear animated, and lasts 0.2 seconds.
     
     - Parameters:
     - currentTime: the current time when the function was called (normally from the `update` function).
     */
    func moveCamera(currentTime: TimeInterval) {
        let moveAnimaton = SKAction.moveTo(y: player.node.position.y+300, duration: camMoveVelocity)
        //moveAnimaton.timingMode = .easeIn
        camNode.run(moveAnimaton)
        lastCameraUpdate = currentTime
    }
}


// ******************************************
// MARK: - GESTURES RECOGNIZERS

extension GameScene {
    
    @objc func tapRecognizer(tap: UITapGestureRecognizer) {
        let pos = self.convertPoint(fromView: tap.location(in: view))
        
        let touchPointMarker = SKSpriteNode(color: .magenta, size: CGSize(width: 10, height: 10))
        touchPointMarker.position = pos
        
        addChild(touchPointMarker)
    
        var nextFoothold : CGPoint?
        for (i, sprite) in spritesOfNearFootholds.enumerated() {
            let foothold = nearFootholds[i]
            if foothold != actualFoothold {
                if self.nodes(at: pos).contains(sprite) {
                    let distance = player.node.position.distance(to: foothold)
                    if distance < maxJumpDistance {
                        sprite.color = .green
                        nextFoothold = foothold
                    }
                }
            }
        }
        
        if pos.x > player.node.position.x {
            player.node.xScale = 1
        }
        else {
            player.node.xScale = -1
        }
        
        if nextFoothold != nil {
            actualFoothold = nextFoothold
            if player.status == .idle {
                playerJump(to: nextFoothold!, completion: {
                    self.player.changeStatus(to: .idle)
                    
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
                playerJump(to: pos, completion: {
                    self.player.changeStatus(to: .falling)
                    self.player.node.turnPhysicsOn()
                })
            }
        }
        
    }
}


// ******************************************
// MARK: PERNAS
extension GameScene {
    
    func addLegsAndFoots() {
        addChild(player.leftLeg)
        player.leftLeg.position = player.node.position + CGPoint(x: -10, y: -player.node.size.height / 2)
        player.leftLeg.physicsBody = SKPhysicsBody()
        player.leftLeg.physicsBody?.isDynamic = true
        player.leftLeg.physicsBody?.affectedByGravity = true
        
        addChild(player.leftFoot)
        player.leftFoot.position = player.leftLeg.position + CGPoint(x: 0, y: -player.leftLeg.size.height)
        player.leftFoot.physicsBody = SKPhysicsBody()
        player.leftFoot.physicsBody?.isDynamic = true
        player.leftFoot.physicsBody?.affectedByGravity = true
        
        
        
        addChild(player.rightLeg)
        player.rightLeg.position = player.node.position + CGPoint(x: 10, y: -player.node.size.height / 2)
        player.rightLeg.physicsBody = SKPhysicsBody()
        player.rightLeg.physicsBody?.isDynamic = true
        player.rightLeg.physicsBody?.affectedByGravity = true
        
        addChild(player.rightFoot)
        player.rightFoot.position = player.rightLeg.position + CGPoint(x: 0, y: -player.rightLeg.size.height)
        player.rightFoot.physicsBody = SKPhysicsBody()
        player.rightFoot.physicsBody?.isDynamic = true
        player.rightFoot.physicsBody?.affectedByGravity = true
        
        
        // Remove a colisão
        player.rightLeg.physicsBody?.collisionBitMask = 0
        player.leftLeg.physicsBody?.collisionBitMask = 0
        player.rightFoot.physicsBody?.collisionBitMask = 0
        player.leftFoot.physicsBody?.collisionBitMask = 0
        
        player.rightLeg.physicsBody?.categoryBitMask  = 0
        player.leftLeg.physicsBody?.categoryBitMask  = 0
        player.rightFoot.physicsBody?.categoryBitMask  = 0
        player.leftFoot.physicsBody?.categoryBitMask  = 0
        
        
        player.leftLeg.physicsBody?.mass = 1
        player.rightLeg.physicsBody?.mass = 1
        player.rightFoot.physicsBody?.mass = 0.1
        player.leftFoot.physicsBody?.mass = 0.1
        
        
        let pinJointE = SKPhysicsJointPin.joint(withBodyA: player.node.physicsBody!,
                                                bodyB: player.leftLeg.physicsBody!,
                                                anchor: player.node.position + CGPoint(x: -10, y: -player.node.size.height / 2))
        scene!.physicsWorld.add(pinJointE)
        
        let pinJointD = SKPhysicsJointPin.joint(withBodyA: player.node.physicsBody!,
                                                bodyB: player.rightLeg.physicsBody!,
                                                anchor: player.node.position + CGPoint(x: 10, y: -player.node.size.height / 2))
        scene!.physicsWorld.add(pinJointD)
        
        
        
        let pinJointCalcE = SKPhysicsJointPin.joint(withBodyA: player.leftLeg.physicsBody!,
                                                    bodyB: player.leftFoot.physicsBody!,
                                                    anchor: player.leftLeg.position + CGPoint(x: 0, y: -player.leftLeg.size.height))
        pinJointCalcE.shouldEnableLimits = true
        pinJointCalcE.lowerAngleLimit = CGFloat(-90).toRadians
        pinJointCalcE.upperAngleLimit = CGFloat(90).toRadians
        scene!.physicsWorld.add(pinJointCalcE)
        
        let pinJointCalcD = SKPhysicsJointPin.joint(withBodyA: player.rightLeg.physicsBody!,
                                                    bodyB: player.rightFoot.physicsBody!,
                                                    anchor: player.rightLeg.position + CGPoint(x: 0, y: -player.rightLeg.size.height))
        pinJointCalcD.shouldEnableLimits = true
        pinJointCalcD.lowerAngleLimit = CGFloat(-90).toRadians
        pinJointCalcD.upperAngleLimit = CGFloat(90).toRadians
        scene!.physicsWorld.add(pinJointCalcD)
    }
    
    
}

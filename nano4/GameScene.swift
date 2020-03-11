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
    
    // Lava
    var lava : Lava!
    var lavaSpeed : CGFloat = 3
    let maxLavaSpeed : CGFloat = 10
    let lavaAcceleration : CGFloat = 0.5
    
    // Próximos pontos de apoio
    var nearFootholds : [CGPoint] = []
    var spritesOfNearFootholds : [SKSpriteNode] = []
    var actualFoothold : CGPoint?

    
    // ******************************************
    // MARK: - START
    
    override func didMove(to view: SKView) {
        
        // Adiciona o pan pro swipe
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longRecognizer(long:)))
        view.addGestureRecognizer(longPress)
        
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

        
        // coloca o circulo de raio
        let circle = SKShapeNode(circleOfRadius: maxJumpDistance ) // Size of Circle
        player.node.addChild(circle)
        circle.position = .zero  //Middle of Screen
        circle.strokeColor = SKColor.green
        circle.glowWidth = 1.0
        
        
        
        let pernaE = SKSpriteNode(color: .systemTeal, size: .init(width: 30, height: 100))
        pernaE.anchorPoint = .init(x: 0.5, y: 1)
        pernaE.position = player.node.position + CGPoint(x: -10, y: -player.node.size.height / 2)
        addChild(pernaE)
        pernaE.physicsBody = SKPhysicsBody(rectangleOf: pernaE.size)
        pernaE.physicsBody?.isDynamic = true
        pernaE.physicsBody?.affectedByGravity = true
        
        let calcanharE = SKSpriteNode(color: .systemTeal, size: .init(width: 30, height: 100))
        calcanharE.anchorPoint = .init(x: 0.5, y: 1)
        calcanharE.position = pernaE.position + CGPoint(x: 0, y: -pernaE.size.height)
        addChild(calcanharE)
        calcanharE.physicsBody = SKPhysicsBody(rectangleOf: calcanharE.size)
        calcanharE.physicsBody?.isDynamic = true
        calcanharE.physicsBody?.affectedByGravity = true
        
        
        
        
        let pernaD = SKSpriteNode(color: .cyan, size: .init(width: 30, height: 100))
        pernaD.anchorPoint = .init(x: 0.5, y: 1)
        pernaD.position = player.node.position + CGPoint(x: 10, y: -player.node.size.height / 2)
        addChild(pernaD)
        pernaD.physicsBody = SKPhysicsBody(rectangleOf: pernaD.size)
        pernaD.physicsBody?.isDynamic = true
        pernaD.physicsBody?.affectedByGravity = true
        
        let calcanharD = SKSpriteNode(color: .cyan, size: .init(width: 30, height: 100))
        calcanharD.anchorPoint = .init(x: 0.5, y: 1)
        calcanharD.position = pernaD.position + CGPoint(x: 0, y: -pernaD.size.height)
        addChild(calcanharD)
        calcanharD.physicsBody = SKPhysicsBody(rectangleOf: calcanharD.size)
        calcanharD.physicsBody?.isDynamic = true
        calcanharD.physicsBody?.affectedByGravity = true
        
        
        // Remove a colisão
        pernaD.physicsBody?.collisionBitMask = 0
        pernaE.physicsBody?.collisionBitMask = 0
        calcanharD.physicsBody?.collisionBitMask = 0
        calcanharE.physicsBody?.collisionBitMask = 0
        
        pernaD.physicsBody?.categoryBitMask  = 0
        pernaE.physicsBody?.categoryBitMask  = 0
        calcanharD.physicsBody?.categoryBitMask  = 0
        calcanharE.physicsBody?.categoryBitMask  = 0
        
        
        
        
        
        let pinJointE = SKPhysicsJointPin.joint(withBodyA: player.node.physicsBody!,
                                               bodyB: pernaE.physicsBody!,
                                               anchor: player.node.position + CGPoint(x: -10, y: -player.node.size.height / 2))
        pinJointE.lowerAngleLimit = -85
        pinJointE.upperAngleLimit = 91
        scene!.physicsWorld.add(pinJointE)
        
        let pinJointD = SKPhysicsJointPin.joint(withBodyA: player.node.physicsBody!,
                                               bodyB: pernaD.physicsBody!,
                                               anchor: player.node.position + CGPoint(x: 10, y: -player.node.size.height / 2))
        pinJointD.lowerAngleLimit = -90
        pinJointD.upperAngleLimit = 87
        scene!.physicsWorld.add(pinJointD)
        
        
        
        let pinJointCalcE = SKPhysicsJointPin.joint(withBodyA: pernaE.physicsBody!,
                                                bodyB: calcanharE.physicsBody!,
                                                anchor: pernaE.position + CGPoint(x: 0, y: -pernaE.size.height))
        pinJointCalcE.shouldEnableLimits = true
        pinJointCalcE.lowerAngleLimit = -40
        pinJointCalcE.upperAngleLimit = 30
        scene!.physicsWorld.add(pinJointCalcE)
        
        let pinJointCalcD = SKPhysicsJointPin.joint(withBodyA: pernaD.physicsBody!,
                                                bodyB: calcanharD.physicsBody!,
                                                anchor: pernaD.position + CGPoint(x: 0, y: -pernaD.size.height))
        pinJointCalcD.shouldEnableLimits = true
        pinJointCalcD.lowerAngleLimit = -36
        pinJointCalcD.upperAngleLimit = 31
        scene!.physicsWorld.add(pinJointCalcD)
        
        
        
        
        // Máscara de colisão do player
        player.node.physicsBody!.collisionBitMask = 12
        player.node.physicsBody!.contactTestBitMask = player.node.physicsBody!.collisionBitMask
        
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
        
    }
    
    
    // ******************************************
    // MARK: - UPDATE
    override func update(_ currentTime: TimeInterval) {
        
        // Atualizações periódicas
        if abs(currentTime.distance(to: lastCameraUpdate)) > 0.2 {
            
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
        lava.node.position.y += lavaSpeed
        removeBottomTileIfBelowLava()
    }
    
    
    func setupEnemy(enemy: SKSpriteNode) {
        // turn off physics and add collision
        enemy.turnPhysicsOff()
        enemy.physicsBody!.contactTestBitMask = player.node.physicsBody!.collisionBitMask
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
        player.node.turnPhysicsOn()
        player.changeStatus(to: .falling)
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
        let moveAnimaton = SKAction.moveTo(y: player.node.position.y+300, duration: 0.2)
        //moveAnimaton.timingMode = .easeIn
        camNode.run(moveAnimaton)
        lastCameraUpdate = currentTime
    }
}


// ******************************************
// MARK: - GESTURES RECOGNIZERS

extension GameScene {
    @objc func longRecognizer(long: UILongPressGestureRecognizer) {
        if long.state == .began {
            let pos = self.convertPoint(fromView: long.location(in: view))
            
            var nextFoothold : CGPoint?
            var actualDistance : CGFloat = 0
            let px = pos.x
            let middleOfScreen : CGFloat = 0
            if px < middleOfScreen {
                for foothold in nearFootholds {
                    if foothold.y < player.node.position.y {
                        if foothold.x < player.node.position.x {
                            if nextFoothold == nil {
                                let distance = player.node.position.distance(to: foothold)
                                if distance < maxJumpDistance {
                                    nextFoothold = foothold
                                    actualDistance = distance
                                }
                            }
                            else {
                                let distance = player.node.position.distance(to: foothold)
                                if distance < actualDistance {
                                    nextFoothold = foothold
                                    actualDistance = distance
                                }
                            }
                        }
                    }
                }
            }
            else {
                for foothold in nearFootholds {
                    if foothold.y < player.node.position.y {
                        if foothold.x > player.node.position.x {
                            if nextFoothold == nil {
                                let distance = player.node.position.distance(to: foothold)
                                if distance < maxJumpDistance {
                                    nextFoothold = foothold
                                    actualDistance = distance
                                }
                            }
                            else {
                                if foothold.y > player.node.position.y {
                                    let distance = player.node.position.distance(to: foothold)
                                    if distance < actualDistance {
                                        nextFoothold = foothold
                                        actualDistance = distance
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if nextFoothold != nil {
                if player.status == .idle {
                    playerJump(to: nextFoothold!)
                }
            }
            else {
                if player.status == .idle {
                    playerJump(to: pos + CGPoint(x: 0, y: 300), completion: {
                        self.player.changeStatus(to: .falling)
                        self.player.node.turnPhysicsOn()
                    })
                }
            }
        }
    }
    
    @objc func tapRecognizer(tap: UITapGestureRecognizer) {
        let pos = self.convertPoint(fromView: tap.location(in: view))
    
        var nextFoothold : CGPoint?
        var actualDistance : CGFloat = 0
        let px = pos.x
        let middleOfScreen : CGFloat = 0
        if px < middleOfScreen {
            for foothold in nearFootholds {
                if foothold != actualFoothold {
                    if foothold.y > player.node.position.y {
                        if foothold.x < player.node.position.x {
                            if nextFoothold == nil {
                                let distance = player.node.position.distance(to: foothold)
                                if distance < maxJumpDistance {
                                    nextFoothold = foothold
                                    actualDistance = distance
                                }
                            }
                            else {
                                let distance = player.node.position.distance(to: foothold)
                                if distance < actualDistance {
                                    nextFoothold = foothold
                                    actualDistance = distance
                                }
                            }
                        }
                    }
                }
            }
        }
        else {
            for foothold in nearFootholds {
                if foothold != actualFoothold {
                    if foothold.y > player.node.position.y {
                        if foothold.x > player.node.position.x {
                            if nextFoothold == nil {
                                let distance = player.node.position.distance(to: foothold)
                                if distance < maxJumpDistance {
                                    nextFoothold = foothold
                                    actualDistance = distance
                                }
                            }
                            else {
                                let distance = player.node.position.distance(to: foothold)
                                if distance < actualDistance {
                                    nextFoothold = foothold
                                    actualDistance = distance
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if nextFoothold != nil {
            actualFoothold = nextFoothold
            if player.status == .idle {
                playerJump(to: nextFoothold!, completion: {
                    self.player.changeStatus(to: .idle)
                    
                    for foothold in self.nearFootholds {
                        let distance = self.player.node.position.distance(to: foothold)
                        if distance < self.maxJumpDistance {
                            self.spritesOfNearFootholds[self.nearFootholds.firstIndex(of: foothold)!].color = .blue
                        }
                        else {
                            self.spritesOfNearFootholds[self.nearFootholds.firstIndex(of: foothold)!].color = .orange
                        }
                    }
                })
            }
        }
        else {
            if player.status == .idle {
                playerJump(to: pos + CGPoint(x: 0, y: 300), completion: {
                    self.player.changeStatus(to: .falling)
                    self.player.node.turnPhysicsOn()
                })
            }
        }
        
    }
}

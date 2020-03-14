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
    
    // Controle do fluxo
    var reseting = false
    var lastGameUpdate : TimeInterval = TimeInterval(0)
    var gameUpdateInterval : TimeInterval = 0.175
    var initialTime : TimeInterval!
    var initalTapDelay = TimeInterval(3)
    var firstUpdate = true
    var canDoInitialTap = false
    var tapp = false
    
    // Pontos
    var pointsNode : SKSpriteNode!
    var pontos = 0
    
    // Tiles
    var presetTiles : [Tile] = []
    var inGameTiles : [Tile] = []
    var tilesProbabilityList : [Int] = []
    var lastTileAdded = -1
    var mostDifficultTileNumber = 4
    var newTilesCount = 0
    
    // Player
    var player : Player!
    let maxJumpDistance : CGFloat = 700
    
    // Camera
    var cam : SKCameraNode = SKCameraNode()
    /// The node where the camera's inside. Used for the camera's move animation.
    var camNode : SKNode = SKNode()
    var lastCameraUpdate : TimeInterval = TimeInterval(0)
    var camUpdateInterval : TimeInterval = 0.2
    var camMoveVelocity : TimeInterval = 0.3
    
    // Lava
    var lava : Lava!
    var lavaSpeed : CGFloat = 2
    let maxLavaSpeed : CGFloat = 6
    let lavaAcceleration : CGFloat = 0.0001
    
    // Próximos pontos de apoio
    var nearFootholds : [CGPoint] = []
    var spritesOfNearFootholds : [SKSpriteNode] = []
    var actualFoothold : CGPoint?

    var titleGame : SKSpriteNode!
    // ******************************************
    // MARK: - START
    
    override func didMove(to view: SKView) {
        
        // adiciona o tap controller
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognizer(tap:)))
        view.addGestureRecognizer(tap)
        
        // Colisões
        physicsWorld.contactDelegate = self
        
        // Cria o player
        player = Player(scene: self)
        player.node.turnPhysicsOff(offset: CGPoint(x: -33, y: 0))
        //addChild(player.node)
        player.node.physicsBody?.isDynamic = false
        
        // Pausa a fisica do jogo
        //scene?.isPaused = true
        scene?.physicsWorld.speed = 0
        
        // coloca o circulo de raio
        let circle = SKShapeNode(circleOfRadius: maxJumpDistance ) // Size of Circle
        //player.node.addChild(circle)
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
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "fundo"), size: CGSize(width: 750, height: 1334))
        background.zPosition = -10
        camNode.insertChild(background, at: 0)
        camNode.addChild(camera!)
        
        // titulo
        titleGame = (scene?.childNode(withName: "title") as! SKSpriteNode)
        titleGame.zPosition = 22
        
        // pontos
        pointsNode = (scene?.childNode(withName: "pontos") as! SKSpriteNode)
        pointsNode.zPosition = 22
        pointsNode.move(toParent: camNode)
        
        
        // Pega os prefabs de fase
        for i in 1...4 {
            let tile = self.childNode(withName: "fase\(i)") as! Tile
            presetTiles.append(tile)
            for _ in 1...tile.getProbability() {
                tilesProbabilityList.append(i-1)
            }
        }
        
        // Ordena as próximas fases
        for i in 0...2 {
            if i == 0 {
                let tile = presetTiles[0].copy() as! Tile
                inGameTiles.append(tile)
                insertChild(tile, at: 0)
            }
            else {
                let tile = presetTiles[drawNextTileNumber()].copy() as! Tile
                inGameTiles.append(tile)
                insertChild(tile, at: 0)
                
            }
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
        lava.node.zPosition = 1
        lava.node.turnPhysicsOff()
        lava.node.physicsBody?.isResting = true
        lava.node.physicsBody!.categoryBitMask = 1
        lava.node.physicsBody!.contactTestBitMask = player.node.physicsBody!.categoryBitMask
        lava.node.physicsBody!.collisionBitMask = 0
        
        
        // frase de start
        boxTapToStart = SKShapeNode()
        boxTapToStart.zPosition = 21
        let corners : UIRectCorner = .allCorners
        boxTapToStart.path = UIBezierPath(roundedRect: CGRect(x: -200, y: -40, width: 400, height: 100), byRoundingCorners: corners, cornerRadii: CGSize(width: 50, height: 50)).cgPath
        boxTapToStart.position = CGPoint(x: 0, y: -100)
        boxTapToStart.fillColor = UIColor.init(named: "escuro")!
        boxTapToStart.strokeColor = UIColor.init(named: "vermelho")!
        boxTapToStart.lineWidth = 16
        addChild(boxTapToStart)
        
        let tapToStartLabel = SKLabelNode(text: "Tap a foothold to start")
        tapToStartLabel.fontName = "Existence-Light"
        tapToStartLabel.fontSize = 34
        tapToStartLabel.fontColor = .yellow
        tapToStartLabel.position = CGPoint(x: 0, y: 0)
        boxTapToStart.addChild(tapToStartLabel)
        boxTapToStart.run(SKAction.repeatForever( SKAction.init(named: "Pulse")!))
    }
    var boxTapToStart : SKShapeNode!
    
    func setupEnemy(enemy: SKSpriteNode) {
        // turn off physics and add collision
        enemy.turnPhysicsOff()
        enemy.physicsBody?.categoryBitMask = 4
        enemy.physicsBody?.collisionBitMask = 0//player.node.physicsBody!.categoryBitMask
        enemy.physicsBody!.contactTestBitMask = player.node.physicsBody!.categoryBitMask
        enemy.physicsBody?.restitution = 0.6
    }
    
    
    
    
    // ******************************************
    // MARK: - UPDATE
    var startTime = TimeInterval(0)
    var started = false
    override func update(_ currentTime: TimeInterval) {
        
        if firstUpdate {
            firstUpdate = false
            initialTime = currentTime
        }
        
        if currentTime > initalTapDelay {
            print("ja é maior")
            canDoInitialTap = true
        }
        
        if (scene?.physicsWorld.speed)! > CGFloat(0) && !started {
            started = true
            startTime = currentTime
        }
        
        // Atualizações periódicas
        if abs(currentTime.distance(to: lastGameUpdate)) > gameUpdateInterval {
            lastGameUpdate = currentTime
            
            // Move a câmera
            //moveCamera(currentTime: currentTime)
            
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
        
        if tapp {
            tapp = false
            lastCameraUpdate = currentTime
        }
        
        if lastCameraUpdate != 0 && abs(currentTime.distance(to: lastCameraUpdate)) > camUpdateInterval {
            
            print("moveu")
            //moveCamera(currentTime: currentTime)

            lastCameraUpdate = 0
            
        }
        moveCamera(currentTime: currentTime)

        
        // Sobe a lava
        if (scene?.physicsWorld.speed)! > CGFloat(0) {
            pontos = Int(currentTime - startTime)
            print("pontos = \(pontos)")
            (pointsNode.children[0] as! SKLabelNode).text = String(pontos)
            
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
            
            lava.node.position.y += lavaAdvance * scene!.speed
            removeBottomTileIfBelowLava()
        }
    }
    

    
    // ******************************************
    // MARK: - TILE CONTROL
    
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
            //print("lava speed: ", lavaSpeed)
            lavaSpeed += lavaAcceleration
        }
        
        // Atualiza a contagem de novos tiles
        newTilesCount += 1
        updateGameDifficulty()
    }
    
    
    func drawNextTileNumber() -> Int {
        var randomTileNumber : Int
        var randomIndex : Int
        repeat {
            randomIndex = Int.random(in: tilesProbabilityList.indices)
            randomTileNumber = tilesProbabilityList[randomIndex]
        } while (randomTileNumber == lastTileAdded) || (randomTileNumber > mostDifficultTileNumber)
        lastTileAdded = randomTileNumber
        
        return randomTileNumber
    }
    
    
    func updateGameDifficulty() {
        if  (newTilesCount == 1)  ||
            (newTilesCount == 4)  ||
            (newTilesCount == 7)  ||
            (newTilesCount == 12) {
            mostDifficultTileNumber += 3
        }
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
    
    var progress: Double = 0
    var timer : Timer!
    
     @objc func updateProgress() {
        guard progress <= 1 else {
            timer.invalidate()
            return
        }
        progress += 0.01
        
        scene!.speed = CGFloat(1 - progress * 0.9)
        self.physicsWorld.speed = CGFloat(1 - progress * 0.9)
    }

}

// ******************************************
// MARK: - COLLISION

extension GameScene {
    
    // Trata o início de uma colisão
    func didBegin(_ contact: SKPhysicsContact) {
        //print("A: \(contact.bodyA), B: \(contact.bodyB)")
        if !reseting {
            reseting = true
            player.node.turnPhysicsOn()
            player.changeStatus(to: .falling)
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
            timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                self.resetGame()
            })
        }
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
        //lastCameraUpdate = currentTime
    }
}


// ******************************************
// MARK: - GESTURES RECOGNIZERS

extension GameScene {
    
    @objc func tapRecognizer(tap: UITapGestureRecognizer) {
        if scene!.physicsWorld.speed > 0 {
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
                player.node.xScale = 1
                player.leftFoot.xScale = 1
                player.rightFoot.xScale = 1
                
                //player.node.turnPhysicsOff(offset: CGPoint(x: -33, y: 0))
                
                player.rightKnee.shouldEnableLimits = true
                player.rightKnee.lowerAngleLimit = CGFloat(-60).toRadians
                player.rightKnee.upperAngleLimit = CGFloat(0).toRadians
                player.leftKnee.shouldEnableLimits = true
                player.leftKnee.lowerAngleLimit = CGFloat(-60).toRadians
                player.leftKnee.upperAngleLimit = CGFloat(0).toRadians
                
                player.rightLeg.physicsBody!.applyForce(.init(dx: 500, dy: 0))
                player.rightFoot.physicsBody!.applyForce(.init(dx: 500, dy: 0))
            }
            else {
                player.node.xScale = -1
                player.leftFoot.xScale = -1
                player.rightFoot.xScale = -1
                
                //player.node.turnPhysicsOff(offset: CGPoint(x: 33, y: 0))
                
                player.rightKnee.shouldEnableLimits = true
                player.rightKnee.lowerAngleLimit = CGFloat(0).toRadians
                player.rightKnee.upperAngleLimit = CGFloat(60).toRadians
                player.leftKnee.shouldEnableLimits = true
                player.leftKnee.lowerAngleLimit = CGFloat(0).toRadians
                player.leftKnee.upperAngleLimit = CGFloat(60).toRadians
                
                player.rightLeg.physicsBody!.applyForce(.init(dx: -500, dy: 0))
                player.rightFoot.physicsBody!.applyForce(.init(dx: -500, dy: 0))
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
                        self.player.changeStatus(to: .falling)
                        self.player.node.turnPhysicsOn()
                        
                        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                            self.resetGame()
                        })
                    })
                }
            }
            
        }
        else {
            if canDoInitialTap {
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



// ******************************************
// MARK: PLAYER MOVEMENTS

extension GameScene {
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
}


// ******************************************
// MARK: PERNAS
extension GameScene {
    
    func addLegsAndFoots() {
        addChild(player.leftLeg)
        player.leftLeg.position = player.node.position + CGPoint(x: -10, y: -player.node.size.height / 2)
        player.leftLeg.physicsBody = SKPhysicsBody(rectangleOf: player.leftLeg.size)
        player.leftLeg.physicsBody?.isDynamic = true
        player.leftLeg.physicsBody?.affectedByGravity = true
        
        addChild(player.leftFoot)
        player.leftFoot.position = player.leftLeg.position + CGPoint(x: 0, y: -player.leftLeg.size.height)
        player.leftFoot.physicsBody = SKPhysicsBody(rectangleOf: player.leftFoot.size)
        player.leftFoot.physicsBody?.isDynamic = true
        player.leftFoot.physicsBody?.affectedByGravity = true
        
        
        
        addChild(player.rightLeg)
        player.rightLeg.position = player.node.position + CGPoint(x: 10, y: -player.node.size.height / 2)
        player.rightLeg.physicsBody = SKPhysicsBody(rectangleOf: player.rightLeg.size)
        player.rightLeg.physicsBody?.isDynamic = true
        player.rightLeg.physicsBody?.affectedByGravity = true
        
        addChild(player.rightFoot)
        player.rightFoot.position = player.rightLeg.position + CGPoint(x: 0, y: -player.rightLeg.size.height)
        player.rightFoot.physicsBody = SKPhysicsBody(rectangleOf: player.rightFoot.size)
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
        
        
        let leftLegJoint = SKPhysicsJointPin.joint(withBodyA: player.node.physicsBody!,
                                                bodyB: player.leftLeg.physicsBody!,
                                                anchor: player.node.position + CGPoint(x: -10, y: -player.node.size.height / 2))
        scene!.physicsWorld.add(leftLegJoint)
        
        let rightLegJoint = SKPhysicsJointPin.joint(withBodyA: player.node.physicsBody!,
                                                bodyB: player.rightLeg.physicsBody!,
                                                anchor: player.node.position + CGPoint(x: 10, y: -player.node.size.height / 2))
        scene!.physicsWorld.add(rightLegJoint)
        
        
        
        player.leftKnee = SKPhysicsJointPin.joint(withBodyA: player.leftLeg.physicsBody!,
                                                    bodyB: player.leftFoot.physicsBody!,
                                                    anchor: player.leftLeg.position + CGPoint(x: 0, y: -player.leftLeg.size.height))
        player.leftKnee.shouldEnableLimits = true
        player.leftKnee.lowerAngleLimit = CGFloat(-60).toRadians
        player.leftKnee.upperAngleLimit = CGFloat(0).toRadians
        scene!.physicsWorld.add(player.leftKnee)
        
        player.rightKnee = SKPhysicsJointPin.joint(withBodyA: player.rightLeg.physicsBody!,
                                                    bodyB: player.rightFoot.physicsBody!,
                                                    anchor: player.rightLeg.position + CGPoint(x: 0, y: -player.rightLeg.size.height))
        player.rightKnee.shouldEnableLimits = true
        player.rightKnee.lowerAngleLimit = CGFloat(-60).toRadians
        player.rightKnee.upperAngleLimit = CGFloat(0).toRadians
        scene!.physicsWorld.add(player.rightKnee)
    }
    
    
}

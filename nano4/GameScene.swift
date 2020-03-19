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
    var initalTapDelay = 1
    var firstUpdate = true
    var canDoInitialTap = false
    var tapp = false
    var showingAd = false
    
    
    var canCollide = true
    var timeInvencible : Double = 3.0
    var invencibleTime = 3.0
    var deltaTime  = 0.0
    
    var tapIndicator : SKSpriteNode!
    
    // Morte
    var progress: Double = 0
    var timer : Timer!
    let resetTimeDelay = 2.5
    
    // Reviver
    var reviveMenu : SKSpriteNode!
    var buttonRevive : Button!
    var pointsLabel : SKLabelNode!
    var highscoreLabel : SKLabelNode!
    var restartButton : Button!
    

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
    var playerCollider : SKSpriteNode!
    
    // Camera
    var cam : SKCameraNode = SKCameraNode()
    /// The node where the camera's inside. Used for the camera's move animation.
    var camNode : SKNode = SKNode()
    var lastCameraUpdate : TimeInterval = TimeInterval(0)
    var camUpdateInterval : TimeInterval = 0.2
    var camMoveVelocity : TimeInterval = 0.1
    
    // Lava
    var lava : Lava!
    var lavaSpeed : CGFloat = 2
    let maxLavaSpeed : CGFloat = 6
    let lavaAcceleration : CGFloat = 0.001
    
    // Próximos pontos de apoio
    var nearFootholds : [Foothold] = []
    var actualFoothold : Foothold?

    var titleMonster : SKLabelNode!
    var titleClimb : SKLabelNode!
    
    var leaderboard : Button!
    
    
    // ******************************************
    // MARK: - START
    
    @objc func mustReset() {
        print("INIT MUSTED")
        showingAd = false
        if !reseting {
            resetGame()
        }
    }
    
    @objc func endAd() {
        showingAd = false
        print("END AD")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        print("INIT 1")
        
        NotificationCenter.default.addObserver(self, selector: #selector(mustReset), name: .mustReset, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(revive), name: .adEndNice, object: nil)
        
        // Colisões
        physicsWorld.contactDelegate = self
        
        // Cria o player
        player = Player(scene: self)
        player.node.turnPhysicsOff(offset: CGPoint(x: -33, y: 0))
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
        playerCollider = (player.node.childNode(withName: "playerCollider") as! SKSpriteNode)
        playerCollider.turnPhysicsOff()
        
        player.node.physicsBody!.categoryBitMask = 0
        player.node.physicsBody!.contactTestBitMask = 0
        player.node.physicsBody?.collisionBitMask = 0
        
        playerCollider.physicsBody!.categoryBitMask = 2
        playerCollider.physicsBody!.contactTestBitMask = 2
        playerCollider.physicsBody?.collisionBitMask = 5
        playerCollider.physicsBody?.usesPreciseCollisionDetection = true
        
//        let joint = SKPhysicsJointFixed.joint(
//            withBodyA: player.node.physicsBody!,
//            bodyB: playerCollider.physicsBody!,
//            anchor: player.node.position)
//        scene!.physicsWorld.add(joint)
//        
        // Inicia a camera
        addChild(camNode)
        camera = cam
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "background"), size: CGSize(width: 750, height: 1334))
        background.zPosition = -10
        camNode.insertChild(background, at: 0)
        camNode.addChild(camera!)
        
        tapIndicator = (childNode(withName: "tap") as! SKSpriteNode)
        tapIndicator.alpha = 0
        tapIndicator.zRotation = 50
        
        // titulo
        titleMonster = (scene?.childNode(withName: "monster") as! SKLabelNode)
        titleClimb = (scene?.childNode(withName: "climb") as! SKLabelNode)
        
        titleMonster.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.moveTo(x: 110, duration: 1)
        ]))
        titleClimb.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.moveTo(x: 10, duration: 1)
        ]))
        
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
            nearFootholds.append(contentsOf: tile.footholds1)
            //(contentsOf: tile.footholds.map({ (f) -> CGPoint in
            //                let point =  tile.convert(f.position, to: scene!)
            //                return point
            //            }))
            
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
        lava.node.physicsBody!.contactTestBitMask = playerCollider.physicsBody!.categoryBitMask
        lava.node.physicsBody!.collisionBitMask = 0
        
        
        // Revive Menu
        reviveMenu = (childNode(withName: "reviveMenu") as! SKSpriteNode)
        reviveMenu.alpha = 0
        reviveMenu.zPosition = 100
        reviveMenu.isUserInteractionEnabled = false
        
        buttonRevive = (reviveMenu.childNode(withName: "continueButton") as! Button)
        buttonRevive.buttonDelegate = self
        buttonRevive.isUserInteractionEnabled = true
        
        restartButton = (reviveMenu.childNode(withName: "restartButton") as! Button)
        restartButton.alpha = 0
        restartButton.buttonDelegate = self
        restartButton.isUserInteractionEnabled = true
        
        pointsLabel = ((reviveMenu.childNode(withName: "pontos") as! SKSpriteNode).childNode(withName: "label") as! SKLabelNode)
        
        highscoreLabel = (reviveMenu.childNode(withName: "highscore") as! SKLabelNode)
        
        
        leaderboard = (childNode(withName: "leaderboard") as! Button)
        leaderboard.buttonDelegate = self
        leaderboard.isUserInteractionEnabled = true
        
        leaderboard.move(toParent: camNode)
        
        
        // frase de start
        boxTapToStart = SKShapeNode()
        boxTapToStart.zPosition = 21
        boxTapToStart.path = UIBezierPath().cgPath
        boxTapToStart.position = CGPoint(x: 0, y: -100)
        boxTapToStart.fillColor = UIColor.init(named: "escuro")!
        boxTapToStart.strokeColor = UIColor.init(named: "vermelho")!
        boxTapToStart.lineWidth = 16
        addChild(boxTapToStart)
        
        let tapToStartLabel = SKLabelNode(text: "Tap to start")
        tapToStartLabel.fontName = "Montserrat-Regular"
        tapToStartLabel.fontSize = 40
        //        tapToStartLabel.fontColor = .yellow
        tapToStartLabel.position = CGPoint(x: 0, y: 0)
        boxTapToStart.addChild(tapToStartLabel)
        boxTapToStart.alpha = 0
        boxTapToStart.run(SKAction.repeatForever( SKAction.init(named: "Pulse")!))
        
        
        // deixa os nodes invisiveis
        for foothold in nearFootholds.sorted(by: { (u, p) -> Bool in
            u.position.y < p.position.y
        }).dropFirst(3) {
            foothold.node.alpha = 0
        }
    }
    
    override func didMove(to view: SKView) {
        
        print("INIT 2")

        // adiciona o tap controller
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognizer(tap:)))
        view.addGestureRecognizer(tap)
    }
    var boxTapToStart : SKShapeNode!
    
    func setupEnemy(enemy: SKSpriteNode) {
        // turn off physics and add collision
//        enemy.turnPhysicsOff()
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width/2, center: CGPoint(x: 0, y: 40))
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.isDynamic = true
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.categoryBitMask = 4
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody!.contactTestBitMask = playerCollider.physicsBody!.categoryBitMask
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
            deltaTime = currentTime
        }
        
        if !canDoInitialTap {
            if Int(currentTime - initialTime) > initalTapDelay {
                print("currentTime: \(currentTime), deixou")
                canDoInitialTap = true
                self.boxTapToStart.run(SKAction.fadeIn(withDuration: 0.2))
            }
        }
        
        if !canCollide && invencibleTime > 0 {
            invencibleTime -= (currentTime - deltaTime)
            if invencibleTime <= 0  {
                canCollide  = true
                invencibleTime  = 3
                initialTime = currentTime
            }
        }
        
        deltaTime = currentTime
        
        if (scene?.physicsWorld.speed)! > CGFloat(0) && !started {
            started = true
            startTime = currentTime
        }
        
        // Atualizações periódicas
        if abs(currentTime.distance(to: lastGameUpdate)) > gameUpdateInterval {
            lastGameUpdate = currentTime
            
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
        
        moveCamera(currentTime: currentTime)

        
        // Sobe a lava
        if (scene?.physicsWorld.speed)! > CGFloat(0) && canCollide && !reseting {
            //pontos = Int(currentTime - startTime)
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
            
            lava.node.position.y += lavaAdvance * lava.node.speed
            removeBottomTileIfBelowLava()
        }
    }

}




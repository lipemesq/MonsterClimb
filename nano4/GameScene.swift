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
    
    // Morte
    var progress: Double = 0
    var timer : Timer!
    let resetTimeDelay = 2.5
    
    // Reviver
    var reviveMenu : SKSpriteNode!
    var buttonRevive : Button!
    var pointsBox : SKShapeNode!
    var pointsLabel : SKLabelNode!

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
    let lavaAcceleration : CGFloat = 0.001
    
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
        
        
        // Revive Menu
        reviveMenu = (childNode(withName: "reviveMenu") as! SKSpriteNode)
        reviveMenu.alpha = 0
        reviveMenu.zPosition = 100
        reviveMenu.isUserInteractionEnabled = false
        
        buttonRevive = (reviveMenu.childNode(withName: "buttonRevive") as! Button)
        buttonRevive.alpha = 0
        buttonRevive.buttonDelegate = self
        buttonRevive.isUserInteractionEnabled = true
        
        pointsBox = (reviveMenu.childNode(withName: "caixaPontos") as! SKShapeNode)
        pointsBox.path = UIBezierPath(roundedRect: CGRect(x: -440/2, y: -300/2, width: 440, height: 300), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 60, height: 60)).cgPath
        pointsBox.lineWidth = 6
        
        pointsLabel = (pointsBox.childNode(withName: "points") as! SKLabelNode)

        
        
        // frase de start
        boxTapToStart = SKShapeNode()
        boxTapToStart.zPosition = 21
        boxTapToStart.path = UIBezierPath(roundedRect: CGRect(x: -200, y: -40, width: 400, height: 100), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 40, height: 40)).cgPath
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
            canDoInitialTap = true
        }
        
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
        if (scene?.physicsWorld.speed)! > CGFloat(0) {
            pontos = Int(currentTime - startTime)
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




//
//  TileController.swift
//  nano4
//
//  Created by Felipe Mesquita on 15/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

extension GameScene {
    
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
    
}

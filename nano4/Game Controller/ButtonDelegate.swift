//
//  ButtonDelegate.swift
//  nano4
//
//  Created by Felipe Mesquita on 16/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

extension GameScene: ButtonDelegate {
    
    func buttonClicked(button: Button) {
        print("botao tapped")
        if (button.userData!["function"] as! String) == "revive" {
            resetGame()
        }
        else if (button.userData!["function"] as! String) == "reset" {
            resetGame()
        }
    }
    
    
}

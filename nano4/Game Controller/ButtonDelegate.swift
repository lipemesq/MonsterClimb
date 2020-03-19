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
        if button.name == "leaderboard" {
           
           print("TOCOU VAMO ABRIR")
            GameCenterHelper.helper.showLeaderboard(presentingVC: GameCenterHelper.helper.viewController!)
            return
        }
        
        print("botao tapped")
        if (button.userData!["function"] as! String) == "revive" {
            showingAd = true
            NotificationCenter.default.post(name: .showAd, object: nil)
        }
        else if (button.userData!["function"] as! String) == "reset" {
            resetGame()
        }
    }
    
    
}

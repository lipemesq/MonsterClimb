//
//  GameViewController.swift
//  nano4
//
//  Created by Felipe Mesquita on 04/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController {
    
    // AD
    var rewardedAd: GADRewardedAd?
    var adRequestInProgress = false
    var haveLoadedAd = false
    var errorAtLoadingAd = false
    var adOk = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAd), name: .showAd, object: nil)
        
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["c1a283c128c9a9bd6087540e4015b2bd"]
        createAndLoadRewardedAd()
        //rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313")
        
        GameCenterHelper.helper.viewController = self
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
               // let animation = SKTransition.fade(with: .black, duration: 2.0)
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = false
            
            view.showsPhysics = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    // showLeaderboard
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //GameCenterHelper.helper.showLeaderboard(presentingVC: GameCenterHelper.helper.viewController!)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

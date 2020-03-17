//
//  GameCenterHelper.swift
//  OgreJump
//
//  Created by M Cavasin on 12/03/20.
//  Copyright © 2020 M Cavasin. All rights reserved.
//

/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import GameKit

final class GameCenterHelper: NSObject, GKGameCenterControllerDelegate {
    
    
  typealias CompletionBlock = (Error?) -> Void
    // 1
    static let helper = GameCenterHelper()

    // 2
    var viewController: UIViewController?
    
    private var localPlayer = GKLocalPlayer.local
    private var leaderboardID = "grp.highscoreRun"
    private var scores: [(playerName: String, score: Int)]?
    private var leaderboard: GKLeaderboard?
    
    
    override init() {
      super.init()
        
      GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
        if GKLocalPlayer.local.isAuthenticated {
          print("Authenticated to Game Center!")
        } else if let vc = gcAuthVC {
          self.viewController?.present(vc, animated: true)
        }
        else {
          print("Error authentication to GameCenter: " +
            "\(error?.localizedDescription ?? "none")")
        }
      }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    
    
    func updateScore(with value: Int) {
        let score = GKScore(leaderboardIdentifier: leaderboardID)
        score.value = Int64(value)
        GKScore.report([score], withCompletionHandler: {(error) in
            if let error = error {
                print("Error while trying to update score \(error)")
            }
        })
    }
    
    func showLeaderboard(presentingVC: UIViewController) {
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .leaderboards
        gameCenterViewController.leaderboardIdentifier = leaderboardID
        presentingVC.present(gameCenterViewController, animated: true, completion: nil)
    }
    
}


extension Notification.Name {
  static let presentGame = Notification.Name(rawValue: "presentGame")
  static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
}

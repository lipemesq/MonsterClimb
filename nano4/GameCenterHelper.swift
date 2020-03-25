// by valengo: https://github.com/valengo/iOS-GameCenter/blob/master/GameCenter.swift

import GameKit

final class GameCenterHelper: NSObject, GKGameCenterControllerDelegate {
    
    static let shared = GameCenterHelper()
    
    private(set) var isGameCenterEnabled = false
    
    private let localPlayer = GKLocalPlayer.local
    
    private let leaderboardID = "com.highscore.cm"
    
    private var defaultLeaderboardId = "com.highscore.cm"
    
    var viewController : UIViewController!
    
    private override init() {
        
    }
    
    func authenticateLocalPlayer(presentingVC: UIViewController) {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // Show login if player is not logged in
                presentingVC.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.isGameCenterEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer: String?, error: Error?) -> Void in
                    if error != nil {
                        print(error!)
                    } else {
                        self.defaultLeaderboardId = leaderboardIdentifer!
                        print("LLL default ID = ", self.defaultLeaderboardId)
                    }
                    })
            } else {
                // 3 Game center is not enabled on the users device
                self.isGameCenterEnabled = false
                print("Local player could not be authenticated, disabling game center")
                print(error ?? "else?")
            }
            
        }
        
//        localPlayer.authenticateHandler = { [weak self] (gameCenterViewController, error) -> Void in
//            if let error = error {
//                print(error)
//            } else if let gameCenterViewController = gameCenterViewController {
//                presentingVC.present(gameCenterViewController, animated: true, completion: nil)
//            } else if (self?.localPlayer.isAuthenticated ?? false) {
//                self?.isGameCenterEnabled = true
//            } else {
//                self?.isGameCenterEnabled = false
//                print("Local player cannot be authenticated!")
//            }
//        }
    }
    
    func updateScore(with value: Int) {
        print("YY mandando")

//        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
//        sScore.value = Int64(value)
//
//        print("YY vou reportar")
//
//        GKScore.report([sScore], withCompletionHandler: { (error: NSError?) -> Void in
//            if error != nil {
//                print("YY erro = ", error!.localizedDescription)
//            } else {
//                print("YY Score submitted")
//            }
//            } as? (Error?) -> Void)
//
//        print("YY reportei")

        
        if GKLocalPlayer.local.isAuthenticated {

            let scoreReporter = GKScore(leaderboardIdentifier: leaderboardID)
            scoreReporter.value = Int64(value)
            let scoreArray : [GKScore] = [scoreReporter]

            GKScore.report(scoreArray) { (error) in
                print("YY o erro = \(error)")
            }

             print("YY reportei")
        }
        
        
        
//        let score = GKScore(leaderboardIdentifier: leaderboardID)
//        score.value = Int64(value)
//        GKScore.report([score], withCompletionHandler: {(error) in
//            if let error = error {
//                print("Error while trying to update score \(error)")
//            }
//        })
    }
    
    func showLeaderboard(presentingVC: UIViewController) {
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        
        
        gcViewController.leaderboardIdentifier = leaderboardID
        
        presentingVC.present(gcViewController, animated: true, completion: nil)
         

//        let gameCenterViewController = GKGameCenterViewController()
//        gameCenterViewController.
//        gameCenterViewController.gameCenterDelegate = self
//        gameCenterViewController.viewState = .leaderboards
//        gameCenterViewController.leaderboardIdentifier = leaderboardID
//        presentingVC.present(gameCenterViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}


extension Notification.Name {
  static let presentGame = Notification.Name(rawValue: "presentGame")
  static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
    
    static let mustReset = Notification.Name(rawValue: "mustResetGame")
    
    static let adEndNice = Notification.Name(rawValue: "adEndedOk")
    
    static let showAd = Notification.Name(rawValue: "showAd")
}

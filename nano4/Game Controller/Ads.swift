//
//  Ads.swift
//  nano4
//
//  Created by Felipe Mesquita on 18/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension GameViewController: GADRewardedAdDelegate {
    
    func loadAd() {
        adRequestInProgress = true
        rewardedAd?.load(GADRequest()) { error in
            self.adRequestInProgress = false
            if let error = error {
                self.errorAtLoadingAd = true
                print("Loading failed: \(error)")
            } else {
                self.haveLoadedAd = true
                self.game.adLoaded()
            }
        }
    }
    
    @objc func showAd() {
        if rewardedAd?.isReady == true {
            rewardedAd?.present(fromRootViewController: self, delegate:self)
        }
    }
    
    /// Tells the delegate that the user earned a reward.
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        adOk = true
    }
    /// Tells the delegate that the rewarded ad was presented.
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        print("Rewarded ad presented.")
    }

    /// Tells the delegate that the rewarded ad failed to present.
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        print("Rewarded ad failed to present.")
        NotificationCenter.default.post(name: .mustReset, object: nil)
    }
    
    func createAndLoadRewardedAd() {
        rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-9518899348446984/6807270448")
        loadAd()
    }
    //"ca-app-pub-9518899348446984/6807270448"

    
    /// Tells the delegate that the rewarded ad was dismissed.
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        self.game.noAds()
        haveLoadedAd = false
        createAndLoadRewardedAd()
        if adOk {
            haveLoadedAd = true
            self.game.adLoaded()
            NotificationCenter.default.post(name: .adEndNice, object: nil)
            adOk = false
        }
    }
}

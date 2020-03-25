//
//  Updatable.swift
//  nano4
//
//  Created by Felipe Mesquita on 25/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import Foundation

protocol DeltaTimed {
    func update(deltaTime: TimeInterval)
}

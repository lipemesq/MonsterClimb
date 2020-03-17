//
//  degreesRadians.swift
//  nano4
//
//  Created by Felipe Mesquita on 10/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import UIKit

extension CGFloat {
    var toRadians : CGFloat {
        return (self * CGFloat(Double.pi) / 180)
    }
}

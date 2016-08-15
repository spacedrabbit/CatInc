//
//  Constants.swift
//  CatInc
//
//  Created by Louis Tur on 8/15/16.
//  Copyright © 2016 catthoughts. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

let StandardSizeCGFloat: CGFloat = 32.0
let StandardSizeFloat: Float = Float(StandardSizeCGFloat)

let StandardSpawnerSize: CGFloat = 64.0

extension CGPoint {
  init(int2: int2) {
    x = CGFloat(int2.x)
    y = CGFloat(int2.y)
  }
}

//
//  SpriteComponent.swift
//  CatInc
//
//  Created by Louis Tur on 8/15/16.
//  Copyright © 2016 catthoughts. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class SpriteComponent: GKComponent {
  let node: SKSpriteNode
  
  init(texture: SKTexture, color: SKColor = SKColor.white(), size: CGFloat = StandardSizeCGFloat) {
    node = SKSpriteNode(texture: texture, color: color, size: CGSize(width: size, height: size))
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

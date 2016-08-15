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

class BounceAnimationComponent: GKComponent {
  let originalPosition: CGPoint
  
  internal init(originalPosition: CGPoint) {
    self.originalPosition = originalPosition
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  internal func animateBounce(node: SKNode) {
    let bounceUpAction: SKAction = SKAction.moveBy(x: 0.0, y: 10.0, duration: 0.1)
    let boundDownAction: SKAction = SKAction.move(to: self.originalPosition, duration: 0.1)
    bounceUpAction.timingMode = SKActionTimingMode.easeOut
    boundDownAction.timingMode = SKActionTimingMode.easeIn
    let bounceSequence: SKAction = SKAction.sequence([bounceUpAction, boundDownAction])
    
    // little bounce animation
    node.run(bounceSequence)
  }
  
}

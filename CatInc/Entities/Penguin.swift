//
//  Penguin.swift
//  CatInc
//
//  Created by Louis Tur on 8/15/16.
//  Copyright © 2016 catthoughts. All rights reserved.
//

import SpriteKit
import GameplayKit

internal class Penguin: GKEntity {
  internal let penguinTexture: SKTexture  = SKTexture(imageNamed: "penguin")
  
  internal convenience init(position: CGPoint) {
    self.init()
    self.move(to: position)
  }
  
  internal override init() {
    super.init()
    self.addComponent(SpriteComponent(texture: self.penguinTexture))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  internal func spriteNode() -> SKSpriteNode {
    return self.componentForClass(SpriteComponent.self)!.node
  }
  
  internal func move(to point: CGPoint) {
    let sprite = self.spriteNode()
    print("position: \(point)")
    sprite.position = point
  }
  
}

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

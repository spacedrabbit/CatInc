//
//  Penguin.swift
//  CatInc
//
//  Created by Louis Tur on 8/15/16.
//  Copyright © 2016 catthoughts. All rights reserved.
//

import SpriteKit
import GameplayKit


internal protocol Spawnable {
  var texture: SKTexture { get }
  func spriteNode() -> SKSpriteNode
  func move(to point: CGPoint)
}

extension Spawnable {
  func move(to point: CGPoint) {
    print("position: \(point)")
    let sprite = self.spriteNode()
    sprite.position = point
  }
}

internal class Penguin: GKEntity, Spawnable {
  internal var texture: SKTexture = SKTexture(imageNamed: "penguin")
  
  internal convenience init(position: CGPoint) {
    self.init()
    self.move(to: position)
  }
  
  internal override init() {
    super.init()
    self.addComponent(SpriteComponent(texture: self.texture))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  internal func spriteNode() -> SKSpriteNode {
    return self.componentForClass(SpriteComponent.self)!.node
  }

}

internal class SpawnPoint: GKEntity, Spawnable {
  internal var texture: SKTexture = SKTexture(imageNamed: "spawn")
  
  internal convenience init(position: CGPoint) {
    self.init()
    self.move(to: position)
    self.addComponent(BounceAnimationComponent(originalPosition: position))
  }
  
  internal override init() {
    super.init()
    self.addComponent(SpriteComponent(texture: self.texture, size: StandardSpawnerSize))
  }
  
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  internal func spriteNode() -> SKSpriteNode {
    return self.componentForClass(SpriteComponent.self)!.node
  }
  
  internal func bounce() {
    let bounceComponent = self.componentForClass(BounceAnimationComponent.self)
    bounceComponent?.animateBounce(node: self.spriteNode())
  }

}

internal class Castle: GKEntity, Spawnable {
  internal var texture: SKTexture = SKTexture(imageNamed: "castle")
  
  internal convenience init(position: CGPoint) {
    self.init()
    self.move(to: position)
  }
  
  internal override init() {
    super.init()
    self.addComponent(SpriteComponent(texture: self.texture, size: StandardSpawnerSize))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  internal func spriteNode() -> SKSpriteNode {
    return self.componentForClass(SpriteComponent.self)!.node
  }
  
}

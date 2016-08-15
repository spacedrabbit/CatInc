//
//  GameScene.swift
//  CatInc
//
//  Created by Louis Tur on 8/12/16.
//  Copyright © 2016 catthoughts. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  var entities = [GKEntity]()
  var graphs = [String : GKGraph]()
  
  private var lastUpdateTime : TimeInterval = 0
  private var label : SKLabelNode?
  private var spinnyNode : SKShapeNode?
  
  var castleNode: SKNode!
  var spawnNode: SKNode!

  let penguin: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "penguin"))
  var passableTerrainNode: SKTileMapNode?
  var passableTerrainIndicies: [int2] = []
  
  override func sceneDidLoad() {
    
    self.lastUpdateTime = 0
    self.createSpinnyNode()
    
    self.castleNode = self.childNode(withName: "castleNode")
    self.spawnNode = self.childNode(withName: "spawnNode")
    
    let mapper = MapManager(with: self)
    let terrainHelper = TerrainInspector(with: mapper)
    
    if let validRoadTiles = mapper.passableTerrainNode {
      self.passableTerrainNode = validRoadTiles
      
      let pathTiles = terrainHelper.getPassableTerrainIndicies()
      if pathTiles.count > 0 {
        self.passableTerrainIndicies = pathTiles
      }
    }
  }
  
  func createSpinnyNode() {
    
    // Create shape node to use during mouse interaction
    let w = (self.size.width + self.size.height) * 0.05
    self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
    
    if let spinnyNode = self.spinnyNode {
      spinnyNode.lineWidth = 2.5
      
      spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
      spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                        SKAction.fadeOut(withDuration: 0.5),
                                        SKAction.removeFromParent()]))
    }
  }
  
  
  func touchDown(atPoint pos : CGPoint) {
    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
      n.position = pos
      n.strokeColor = SKColor.green()
      self.addChild(n)
    }
  }
  
  func touchMoved(toPoint pos : CGPoint) {
    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
      n.position = pos
      n.strokeColor = SKColor.blue()
      self.addChild(n)
    }
  }
  
  func touchUp(atPoint pos : CGPoint) {
    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
      n.position = pos
      n.strokeColor = SKColor.red()
      self.addChild(n)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let label = self.label {
      label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
    }
    
    for t in touches {
      let tappedLocation = t.location(in: self)
      
      // locate the spawnNode in tapped location
      let spawn: [SKNode] = self.nodes(at: tappedLocation).filter({ (node) -> Bool in
        if node == self.spawnNode { return true }
        return false
      })
      
      // if spawn was found, it would be the first element in spawn<SKNode>
      if let foundSpawnNode: SKNode = spawn.first {
//        print("found spawn node")
        
        let currentLocation: CGPoint = foundSpawnNode.position
        let bounceUpAction: SKAction = SKAction.moveBy(x: 0.0, y: 10.0, duration: 0.1)
        let boundDownAction: SKAction = SKAction.move(to: currentLocation, duration: 0.1)
        bounceUpAction.timingMode = SKActionTimingMode.easeOut
        boundDownAction.timingMode = SKActionTimingMode.easeIn
        let bounceSequence: SKAction = SKAction.sequence([bounceUpAction, boundDownAction])
        
        // little bounce animation
        foundSpawnNode.run(bounceSequence)
        
        // create the penguin
        let penguinSpawnPosition = CGPoint(
          x: GKARC4RandomSource.sharedRandom().nextInt(withUpperBound: self.passableTerrainNode!.numberOfColumns),
          y: GKARC4RandomSource.sharedRandom().nextInt(withUpperBound: self.passableTerrainNode!.numberOfRows)
        )
        
        let spawnNodePosition = self.passableTerrainNode!.centerOfTile(atColumn: Int(penguinSpawnPosition.x), row: Int(penguinSpawnPosition.y))
        let newPenguin = Penguin(position: spawnNodePosition)
        self.addChild(newPenguin.spriteNode())
      }
      
//      for n in self.nodes(at: tappedLocation) {
//        print("Node: \(n)")
//      }
      
      self.touchDown(atPoint: t.location(in: self))
    }
  }
  
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
  }
  
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    // Initialize _lastUpdateTime if it has not already been
    if (self.lastUpdateTime == 0) {
      self.lastUpdateTime = currentTime
    }
    
    // Calculate time since last update
    let dt = currentTime - self.lastUpdateTime
    
    // Update entities
    for entity in self.entities {
      entity.update(withDeltaTime: dt)
    }
    
    self.lastUpdateTime = currentTime
  }
}

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
  
  var castle: Castle!
  var spawn: SpawnPoint!
  
  var mapper: MapManager!
  var terrainHelper: TerrainInspector!

  let penguin: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "penguin"))
  var passableTerrainNode: SKTileMapNode?
  var passableTerrainIndicies: [CGPoint] = []
  
  override func sceneDidLoad() {
    
    self.lastUpdateTime = 0
    self.createSpinnyNode()

    self.mapper = MapManager(with: self)
    self.terrainHelper = TerrainInspector(with: mapper)
    
    if let validRoadTiles = mapper.passableTerrainNode {
      self.passableTerrainNode = validRoadTiles
      
      let pathTiles = terrainHelper.getPassableTerrainIndicies()
      if pathTiles.count > 0 {
        self.passableTerrainIndicies = pathTiles
        let (castleSpawn, penguinSpawn) = terrainHelper.locatePointsOfInterest(indicies: pathTiles)
        
        let adjustedSpawnGridPosition = validRoadTiles.centerOfTile(atColumn: Int(penguinSpawn.x), row: Int(penguinSpawn.y))
        let adjustedCastleGridPosition = validRoadTiles.centerOfTile(atColumn: Int(castleSpawn.x), row: Int(castleSpawn.y))
        self.spawn = SpawnPoint(position: adjustedSpawnGridPosition)
        self.castle = Castle(position: adjustedCastleGridPosition)
        
        self.addChild(self.spawn.spriteNode())
        self.addChild(self.castle.spriteNode())
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
        if node == self.spawn.spriteNode() { return true }
        return false
      })
      
      // if spawn was found, it would be the first element in spawn<SKNode>
      if let _: SKNode = spawn.first {
        self.spawn.bounce()
        
        // create the penguin
        let spawnPosition = self.passableTerrainIndicies[
          GKARC4RandomSource.sharedRandom().nextInt(withUpperBound: self.passableTerrainIndicies.count)
        ]
        
        let spawnNodePosition = self.passableTerrainNode!.centerOfTile(atColumn: Int(spawnPosition.x), row: Int(spawnPosition.y))
        let newPenguin = Penguin(position: spawnNodePosition)
        self.addChild(newPenguin.spriteNode())
        
        // these two values get the correct index values (6, 6)
        let rowIndex = self.passableTerrainNode?.tileRowIndex(fromPosition: spawnNodePosition)
        let colIndex = self.passableTerrainNode?.tileColumnIndex(fromPosition: spawnNodePosition)
        
        
        // this iterration has no problem connecting all of the nodes
        let specificGraph: GKGridGraph<GKGridGraphNode> = GKGridGraph(nodes: self.terrainHelper.traverseableTerrain)
        if let specificGraphNodes = specificGraph.nodes {
          for nodes in specificGraphNodes {
            nodes.addConnections(to: specificGraphNodes, bidirectional: true)
          }
        }
        
        // these two node searches always fail. no matter the index values. 
        // i guess its more accurate that node(atGridPosition:) always fails when the underlying GKGridGraph is made from 
        // [GKGridGraphNode].
        let thing = specificGraph.node(atGridPosition: vector_int2(Int32(spawnPosition.x), Int32(spawnPosition.y)))
        let castleNode = specificGraph.node(atGridPosition: vector_int2(7, 9))

        // HOWEVER: the below works! 
        // specificGraph contains a list of all of its nodes, and can be accessed via its .nodes property. BUT
        // only if you force typecast the collection element to GKGridGraphNode. Otherwise, it will also fail.
        // MOREOVER: each of these GKGridGraphNode's knows their gridPosition!!!! so how is it that the GKGridGraph has
        // knowledge of its nodes, which have knowledge of their grid positions, but if you query the GKGripGraph for 
        // a node using node(atGridPosition:) it will always return nil?
        let solutionPath = specificGraph.findPath(from: specificGraph.nodes![0] as! GKGridGraphNode, to: specificGraph.nodes![20] as! GKGridGraphNode)
        
        print("Solution: \(solutionPath)")
      }
      
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

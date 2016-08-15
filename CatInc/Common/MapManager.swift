//
//  MapManager.swift
//  CatInc
//
//  Created by Louis Tur on 8/15/16.
//  Copyright © 2016 catthoughts. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

internal class MapManager {
  internal let scene: SKScene
  
  internal var groundNode: SKTileMapNode?
  internal var grassNode: SKTileMapNode?
  internal var grassObjectsNode: SKTileMapNode?
  internal var passableTerrainNode: SKTileMapNode?

  internal init(with scene: SKScene) {
    self.scene = scene
    self.locateMapNodes()
  }
  
  internal func locateMapNodes() {
    guard
      let groundTileMap = self.scene.childNode(withName: "/Dirt Node") as? SKTileMapNode,
      let grassTileMap = self.scene.childNode(withName: "/Grass Node") as? SKTileMapNode,
      let grassObjectsTileMap = self.scene.childNode(withName: "/Grass Node/Grass Objects") as? SKTileMapNode,
      let passableTerrainTileMap = self.scene.childNode(withName: "/Grass Node/Road") as? SKTileMapNode
    else {
      assertionFailure("Could not locate the proper terrain node resources!!!")
      return
    }
    
    self.groundNode = groundTileMap
    self.grassNode = grassTileMap
    self.grassObjectsNode = grassObjectsTileMap
    self.passableTerrainNode = passableTerrainTileMap
    print("All terrain nodes located")
  }
}

internal class TerrainInspector {
  let mapper: MapManager!
  
  required init(with mapper: MapManager) {
    self.mapper = mapper
  }
  
  internal func getFullGridGraph() -> GKGridGraph<GKGridGraphNode>? {
    if let validTileNode: SKTileMapNode = self.mapper.passableTerrainNode {
      let cols = validTileNode.numberOfColumns
      let rows = validTileNode.numberOfRows
      
      return GKGridGraph(fromGridStartingAt: int2(0,0), width: Int32(cols), height: Int32(rows), diagonalsAllowed: false)
    }
    return nil
  }
  
  internal func getPassableTerrainIndicies() -> [int2] {
    var validIndicies: [int2] = []
    if let validTileNode: SKTileMapNode = self.mapper.passableTerrainNode {
      let cols = Int32(validTileNode.numberOfColumns)
      let rows = Int32(validTileNode.numberOfRows)
      
      for c in 0..<cols {
        for r in 0..<rows {
          if let _ = validTileNode.tileGroup(atColumn: Int(c), row: Int(r)) {
            validIndicies.append(int2(c, r))
          }
        }
      }
    }
    return validIndicies
  }
}

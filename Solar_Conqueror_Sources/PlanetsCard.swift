//
//  PlanetCard.swift
//  Solar_Conqueror_Sources
//
//  Created by Xiaolin Wang on 24/03/2019.
//  Copyright © 2019 Xiaolin Wang. All rights reserved.
//

import SpriteKit

class PlanetsCard: Card {
    lazy var screenShot: SKSpriteNode = {
        return self.childNode(withName: ".//planetsScreenShot") as! SKSpriteNode
    }()
    
    lazy var fakePlanetsScene: SKNode = {
        return self.childNode(withName: ".//fakePlanetsScene")!
    }()
}

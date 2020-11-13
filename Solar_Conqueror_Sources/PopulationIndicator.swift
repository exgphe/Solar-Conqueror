//
//  PopulationIndicator.swift
//  Solar_Conqueror_Sources
//
//  Created by Xiaolin Wang on 24/03/2019.
//  Copyright © 2019 Xiaolin Wang. All rights reserved.
//

import SpriteKit

class PopulationIndicator: SKNode {
    
    static let maxWidth = CGFloat(720)
    static let totalLimit = Limits.reduce(0) { $0 + $1.value }
    lazy var coefficient: CGFloat = {
        return PopulationIndicator.maxWidth / CGFloat(PopulationIndicator.totalLimit)
    }()
    
    lazy var populationRect: SKSpriteNode = {
        return self.childNode(withName: "PopulationRect") as! SKSpriteNode
    }()
    
    lazy var limitRect: SKSpriteNode = {
        return self.childNode(withName: "LimitRect") as! SKSpriteNode
    }()
    
    lazy var label: SKLabelNode = {
        return self.childNode(withName: "label") as! SKLabelNode
    }()
    
    var color: SKColor {
        get {
            return self.populationRect.color
        }
        set {
            self.populationRect.color = newValue
            self.limitRect.color = newValue
        }
    }
    
    var population = 0 {
        didSet {
            if population != oldValue {
                self.populationRect.run(SKAction.resize(toWidth: CGFloat(population) * coefficient, duration: 0.1))
                self.label.text = "\(population)/\(self.limit)"
            }
        }
    }
    var limit = 0 {
        didSet {
            if limit != oldValue {
                self.limitRect.run(SKAction.resize(toWidth: CGFloat(limit) * coefficient, duration: 0.1))
                self.label.text = "\(self.population)/\(limit)"
            }
            
        }
    }
    
}

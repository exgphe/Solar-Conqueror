//
//  Enemy.swift
//  Solar Conqueror
//
//  Created by exgphe on 16/03/2019.
//  Copyright © 2019 exgphe. All rights reserved.
//
import GameplayKit

class Enemy: Role {
    override init(scene: InteractableScene) {
        super.init(scene: scene)
        
        self.identity = Owner.enemy
        if scene is PlanetsScene {
            self.addComponent(Intelligence())
            self.addComponent(Statistics(indicatorName: "EnemyPopulationIndicator"))
            let producer = SpecialWeaponProducer(relatedLabelName: nil)
            self.specialWeaponProducer = producer
            self.addComponent(producer)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


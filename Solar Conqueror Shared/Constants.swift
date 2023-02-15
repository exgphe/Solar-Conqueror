//
//  Constants.swift
//  Solar Conqueror
//
//  Created by exgphe on 14/03/2019.
//  Copyright © 2019 exgphe. All rights reserved.
//
import SpriteKit
let PlanetNames = ["Earth","Moon","Venus","Mars","Uranus","Saturn","Neptune","Mercury","Jupiter","Sun","Pluto"]
public enum Owner {
    case player,enemy,gaia
    func color() -> SKColor {
        switch self {
        case .enemy:
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case .gaia:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .player:
            return #colorLiteral(red: 0.2229503051, green: 0.618262824, blue: 1, alpha: 1)
        }
    }
}

let maximumSpecialWeaponAmount = 1

let Limits = ["Earth":50,"Moon":10,"Venus":50,"Mars":50,"Uranus":50,"Saturn":90,"Neptune":40,"Mercury":30,"Jupiter":100,"Sun":250,"Pluto":20]

let spawnIntervalFor = ["Earth":1.0, "Moon":1.0, "Venus":1.0, "Mars":1.0, "Uranus":1.0, "Saturn":0.75, "Neptune":1.65, "Mercury":1.25, "Jupiter":0.75, "Sun":0.5, "Pluto":1.25]

public enum ResultType {
    case victory, defeated
}

let planetCardIndex = 6
let finalResultCardIndex = 7

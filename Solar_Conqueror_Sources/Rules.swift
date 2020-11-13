import GameplayKit

struct facts {
    static let canAttack = "canAttack" as NSObject
    static let vulnerability = "vulnerability" as NSObject
    static let shouldForceTouchHere = "shouldForceTouchHere" as NSObject
}

class Rules {
    
    //Here for Vulnerability Rule
    
    // (0, 1) (100, 0,1) (250, 0) order 2
    static let hisPowerRule = PlanetAIRule(predicate: NSPredicate(block: {
        return ($1!["target"] as! PlanetNode).currentOwner != Owner.gaia
    }), produceData: {Float(($0.state["target"] as! PlanetNode).population)}, functionMode: .quadratic, coefficients: [3.333E-5, -0.0123, 1], fact: facts.vulnerability, weight: 0.5)
    
    static let hisOwnerRule = GKRule(blockPredicate: {
        ($0.state["target"] as! PlanetNode).currentOwner != Owner.player
    }) { (system) in
        let hisOwner = (system.state["target"] as! PlanetNode).currentOwner
        switch hisOwner {
        case .gaia:
            system.assertFact(facts.vulnerability, grade: 0.5)
        case .enemy:
            system.retractFact(facts.vulnerability, grade: 0.3)
        default:
            break
        }
    }
    
    
    // (10, 0) (250, 1) logarithm
    static let hisLimitRule = PlanetAIRule(predicate: NSPredicate(block: {
        ($1!["target"] as! PlanetNode).currentOwner != Owner.enemy
    }), produceData: { Float(($0.state["target"] as! PlanetNode).limit) }, functionMode: .logarithm, coefficients: [0.3107, -0.7153], fact: facts.vulnerability, weight: 0.25)
    
    static let hisLimitIfOwnedRule = PlanetAIRule(predicate: NSPredicate(block: {
        ($1!["target"] as! PlanetNode).currentOwner == Owner.enemy
    }), produceData: { Float(($0.state["target"] as! PlanetNode).limit) }, functionMode: .logarithm, coefficients: [0.3107, -0.7153], fact: facts.vulnerability, weight: 0.1)
    
    
    // (100, 1) (600, 0) logarithm
    static let averageDistanceRule = PlanetAIRule(predicate: NSPredicate(format: "$averageDistance BETWEEN {100, 600}"), produceData: { $0.state["averageDistance"] as! Float}, functionMode: .logarithm, coefficients: [-0.5581, 3.5702], fact: facts.vulnerability, weight: 0.25)
    
    
    
    static let averageDistanceNearRule = GKRule(predicate: NSPredicate(format: "$averageDistance <= 100"), assertingFact: facts.vulnerability, grade: 0.25)
    
    static let overpopulatedRule = GKRule(blockPredicate: {
        let planet = $0.state["target"] as! PlanetNode
        return planet.currentOwner == .enemy && planet.population >= planet.limit
    }) { $0.retractFact(facts.vulnerability) }
    
    static let myPlanetIsForceTouchedRule = GKRule(blockPredicate: {
        let planet = $0.state["target"] as! PlanetNode
        return planet.currentOwner == .enemy && planet.isForceTouched
    }) { $0.retractFact(facts.vulnerability) }
    
    //Here for Attack Grade Rule
    
    // (0, 0), (100, 0,8), (250, 1) order two
    static let myPowerRule = PlanetAIRule(predicate: NSPredicate(value: true), produceData: { Float(($0.state["planet"] as! PlanetNode).population) }, functionMode: .quadratic, coefficients: [-2.667E-5, 0.0107, 0.0], fact: facts.canAttack, weight: 0.45)
    
    
    // (0,5, 0) (1, 1) linear
    static let myPowerRatioRule = PlanetAIRule(predicate: NSPredicate(block: {
        let planet = $1!["planet"] as! PlanetNode
        return planet.population * 2 > planet.limit
    }), produceData: {
        let planet = $0.state["planet"] as! PlanetNode
        return Float(planet.population) / Float(planet.limit)
    }, functionMode: .linear, coefficients: [2.0, -1.0], fact: facts.canAttack, weight: 0.3)
    
    // (100, 1) (600, 0) logarithm
    static let distanceRule = PlanetAIRule(predicate: NSPredicate(format: "$distance BETWEEN {100, 600}"), produceData: { $0.state["distance"] as! Float }, functionMode: .logarithm, coefficients: [-0.5581, 3.5702], fact: facts.canAttack, weight: 0.25)
    
    
    
    static let distanceNearRule = GKRule(predicate: NSPredicate(format: "$distance <= 100"), assertingFact: facts.canAttack, grade: 0.2)
    
    static let forceTouchedRule = GKRule(blockPredicate: {
        let planet = $0.state["planet"] as! PlanetNode
        return planet.isForceTouched
    }) { $0.retractFact(facts.canAttack) }
    
    
    // Here for Special Weapon rules
    
    //(0, 0) (100, 0,8) (250, 1) order two
    static let hisPowerForSpecialWeaponRule = PlanetAIRule(predicate: NSPredicate(value: true), produceData: { Float(($0.state["target"] as! PlanetNode).population) }, functionMode: .quadratic, coefficients: [-2.667E-5, 0.0107, 0.0], fact: facts.shouldForceTouchHere, weight: 0.5)
    
    //(10, 0) (100, 0,7) (250, 1) order two
    static let hisLimitForSpecialWeaponRule = PlanetAIRule(predicate: NSPredicate(value: true), produceData: { Float(($0.state["target"] as! PlanetNode).limit) }, functionMode: .quadratic, coefficients: [-2.407E-5, 0.0104, -0.1019], fact: facts.shouldForceTouchHere, weight: 0.4)
    
    // (0, 0) (600, 1) linear
    static let distanceForSpecialWeaponRule = PlanetAIRule(predicate: NSPredicate(value: true), produceData: { $0.state["averageDistance"] as! Float }, functionMode: .linear, coefficients: [Float(1.0/600.0), 0], fact: facts.shouldForceTouchHere, weight: 0.1)
    
    
    
}

//class EnemyTotalPopulationRule: GKRule {
//
//    override func evaluatePredicate(in system: GKRuleSystem) -> Bool {
//        return true
//    }
//
//    override func performAction(in system: GKRuleSystem) {
//        <#code#>
//    }
//}

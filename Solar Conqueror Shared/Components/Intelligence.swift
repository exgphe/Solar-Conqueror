import Foundation
import GameplayKit

class Intelligence: GKComponent {
    var timeToLastEvaluation: TimeInterval = 0.2
    let evaluationInterval: TimeInterval = 0.5
    let attackGradeThreshold: Float = 0.3
    let attackEvaluateRuleSystem = GKRuleSystem()
    let vulnerabilityEvaluateRuleSystem = GKRuleSystem()
    let specialWeaponUsageEvaluateRuleSystem = GKRuleSystem()
    var me: Enemy {
        return self.entity as! Enemy
    }
    //    let player: Player
    //    init(player: Player) {
    //        self.player = player
    //        super.init()
    //    }
    
    override init() {
        vulnerabilityEvaluateRuleSystem.add([
            Rules.hisPowerRule,
            Rules.hisLimitRule,
            Rules.averageDistanceRule,
            Rules.averageDistanceNearRule,
            Rules.hisOwnerRule,
            Rules.overpopulatedRule,
            Rules.myPlanetIsForceTouchedRule
            ])
        attackEvaluateRuleSystem.add([
            Rules.myPowerRule,
            Rules.myPowerRatioRule,
            Rules.distanceRule,
            Rules.distanceNearRule,
            Rules.forceTouchedRule
            ])
        specialWeaponUsageEvaluateRuleSystem.add([
            Rules.hisPowerForSpecialWeaponRule,
            Rules.hisLimitForSpecialWeaponRule,
            Rules.distanceForSpecialWeaponRule
            ])
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        self.timeToLastEvaluation += seconds
        if self.timeToLastEvaluation >= evaluationInterval {
            //            print("time to decide")
            self.decide()
            self.timeToLastEvaluation = 0.0
        }
    }
    
    func decide() {
        var attackGrades = [PlanetNode: Float]()
        var vulnerabilityGrades = [PlanetNode: Float]()
        var averageDistances = [PlanetNode: Float]()
        var specialWeaponGrades = [PlanetNode: Float]()
        // Check for vulnerability for all planets and select the most vulnerable planet to attack
        //        print("a")
        var shouldUseSpecialWeapon = false
        if self.me.specialWeaponsLeft >= maximumSpecialWeaponAmount {
            if arc4random_uniform(10) == 0 { // 0/10 chance to evoke
                shouldUseSpecialWeapon = true
            }
        }
        for planet in me.scene.planets {
            // averageDistance calculates average distance of the planet to the three nearest of my planets
            let sample = (planet.distanceTo.filter({ me.ownedPlanets.contains($0.key) }) as [PlanetNode: CGFloat]).sorted(by: {$0.value < $1.value}).prefix(3)
            let averageDistance = Float(sample.reduce(0, {$0 + $1.value})) / Float(sample.count)
            averageDistances[planet] = averageDistance
            
            // Evaluate vulnerability
            self.vulnerabilityEvaluateRuleSystem.state.setDictionary(["target": planet,"averageDistance": averageDistance])
            self.vulnerabilityEvaluateRuleSystem.reset()
            self.vulnerabilityEvaluateRuleSystem.evaluate()
            vulnerabilityGrades[planet] = self.vulnerabilityEvaluateRuleSystem.grade(forFact: facts.vulnerability)
            
            // Evaluate forceTouch
            if shouldUseSpecialWeapon && planet.currentOwner == .player {
                self.specialWeaponUsageEvaluateRuleSystem.state.setDictionary(["target": planet,"averageDistance": averageDistance])
                self.specialWeaponUsageEvaluateRuleSystem.reset()
                self.specialWeaponUsageEvaluateRuleSystem.evaluate()
                specialWeaponGrades[planet] = self.specialWeaponUsageEvaluateRuleSystem.grade(forFact: facts.shouldForceTouchHere)
            }
        }
        //        print("b")
        let targetPlanet = vulnerabilityGrades.max(by: { $0.value < $1.value })!.key
        // Check for attack grades for all my planets and sort them
        //        print("c")
        for thisPlanet in me.ownedPlanets {
            if !thisPlanet.isEqual(to: targetPlanet) {
                let distance = Float(thisPlanet.distanceTo[targetPlanet]!)
                self.attackEvaluateRuleSystem.state.setDictionary(["planet": thisPlanet, "distance": Float(distance)])
                self.attackEvaluateRuleSystem.reset()
                //                print("c1")
                self.attackEvaluateRuleSystem.evaluate()
                //                print("c2")
                let grade = self.attackEvaluateRuleSystem.grade(forFact: facts.canAttack)
                attackGrades[thisPlanet] = grade
            }
        }
        //        print("d")
        let attackGradesSorted = attackGrades.sorted { $0.value > $1.value}
        let maxAttackGrade = attackGradesSorted.first?.value
        //        print("e")
        //        print("vulnerable Grades\(vulnerabilityGrades)")
        //        print("target \(targetPlanet)")
        //        print("attack Grades \(attackGrades)")
        //        print("average distances \(averageDistances)")
        //        print("maxAG\(String(describing: maxAttackGrade))")
        
        // Check how many planets should I send
        if targetPlanet.currentOwner != .enemy {
            var willAttackPlanets = [PlanetNode]()
            var armyPopulation = 0
            for (startPlanet, _) in attackGradesSorted {
                willAttackPlanets.append(startPlanet)
                armyPopulation += startPlanet.population / 2
                if armyPopulation > targetPlanet.population {
                    break
                }
            }
            var chance = true
            if maxAttackGrade != nil {
                if maxAttackGrade! <= attackGradeThreshold {
                    chance = (arc4random_uniform(6) == 1)
                }
            }
            if chance && armyPopulation > targetPlanet.population {
                me.moveComponent.send(from: willAttackPlanets, to: targetPlanet)
            } else {
                if chance && arc4random_uniform(3) == 1 { //  1/3 chances to attack
                    me.moveComponent.send(from: willAttackPlanets, to: targetPlanet)
                }
            }
        } else {
            if let beginPlanet = attackGradesSorted.first?.key {
                if arc4random_uniform(3) == 1 { //  1/3 chances to move fleets
                    me.moveComponent.send(from: [beginPlanet], to: targetPlanet)
                }
            }
        }
        
        // Perform special weapon
        
        if shouldUseSpecialWeapon {
            // print(specialWeaponGrades)
            if let targetForSpecialWeapon = specialWeaponGrades.max(by: { $0.value < $1.value})?.key {
                targetForSpecialWeapon.forceTouched(location: CGPoint.zero)
                self.me.specialWeaponsLeft -= 1
            }
        }
    }
}

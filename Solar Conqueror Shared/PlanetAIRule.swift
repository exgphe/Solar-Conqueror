import GameplayKit

enum FunctionMode {
    case linear, logarithm, quadratic
}

class PlanetAIRule: GKNSPredicateRule {
    let functionMode: FunctionMode
    let coefficients: [Float]
    let weight: Float
    let fact: NSObject
    let produceData: (_ system: GKRuleSystem)->Float
    
    init(predicate: NSPredicate, produceData: @escaping (_ system: GKRuleSystem)->Float, functionMode: FunctionMode, coefficients: [Float], fact: NSObject, weight: Float) {
        self.functionMode = functionMode
        self.coefficients = coefficients
        self.weight = weight
        self.produceData = produceData
        self.fact = fact
        super.init(predicate: predicate)
    }
    
    override func performAction(in system: GKRuleSystem) {
        let variable = self.produceData(system)
        var grade: Float
        switch self.functionMode {
        case .linear:
            grade = self.coefficients[0] * variable + self.coefficients[1]
            break
        case .logarithm:
            grade = self.coefficients[0] * logf(variable) + self.coefficients[1]
            break
        case .quadratic:
            grade = self.coefficients[0] * variable * variable + self.coefficients[1] * variable + self.coefficients[2]
            break
        }
        grade = grade * self.weight
        system.assertFact(self.fact, grade: grade)
    }
}

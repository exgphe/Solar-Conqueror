//
//  Preferences.swift
//  Solar Conqueror
//
//  Created by Xiaolin Wang on 15/02/2023.
//

import Foundation

enum Difficulty: Int {
    case easy = 0, normal, hard
}

struct Preferences {
    public static var difficulty: Difficulty {
        get {
            Difficulty(rawValue: UserDefaults.standard.integer(forKey: "difficulty")) ?? .normal
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "difficulty")
        }
    }
}

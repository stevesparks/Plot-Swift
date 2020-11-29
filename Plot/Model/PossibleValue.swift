//
//  PossibleValue.swift
//  Plot
//
//  Created by Steve Sparks on 11/2/20.
//

import UIKit

extension FunctionReturnValue {
    struct PossibleValue {
        let value: T
        let chances: Int
    }
}

extension FunctionReturnValue {
    func pickOne() -> T {
        switch self {
        case .real(let x): return x
        case .multiple(let arr): return arr.randomElement()!
        case .oneOf(let possibles):
            if possibles.count == 0 { preconditionFailure("One of nothing?") }
            let allChances = possibles.reduce(0, { $0 + $1.chances })

            if allChances == 0 { return possibles.first!.value }
            
            var diceRoll = Int(arc4random() % UInt32(allChances))
            for possible in possibles {
                if diceRoll < possible.chances { return possible.value }
                diceRoll -= possible.chances
            }
            return possibles.first!.value
        }
    }
}

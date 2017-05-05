//
//  Binomial Recursion.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 5/1/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class Recursion {
    func start(actual: Int, maximum: Int) {
        let minimum = 1
        if (maximum < actual) || (maximum <= minimum) {
            print("Error")
        } else {
            let initialGuess = (maximum - minimum)/2
            print("Result is: \(converge(guess: initialGuess, actual: actual, minimum: minimum, maximum: maximum))")
        }

    }
    
    func converge(guess: Int, actual: Int, minimum: Int, maximum: Int) -> Int {
        if guess == actual {
            return guess
        } else if (minimum == maximum) && (actual == maximum) {
            return maximum
        } else if (actual < minimum) || (actual > maximum) || (maximum <= minimum) {
            // throw error
            return -1000000000000 // plug for compiling for now
        } else {
            let range = maximum - minimum
            let odd = range % 2
            let lowHalf = minimum + range/2 + odd
            let highHalf = maximum - range - odd
            if actual < lowHalf {
                let guess = minimum + ((lowHalf - minimum ) / 2)
                return converge(guess:guess, actual:actual, minimum: minimum, maximum: lowHalf)
            } else {
                let guess = maximum - ((maximum - highHalf) / 2)
                return converge(guess: guess, actual: actual, minimum: highHalf, maximum: maximum)
            }
        }
    }
}

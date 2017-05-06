//
//  BotLoader.swift
//  Humanity Against Cards
//
//  Created by Connor Rawls on 5/4/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import Foundation

class BotLoader {
    
    var botNames: [String]
    
    init() {
        
        let namePath = Bundle.main.path(forResource: "BotNames", ofType: "txt")
        
        do {
            let nameStr = try String(contentsOfFile: namePath!)
            
            
            botNames = [String]()
            
            botNames.append(contentsOf: nameStr.components(separatedBy: NSCharacterSet.newlines))
            
        } catch (let error) {
            Swift.print("Could Not Find Bot names file")
            Swift.print(error)
            
            botNames = ["Fredbot", "Janebot", "Bigbot", "Smallbot"]
        }
    }
    
    func getName() -> String {
        let index : Int = Int(arc4random_uniform(UInt32(botNames.count - 1)))
        
        return botNames[index]
    }
}

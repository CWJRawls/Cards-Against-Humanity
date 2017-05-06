//
//  Card.swift
//  You Got Games
//
//  Created by synthesis on 4/19/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import Foundation
import SpriteKit

class Card : SKSpriteNode {
 
    var cardType : DeckType
    var cardIdx : Int
    
    var cardTexture: SKTexture?
    
    init?(type: DeckType, number: Int, loader: CardLoader) {
       
        let filename = loader.getCardFileName(forType: type, cardIdx: number)
        
        cardTexture = SKTexture(imageNamed: filename)
        
        cardType = type
        cardIdx = number
        
        super.init(texture: cardTexture, color: .clear, size: (cardTexture?.size())!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  WaitingScene.swift
//  You Got Games
//
//  Created by Connor Rawls on 5/2/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import Foundation
import SpriteKit

class WaitingScene : SKScene {
    
    var background : SKSpriteNode
    
    var cards = [SKSpriteNode]()
    
    var player : Player
    
    init(size: CGSize, player: Player) {
        
        //create the background sprite node
        background =  SKSpriteNode(imageNamed: "green_felt_back")
        
        //set the player object
        self.player = player
        
        //get which black card is in play
        let blackCardIndex = player.game?.getCurrentBlackCard()
        
        //create the sprite node for that black card
        let blackCardNode = Card(type: DeckType.black, number: blackCardIndex!, loader: (player.game?.cardLoader)!)
        
        //add it to the cards list
        cards.append(blackCardNode!)
        
        //add the white cards from the player's hand to the node list
        for card in player.hand.cards {
            let cardNode = Card(type: .white, number: card, loader: (player.game?.cardLoader)!)
            cards.append(cardNode!)
        }
        
        //make the super call when everything else is done
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
        
        let scaled_size : CGFloat = frame.size.height / 6
        
        let origin : CGPoint = frame.origin
        
        let bottom_space : CGFloat = frame.maxY * 0.15
        
        let y_spacing : CGFloat = (frame.maxY * 0.8) / 4
        
        let left_space : CGFloat = frame.maxX * 0.25
        
        let x_spacing : CGFloat = (frame.maxX * 0.9) / 2
        
        for (index, card) in cards.enumerated() {
            
            let yVal : CGFloat = CGFloat(bottom_space + (CGFloat(index % 4) * y_spacing))
            let xVal : CGFloat = (floor(CGFloat((index) / 4)) * x_spacing) + left_space
            
            card.position = CGPoint(x: origin.x + xVal, y: origin.y + yVal)
            card.scale(to: CGSize(width: scaled_size, height: scaled_size))
            
            addChild(card)
        }
    }
    
}

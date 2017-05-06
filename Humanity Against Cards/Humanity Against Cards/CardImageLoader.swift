//
//  CardImageLoader.swift
//  You Got Games
//
//  Created by synthesis on 4/19/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import Foundation

/*
 CardLoader class
    Designed to be a reference class for the hundreds of cards used in the game
    loads the card names for use in SKSpriteNodes rather than loading each
        individual image into memory.
 
    Meant to be passed to each card class and player class to determine card images and number of cards required
 
    variables
        -whiteCards : [String]
            - array of white card image names
        -blackCards : [String]
            - array of black card image names
        -cardsPlayed : [Int]
            - array of integers detailing how many cards must be played on each black card
 
 
    initializer
        -No Parameters
        -fills the two string arrays with the appropriate names
            -In the case that the files can't be found, fills with the first card that type
        -fills the integer array with the integer array with how many cards are required for each black card
            -In the case that the file has an error, fills with 1 card default for the size of the blackCards array
 
    getCardFileName -> String
        - parameters
            - forType : DeckType
                - which type of card is being asked for
            - cardIdx : Int
                - which card of the specified type it is (checked to make sure it is not negative and within the array
        - returns
            - String
                -if the index was valid, the name of the card image file
                -if the index was invalid, the first card of that type is returned
 
    getCardsToPlay -> Int
        - parameters
            - cardIdx : Int
                - which black card to find info for (checked to make sure it is not negative and within the array)
        -returns
            - Int
                - the number of cards to be played on this black card
                - if the index was invalid 1 is returned
 */

class CardLoader {
    
    private var whiteCards : [String]
    private var blackCards : [String]
    private var cardsPlayed: [Int]
    
    init() {
        
        do {
            let path = Bundle.main.path(forResource: "WhiteCardNames", ofType: "txt")
            let contents = try String(contentsOfFile: path!)
            let names = contents.components(separatedBy: NSCharacterSet.newlines)

            whiteCards = names
            
            for (i,_) in whiteCards.enumerated() { //get rid of error cards
                if i == whiteCards.count - 1 {
                    whiteCards.remove(at: i)
                }
            }
            
        } catch let error {
            Swift.print(error)
            Swift.print("Setting to default values")
            whiteCards = ["White_Cards1_01"]
        }
        
        do {
            let path = Bundle.main.path(forResource: "BlackCardNames", ofType: "txt")
            let contents = try String(contentsOfFile: path!)
            let names = contents.components(separatedBy: NSCharacterSet.newlines)
            
            blackCards = names
            
            for (i,_) in blackCards.enumerated() { //get rid of error cards
                if i == blackCards.count - 1 {
                    blackCards.remove(at: i)
                }
            }
            
        } catch let error {
            Swift.print(error)
            Swift.print("Setting to default values")
            blackCards = ["Black_Cards1_01"]
        }

        do {
            let path = Bundle.main.path(forResource: "BlackCardAmount", ofType: "txt")
            let contents = try String(contentsOfFile: path!)
            
            
            let counts = contents.components(separatedBy: NSCharacterSet.newlines)
            
            cardsPlayed = [Int]()
            
            for (index, count) in counts.enumerated() {
                

                
                if index < counts.count - 1 {
                    cardsPlayed.append(Int(count)!)
                }
            }
    
        } catch let error {
            Swift.print(error)
            Swift.print("Setting to default values")
            cardsPlayed = [Int]()
            
            for _ in blackCards {
                cardsPlayed.append(1)
            }
        }
        
    }
    
    func getCardFileName(forType: DeckType, cardIdx: Int) -> String {
        
        switch forType {
        case DeckType.black :
            if cardIdx >= 0 && cardIdx < blackCards.count {
                return blackCards[cardIdx]
            } else {
                return "Black_Cards1_01"
            }
        case DeckType.white :
            if cardIdx > 0 && cardIdx < whiteCards.count {
                return whiteCards[cardIdx]
            } else {
                return "White_Cards1_01"
            }
        }
    }
    
    func getCardsToPlay(cardIdx: Int) -> Int {
        
        if cardIdx >= 0 && cardIdx < cardsPlayed.count {
            return cardsPlayed[cardIdx]
        }
        
        return 1
    }
}

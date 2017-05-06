//
//  URLDecoder.swift
//  You Got Games
//
//  Created by Connor Rawls on 4/30/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import Foundation


class URLDecoder {
    
    var url : URL
    
    var game : Game?
    
    init(url: URL) {
        self.url = url
        
        Swift.print(url)
    }
    
    func decode() {
        
        //get the components from the game url
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if let queryItems = components?.queryItems {
            
            //create all the parts of the game that we will need to read from the file
            var players = [Player]()
            var wDeck : Deck?
            var bDeck : Deck?
            var mode : DecodeMode = DecodeMode.none //init to none to avoid issues with decoding
            var history : GameHistory?
            var usedCards : [UsedCard]?
            var judgeIdx : Int = -1 //default setting to detect an error in the url
            var currentPlayer : Int = -1 //default setting
            var blackCard : Int = -1
            
            //items for keeping track of deck parts
            var deck_string : String = ""
            var deck_type : String = ""
            var deck_discard : String? = nil
            
            //items for keeping track of history parts
            var histUsedCards = [UsedCard]()
            var histBlackCard : Int = 0
            var histPlayers = [UUID]()
            
            //used for keeping track of played cards
            var uCards = [Int]()
            var uCardsPlayer : Int? = nil //just to get around safety warnings for use before initialization
            
            
            for item in queryItems {
                
                if mode.rawValue == 0 { //used for changing which type of object we are decoding info for or general simple info
                    if item.name == "playerStart" {
                        mode = DecodeMode.player
                        let newPlayer = Player()
                        
                        players.append(newPlayer)
                    }
                    else if item.name == "deckBegin" {
                        mode = DecodeMode.deck
                    }
                    else if item.name == "historyBegin" {
                        mode = DecodeMode.history
                    }
                    else if item.name == "usedCardBegin" {
                        mode = DecodeMode.usedcards
                    }
                    else if item.name == "judge_index" {
                        judgeIdx = Int(item.value!)!
                    }
                    else if item.name == "current_player" {
                        currentPlayer = Int(item.value!)!
                    }
                    else if item.name == "black_card" {
                        blackCard = Int(item.value!)!
                    }
                }
                else if mode == DecodeMode.player {
                    
                    switch item.name {
                    case "name" :
                        players[players.count - 1].name = item.value!
                    case "id" :
                        players[players.count - 1].id = Int(item.value!)!
                    case "hand" :
                        let handString = item.value!
                        
                        let cardStrs = handString.components(separatedBy: "-")
                        for card in cardStrs {
                            players[players.count - 1].addCard(card: Int(card)!)
                        }
                    case "wins":
                        players[players.count - 1].handWins = Int(item.value!)!
                    case "type":
                        let newBot = Bot()
                        newBot.name = players[players.count - 1].name
                        newBot.handWins = players[players.count - 1].handWins
                        newBot.hand = players[players.count - 1].hand
                        newBot.id = players[players.count - 1].id
                        
                        players.remove(at: players.count - 1)
                        players.append(newBot)
                        
                    case "playerEnd":
                        mode = DecodeMode.none
                    default:
                        break
                    }
                }
                else if mode == DecodeMode.deck {
                    
                    switch item.name {
                    case "deck_type":
                        deck_type = item.value!
                    case "deck":
                        deck_string = item.value!
                    case "discard":
                        deck_discard = item.value
                    case "deckEnd":
                        let dType : DeckType = DeckType(rawValue: deck_type)!
                        let dCards_str = deck_string.components(separatedBy: "-")
                        
                        var dCards_int = [Int]()
                        
                        for str in dCards_str {
                            dCards_int.append(Int(str)!)
                        }
                        
                        switch dType {
                        case .black:
                            bDeck = Deck(type: dType, cards: dCards_int, dCards: nil)
                        case .white:
                            if let discard = deck_discard {
                                if discard != "-1" {
                                    
                                    let discard_Strs = discard.components(separatedBy: "-")
                                    
                                    var discard_int = [Int]()
                                    
                                    for str in discard_Strs {
                                        discard_int.append(Int(str)!)
                                    }
                                    
                                    wDeck = Deck(type: dType, cards: dCards_int, dCards: discard_int)
                                    break
                                }
                            }
                            
                            wDeck = Deck(type: dType, cards: dCards_int, dCards: nil)
                        }
                        
                        mode = DecodeMode.none
                        
                    default:
                        break
                    }
                }
                else if mode == DecodeMode.history {
                    switch item.name {
                    case "players": //get the player uuid strings
                        let player_str = item.value! //get the whole string
                        
                        let player_ids = player_str.components(separatedBy: "+") //get an array of component strings
                        
                        for id in player_ids { //loop through array and add them to the players array
                            histPlayers.append(UUID(uuidString: id)!)
                        }
                    case "blackCard": //get which black is included in the history object
                        
                        if let cardStr = item.value { //just a safety check on the optional value
                            histBlackCard = Int(cardStr)!
                        }
                    case "usedCardBegin": //beginning of what has been played by other players
                        mode = DecodeMode.history_usedcards
                    case "historyEnd" : //found the end of data for the history object
                        
                        history = GameHistory(players: histPlayers, bCard: histBlackCard, cards: histUsedCards) //create the history object
                        
                        mode = DecodeMode.none
                    default: //just here because it has to be
                        break
                    }
                }
                else if mode == DecodeMode.history_usedcards {
                    switch item.name{
                    case "play":
                        
                        if let playStr = item.value {
                            let playStrs = playStr.components(separatedBy: "-")
                            
                            for play in playStrs {
                                uCards.append(Int(play)!)
                            }
                            
                        }
                    case "card_player":
                        
                        if let playerStr = item.value {
                            uCardsPlayer = Int(playerStr)!
                        }
                    case "usedCardEnd":
                        
                        if uCards.count > 0 && uCardsPlayer != nil {
                            histUsedCards.append(UsedCard(cardNum: uCards, player: uCardsPlayer!))
                        }
                        
                        mode = DecodeMode.history
                        
                    default:
                        break
                    }
                }
                else if mode == DecodeMode.usedcards {
                    switch item.name{
                    case "play":
                        
                        if let playStr = item.value {
                            let playStrs = playStr.components(separatedBy: "-")
                            
                            for play in playStrs {
                                uCards.append(Int(play)!)
                            }
                            
                        }
                    case "card_player":
                        
                        if let playerStr = item.value {
                            uCardsPlayer = Int(playerStr)!
                        }
                    case "usedCardEnd":
                        
                        if uCards.count > 0 && uCardsPlayer != nil {
                            if let _ = usedCards {
                                usedCards?.append(UsedCard(cardNum: uCards, player: uCardsPlayer!))
                            }
                            else {
                                usedCards = [UsedCard(cardNum: uCards, player: uCardsPlayer!)]
                            }

                        }
                        
                        mode = DecodeMode.none
                    default:
                        break
                    }
                }
            }
            
            //create the new game if all of the parts are valid (except for the optionals)
            if let whiteDeck = wDeck, let blackDeck = bDeck {
                if players.count > 0 && currentPlayer != -1 && judgeIdx != -1 {
                    
                    game = Game(players: players, wCards: whiteDeck, bCards: blackDeck, uCards: usedCards, cPlayer: currentPlayer, jPlayer: judgeIdx, currentGoal: blackCard, history: history)
                    
                    for player in (game?.getPlayers())! {
                        player.game = game
                    }
                }
                else {
                    Swift.print("There were no players, or no current player, or no current judge")
                }
            }
            else {
                Swift.print("A Deck was incomplete")
            }
        }
    }
    
    
    //ALWAYS CALL BEFORE getGame() !
    func hasGame() -> Bool {
        if game != nil {
            return true
        }
        
        return false
    }
    
    func getGame() -> Game? {
        
        //only temporary
        return game
    }
}

//enum for decoding complex object from the url
enum DecodeMode : Int {
    case none = 0
    case player = 1
    case deck = 2
    case usedcards = 3
    case history = 4
    case history_usedcards = 5 //special case for used cards contained by the history object
}
